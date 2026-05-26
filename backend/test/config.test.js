import assert from "node:assert/strict";
import test from "node:test";

import { requireDatabaseUrl } from "../src/config.js";

test("requireDatabaseUrl returns configured database URL", () => {
  const databaseUrl = "postgres://user:${POSTGRES_PASSWORD}@localhost:5432/app";

  assert.equal(requireDatabaseUrl({ DATABASE_URL: databaseUrl }), databaseUrl);
});

test("requireDatabaseUrl rejects missing database URL", () => {
  assert.throws(
    () => requireDatabaseUrl({}),
    /DATABASE_URL environment variable is required/
  );
});
