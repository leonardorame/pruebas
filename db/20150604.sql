alter table informes_wl add column titulo text;

CREATE OR REPLACE FUNCTION onstatuschange()
  RETURNS trigger AS
$BODY$
declare
  _revision integer;
  _prestacioncod integer;
  _accession integer;
BEGIN
  IF NEW.report IS NULL THEN
    NEW.report = (select report from studyprocedure where idstudyprocedure=NEW.idstudyprocedure);
  END IF;
  IF NEW.title IS NULL THEN
    NEW.title = (select title from studyprocedure where idstudyprocedure=NEW.idstudyprocedure);
  END IF;  

  /* controla si el reporte es nuevo o actualizado */
  _accession = (select accessionnumber from study where idstudy=NEW.idstudy)::integer;
  _prestacioncod = (select codprocedure from studyprocedure sp 
         join procedure pr on sp.idprocedure=pr.idprocedure
         where sp.idstudyprocedure=NEW.idstudyprocedure)::integer;
  _revision = (select count(*) from informes_wl where id_estudio=_accession and prestacioncod::integer=_prestacioncod);

  /* hace el insert */
  IF NEW.idstatus = (select idstatus from status where status = 'Revisado') THEN
    insert into informes_wl(id_estudio, prestacioncod, prestacionnombre, fecha_informe, informe, titulo, mp_informante, modalidad, revision) values
      ((select accessionnumber from study where idstudy=NEW.idstudy)::integer,
       (select codprocedure from studyprocedure sp 
         join procedure pr on sp.idprocedure=pr.idprocedure
         where sp.idstudyprocedure=NEW.idstudyprocedure)::integer,
	(select procedure from studyprocedure sp 
         join procedure pr on sp.idprocedure=pr.idprocedure
         where sp.idstudyprocedure=NEW.idstudyprocedure),    
       current_date,
       extract_contents_from_html(NEW.report),
       extract_contents_from_html(NEW.title),
       (select p.license from professional p where p.idprofessional = NEW.idprimaryinterpretingphysician),
       (select modality from study where idstudy=NEW.idstudy),
       _revision      
       );
  END IF;
  RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;