import {
  pgTable,
  serial, text, date,
  index
} from "node_modules/drizzle-orm/pg-core";

export const Image = pgTable("Image", {
  Id: serial().primaryKey().notNull(),
  FileName: text().notNull().unique(),
  CreatedDate: date().defaultNow().notNull(),
}, (table) => [
  index("Image_date_index").on(table.CreatedDate),
]);

export const User = pgTable("User", {
  UserName: text().primaryKey().notNull(),
  PassWord: text().notNull(),
  CreatedDate: date().defaultNow().notNull(),
});
