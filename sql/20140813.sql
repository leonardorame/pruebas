alter table study add column modality varchar(2);
alter table professional add column license varchar(15);


CREATE OR REPLACE FUNCTION insert_study(
  _accession character varying, _fecha_de_creacion timestamp without time zone, _modalidad character varying, 
  _patient_class character varying, _admission_type character varying, _institucion character varying, 
  _fecha_desde timestamp without time zone, _fecha_hasta timestamp without time zone, _domicilio character varying, 
  _fecha_nacimiento date, _apellidos character varying, _nombres character varying, _nro_doc character varying, 
  _sexo sex_type, _telefono character varying, _pro_der_ape_pat character varying, 
  _pro_der_nombres character varying, _pro_efe_ape_pat character varying, _pro_efe_nombres character varying, 
  _prestacionqty integer, _prestacioncod integer, _prestacionnombre character varying, _aetitle character varying, 
  _id_paciente integer)
  RETURNS void 
AS 
$$
declare 
  _IdPatient integer;
  _IdProfEfe integer;
  _IdProfDer integer;
  _IdProcedure integer;
  _IdStudy integer;
BEGIN
/* Inserta datos de paciente */
  _IdPatient = (select IdPatient from patient where FirstName = _nombres and LastName = _apellidos);
  if _IdPatient is null then
    insert into patient(FirstName, LastName, BirthDate, Sex, Address, OtherIds, Phone1) values
      (_nombres, _apellidos, _fecha_nacimiento, _sexo, _domicilio, _nro_doc, _telefono);
    _IdPatient = (select currval('patient_idpatient_seq'));
  end if;

  /* Inserta datos de profesional deriva */
  _IdProfDer = (select IdProfessional from professional where FirstName = _pro_der_nombres and LastName = _pro_der_ape_pat);
  if (_IdProfDer is null) then
    insert into professional(FirstName, LastName) values (_pro_der_nombres, _pro_der_ape_pat);
    _IdProfDer = (select currval('professional_idprofessional_seq'));
  end if;

  /* Inserta datos de profesional efectua */
  _IdProfEfe = (select IdProfessional from professional where FirstName = _pro_efe_nombres and LastName = _pro_efe_ape_pat);
  if (_IdProfEfe is null) then
    insert into professional(FirstName, LastName) values (_pro_efe_nombres, _pro_efe_ape_pat);
    _IdProfEfe = (select currval('professional_idprofessional_seq'));
  end if;

  /* Inserta datos de prestacion */
  _IdProcedure = (select IdProcedure from procedure where CodProcedure = _prestacioncod::varchar and Procedure = _prestacionnombre);
  if (_IdProcedure is null) then
    insert into procedure(CodProcedure, Procedure) values(_prestacioncod, _prestacionnombre);
    _IdProcedure = (select currval('procedure_idprocedure_seq'));
  end if;

  /* Inserta datos de turno */
  _IdStudy = (select IdStudy from study where AccessionNumber = _accession);
  if ( _IdStudy is null) then
    insert into study(IdPatient, IdRequestingPhysician, IdPerformingPhysician, IdStatus,  AccessionNumber,  StudyDate, Modality)
      values(_IdPatient, _IdProfDer, _IdProfEfe, 1, _accession, _fecha_desde, _modalidad);
    _IdStudy = (select currval('study_idstudy_seq'));
    insert into studyprocedure(IdStudy, IdProcedure, Qty) values(_IdStudy, _IdProcedure, _prestacionqty);
  end if;      
END
$$
LANGUAGE plpgsql;

create table informes_wl(
  id_estudio integer not null,
  prestacioncod integer not null,
  fecha_informe date,
  informe text,
  mp_informante varchar(6),
  modalidad varchar(5),
  enviado boolean,
  primary key(id_estudio));

create function onstatuschange() returns trigger as
$$
BEGIN
  IF NEW.report IS NULL THEN
    NEW.report = (select report from study where idstudy=NEW.idstudy);
  END IF;

  IF NEW.idstatus = (select idstatus from status where status = 'Corregido') THEN
    insert into informes_wl(id_estudio, prestacioncod, fecha_informe, informe, mp_informante, modalidad) values
      (NEW.idstudy,
       (select codprocedure from studyprocedure sp 
         join procedure pr on sp.idprocedure=pr.idprocedure
         where sp.idstudy=NEW.idstudy limit 1)::integer,
       current_date,
       NEW.report,
       (select p.license from professional p where p.idprofessional = NEW.idprimaryinterpreterphysician),
       NEW.modality);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

create trigger tr_statuschange after update on study 
  for each row execute procedure onstatuschange();
