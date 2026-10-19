// @ts-check
import { defineConfig } from "astro/config";

import node from "@astrojs/node";
import solidJs from "@astrojs/solid-js";
import { unified } from "@astrojs/markdown-remark";

// https://astro.build/config
export default defineConfig({
    output: "server",

    adapter: node({
        mode: "standalone"
    }),

    markdown: {
      processor: unified()
    },

    integrations: [solidJs()],
});
