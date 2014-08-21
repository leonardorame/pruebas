create table studywav(
  idstudy integer not null references study(idstudy),
  wav bytea not null,
  primary key(idstudy))

