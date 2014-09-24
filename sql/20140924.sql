create table gridfilters(
  idgridfilter serial not null,
  grid varchar(50),
  field varchar(50),
  iduser integer references users(iduser),
  filter varchar(50),
  primary key(idgridfilter));

