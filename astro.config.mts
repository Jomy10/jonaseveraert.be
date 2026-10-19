// @ts-check
import { defineConfig } from "astro/config";

import node from "@astrojs/node";
import solidJs from "@astrojs/solid-js";
// import db from "@astrojs/db";

// https://astro.build/config
export default defineConfig({
  output: "server",

  // integrations: [db()],
  adapter: node({
    mode: "standalone"
  }),

  integrations: [solidJs()],
});