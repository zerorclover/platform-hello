create table if not exists items (
  id serial primary key,
  name text not null,
  created_at timestamptz not null default now()
);

insert into items (name)
values ('seed item')
on conflict do nothing;
