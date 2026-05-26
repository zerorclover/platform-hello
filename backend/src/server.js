import http from "node:http";

import { createApp, sendNodeResponse } from "./app.js";
import { requireDatabaseUrl } from "./config.js";
import { PgItemStore } from "./store.js";

const port = Number(process.env.PORT || 3000);
const environment = process.env.APP_ENV || process.env.NODE_ENV || "dev";
const databaseUrl = requireDatabaseUrl();

const store = new PgItemStore(databaseUrl);
await store.initialize();

const app = createApp({ environment, store });

const server = http.createServer(async (request, response) => {
  try {
    const appResponse = await app.handle(request);
    sendNodeResponse(response, appResponse);
  } catch (error) {
    console.error(error);
    sendNodeResponse(response, {
      statusCode: 500,
      headers: { "content-type": "application/json; charset=utf-8" },
      body: JSON.stringify({ error: "internal server error" })
    });
  }
});

server.listen(port, () => {
  console.log(`platform-hello-api listening on ${port}`);
});
