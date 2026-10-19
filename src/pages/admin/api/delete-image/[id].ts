import { db } from "@db/index";
import { Image } from "@db/schema";
import type { APIRoute } from "astro";
import { eq, gt, sql } from "drizzle-orm";
import { StatusCodes } from "http-status-codes";

export const prerender = false;

export const DELETE: APIRoute = async ({ params }) => {
    try {
        return await handleRequest(params);
    } catch (e: any) {
        console.error(e);
        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR });
    }
};

async function handleRequest(params: Record<string, string | undefined>): Promise<Response> {
    if (params.id == null)
        return new Response(undefined, { status: StatusCodes.BAD_REQUEST });

    const id = parseInt(params.id);

    const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

    const fileNameResult = await db.select()
        .from(Image)
        .where(eq(Image.Id, id));

    if (fileNameResult.length != 1)
        return new Response(undefined, { status: StatusCodes.NO_CONTENT, statusText: `No image with id ${id} exists` });

    const fileName = fileNameResult[0].FileName;
    const filePath = `${imgFolder}/original/${fileName}`;
    const galleryFilePath = `${imgFolder}/gallery/${fileName}`;

    if (import.meta.env.PROD) {
        const file = Bun.file(filePath);
        await file.delete();

        const galleryFile = Bun.file(galleryFilePath);
        await file.delete();
    } else {
        console.log(`Would remove ${filePath}`);
        console.log(`Would remove ${galleryFilePath}`);
    }

    const result = await db.delete(Image)
        .where(eq(Image.Id, id))
        .returning({ GalleryOrder: Image.GalleryOrder });

    if (result.length != 1)
        return new Response(undefined, { status: StatusCodes.NOT_MODIFIED, statusText: "There exists no image with specified id in the database" }); // should never occur unless modification happens during this api call

    // Move GalleryOrder of photos that come after it (before it in the gallery)
    const deletedOrder = result[0].GalleryOrder;
    const moveResult = await db.update(Image)
        .set({ GalleryOrder: sql`${Image.GalleryOrder} - 1` })
        .where(sql`${Image.GalleryOrder} > ${deletedOrder}`);

    return new Response(JSON.stringify(fileNameResult[0]), { status: StatusCodes.OK });
}
