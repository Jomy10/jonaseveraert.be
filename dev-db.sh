# Create a database for debugging environment

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-website_dev}"

JS="${JSRUNTIME:-bun}"

export DATABASE_URL="postgresql://$DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"

create_db() {
  echo "Creating database $DB_NAME at $DB_HOST:$DB_PORT with user $DB_USER..."

  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE \"$DB_NAME\""

  if [ $? -eq 0 ]; then
    echo "✅  Database '$DB_NAME' created successfully."
  else
    echo "⚠️  Could not create database. It may already exist or connection failed. Trying to connect to it now..."

    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB°NAME" -c '\q'

    if [ $? -eq 0 ]; then
        echo "ℹ️  Database '$DB_NAME' already exists and is connectable."
    else
        echo "🛑  Failed to create database and could not connect to it. Check credentials and server status."
        exit 1
    fi
  fi

  echo "Creating tables..."

  $JS drizzle-kit push

  echo "Seeding database..."

  $JS ./seed.ts
}

delete_db() {
  echo "Deleting database $DB_NAME on $DB_HOST:$DB_PORT..."

  echo "Terminating existing connections to $DB_NAME..."
  # Force close all existing connections to the target database before dropping it.
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$DB_NAME' AND pid <> pg_backend_pid();"

  echo "Dropping database '$DB_NAME'..."
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE \"$DB_NAME\""

  if [ $? -eq 0 ]; then
    echo "🗑️  Database '$DB_NAME' successfully deleted."
  else
    echo "🛑  Failed to delete database '$DB_NAME'. It may not exist or an error occurred."
    exit 1
  fi
}

case "$1" in
  create)
    create_db
    ;;
  delete)
    delete_db
    ;;
  *)
    echo "Usage: $0 {create|delete}"
    exit 1
    ;;
esac
