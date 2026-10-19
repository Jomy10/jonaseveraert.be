import { db } from "@db/index";
import { Image } from "@db/schema";
import type { APIRoute } from "astro";
import { eq } from "drizzle-orm";
import { StatusCodes } from "http-status-codes";

export const prerender = false;

export const GET: APIRoute = async ({ params }) => {
    try {
        return await handleRequest(params);
    } catch (e: any) {
        console.error(e);
        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR });
    }
};

async function handleRequest(params: Record<string, string | undefined>): Promise<Response> {
    const id = parseInt(params.id!);
    const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";

    const result = await db.select({
        FileName: Image.FileName,
        OriginalFileName: Image.OriginalFileName
    })
        .from(Image)
        .where(eq(Image.Id, id));

    if (result.length == 0)
        return new Response(undefined, { status: StatusCodes.NOT_FOUND });

    const imgFileName = result[0].FileName;
    const imgPath = `${imgFolder}/gallery/${imgFileName}`;
    const file = Bun.file(imgPath);

    return new Response(
        await file.bytes(),
        {
            headers: {
                "Content-Type": file.type,
                "original-file-name": result[0].OriginalFileName
            }
        }
    )
}
