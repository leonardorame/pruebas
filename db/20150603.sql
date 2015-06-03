alter table studyprocedure add column title text;

DROP FUNCTION update_study(integer, text, integer, integer, integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION update_study(_idstudy integer, _report text, _idrequestingphysician integer, _idperformingphysician integer, _idprimaryinterpretingphysician integer, _idsecondaryinterpreteingphysician integer, _idstatus integer, _iduser integer, _idprocedure integer, _qty integer, _title text)
  RETURNS void AS
$BODY$
DECLARE _idstudyprocedure Integer;
BEGIN
  update study set
    IdRequestingPhysician = _idrequestingphysician,
    IdPerformingPhysician = _idperformingphysician
  where idstudy = _idstudy;

  _idstudyprocedure = (select idstudyprocedure from studyprocedure
    where idstudy=_idstudy and idprocedure=_idprocedure);

  if(_idstudyprocedure is not null) then
    update studyprocedure set
      idprocedure = _idprocedure,
      qty = _qty,
      report = _report,
      title = _title,
      IdPrimaryInterpretingPhysician = _idprimaryinterpretingphysician,
      IdSecondaryInterpretingPhysician = _idsecondaryinterpreteingphysician,
      idstatus = _idstatus,
      idcurrentuser = _iduser
      where idstudyprocedure = _idstudyprocedure;
  else  
    insert into studyprocedure(idstudy, idprocedure, qty, report, title, idstatus)
      values(_idstudy, _idprocedure, _qty, _report, _title, _idstatus);
  end if;

  insert into study_status(idstudy, idstatus, iduser, idprocedure) 
    values(_idstudy, _idstatus, _iduser, _idprocedure);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
