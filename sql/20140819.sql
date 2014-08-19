create table studywav(
  idstudy integer not null foreign key(idstudy) references study(idstudy),
  wav bytea not null,
  primary key(idstudy))

