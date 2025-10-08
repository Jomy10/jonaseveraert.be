import { Client } from "pg";

const connectionString = import.meta.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is not set in environment variables");
}

const client = new Client({
  connectionString: connectionString,
  ssl: { rejectUnauthorized: true }
});

await client.connect();

export { client };
