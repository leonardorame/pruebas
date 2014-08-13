CREATE OR REPLACE FUNCTION update_status(
  _idstudy integer,
  _idstatus integer,
  _iduser integer)
  RETURNS void
AS
$$
BEGIN
  update study set
    idstatus = _idstatus
  where idstudy = _idstudy;

  insert into study_status(idstudy, idstatus, iduser) 
    values(_idstudy, _idstatus, _iduser);
END
$$
LANGUAGE plpgsql;
