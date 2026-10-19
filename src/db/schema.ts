import {
    pgTable,
    serial, text, date, integer,
    uniqueIndex
} from "node_modules/drizzle-orm/pg-core";

export const Image = pgTable("Image", {
    Id: serial().primaryKey().notNull(),
    FileName: text().notNull().unique(),
    OriginalFileName: text().notNull(),
    GalleryOrder: integer().generatedByDefaultAsIdentity().notNull().unique(),
    CreatedDate: date().defaultNow().notNull(),
}, (table) => [
    uniqueIndex("Image_order_index").on(table.GalleryOrder.desc()),
]);

export type ImageSchema = {
    Id: number,
    FileName: string,
    OriginalFileName: string,
    GalleryOrder: number,
    CreatedDate: number
};
