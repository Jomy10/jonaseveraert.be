import { db, Image } from 'astro:db';

let id = 0;

// Data for development
export default async function seed() {
  await db.insert(Image).values([
    {Id: id++, FileName: "Groepsfoto elfde.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "IMG_9214.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "Trammelant_01_01-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "Trammelant_04_01.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "Trammelant_04_05.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "_MG_5836.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "_MG_7243.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "_MG_7254.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "_MG_8118-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "_groepsfoto_panorama.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_03-bewerkt-2.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_1-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_11-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_13-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_18-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_1_06-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_1_13-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_2-positive.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_26-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "frame_34-bewerkt.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "img_1-positive.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "img_28-positive.webp", CreatedDate: new Date() },
    {Id: id++, FileName: "img_8-positive-2.webp", CreatedDate: new Date() },
  ]);
};
