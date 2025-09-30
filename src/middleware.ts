import { defineMiddleware } from "astro/middleware";
import { db, eq, User } from "astro:db";
import bcrypt from "bcrypt";

const PROTECTED_ROUTES = [
  "/admin"
];

function isProtected(route: string): boolean {
  return PROTECTED_ROUTES.some((protectedRoute) => route.startsWith(protectedRoute));
}

async function verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
  return await bcrypt.compare(password, hashedPassword);
}

async function validateCredentials(username: string, password: string): Promise<boolean> {
  if (import.meta.env.DEV) {
    return true;
  } else {
    const passwordResult = await db.select({
      password: User.password
    }).from(User)
      .where(eq(User.UserName, username));

    if (passwordResult.length === 0) {
      return false;
    }

    const dbPassword = passwordResult[0].password;

    return await verifyPassword(password, dbPassword);
  }
}

// basic authentication
export const onRequest = defineMiddleware(async function (context, next) {
  const { url, request } = context;
  const pathname = new URL(url).pathname;

  if (isProtected(pathname)) {
    const authHeader = request.headers.get("authorization");
    console.log(request.headers);

    if (!authHeader || !authHeader.startsWith("Basic ")) {
      return new Response("Authentication required", {
        status: 401,
        headers: {
          "WWW-Authenticate": "Basic realm=\"Secure Area\"",
          "Content-Type": "text/plain",
        },
      });
    }

    const encodedCredetials = authHeader.substring(6);
    const decodedCredentials = atob(encodedCredetials);
    const [username, password] = decodedCredentials.split(':');

    if (!(await validateCredentials(username, password))) {
      return new Response("Invalid credentials", {
        status: 401,
        headers: {
          "WWW-Authenticate": "Basic realm=\"Secure Area\"",
          "Content-Type": "text/plain",
        },
      });
    }
  }

  return next();
});
