// Seed the database

import { db } from "@db/index";
import { Image } from "@db/schema";
import { Glob, randomUUIDv7 } from "bun";
import path from "node:path";

async function main() {
    const glob = new Glob("data/img/gallery/*");
    const files = await Array.fromAsync(glob.scan("."));

    const images: (typeof Image.$inferInsert)[] = files.map((f) => {
        const fname = path.basename(f);
        return {
            OriginalFileName: fname,
            FileName: fname,
        };
    });

    await db.insert(Image).values(images);
}

await main();
