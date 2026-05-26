export function requireDatabaseUrl(env = process.env) {
  if (!env.DATABASE_URL) {
    throw new Error("DATABASE_URL environment variable is required");
  }

  return env.DATABASE_URL;
}
