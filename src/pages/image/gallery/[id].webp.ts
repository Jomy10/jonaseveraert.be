import type { APIRoute } from "astro";
import { sql } from "drizzle-orm";
import { db } from "@db/index";
import { Image } from "@db/schema";
import { StatusCodes } from "http-status-codes";

export const prerender = false;

// returns image data, depending on its position (based on id param) in the
// database, ordered by GalleryOrder
export const GET: APIRoute = async ({ params }) => {
    try {
        return await handleRequest(params);
    } catch (e: any) {
        console.error(e);
        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR });
    }
};

async function handleRequest(params: Record<string, string | undefined>): Promise<Response> {
    const galleryId = parseInt(params.id!);
    const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

    const result = await db.execute(sql`
        select ${Image.FileName}, ${Image.OriginalFileName}
        from ${Image}
        where ${Image.GalleryOrder} = (select max(${Image.GalleryOrder}) from ${Image}) - ${galleryId};
    `);

    if (result.rowCount == 0)
        return new Response(undefined, { status: StatusCodes.NOT_FOUND });

    const row = result.rows[0];

    const imgFileName = row.FileName;
    const imgPath = `${imgFolder}/gallery/${imgFileName}`;
    const file = Bun.file(imgPath);

    return new Response(
        await file.bytes(),
        {
            headers: {
                "Content-Type": file.type,
                "original-file-name": row.OriginalFileName
            }
        }
    );
}
