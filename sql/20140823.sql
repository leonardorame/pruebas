CREATE OR REPLACE FUNCTION savewav(
  _wav bytea,
  _idstudy integer)
  RETURNS void
AS
$$
BEGIN
  if((select idstudy from studywav where idstudy = _idstudy) IS NULL) then
    insert into studywav(idstudy, wav) values(_idstudy, _wav);
  else
    update studywav set wav = _wav where idstudy = _idstudy;
  end if;
END
$$
LANGUAGE plpgsql;
