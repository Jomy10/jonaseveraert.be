import type { APIRoute } from "astro";
import { eq } from "drizzle-orm";
import { db } from "@db/index";
import { Image } from "@db/schema";
import fs from "fs";

export const DELETE: APIRoute = async ({ params, request }) => {
  const body = JSON.parse(new TextDecoder().decode((await request.body?.getReader().read())?.value));
  console.log(body);
  const id = parseInt(body.id);


  const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";
  if (import.meta.env.PROD) {
    const fileNameResult = await db.select()
      .from(Image)
      .where(eq(Image.Id, id));

    if (fileNameResult.length != 1) {
      return new Response(null, { status: 304, statusText: "There exists no image with the specified id in the database" });
    }

    const fileName = fileNameResult[0].FileName;
    const filePath = imgFolder + "/original/" + fileName;
    const galleryFilePath = imgFolder + "/gallery/" + fileName;

    fs.unlink(filePath, (err) => {
      if (err) console.log(filePath, "| ERROR |", err);
      else console.log(filePath, "was deleted");
    });

    fs.unlink(galleryFilePath, (err) => {
      if (err) console.log(galleryFilePath, "| ERROR |", err);
      else console.log(galleryFilePath, "was deleted");
    });
  }

  const result = await db.delete(Image)
    .where(eq(Image.Id, id));

  console.log(result);

  if (result.rowsAffected != 1)
    return new Response(null, { status: 304, statusText: "There exists no image with the specified id in the database" });
  else
    return new Response(null, { status: 200 });
};
