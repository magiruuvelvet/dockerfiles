#!/bin/sh

set -eo pipefail
# set -x

socat TCP4-LISTEN:3306,fork UNIX-CONNECT:/run/mysqld/mysqld.sock &

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
  set -- mysqld_safe "$@"
fi

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  var=$1
  file_var="${var}_FILE"
  var_value=$(printenv $var || true)
  file_var_value=$(printenv $file_var || true)
  default_value=$2

  if [ -n "$var_value" -a -n "$file_var_value" ]; then
    echo >&2 "error: both $var and $file_var are set (but are exclusive)"
    exit 1
  fi

  if [ -z "${var_value}" ]; then
    if [ -z "${file_var_value}" ]; then
      export "${var}"="${default_value}"
    else
      export "${var}"="${file_var_value}"
    fi
  fi

  unset "$file_var"
}

# Fetch value from server config
# We use mysqld --verbose --help instead of my_print_defaults because the
# latter only show values present in config files, and not server defaults
_get_config() {
  conf="$1"
  mysqld --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null | awk '$1 == "'"$conf"'" { print $2; exit }'
}

DATA_DIR="$(_get_config 'datadir')"

# Initialize database if necessary
if [ ! -d "$DATA_DIR/mysql" ]; then
  file_env 'MARIADB_ROOT_PASSWORD'
  if [ -z "$MARIADB_ROOT_PASSWORD" -a -z "$MARIADB_ALLOW_EMPTY_PASSWORD" -a -z "$MARIADB_RANDOM_ROOT_PASSWORD" ]; then
    echo >&2 'error: database is uninitialized and password option is not specified '
    echo >&2 '  You need to specify one of MARIADB_ROOT_PASSWORD, MARIADB_ALLOW_EMPTY_PASSWORD and MARIADB_RANDOM_ROOT_PASSWORD'
    exit 1
  fi

  mkdir -p "$DATA_DIR"
  chown mysql: "$DATA_DIR"

  echo 'Initializing database'
  mysql_install_db --user=mysql --datadir="$DATA_DIR" --rpm
  chown -R mysql: "$DATA_DIR"
  echo 'Database initialized'

  # Start mysqld to config it
  mysqld_safe --skip-networking --nowatch

  mysql_options='--protocol=socket -uroot'

  # Execute mysql statement
  # statement can be passed directly or by HEREDOC
  execute() {
    statement="$1"
    if [ -n "$statement" ]; then
      mysql -ss $mysql_options -e "$statement"
    else
      cat /dev/stdin | mysql -ss $mysql_options
   fi
  }

  for i in `seq 30 -1 0`; do
    if execute 'SELECT 1' &> /dev/null; then
      break
    fi
    echo 'MySQL init process in progress...'
    sleep 1
  done
  if [ "$i" = 0 ]; then
    echo >&2 'MySQL init process failed.'
    exit 1
  fi

  if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
    # sed is for https://bugs.mysql.com/bug.php?id=20545
    mysql_tzinfo_to_sql /usr/share/zoneinfo | \
      sed 's/Local time zone must be set--see zic manual page/FCTY/' | \
      mysql $mysql_options mysql
  fi

  if [ -n "$MARIADB_RANDOM_ROOT_PASSWORD" ]; then
    export MARIADB_ROOT_PASSWORD="$(tr -dc _A-Z-a-z-0-9 < /dev/urandom | head -c10)"
    echo "GENERATED ROOT PASSWORD: $MARIADB_ROOT_PASSWORD"
  fi

  # Create root user, set root password, drop useless table
  # Delete root user except for
  execute <<SQL
    -- What's done in this file shouldn't be replicated
    --  or products like mysql-fabric won't work
    SET @@SESSION.SQL_LOG_BIN=0;

    DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost') ;
    SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MARIADB_ROOT_PASSWORD}') ;
    GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
    DROP DATABASE IF EXISTS test ;
    FLUSH PRIVILEGES ;
SQL

  # https://mariadb.com/kb/en/library/mariadb-environment-variables/
  export MYSQL_PWD="$MARIADB_ROOT_PASSWORD"

  # Create root user for $MARIADB_ROOT_HOST
  file_env 'MARIADB_ROOT_HOST' '%'
  if [ "$MARIADB_ROOT_HOST" != 'localhost' ]; then
    execute <<SQL
      CREATE USER 'root'@'${MARIADB_ROOT_HOST}' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' ;
      GRANT ALL ON *.* TO 'root'@'${MARIADB_ROOT_HOST}' WITH GRANT OPTION ;
      FLUSH PRIVILEGES ;
SQL
  fi

  file_env 'MARIADB_DATABASE'
  if [ "$MARIADB_DATABASE" ]; then
    execute "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\` ;"
  fi

  file_env 'MARIADB_USER'
  file_env 'MARIADB_PASSWORD'
  if [ "$MARIADB_USER" -a "$MARIADB_PASSWORD" ]; then
    execute "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD' ;"

    if [ "$MARIADB_DATABASE" ]; then
      execute "GRANT ALL ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%' ;"
    fi

    execute 'FLUSH PRIVILEGES ;'
  fi

  # Database cannot be specified when creating user,
  # otherwise it will fail with "Unknown database"
  if [ "$MARIADB_DATABASE" ]; then
    mysql_options="$mysql_options \"$MARIADB_DATABASE\""
  fi

  echo
  for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
      *.sh)     echo "$0: running $f"; . "$f" ;;
      *.sql)    echo "$0: running $f"; execute < "$f"; echo ;;
      *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | execute; echo ;;
      *)        echo "$0: ignoring $f" ;;
    esac
    echo
  done

  if ! mysqladmin -uroot --password="$MYSQL_PWD" shutdown; then
    echo >&2 'Shutdown failed'
    exit 1
  fi

  echo
  echo 'MySQL init process done. Ready for start up.'
  echo
fi

chown -R mysql: "$DATA_DIR"
exec "$@"
