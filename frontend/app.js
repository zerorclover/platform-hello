const messageElement = document.querySelector("#message");
const itemsElement = document.querySelector("#items");
const form = document.querySelector("#item-form");
const input = document.querySelector("#item-name");

async function fetchJson(path, options) {
  const response = await fetch(path, options);
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }
  return response.json();
}

function renderItems(items) {
  itemsElement.replaceChildren(
    ...items.map((item) => {
      const element = document.createElement("li");
      element.textContent = `#${item.id} ${item.name}`;
      return element;
    })
  );
}

async function load() {
  const [message, itemResponse] = await Promise.all([
    fetchJson("/api/message"),
    fetchJson("/api/items")
  ]);

  messageElement.textContent = `${message.message} (${message.environment})`;
  renderItems(itemResponse.items);
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  const name = input.value.trim();
  if (!name) {
    return;
  }

  await fetchJson("/api/items", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ name })
  });

  input.value = "";
  await load();
});

load().catch((error) => {
  messageElement.textContent = error.message;
});
