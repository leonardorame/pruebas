drop function insert_study(character varying, timestamp without time zone, character varying, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone, character varying, date, character varying, character varying, character varying, sex_type, character varying, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, integer);

create or replace function insert_study(_accession character varying, _fecha_de_creacion timestamp without time zone, _modalidad character varying, _patient_class character varying, _admission_type character varying, _institucion character varying, _fecha_desde timestamp without time zone, _fecha_hasta timestamp without time zone, _domicilio character varying, _fecha_nacimiento date, _apellidos character varying, _nombres character varying, _nro_doc character varying, _sexo sex_type, _telefono character varying, _pro_der_ape_pat character varying, _pro_der_nombres character varying, _pro_efe_ape_pat character varying, _pro_efe_nombres character varying, _prestacionqty integer, _prestacioncod integer, _prestacionnombre character varying, _aetitle character varying, _id_paciente integer)
  returns void as
$body$
declare 
  _idpatient integer;
  _idprofefe integer;
  _idprofder integer;
  _idprocedure integer;
  _idstudy integer;
begin
/* inserta datos de paciente */
  _idpatient = (select idpatient from patient where firstname = _nombres and lastname = _apellidos);
  if _idpatient is null then
    insert into patient(firstname, lastname, birthdate, sex, address, otherids, phone1) values
      (_nombres, _apellidos, _fecha_nacimiento, _sexo, _domicilio, _nro_doc, _telefono);
    _idpatient = (select currval('patient_idpatient_seq'));
  end if;

  /* inserta datos de profesional deriva */
  _idprofder = (select idprofessional from professional where firstname = _pro_der_nombres and lastname = _pro_der_ape_pat);
  if (_idprofder is null) then
    insert into professional(firstname, lastname) values (_pro_der_nombres, _pro_der_ape_pat);
    _idprofder = (select currval('professional_idprofessional_seq'));
  end if;

  /* inserta datos de profesional efectua */
  _idprofefe = (select idprofessional from professional where firstname = _pro_efe_nombres and lastname = _pro_efe_ape_pat);
  if (_idprofefe is null) then
    insert into professional(firstname, lastname) values (_pro_efe_nombres, _pro_efe_ape_pat);
    _idprofefe = (select currval('professional_idprofessional_seq'));
  end if;

  /* inserta datos de prestacion */
  _idprocedure = (select idprocedure from procedure where codprocedure = _prestacioncod::varchar and procedure = _prestacionnombre);
  if (_idprocedure is null) then
    insert into procedure(codprocedure, procedure) values(_prestacioncod, _prestacionnombre);
    _idprocedure = (select currval('procedure_idprocedure_seq'));
  end if;

  /* inserta datos de turno */
  _idstudy = (select idstudy from study where accessionnumber = _accession);
  if ( _idstudy is null) then
    insert into study(idpatient, idrequestingphysician, idperformingphysician, accessionnumber,  studydate, modality)
      values(_idpatient, _idprofder, _idprofefe, _accession, _fecha_desde, _modalidad);
    _idstudy = (select currval('study_idstudy_seq'));
    insert into studyprocedure(idstudy, idprocedure, qty, idstatus) values(_idstudy, _idprocedure, _prestacionqty, 1);
  end if;      
end
$body$
  language plpgsql volatile
  cost 100;
