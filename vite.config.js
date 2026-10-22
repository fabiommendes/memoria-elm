import { defineConfig } from "vite";
import elmPlugin from "vite-plugin-elm";

export default defineConfig({
  // Caminhos relativos: o build funciona em qualquer subpasta do servidor.
  base: "./",
  plugins: [elmPlugin()],
});
