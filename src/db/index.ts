import { drizzle } from "drizzle-orm/node-postgres";

const connectionString = Bun.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is not set in environment variables");
}

export const db = drizzle(connectionString);
