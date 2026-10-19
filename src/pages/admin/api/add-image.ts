import type { APIRoute } from "astro";
import { db } from "@db/index";
import { Image } from "@db/schema";
import sharp from "sharp";
import { StatusCodes } from "http-status-codes";
import { randomUUIDv7 } from "bun";

export const prerender = false;

export const POST: APIRoute = async ({ request }) => {
    try {
        return await handleRequest(request);
    } catch (e: any) {
        console.error(e);
        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR, statusText: "Internal server error" });
    }
}

async function handleRequest(request: Request): Promise<Response> {
    console.debug(request);

    const imgFolder = import.meta.env["JONASEVERAERT_BE_IMAGE_FOLDER"] ?? "./data/img";
    const imageData = await request.blob();
    let originalFilename = request.headers.get("file-name");
    if (originalFilename == null)
        return new Response(undefined, { status: StatusCodes.BAD_REQUEST, statusText: "`file-name` header was not provided" })
    originalFilename = decodeURIComponent(originalFilename);

    const filename = `${randomUUIDv7()}_${originalFilename}`;

    const filePath = `${imgFolder}/original/${filename}`;
    const galleryFilePath = `${imgFolder}/gallery/${filename}`;

    console.debug("Saving to files", filePath, galleryFilePath);

    console.log(`Writing original file to ${filePath}...`);
    const imageDataBuffer = await imageData.arrayBuffer();
    await Bun.write(filePath, imageDataBuffer);

    try {
        console.log("Transforming file...")
        const buffer = Buffer.from(imageDataBuffer);
        console.debug("Sharp versions:", sharp.versions);

        const metadata = await sharp(buffer).metadata();
        console.log("Metadata:", metadata);

        const sharpBuffer = await sharp(buffer)
            .resize(400)
            .webp({ quality: 40 })
            .toBuffer();

        console.log(`Writing transformed file to ${galleryFilePath}...`);
        await Bun.write(galleryFilePath, sharpBuffer);
    } catch (e: any) {
        console.error(e);
        const ogFile = Bun.file(filePath);
        ogFile.delete();

        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR, statusText: "Something unexpected happened while transforming the iamge, consult the server logs" });
    }

    console.debug("Adding image entry...");
    const res = await db.insert(Image).values({
        OriginalFileName: originalFilename,
        FileName: filename
    });

    console.debug(res);

    if (res.rowCount != 1) {
        console.error("No rows inserted");
        return new Response(undefined, { status: StatusCodes.INTERNAL_SERVER_ERROR, statusText: "This case should never happen" });
    }

    return new Response(res.FileName, { status: StatusCodes.OK });
}
