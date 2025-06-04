import lygia from "vite-plugin-lygia-resolver";

import { defineConfig } from "vite";

export default defineConfig({
  plugins: [lygia()],
  optimizeDeps: {
    exclude: ["@ffmpeg/ffmpeg", "@ffmpeg/util"],
  },
  server: {
    headers: {
      "Cross-Origin-Opener-Policy": "same-origin",
      "Cross-Origin-Embedder-Policy": "require-corp",
    },
  },
});
