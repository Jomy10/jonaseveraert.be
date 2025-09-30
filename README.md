## Updating the database

```
ASTRO_DB_REMOTE_URL="..." bun astro db push
ASTRO_DB_REMOTE_URL="..." bun astro db verify
```

where `ASTRO_DB_REMOTE_URL` is a url to the databse. (e.g. for local development:
"file:./db/database.db")

## Authentication

See User table.
hash password using bcrypt

<!--**Environment variables**
- `JONASEVERAERT_BE_ENCRYPTION_KEY`

**Notes**
<!--- relies on the `X-Forwarded-For` header for getting the client's IP address.-->-->

## Other config

**Environment variables**
- `JONASEVERAERT_BE_IMAGE_FOLDER`
