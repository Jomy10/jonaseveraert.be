import type { APIRoute } from "astro";
import { db, eq, desc, Image } from "astro:db";

export const POST: APIRoute = async ({ request }) => {
  console.log(request);

  const bodyString = new TextDecoder().decode((await request.body?.getReader().read())?.value);
  console.log(bodyString);
  const body = JSON.parse(bodyString);

  console.log("request query", body);

  // Any text field (filename)
  const searchText: string | undefined = body.textFields;

  // The sequence id of the image, sorted by created date
  const sequenceId: number | undefined = body.sequenceId;

  let query = db.select().from(Image)

  if (searchText != undefined)
    // @ts-ignore
    query = query.where(eq(Image.FileName, searchText));

  if (sequenceId != undefined)
    // @ts-ignore
    query = query
      .orderBy(desc(Image.CreatedDate))
      .offset(sequenceId)
      .limit(1);

  const images = await query;

  return new Response(JSON.stringify({ images: images }), { status: 200 });
};
