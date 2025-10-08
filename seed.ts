// Seed the database

import { db } from "@db/index";
import { User, Image } from "@db/schema";

async function main() {
  const user: typeof User.$inferInsert = {
    UserName: "jomy",
    PassWord: "a"
  };

  await db.insert(User).values(user);

  const images: (typeof Image.$inferInsert)[] = [
    {FileName: "Groepsfoto elfde.webp"},
    {FileName: "IMG_9214.webp"},
    {FileName: "Trammelant_01_01-bewerkt.webp"},
    {FileName: "Trammelant_04_01.webp"},
    {FileName: "Trammelant_04_05.webp"},
    {FileName: "_MG_5836.webp"},
    {FileName: "_MG_7243.webp"},
    {FileName: "_MG_7254.webp"},
    {FileName: "_MG_8118-bewerkt.webp"},
    {FileName: "_groepsfoto_panorama.webp"},
    {FileName: "frame_03-bewerkt-2.webp"},
    {FileName: "frame_1-bewerkt.webp"},
    {FileName: "frame_11-bewerkt.webp"},
    {FileName: "frame_13-bewerkt.webp"},
    {FileName: "frame_18-bewerkt.webp"},
    {FileName: "frame_1_06-bewerkt.webp"},
    {FileName: "frame_1_13-bewerkt.webp"},
    {FileName: "frame_2-positive.webp"},
    {FileName: "frame_26-bewerkt.webp"},
    {FileName: "frame_34-bewerkt.webp"},
    {FileName: "img_1-positive.webp"},
    {FileName: "img_28-positive.webp"},
    {FileName: "img_8-positive-2.webp"},
  ];

  await db.insert(Image).values(images);
}

await main();
