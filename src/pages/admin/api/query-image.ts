import type { APIRoute } from "astro";
import { eq, gt, lt, gte, lte, inArray } from "drizzle-orm";
import { db } from "@db/index";
import { Image } from "@db/schema";

export const POST: APIRoute = async ({ request }) => {
  const bodyString = new TextDecoder().decode((await request.body?.getReader().read())?.value);
  const body = JSON.parse(bodyString);

  let query: any = db.select().from(Image);

  if (body.fileNames != undefined) {
    if (typeof body.fileNames === "string") {
      query = query.where(eq(Image.FileName, body.fileNames));
    } else {
      query = query.where(inArray(Image.FileName, body.fileNames));
    }
  }

  if (body.ids != undefined) {
    if (typeof body.ids === "string") {
      query = query.where(eq(Image.Id, body.ids));
    } else {
      query = query.where(inArray(Image.Id, body.ids));
    }
  }

  if (body.createdAfter != undefined) {
    query = query.where(gt(Image.CreatedDate, body.createdAfter));
  }

  if (body.createdBefore != undefined) {
    query = query.where(lt(Image.CreatedDate, body.createdBefore))
  }

  if (body.createdAfterOrEqual != undefined) {
    query = query.where(gte(Image.CreatedDate, body.createdAfter));
  }

  if (body.createdBeforeOrEqual != undefined) {
    query = query.where(lte(Image.CreatedDate, body.createdBefore))
  }

  const images = await query;

  return new Response(JSON.stringify({ images: images }), { status: 200 });
};

// export const POST: APIRoute = async ({ request }) => {
//   console.log(request);

//   const bodyString = new TextDecoder().decode((await request.body?.getReader().read())?.value);
//   console.log(bodyString);
//   const body = JSON.parse(bodyString);

//   console.log("request query", body);

//   // Any text field (filename)
//   const searchText: string | undefined = body.textFields;

//   // The sequence id of the image, sorted by created date
//   const sequenceId: number | undefined = body.sequenceId;

//   let query: any = db.select().from(Image)

//   if (searchText != undefined)
//     query = query.where(eq(Image.FileName, searchText));

//   if (sequenceId != undefined)
//     query = query
//       .orderBy(desc(Image.CreatedDate))
//       .offset(sequenceId)
//       .limit(1);

//   const images = await query;

//   return new Response(JSON.stringify({ images: images }), { status: 200 });
// };
