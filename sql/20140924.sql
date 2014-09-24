create table gridfilters(
  idgridfilter serial not null,
  grid varchar(50),
  column varchar(50),
  iduser integer references(users),
  filter varchar(50),
  primary key(idgridfilter));

