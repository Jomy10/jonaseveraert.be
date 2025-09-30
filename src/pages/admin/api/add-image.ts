import type { APIRoute } from "astro";
import { db, eq, Image } from "astro:db";
import fs from "node:fs";
import sharp from "sharp";

export const POST: APIRoute = async ({ request }) => {
  console.log(request);

  const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

  const imageData = await request.blob();
  const fileName = request.headers.get("file-name");
  if (fileName == null)
    return new Response(null, { status: 400, statusText: "`file-name` header was not provided" });

  const filePath = imgFolder + "/original/" + fileName;
  const galleryFilePath = imgFolder + "/gallery/" + fileName;

  console.log(filePath, galleryFilePath);

  // if (fs.existsSync(filePath))
  const existsResult = await db.select().from(Image)
    .where(eq(Image.FileName, fileName));

  if (existsResult.length > 0)
    return new Response(null, { status: 400, statusText: "A file with filename " + fileName + " already exists" });

  // Write original file
  console.log("Writing original file...");
  const imageDataBuffer = await imageData.arrayBuffer()
  const ogFileWriteResult = new Promise((resolve, reject) => fs.writeFile(filePath, Buffer.from(imageDataBuffer), err => {
    if (err) {
      console.error(err);
      reject(err);
    } else {
      console.log("Original file written");
      resolve(null);
    }
  }));

  // Write webp file
  try {
    console.log("Transforming file...");
    const sharpBuffer = await sharp(imageDataBuffer)
      .resize(400)
      .webp({ quality: 40 })
      .toBuffer();

    fs.writeFileSync(galleryFilePath, sharpBuffer);
    console.log("File transformed");
  } catch (e: any) {
    console.error(e);
    await ogFileWriteResult;
    fs.unlinkSync(filePath);

    console.error(e);

    return new Response(null, { status: 500, statusText: "Something unexpected happened, consult the server logs" });
  }

  await ogFileWriteResult;

  // Add entry to db when success
  console.log("Adding image entry...");
  const res = await db.insert(Image).values({
    FileName: fileName,
  });

  console.log("Finished");

  return new Response(JSON.stringify({ rowid: res.lastInsertRowid!.toString() }), { status: 200 });
};
