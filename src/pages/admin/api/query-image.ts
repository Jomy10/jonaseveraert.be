import type { APIRoute } from "astro";
import { union } from 'drizzle-orm/pg-core'
import { eq, gt, lt, and, desc, type SQL, count } from "drizzle-orm";
import { db } from "@db/index";
import { Image } from "@db/schema";
import { StatusCodes } from "http-status-codes";
import { queryResponse } from "@lib/api/utils";

export const prerender = false;

interface Request {
    queries?: ImageQuery[],
    query?: ImageQuery,
    // Overwrites query parameters
    page?: number,
    // Overwrites query parameters
    page_size?: number
    with_count?: boolean
};

interface ImageQuery {
    id?: number,
    file_name?: string,
    created?:
        { on: string } |
        { after: string } |
        { before: string }
};

function createImageQuery(query: ImageQuery, get_count: boolean = false) {
    let where_clause: SQL[] = [];
    if (query.id != null) {
        where_clause.push(eq(Image.Id, query.id));
    }

    if (query.file_name != null) {
        where_clause.push(eq(Image.FileName, query.file_name));
    }

    if (query.created != null) {
        if ('on' in query.created) {
            // @ts-ignore
            where_clause.push(eq(Image.CreatedDate, new Date(query.created.on)));
        } else if ('after' in query.created) {
            // @ts-ignore
            where_clause.push(gt(Image.CreatedDate, new Date(query.created.after)));
        } else if ('before' in query.created) {
            // @ts-ignore
            where_clause.push(lt(Image.CreatedDate, new Date(query.created.before)));
        }
    }

    let q;
    if (get_count) {
        q = db.select({ count: count() }).from(Image)
    } else {
        q = db.select().from(Image);
    }
    return q.where(where_clause.length > 0 ? and(...where_clause) : undefined);
}

export const POST: APIRoute = async ({ request, url }) => {
    try {
        return await handleRequest(request, url);
    } catch (e: any) {
        return new Response(undefined, {
            status: StatusCodes.INTERNAL_SERVER_ERROR,
            statusText: (e.message ?? "Internal server error")
                .replace(/[\x00-\x08\x0A-\x1F\x7F-\uFFFF]/g, " ")
                .slice(0, 512)
        });
    }
};

async function handleRequest(request: globalThis.Request, url: URL): Promise<Response> {
    const bodyString: string = await request.text();
    const body: Request = bodyString.trim().length > 0 ? JSON.parse(bodyString) : {};

    const page_size = body.page_size || parseInt(url.searchParams.get("page_size") as string) || 50;
    const page = body.page || parseInt(url.searchParams.get("page") as string) || 0;
    const with_count = body.with_count || false;

    // Single query
    if ('query' in body) {
        const query = createImageQuery(body.query!);
        let qcount = 0;
        if (with_count) {
            qcount = (await db.select({ count: count() }).from(query.as("t")))[0].count;
        }
        const result = await query
            .orderBy(desc(Image.GalleryOrder))
            .limit(page_size + 1)
            .offset(page * page_size);
        return queryResponse(
            result,
            page_size, page,
            url,
            "images",
            with_count ? { count: qcount } : null
        );
    }

    // No query
    if (!('queries' in body) || body.queries == null || body.queries.length == 0) {
        let qcount = 0;
        if (with_count)
            qcount = (await db.select({ count: count() }).from(Image))[0].count;
        const result = await db.select().from(Image)
            .orderBy(desc(Image.GalleryOrder))
            .limit(page_size + 1)
            .offset(page * page_size);
        return queryResponse(
            result,
            page_size, page,
            url,
            "images",
            with_count ? { count: qcount } : null
        )
    }

    // Multiple queries
    let queries: ReturnType<typeof createImageQuery>[] = [];
    for (let query of body.queries) {
        queries.push(createImageQuery(query));
    }

    // @ts-ignore
    let query = queries.length == 1 ? queries[0] : union(...queries);

    let qcount = 0;
    if (with_count) {
        qcount = (await db.select({ count: count() }).from(query.as("t")))[0].count;
    }

    const result = await query
        .orderBy(desc(Image.GalleryOrder))
        .limit(page_size + 1) // fetch one extra row to check that there is still more data
        .offset(page * page_size);

    return queryResponse(result, page_size, page, url, "images", with_count ? { count: qcount } : null);
}
