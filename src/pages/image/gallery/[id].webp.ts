import type { APIRoute } from "astro";
import { db, Image, desc } from "astro:db";
import fs from "node:fs";

export const prerender = false;

// returns image data, depending on its position (based on id param) in the
// database, ordered by creation date
export const GET: APIRoute = async ({ params, request }) => {
  const id = parseInt(params.id!);
  const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

  const result = await db.select().from(Image)
    .orderBy(desc(Image.CreatedDate))
    .offset(id)
    .limit(1);

  if (result.length == 0)
    return new Response(undefined);

  const imgFileName = result[0].FileName;
  const imgPath = `${imgFolder}/gallery/${imgFileName}`;

  return new Response(
    fs.readFileSync(imgPath).buffer,
    {
      headers: {
        "original-file-name": imgFileName,
      }
    }
  );
};
