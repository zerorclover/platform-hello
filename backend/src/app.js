const jsonHeaders = {
  "content-type": "application/json; charset=utf-8",
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "GET,POST,OPTIONS",
  "access-control-allow-headers": "content-type"
};

function json(statusCode, payload) {
  return {
    statusCode,
    headers: jsonHeaders,
    body: JSON.stringify(payload)
  };
}

async function readJsonBody(request) {
  if (request.body !== undefined) {
    return JSON.parse(request.body || "{}");
  }

  let raw = "";
  for await (const chunk of request) {
    raw += chunk;
  }
  return JSON.parse(raw || "{}");
}

function defaultStore() {
  const items = [{ id: 1, name: "sample item" }];
  return {
    async listItems() {
      return items;
    },
    async createItem(name) {
      const item = { id: items.length + 1, name };
      items.push(item);
      return item;
    }
  };
}

export function createApp({ environment = "dev", store = defaultStore() } = {}) {
  async function handle(request) {
    const url = new URL(request.url, "http://localhost");

    if (request.method === "OPTIONS") {
      return { statusCode: 204, headers: jsonHeaders, body: "" };
    }

    if (request.method === "GET" && url.pathname === "/health") {
      return json(200, {
        status: "ok",
        service: "platform-hello-api",
        environment
      });
    }

    if (request.method === "GET" && url.pathname === "/api/message") {
      return json(200, {
        message: "Hello from the platform API",
        environment
      });
    }

    if (request.method === "GET" && url.pathname === "/api/items") {
      const items = await store.listItems();
      return json(200, { items });
    }

    if (request.method === "POST" && url.pathname === "/api/items") {
      const payload = await readJsonBody(request);
      const name = typeof payload.name === "string" ? payload.name.trim() : "";

      if (!name) {
        return json(400, { error: "name is required" });
      }

      const item = await store.createItem(name);
      return json(201, { item });
    }

    return json(404, { error: "not found" });
  }

  return { handle };
}

export function sendNodeResponse(nodeResponse, appResponse) {
  nodeResponse.writeHead(appResponse.statusCode, appResponse.headers);
  nodeResponse.end(appResponse.body);
}
