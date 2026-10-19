import {
    pgTable,
    serial, text, date, integer,
    index
} from "node_modules/drizzle-orm/pg-core";

export const Image = pgTable("Image", {
    Id: serial().primaryKey().notNull(),
    FileName: text().notNull().unique(),
    OriginalFileName: text().notNull(),
    GalleryOrder: integer().generatedByDefaultAsIdentity().notNull().unique(),
    CreatedDate: date().defaultNow().notNull(),
}, (table) => [
    index("Image_date_index").on(table.CreatedDate),
]);

export type ImageSchema = {
    Id: number,
    FileName: string,
    OriginalFileName: string,
    GalleryOrder: number,
    CreatedDate: number
};
