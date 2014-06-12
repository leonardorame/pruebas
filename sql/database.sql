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
  primary key(IdStudy)
);