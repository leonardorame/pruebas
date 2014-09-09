alter table studywav drop constraint studywav_pkey;
alter table studywav add constraint studywav_pkey primary key(idstudyprocedure);
alter table studyprocedure add column idcurrentuser integer references users(iduser);
alter table study drop column idcurrentuser;
