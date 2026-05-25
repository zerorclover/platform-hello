import pg from "pg";

export class PgItemStore {
  constructor(connectionString) {
    this.pool = new pg.Pool({ connectionString });
  }

  async initialize() {
    await this.pool.query(`
      create table if not exists items (
        id serial primary key,
        name text not null,
        created_at timestamptz not null default now()
      )
    `);
  }

  async listItems() {
    const result = await this.pool.query(
      "select id, name from items order by id asc limit 50"
    );
    return result.rows;
  }

  async createItem(name) {
    const result = await this.pool.query(
      "insert into items (name) values ($1) returning id, name",
      [name]
    );
    return result.rows[0];
  }

  async close() {
    await this.pool.end();
  }
}
