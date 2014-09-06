alter table studyprocedure add column report text;
alter table study drop column report;
alter table study drop column idstatus;
alter table studyprocedure add column idstatus integer not null references status(idstatus);
alter table study_status add column idprocedure integer references procedure(idprocedure);

DROP FUNCTION update_study(integer, text, integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION update_study(_idstudy integer, _report text, _idrequestingphysician integer, _idperformingphysician integer, _idprimaryinterpretingphysician integer, _idsecondaryinterpreteingphysician integer, _idstatus integer, _iduser integer, _idprocedure integer, _qty integer)
  RETURNS void AS
$BODY$
DECLARE _idstudyprocedure Integer;
BEGIN
  update study set
    IdRequestingPhysician = _idrequestingphysician,
    IdPerformingPhysician = _idperformingphysician,
    IdPrimaryInterpreterPhysician = _idprimaryinterpretingphysician,
    IdSecondaryInterpreterPhysician = _idsecondaryinterpreteingphysician
  where idstudy = _idstudy;

  _idstudyprocedure = (select idstudyprocedure from studyprocedure
    where idstudy=_idstudy and idprocedure=_idprocedure);

  if(_idstudyprocedure is not null) then
    update studyprocedure set
      idprocedure = _idprocedure,
      qty = _qty,
      report = _report,
      idstatus = _idstatus
      where idstudyprocedure = _idstudyprocedure;
  else  
    insert into studyprocedure(idstudy, idprocedure, qty, report, idstatus)
      values(_idstudy, _idprocedure, _qty, _report, _idstatus);
  end if;

  insert into study_status(idstudy, idstatus, iduser, idprocedure) 
    values(_idstudy, _idstatus, _iduser, _idprocedure);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

DROP TRIGGER tr_statuschange on study;

CREATE TRIGGER tr_statuschange
  AFTER UPDATE
  ON studyprocedure
  FOR EACH ROW
  EXECUTE PROCEDURE onstatuschange();


DROP FUNCTION onstatuschange();

CREATE OR REPLACE FUNCTION onstatuschange()
  RETURNS trigger AS
$BODY$
BEGIN
  IF NEW.report IS NULL THEN
    NEW.report = (select report from studyprocedure where idstudyprocedure=NEW.idstudyprocedure);
  END IF;

  IF NEW.idstatus = (select idstatus from status where status = 'Revisado') THEN
    insert into informes_wl(id_estudio, prestacioncod, fecha_informe, informe, mp_informante, modalidad) values
      (NEW.idstudy,
       (select codprocedure from studyprocedure sp 
         join procedure pr on sp.idprocedure=pr.idprocedure
         where sp.idstudy=NEW.idstudy limit 1)::integer,
       current_date,
       extract_contents_from_html(NEW.report),
       (select p.license from professional p where p.idprofessional = NEW.idprimaryinterpreterphysician),
       NEW.modality);
  END IF;
  RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


alter table studywav add column IdStudyProcedure integer;
update studywav sw set idstudyprocedure=(select idstudyprocedure from studyprocedure where idstudy=sw.idstudy);
alter table studywav add constraint fk_studyprocedure_idstudyprocedure foreign key(IdStudyProcedure) references studyprocedure(IdStudyProcedure);
