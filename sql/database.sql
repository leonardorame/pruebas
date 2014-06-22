CREATE TYPE sex_type AS ENUM ('M', 'F', 'U');

create table status(
  IdStatus serial not null,
  Status varchar(20),
  primary key(IdStatus)
);

create table patient(
  IdPatient serial not null,
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

insert into status(status) values('Ingresado');
insert into status(status) values('Transcripto');
insert into status(status) values('Corregido');
insert into status(status) values('Entregado');
insert into user_groups(UserGroup) values('Administrators');
insert into user_groups(UserGroup) values('Reporters');
insert into user_groups(UserGroup) values('ReadOnly');
insert into professional(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Carlos', 'Gonzalez', '1965-02-10', 'M', 'Laprida 2222', '883838');
insert into users(IdUserGroup, IdProfessional, Username, Password) values(1, 1, 'admin', '123');
insert into users(IdUserGroup, IdProfessional, Username, Password) values(2, 1, 'medico', 'medico');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Juan', 'Pérez', '2001-04-20', 'M', '9 de Julio 123', '1212312');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Romina', 'García', '1990-08-12', 'F', 'Juncal 123', '1231231');
insert into patient(FirstName, LastName, BirthDate, Sex, Address, Phone1) values('Lucas', 'Trejo', '1995-02-10', 'M', 'Santa Fe 444', '9999999');
insert into study(IdPatient, IdPerformingPhysician, IdPrimaryInterpreterPhysician, IdStatus, StudyDate)
  values(1, 1, 1, 1, current_timestamp);
insert into study(idpatient, idperformingphysician, idprimaryinterpreterphysician, idstatus, studydate)
  values(2, 1, 1, 1, current_timestamp);
insert into study(idpatient, idperformingphysician, idprimaryinterpreterphysician, idstatus, studydate)
  values(2, 1, 1, 1, current_timestamp);
