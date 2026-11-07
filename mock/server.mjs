import { createServer } from "node:http";
import { pathToFileURL } from "node:url";

import { createApi } from "./logic.mjs";

const port = Number(process.env.PORT || 4010);
const api = createApi();

function readBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    request.on("data", (chunk) => chunks.push(chunk));
    request.on("end", () => {
      const raw = Buffer.concat(chunks).toString("utf8").trim();
      if (!raw) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(raw));
      } catch {
        reject(new Error("JSON inválido"));
      }
    });
    request.on("error", reject);
  });
}

export function startServer(customPort = port) {
  const server = createServer(async (request, response) => {
    const url = new URL(request.url || "/", "http://localhost");
    if (request.method === "OPTIONS") {
      response.writeHead(204, {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Authorization, Content-Type, Accept",
        "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
      });
      response.end();
      return;
    }
    const path = url.pathname.replace(/^\/v1/, "") || "/";
    const header = request.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : "";
    try {
      const body = request.method === "GET" ? {} : await readBody(request);
      const result = api.handle({ method: request.method || "GET", path, token, body });
      response.writeHead(result.status, {
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Authorization, Content-Type, Accept",
        "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
      });
      response.end(JSON.stringify(result.body, null, 2));
    } catch {
      response.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
      response.end(JSON.stringify({ error: { code: "BAD_REQUEST", message: "JSON inválido.", fields: {} } }));
    }
  });
  return new Promise((resolve) => {
    server.listen(customPort, "0.0.0.0", () => resolve(server));
  });
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isMain) {
  startServer().then(() => {
    console.log(`Mock do Ciclo em http://localhost:${port}/v1`);
    console.log("No emulador Android use http://10.0.2.2:" + port + "/v1");
  });
}
