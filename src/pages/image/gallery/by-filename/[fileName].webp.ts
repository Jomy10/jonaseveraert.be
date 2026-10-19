import { db } from "@db/index";
import { Image } from "@db/schema";
import type { APIRoute } from "astro";
import { sql } from "drizzle-orm";
import { StatusCodes } from "http-status-codes";

export const prerender = false;

// Get the gallery image data for an image by filename
export const GET: APIRoute = async ({ params }) => {
    const fileName = params.fileName;
    const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

    if (fileName == null || fileName.includes("..") || fileName.includes("/") || fileName.includes("\\"))
        return new Response(undefined, { status: 400 });

    const result = await db.select({ FileName: Image.FileName })
        .from(Image)
        .where(sql`${Image.FileName} = ${fileName}`);

    if (result.length == 0)
        return new Response(undefined, { status: StatusCodes.NOT_FOUND });

    const imgPath = `${imgFolder}/gallery/${result[0].FileName}`;
    const file = Bun.file(imgPath);

    return new Response(
        await file.bytes(),
        {
            headers: {
                "Content-Type": file.type,
                "original-file-name": fileName
            }
        }
    )
};
