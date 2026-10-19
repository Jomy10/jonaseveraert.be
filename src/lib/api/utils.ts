import { StatusCodes } from "http-status-codes";

/// @param `result`: An array of query results where the length is page_size + 1
export function queryResponse(
    result: any[],
    page_size: number, page: number,
    url: any,
    key: string = "images",
    extra_keys: { [k: string]: any } | null = {},
): Response {
    const has_next_page = result.length > page_size;

    let res: any = {};
    res[key] = result.slice(0, page_size);
    res["next_page"] = has_next_page ? `${url.protocol}//${url.host}${url.pathname}?page_size=${page_size}&page=${page + 1}` : null
    if (extra_keys != null)
        for (let k of Object.keys(extra_keys)) {
            res[k] = extra_keys[k];
        }

    return new Response(JSON.stringify(res), { status: StatusCodes.OK });
}
