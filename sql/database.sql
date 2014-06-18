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

delete from users;
delete from user_groups;
insert into user_groups(UserGroup) values('Administrators');
insert into user_groups(UserGroup) values('Reporters');
insert into user_groups(UserGroup) values('ReadOnly');

create table users(
  IdUser serial not null,
  IdUserGroup integer not null references user_groups(IdUserGroup),
  IdProfessional integer not null references professional(IdProfessional),
  UserName varchar(8),
  Password varchar(8),
  FullName varchar(100), 
  primary key(IdUser)
); 

insert into users(IdUserGroup, Username, Password, FullName) values(3, 'admin', '123', 'Leonardo M. Ramé');

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
