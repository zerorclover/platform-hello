import assert from "node:assert/strict";
import test from "node:test";

import { createApp } from "../src/app.js";

function request(app, method, path, body) {
  return app.handle({
    method,
    url: path,
    headers: { "content-type": "application/json" },
    body: body === undefined ? undefined : JSON.stringify(body)
  });
}

test("GET /health returns service status", async () => {
  const app = createApp({ environment: "test" });

  const response = await request(app, "GET", "/health");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(JSON.parse(response.body), {
    status: "ok",
    service: "platform-hello-api",
    environment: "test"
  });
});

test("GET /api/message returns a hello message", async () => {
  const app = createApp({ environment: "dev" });

  const response = await request(app, "GET", "/api/message");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(JSON.parse(response.body), {
    message: "Hello from the platform API",
    environment: "dev"
  });
});

test("GET /api/items returns database items", async () => {
  const app = createApp({
    environment: "test",
    store: {
      listItems: async () => [{ id: 1, name: "first item" }]
    }
  });

  const response = await request(app, "GET", "/api/items");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(JSON.parse(response.body), {
    items: [{ id: 1, name: "first item" }]
  });
});

test("POST /api/items creates a database item", async () => {
  const app = createApp({
    environment: "test",
    store: {
      createItem: async (name) => ({ id: 7, name })
    }
  });

  const response = await request(app, "POST", "/api/items", { name: "new item" });

  assert.equal(response.statusCode, 201);
  assert.deepEqual(JSON.parse(response.body), {
    item: { id: 7, name: "new item" }
  });
});

test("POST /api/items rejects empty names", async () => {
  const app = createApp({ environment: "test" });

  const response = await request(app, "POST", "/api/items", { name: " " });

  assert.equal(response.statusCode, 400);
  assert.deepEqual(JSON.parse(response.body), {
    error: "name is required"
  });
});
