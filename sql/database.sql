CREATE TYPE sex_type AS ENUM ('M', 'F', 'U');

create table status(
  IdStatus serial not null,
  Status varchar(20),
  primary key(IdStatus)
);

create table patient(
  IdPatient serial not null,
  OtherIds varchar(100),
  FirstName varchar(100), 
  LastName varchar(100),
  BirthDate date,
  Sex sex_type,
  Address Varchar(250),
  Phone1 varchar(20),
  Phone2 varchar(20),
  primary key(IdPatient)
);

create table professional(
  IdProfessional serial not null,
  OtherIds varchar(100),
  FirstName varchar(100), 
  LastName varchar(100),
  BirthDate date,
  Sex sex_type,
  Address Varchar(250),
  Phone1 varchar(20),
  Phone2 varchar(20),
  primary key(IdProfessional)
);

create table study(
  IdStudy serial not null,
  IdPatient Integer not null references patient(IdPatient),
  IdRequestingPhysician Integer references professional(IdProfessional),
  IdPerformingPhysician Integer not null references professional(IdProfessional),
  IdPrimaryInterpreterPhysician Integer references professional(IdProfessional),
  IdSecondaryInterpreterPhysician Integer references professional(IdProfessional),
  IdStatus Integer not null references status(IdStatus),
  AccessionNumber varchar(16),
  StudyDate date not null,
  Report text,
  primary key(IdStudy)
);

create table user_groups(
  IdUserGroup serial not null,
  UserGroup varchar(100),
  primary key(IdUserGroup)
 );

create table users(
  IdUser serial not null,
  IdUserGroup integer not null references user_groups(IdUserGroup),
  IdProfessional integer not null references professional(IdProfessional),
  UserName varchar(8),
  Password varchar(8),
  primary key(IdUser)
); 

create table sessions(
  SessionId serial not null,
  SessionTimeStamp timestamp default current_timestamp,
  SessionData text,
  primary key(SessionId)
);

create table study_status(
  IdStudyStatus serial not null,
  IdStudy Integer not null references study(idstudy),
  Updated timestamp default current_timestamp,
  IdUser Integer not null references users(iduser),
  IdStatus Integer not null references status(IdStatus),
  primary key(IdStudyStatus)
);


create table templates(
  IdTemplate serial not null,
  Name varchar(100) unique not null,
  Code varchar(20) unique not null,
  Template text,
  primary key(IdTemplate)
);


create table procedure(
  IdProcedure serial not null,
  CodProcedure varchar(100) unique not null,
  Procedure varchar(100), 
  primary key(IdProcedure)
);

create table studyprocedure(
  IdStudyProcedure serial not null,
  IdStudy Integer not null references study(IdStudy),
  IdProcedure Integer not null references procedure(IdProcedure),
  Qty Integer not null default 1,
  primary key(IdStudyProcedure)
);


CREATE OR REPLACE FUNCTION insertar_turno(_accession character varying, _fecha_de_creacion timestamp without time zone, _modalidad character varying, _patient_class character varying, _admission_type character varying, _institucion character varying, _fecha_desde timestamp without time zone, _fecha_hasta timestamp without time zone, _domicilio character varying, _fecha_nacimiento date, _apellidos character varying, _nombres character varying, _nro_doc character varying, _sexo character varying, _telefono character varying, _pro_der_ape_pat character varying, _pro_der_nombres character varying, _pro_efe_ape_pat character varying, _pro_efe_nombres character varying, _prestacionqty integer, _prestacioncod integer, _prestacionnombre character varying, _aetitle character varying, _id_paciente integer)
  RETURNS void AS
$BODY$
BEGIN
  /* Inserta datos de paciente */
  insert into patient(FirstName, LastName, BirthDate, Sex, Address, OtherIds, Phone1) values
    (nombres, apellidos, fecha_nacimiento, sexo, nro_doc, telefono);
  /* Inserta datos de profesional deriva */
  insert into proffesional(FirstName, LastName) values (pro_der_nombres, pro_der_nombres);
  /* Inserta datos de profesional efectua */
  insert into proffesional(FirstName, LastName) values (pro_efe_nombres, pro_efe_nombres);
  /* Inserta datos de prestacion */
  insert into procedure(CodProcedure, Procedure) values(prestacioncod, prestacionnombre);
  /* Inserta datos de turno */
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

insert into status(status) values('Ingresado');
insert into status(status) values('Transcripto');
insert into status(status) values('Corregido');
insert into status(status) values('Entregado');
insert into user_groups(UserGroup) values('Administrators');
insert into user_groups(UserGroup) values('Reporters');
insert into user_groups(UserGroup) values('ReadOnly');
insert into procedure(CodProcedure, Procedure) values ('001', 'RX de columna');
insert into procedure(CodProcedure, Procedure) values ('002', 'RX de hombro');
insert into procedure(CodProcedure, Procedure) values ('003', 'RX de cadera');
insert into procedure(CodProcedure, Procedure) values ('004', 'Resonancia mamográfica');
insert into procedure(CodProcedure, Procedure) values ('005', 'Mamografía');
insert into procedure(CodProcedure, Procedure) values ('006', 'Ecografía abdominal');
insert into professional(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Carlos', 'Gonzalez', '1965-02-10', 'M', 'Laprida 2222', '883838');
insert into users(IdUserGroup, IdProfessional, Username, Password) values(1, 1, 'admin', '123');
insert into users(IdUserGroup, IdProfessional, Username, Password) values(2, 1, 'medico', 'medico');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Juan', 'Pérez', '2001-04-20', 'M', '9 de Julio 123', '1212312');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Romina', 'García', '1990-08-12', 'F', 'Juncal 123', '1231231');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Lucas', 'Trejo', '1995-02-10', 'M', 'Santa Fe 444', '9999999');
insert into templates(name, code) values('Mammo', '001');
insert into templates(name, code) values('Radiology', '002');
insert into templates(name, code) values('Ultrasound', '003');
insert into study(IdPatient, IdPerformingPhysician, IdPrimaryInterpreterPhysician, IdStatus, StudyDate)
  values(1, 1, 1, 1, current_timestamp);
insert into study(idpatient, idperformingphysician, idprimaryinterpreterphysician, idstatus, studydate)
  values(2, 1, 1, 1, current_timestamp);
insert into study(idpatient, idperformingphysician, idprimaryinterpreterphysician, idstatus, studydate)
  values(2, 1, 1, 1, current_timestamp);
insert into studyprocedure(IdStudy, IdProcedure, Qty) values(1, 2, 1);
insert into studyprocedure(IdStudy, IdProcedure, Qty) values(2, 1, 1);
insert into studyprocedure(IdStudy, IdProcedure, Qty) values(2, 4, 1);
