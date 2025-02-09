--
--  sqlo2.sql
--
--  $Id$
--
--  Various SQL optimized compiler tests, part 2.
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2025 OpenLink Software
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--
--

echo BOTH "\nSTARTED: SQL Optimizer tests part 2 (sqlo2.sql)\n";
SET ARGV[0] 0;
SET ARGV[1] 0;

drop table B3649;
create table B3649 (ID int primary key, TM time, DT date);
insert into B3649 values (1, curtime(), curdate());
select 1 from (select top 2 * from B3649 order by TM) x, B3649 y where x.ID = y.ID;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 3649: subq w/ group by STATE=" $STATE " MESSAGE=" $MESSAGE "\n";


select 1 from SYS_PROCEDURES where P_MORE <> 'ab';
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4312: <> on BLOBs STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B4346;
create table B4346 (DATA ANY);
insert into B4346 values (NULL);
insert into B4346 values (serialize (NULL));

select distinct DATA from B4346;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4346: distinct over ANY column STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B4346_1;
create table B4346_1 (ID int PRIMARY KEY, DATA ANY);
insert into B4346_1 values (1, 'a');
insert into B4346_1 values (2, 12);

select * from B4346_1 a, B4346_1 b where a.ID = b.ID;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4346_1: ANY column in the non-keypart of a temp key STATE=" $STATE " MESSAGE=" $MESSAGE "\n";


drop table B4634_TB;
drop procedure B4634_PROC;
create procedure B4634_PROC(in pArray any){
  declare i,iValue integer;
  result_names(iValue);
  i := 0;
  while(i < length(pArray)){
    result(pArray[i]);
    i := i + 1;
  };
};

create table B4634_TB(ID integer primary key);
insert into B4634_TB(ID) values (1);
insert into B4634_TB(ID) values (2);
insert into B4634_TB(ID) values (3);

select * from B4634_TB where ID in (select aid from B4634_PROC(m)(aid int) rc where m = vector(1,3));
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4634_1: IN w/ a procedure view returned " $ROWCNT " rows\n";
-- but this statement returns NOTHING, instead of the record with ID = 2
select * from B4634_TB where ID not in (select aid from B4634_PROC(m)(aid int) rc where m = vector(1,3));
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4634_2: NOT IN w/ a procedure view " $ROWCNT " rows\n";


drop table B4740;
create table B4740(id integer not null primary key,dt datetime);

insert into B4740(id,dt) values (11,{fn curdate()});
insert into B4740(id,dt) values (12,null);

select * from B4740 where dt <= {fn curdate()};    -- returns record 11 - it's OK
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-1: inx on a NULLable col search returned " $ROWCNT " rows\n";

create index B4740_sk1 on B4740(dt);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-2: inx created STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select * from B4740 where dt <= {fn curdate()};    -- returns: 11,12 - I think this is wrong.
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-3: inx on a NULLable col search returned " $ROWCNT " rows\n";

select * from B4740 where dt <= {fn curdate()} order by dt desc;    -- returns: 11,12 - I think this is wrong.
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-3: inx on a NULLable col search returned " $ROWCNT " rows\n";


-- the following two statements I have inattentively wrote, but the result from them is interesting too
select * from B4740 where dt <= {fn curdate()} order by id;    -- returns: 11
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-4: inx on a NULLable col search returned " $ROWCNT " rows\n";

select * from B4740 where dt <= {fn curdate()} order by null;  -- returns 12,11
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4740-5: inx on a NULLable col search returned " $ROWCNT " rows\n";


select max(count(*)) from SYS_USERS group by U_ID;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 4904: nested aggregates STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop view B5160_VAGPF;
drop view B5160_VA;
drop table B5160;

create table B5160(ID integer primary key,TXT varchar);
create view B5160_VA(ID,TXT) as select ID,NULL from B5160;
create view B5160_VAGPF as select ID,TXT from B5160_VA;

select * from B5160_VAGPF;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": bug 5160: view of null cols STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

DROP VIEW B5176_XSYS_ROBJECTS;
DROP VIEW B5176_XSYS_RELATIONS;
DROP VIEW B5176_XSYS_EMPLOYMENT_ROBJECTS;
DROP VIEW B5176_XSYS_EMPLOYMENT_RELATIONS;
DROP TABLE B5176_SFA_COMPANIES;
DROP TABLE B5176_SFA_CONTACTS;
DROP TABLE B5176_SFA_EMPLOYMENTS;


CREATE TABLE B5176_SFA_COMPANIES(
  ORG_ID           INTEGER        NOT NULL,
  COMPANY_ID       NUMERIC(12)    NOT NULL,
  OWNER_ID         INTEGER        NOT NULL,
  FREETEXT_ID      INTEGER        NOT NULL IDENTITY,
  COMPANY_NAME     NVARCHAR(255)  NOT NULL,
  INDUSTRY_ID      INTEGER,                      --- Reference to a list (B5176_XSYS_LIST_MEMBERS)
  URL              VARCHAR(255),
  PHONE_NUMBER     VARCHAR(30),
  PHONE_EXTENSION  VARCHAR(10),
  FAX_NUMBER       VARCHAR(30),
  FAX_EXTENSION    VARCHAR(10),
  MOBILE_NUMBER    VARCHAR(30),
  EMAIL            VARCHAR(255),
  COUNTRY_ID       CHAR(2),
  PROVINCE         NVARCHAR(50),
  CITY             NVARCHAR(50),
  POSTAL_CODE      NVARCHAR(10),
  ADDRESS1         NVARCHAR(100),
  ADDRESS2         NVARCHAR(100),
  DESCRIPTION      NVARCHAR(255),

  CONSTRAINT B5176_SFA_COMPANIES_PK PRIMARY KEY(ORG_ID,COMPANY_ID)
);

CREATE TABLE B5176_SFA_CONTACTS(
  ORG_ID           INTEGER        NOT NULL,
  CONTACT_ID       NUMERIC(12)    NOT NULL,
  OWNER_ID         INTEGER        NOT NULL,
  FREETEXT_ID      INTEGER        NOT NULL IDENTITY,
  NAME_TITLE       NVARCHAR(5),
  NAME_FIRST       NVARCHAR(30),
  NAME_MIDDLE      NVARCHAR(30),
  NAME_LAST        NVARCHAR(30),
  BIRTH_DATE       DATE,
  CONTACT_TYPE_ID  INTEGER,
  SOURCE_ID        INTEGER,
  PHONE_NUMBER     VARCHAR(30),
  PHONE_EXTENSION  VARCHAR(10),
  PHONE2_NUMBER    VARCHAR(30),
  PHONE2_EXTENSION VARCHAR(10),
  FAX_NUMBER       VARCHAR(30),
  FAX_EXTENSION    VARCHAR(10),
  MOBILE_NUMBER    VARCHAR(30),
  EMAIL            VARCHAR(255),
  COUNTRY_ID       CHAR(2),
  PROVINCE         NVARCHAR(50),
  CITY             NVARCHAR(50),
  POSTAL_CODE      NVARCHAR(10),
  ADDRESS1         NVARCHAR(100),
  ADDRESS2         NVARCHAR(100),
  DESCRIPTION      NVARCHAR(255),

  CONSTRAINT B5176_SFA_CONTACTS_PK PRIMARY KEY(ORG_ID,CONTACT_ID)
);

CREATE TABLE B5176_SFA_EMPLOYMENTS(
  ORG_ID           INTEGER        NOT NULL,
  OWNER_ID         INTEGER        NOT NULL,
  COMPANY_ID       NUMERIC(12)    NOT NULL,
  CONTACT_ID       NUMERIC(12)    NOT NULL,
  DEPARTMENT       NVARCHAR(255),
  TITLE            NVARCHAR(255),
  PHONE_NUMBER     VARCHAR(30),
  PHONE_EXTENSION  VARCHAR(10),
  FAX_NUMBER       VARCHAR(30),
  FAX_EXTENSION    VARCHAR(10),
  MOBILE_NUMBER    VARCHAR(30),
  EMAIL            VARCHAR(255),

  CONSTRAINT B5176_SFA_EMPLOYMENTS_PK PRIMARY KEY(ORG_ID,COMPANY_ID,CONTACT_ID)
);


CREATE VIEW B5176_XSYS_EMPLOYMENT_RELATIONS(
  ORG_ID,
  OBJ_ID,
  CLASS_ID,
  OWNER_ID,
  FREETEXT_ID,
  IS_PUBLIC,
  LABEL,
  DATA,
  DATA_SIZE
) AS
SELECT EM.ORG_ID,
       concat(xslt_format_number
(EM.COMPANY_ID,'############'),xslt_format_number
(EM.CONTACT_ID,'############')),
       'Employment',
       EM.OWNER_ID,
       0,
       0,
       '',
       '',
       0
FROM B5176_SFA_EMPLOYMENTS EM;

CREATE VIEW B5176_XSYS_EMPLOYMENT_ROBJECTS(ORG_ID,REL_ID,OBJ_ID,ROLE_SIDE)
    AS
SELECT EML.ORG_ID,
       MSFA_XML.id_xml(EML.COMPANY_ID,EML.CONTACT_ID),
       EML.COMPANY_ID,'L'
  FROM B5176_SFA_EMPLOYMENTS EML
UNION
SELECT EMR.ORG_ID,
       MSFA_XML.id_xml(EMR.COMPANY_ID,EMR.CONTACT_ID),
       EMR.CONTACT_ID,'R'
  FROM B5176_SFA_EMPLOYMENTS EMR
;


--
CREATE VIEW B5176_XSYS_RELATIONS
(ORG_ID,OBJ_ID,CLASS_ID,OWNER_ID,FREETEXT_ID,IS_PUBLIC,LABEL,DATA,DATA_SIZE)
    AS
SELECT
ORG_ID,OBJ_ID,CLASS_ID,OWNER_ID,FREETEXT_ID,IS_PUBLIC,LABEL,DATA,DATA_SIZE
  FROM B5176_XSYS_EMPLOYMENT_RELATIONS
;


CREATE VIEW B5176_XSYS_ROBJECTS(ORG_ID,REL_ID,OBJ_ID,ROLE_SIDE)
    AS
SELECT ORG_ID,REL_ID,OBJ_ID,ROLE_SIDE
  FROM B5176_XSYS_EMPLOYMENT_ROBJECTS;


create  procedure relation_object_report_new(
  in pOrgID integer,
  in pObjID integer)
{

  for ( SELECT R.OBJ_ID ObjID
          FROM B5176_XSYS_ROBJECTS Robj
    INNER JOIN B5176_XSYS_RELATIONS R ON
               Robj.ORG_ID = R.ORG_ID AND Robj.REL_ID = R.OBJ_ID AND
               Robj.Obj_ID = pObjID   AND
               R.CLASS_ID in
('Employment','Opportunity/Company','Lead/Company')
    INNER JOIN B5176_XSYS_ROBJECTS RO ON
               RO.ORG_ID = R.ORG_ID AND
               RO.REL_ID = R.OBJ_ID AND
               RO.OBJ_ID <> pObjID
         WHERE Robj.ORG_ID = pOrgID ) do
  {
    dbg_obj_print('BUMMMM');
  };

};
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ":BUG 5176: STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--- Test for Bug 14167 fix

create table LocutusMetadata.DBA.dcterms_subject_Table
(
 SubjectUri VARCHAR(2048),
 GraphName VARCHAR(32),
 dcterms_subject VARCHAR(52)
);

create table LocutusMetadata.DBA.fam_assetUrl_Table
(
 SubjectUri VARCHAR(2048),
 GraphName VARCHAR(32),
 ParentUri VARCHAR(2048),
 fam_dateTimeOriginalUtc VARCHAR(30)
);

delete from locutusmetadata.dba.dcterms_subject_Table;
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj1', 'graph1', 'The Larry Subject 1');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj2', 'graphBAD1', 'The Larry Subject 2');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj3', 'graph1', 'Larry');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj4', 'graphBAD1', 'Larry');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj5', 'graph1', 'The King Subject 5');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj6', 'graphBAD1', 'The King Subject 6');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj7', 'graph1', 'King');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj8', 'graphBAD1', 'King');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj9', 'graph1', 'The Larry Subject 9');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj10', 'graphBAD1', 'The Larry Subject 10');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj11', 'graph1', 'Larry');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj12', 'graphBAD1', 'Larry');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj13', 'User1', 'The Larry Subject 13');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj14', 'User1', 'Larry');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj15', 'User1', 'The King Subject 15');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj16', 'User1', 'King');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj17', 'User1', 'The Larry Subject 17');
insert into locutusmetadata.dba.dcterms_subject_Table (SubjectUri, GraphName, dcterms_subject) values ('subj18', 'User1', 'Larry');

delete from locutusmetadata.dba.fam_assetUrl_Table;
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj1', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj2', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj3', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj4', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj5', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj6', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj7', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj8', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj13', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj14', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj15', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj16', 'graph1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj1', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj2', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj3', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj4', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj5', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj6', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj7', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj8', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj13', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj14', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj15', 'User1');
insert into locutusmetadata.dba.fam_assetUrl_Table (SubjectUri, GraphName) values ('subj16', 'User1');

-- XXX
SELECT dcterms_subject_Table.SubjectUri,fam_assetUrl_Table.fam_dateTimeOriginalUtc
FROM
  locutusmetadata.dba.dcterms_subject_Table,
  locutusmetadata.dba.fam_assetUrl_Table
WHERE ((
    (dcterms_subject_Table.subjectUri in
      (select DISTINCT SubjectUri from locutusmetadata.dba.dcterms_subject_Table T
        where T.dcterms_subject like '%Larr%'
        union select DISTINCT SubjectUri from locutusmetadata.dba.dcterms_subject_Table T
        where T.dcterms_subject = 'Larry' )
    and dcterms_subject_Table.SubjectUri = fam_assetUrl_Table.SubjectUri
    and dcterms_subject_Table.GraphName = fam_assetUrl_Table.GraphName))
  and dcterms_subject_Table.GraphName ='User1')
ORDER BY  fam_dateTimeOriginalUtc ASC;

--ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG 14167 : union of DISTINCTs inside IN operator STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- XXX
--SELECT DS.SubjectUri, FA.fam_dateTimeOriginalUtc
--FROM
--  locutusmetadata.dba.dcterms_subject_Table DS,
--  locutusmetadata.dba.fam_assetUrl_Table FA
--WHERE
--    (DS.subjectUri in (select * from
--      (select T1.SubjectUri from locutusmetadata.dba.dcterms_subject_Table T1
--        where T1.dcterms_subject like '%Larr%'
--        union select T2.SubjectUri from locutusmetadata.dba.dcterms_subject_Table T2
--        where T2.dcterms_subject = 'Larry' ) T3))
--and DS.SubjectUri = FA.SubjectUri
--and 'User1' /* DS.GraphName */ = FA.GraphName
--and DS.GraphName ='User1'
--ORDER BY  FA.fam_dateTimeOriginalUtc ASC;

--ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG 14167 : union inside IN operator STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME in ('dba', 'admin', 'george');
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & IN non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME in ('dbo', 'admin', 'george');
ECHO BOTH $IF $EQU $LAST[1] 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & IN contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = concat ('dba', '') and U_NAME in ('dba', 'admin', 'george');
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": invariant = & IN non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME in (concat ('dba', ''), 'admin', 'george');
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & invariant IN non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME  = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & = non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME = 'dbo';
ECHO BOTH $IF $EQU $LAST[1] 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & = contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = concat ('dba', '') and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": invariant = & = non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where U_NAME = 'dba' and U_NAME = concat ('dba', '');
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = & invariant = non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where 'dba' = 'dba' and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant = constant non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where concat ('dba', '') = 'dba' and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": invariant = constant non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where 'dba' in ('dba', 'dbo') and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant in constant non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where concat ('dba', '') in ('dba', 'dbo') and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": invariant in constant non-contr returned " $LAST[1] " rows\n";

select count (*) from SYS_USERS where 'dba' in (concat ('dba', ''), 'dbo') and U_NAME = 'dba';
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": constant in invariant non-contr returned " $LAST[1] " rows\n";

drop view B5189V;
drop table B5189T;

create table B5189T (ID integer primary key);

insert into B5189T values (1);
insert into B5189T values (2);

create view B5189V as
select ID from B5189T
union all
select ID + 10 from B5189T
union all
select ID + 20 from B5189T
union all
select ID + 30 from B5189T
union all
select ID + 40 from B5189T
;

explain ('select count (*) from
B5189V A where exists (select 1 from B5189V E where E.ID = A.ID - 1)');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5189-1 : not propagating complex preds to union terms of a union view STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

explain ('select count (*) from
(
select ID from B5189T
union all
select ID + 10 from B5189T
union all
select ID + 20 from B5189T
union all
select ID + 30 from B5189T
union all
select ID + 40 from B5189T
) A where exists (select 1 from B5189V E where E.ID = A.ID - 1)');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5189-2 : not propagating complex preds to union terms of a dt STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- XXX
select count (*) from
B5189V A where exists (select 1 from B5189V E where E.ID = A.ID - 1);
--ECHO BOTH $IF $EQU $LAST[1] 5 "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG 5189-3 : not propagating complex preds to union terms of a view returned " $LAST[1] "rows\n";

select composite_ref (composite ('Miles','Herbie','Wayne','Ron','Tony'), 0);
ECHO BOTH $IF $EQU $LAST[1] Miles "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5113-1 : composite_ref returned " $LAST[1] "\n";

select composite_ref (composite ('Miles','Herbie','Wayne','Ron','Tony'), -1);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5113-2 : composite_ref neg ofs STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select composite_ref (composite ('Miles','Herbie','Wayne','Ron','Tony'), 5);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5113-3 : composite_ref ofs too large STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop view B5300VV;
drop table B5300_T1;
drop table B5300_T2;
drop table B5300_T3;

create table B5300_T1 (KEY_ID integer primary key);
create table B5300_T2 (KEY_ID integer primary key);
create table B5300_T3 (KEY_ID integer primary key);

insert into B5300_T1 values (1);
insert into B5300_T2 values (1);
insert into B5300_T3 values (1);

create view B5300VV (B) as
select 10000 from
(select distinct B5300_T1.KEY_ID as jc1 from B5300_T1) x
LEFT join B5300_T3 on B5300_T3.KEY_ID = jc1
union all
select 20000 from B5300_T2;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5300 : view created STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select count (*) from B5300VV where B = 1000 or B = 20000;
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5300-2 : pred propagated OK STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select charset_recode (NULL, '_WIDE_', 'UTF-8');
ECHO BOTH $IF $EQU $LAST[1] NULL "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5324 : null from charset_recode (null) OK STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B5010;
create table B5010 (ID integer identity (start with 11, increment by 10), DATA varchar);

insert into B5010 (DATA) values ('a');
insert into B5010 (DATA) values ('b');

select ID from B5010 where DATA = 'a';
ECHO BOTH $IF $EQU $LAST[1] 11 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5010-1 : START WITH on ID col STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select ID from B5010 where DATA = 'b';
ECHO BOTH $IF $EQU $LAST[1] 21 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5010-2 : increment by on ID col STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B5483;
create table B5483 (ID integer PRIMARY KEY);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5483-1 : table created STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

alter table B5483 add D1 integer, D2 integer;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5483-2 : table altered STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- XXX
columns B5483;
--ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG 5483-3 : 3 cols after add col STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

alter table B5483 drop column D1, D2;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5483-4 : table altered STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

columns B5483;
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5483-5 : 1 cols after drop col STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B5579_BAR;
drop table B5579_FOO;

create table B5579_FOO (id integer primary key, snaptime datetime);
create table B5579_BAR (id integer primary key references B5579_FOO, value varchar);

insert into B5579_FOO (id, snaptime) values (1, now());

--
create procedure B5579_BAR0 (in dt datetime)
{
      declare i integer;
      declare sn datetime;
  result_names (i, sn);
  declare cr cursor for
      select B5579_FOO.id, snaptime
      from B5579_FOO left join B5579_BAR on (B5579_FOO.id = B5579_BAR.id)
      where dt is null or snaptime <= dt
      order by snaptime;
  open cr;
  whenever not found goto done;
  while (1)
    {
      fetch cr into i, sn;
      result (i, sn);
    }
done:
  ;
}
;

-- XXX
B5579_BAR0 (null);
--ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG 5579 : oj w/ an ks_setp wrong STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create procedure B5577()
{
  label:
    declare i integer;
};
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG 5577 : label on declare STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

explain ('
create procedure b5952 (in uid int) {
   declare folder varchar;
   select folder into folder from SYS_USERS where U_ID = uid;
 }
');
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": Circular assignment in query STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

explain ('select 1 from SYS_COLS where "TABLE"=? and "TABLE" LIKE \'Demo.demo%\'');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": demo.usnet.private crash STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table GBYNOFREF;
create table GBYNOFREF (ID int primary key, D1 varchar(20));
insert into GBYNOFREF values (1, 'a');
insert into GBYNOFREF values (2, 'aa');
insert into GBYNOFREF values (3, 'aa');
select length (D1) from GBYNOFREF group by D1;
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": GROUP BY without funref and with expression in the select list STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B5942;
create table B5942 (ID int primary key, DATA varchar(20), DATA1 varchar (20));
insert into B5942 values (1, dbname(), dbname());
explain ('select 1 from B5942 where DATA = coalesce (null, dbname()) and DATA1 = coalesce (''DB'', dbname())');
select 1 from B5942 where DATA = coalesce (null, dbname()) and DATA1 = coalesce ('DB', dbname());
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B5942 returned " $ROWCNT " rows STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

explain ('select 1 from B5942 a where coalesce (12, (select 1 from B5942 b, B5942 c table option (hash) where b.ID = c.ID))');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B5942 hash join in coalesce STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- bug 5170
drop module BUG5170.webnew.cookie_mod;

exec ('create module BUG5170.webnew.cookie_mod {
     procedure cookie_time(in _exp integer)  returns varchar
       {
	 return 1;
       };
  }');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B5170 module created STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

sql_parse ('create module BUG5170.webnew.cookie_mod {
     procedure cookie_time(in _exp integer)  returns varchar
       {
	 return 1;
       };
  }');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B5170 module parsed STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- alter table and creater index on the new col right after.
drop table ALTINX;
create table ALTINX (ID int primary key, DATA varchar);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-1 table created STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

insert into ALTINX values (1, 'a');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-2 row added STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

insert into ALTINX values (2, 'b');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-3 row added STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

alter table ALTINX add D2 integer;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-3 column D2 added STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create index ALTINX_D2_IX on ALTINX (D2);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-4 inx on column D2 added STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select * from ALTINX;
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-5 still " $ROWCNT " rows present\n";

statistics ALTINX;
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": ALTINX-6 pk & the inx present STATE\n";


-- bug #6295
drop table B6295;
CREATE TABLE B6295(
  ID integer PRIMARY key,
  ID1 integer,
  ID2 integer,
  name varchar
);

insert into B6295 values(1,1,1,'1');
insert into B6295 values(2,2,2,'2');
insert into B6295 values(3,3,3,'3');
insert into B6295 values(4,4,4,'4');

select * from B6295 where id2 = 2 and 'abv' = 'cde';
ECHO BOTH $IF $EQU $ROWCNT 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B6295-1 : returned " $ROWCNT " rows\n";

select * from B6295 where id2 = 3 and not('abv' = 'cde');
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B6295-2 : returned " $ROWCNT " rows\n";

select * from B6295 where id2 = 2 and 'abv' = 'cde'
union all
select * from B6295 where id2 = 3 and not('abv' = 'cde');
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B6295-3 : returned " $ROWCNT " rows\n";

-- bug #6322
drop table B6322;
create table B6322 (ID INTEGER primary key, DATA varchar);

insert into B6322 values (1, 'DB.DBA.HTTP_PATH');
insert into B6322 values (2, 'DB.DBA.SYS_DAV_RES_FULL_PATH');

insert into B6322 values (3, 'BLOG_COMMENTS_FK');
insert into B6322 values (4, 'SYS_DAV_RES_ID');

select DATA from B6322 where DATA like '%HTTP%' and DATA like '%PATH';
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B6322-1 : returned " $ROWCNT " rows\n";

select DATA from B6322 where DATA <= 'D' and DATA <= 'V';
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B6322-2 : returned " $ROWCNT " rows\n";

explain ('select KEY_ID, count (KEY_ID) from DB.DBA.SYS_KEYS');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": wrong mix of frefs + cols no group by STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create procedure CFOR_TEST ()
{
  declare _sum integer;

  _sum := 0;
  for (declare x any, x := 1; x <= 2 ; x := x + 1)
    {
      _sum := _sum + x;
    }

  if (_sum <> 3)
    signal ('42000', 'FULL FOR not working');

  _sum := 0;
  for (declare x any, x := 1; x <= 2 ; )
    {
      _sum := _sum + x;
      x := x + 1;
    }

  if (_sum <> 3)
    signal ('42000', 'no-inc FOR not working');

  _sum := 0;
  for (declare x any, x := 1; ; x := x + 1)
    {
      if (x > 2)
	goto no_cond_done;
      _sum := _sum + x;
    }
no_cond_done:
  if (_sum <> 3)
    signal ('42000', 'no-cond FOR not working');

  declare inx integer;
  _sum := 0;
  inx := 1;
  for (; inx <= 2 ; inx := inx + 1)
    {
      _sum := _sum + inx;
    }

  if (_sum <> 3)
    signal ('42000', 'no-init FOR not working');
};
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": C Style FOR compiled STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

CFOR_TEST ();
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": C Style FOR working STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create procedure FOREACH_TEST ()
{
  declare xarr any;
  declare _sum integer;
  xarr := vector (1,2);
  _sum := 0;
  foreach (int x in xarr) do
    {
      _sum := _sum + x;
    }
  if (_sum <> 3)
    signal ('42000', 'FOREACH not working');
};
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": FOREACH compiled STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

FOREACH_TEST();
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": FOREACH working STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

use BUG6685;
select * from DB.DBA.SYS_D_STAT;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG6685: SYS_D_STAT from a qual STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
USE DB;

drop table ER1;
create table ER1 (
  id integer primary key,
  txt varchar);

insert into ER1 values(1,'text 1');
insert into ER1 values(2,'text 2');

drop table ER2;
create table ER2 (
  id integer primary key,
  ER1_id integer,
  txt varchar);

insert into ER2 values(1,2,'text 1');
insert into ER2 values(2,1,'text 2');

drop table ER3;
create table ER3 (
  id integer primary key,
  ER1_id integer,
  txt varchar);

insert into ER3 values(1,2,'text 1');

create procedure test_it ()
  {
    declare res any;
    exec ('
	select ER1_txt from (
	    select (select txt from ER1 where ER1.id = ER2.ER1_id) as ER1_txt from ER2
	union all
	    select ''1'' from ER3
        ) x',
	null, null, null, 0, null, res);


   declare has_t1, has_t2, has_one integer;
   has_t1 := has_t2 := has_one := 0;
   declare rs varchar;
   result_names (rs);
   foreach (varchar _row in res) do
     {
       declare x varchar;
       x := _row[0];
       result (x);
       if (x = 'text 1')
	 {
	   if (has_t1)
	     signal ('42000', 'duplicate t1');
	   has_t1 := 1;
	 }
       if (x = 'text 2')
	 {
	   if (has_t2)
	     signal ('42000', 'duplicate t2');
	   has_t2 := 1;
	 }
       if (x = '1')
	 {
	   if (has_one)
	     signal ('42000', 'duplicate one (1)');
	   has_one := 1;
	 }
     }
};


test_it ();
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B7589: deps of scalar exp not placed when in dt STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create procedure B7638 (in sql varchar, in col_no integer := 0)
{
  declare meta any;

  exec (sql, null, null, null, 0, meta);

  declare col_desc any;

  col_desc := meta[0][col_no];

  return col_desc[0];
};

select B7638 ('select 1 as ''COL1''');
ECHO BOTH $IF $EQU $LAST[1] COL1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": b7638: AS aliases as strings w/ AS returned : " $LAST[1] "\n";

select B7638 ('select 1 ''COL1''');
ECHO BOTH $IF $EQU $LAST[1] COL1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": b7638: AS aliases as strings w/o AS returned : " $LAST[1] "\n";

drop table TOP1_SUBQ1;
drop table TOP1_SUBQ2;

create table TOP1_SUBQ1 (t1_id int primary key);
create table TOP1_SUBQ2 (t2_id int primary key, t2_t1_id int);

explain ('select
(
		select
			1
		from
			TOP1_SUBQ1,
			TOP1_SUBQ2
		where
			t1_id = t2_t1_id
			and t2_id = 7
		)
from
	TOP1_SUBQ2', -5);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": TOP 1 optimization to hash in a subq STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

create procedure B8436 (
  in propertyValue varchar)
{
  if (regexp_match('^[0-9]+$', propertyValue) = null)
    return 0;
  return 1;
}
;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": BUG8436: fatal flex error covered STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop view B7590_V1;
drop table B7590_T1;
drop table B7590_T2;
create table B7590_T1 (
  ID integer primary key,
  TXT varchar (20));

insert into B7590_T1 values(1,'a');
insert into B7590_T1 values(2,'b');
insert into B7590_T1 values(3,'c');
insert into B7590_T1 values(4,'d');
insert into B7590_T1 values(5,'e 2');
insert into B7590_T1 values(6,'f 2');
insert into B7590_T1 values(7,'g 2');
insert into B7590_T1 values(8,'t 2');
insert into B7590_T1 values(9,'fd 2');
insert into B7590_T1 values(10,'ed 2');
insert into B7590_T1 values(11,'rt 2');
insert into B7590_T1 values(12,'f 2');
insert into B7590_T1 values(13,'df 2');
insert into B7590_T1 values(14,'text 2');
insert into B7590_T1 values(15,'df 2');
insert into B7590_T1 values(16,'hgf 2');
insert into B7590_T1 values(17,'fg 2');
insert into B7590_T1 values(18,'xcv 2');
insert into B7590_T1 values(19,'cvb 2');
insert into B7590_T1 values(20,'vbn 2');
insert into B7590_T1 values(21,'sdf 2');
insert into B7590_T1 values(22,'sdf 2');
insert into B7590_T1 values(23,'text 2');
insert into B7590_T1 values(24,'cvb 2');
insert into B7590_T1 values(25,'sdf 2');
insert into B7590_T1 values(26,'df 2');
insert into B7590_T1 values(27,'sdf 2');
insert into B7590_T1 values(28,'tesdfxt 2');
insert into B7590_T1 values(29,'s 2');
insert into B7590_T1 values(30,'sdf 2');
insert into B7590_T1 values(31,'sdf 2');
insert into B7590_T1 values(32,'wer 2');
insert into B7590_T1 values(33,'sdf 2');

create table B7590_T2 (
  ID integer primary key,
  t1_id integer,
  TXT varchar (20));

insert into B7590_T2 values(1,2,'text 1');
insert into B7590_T2 values(2,null,'text 2');
insert into B7590_T2 values(3,1,'text 2');
insert into B7590_T2 values(4,null,'text 2');
insert into B7590_T2 values(5,3,'text 2');
insert into B7590_T2 values(6,null,'text 2');
insert into B7590_T2 values(7,4,'text 2');
insert into B7590_T2 values(8,null,'text 2');
insert into B7590_T2 values(9,6,'text 2');
insert into B7590_T2 values(11,null,'text 2');
insert into B7590_T2 values(12,4,'text 2');
insert into B7590_T2 values(13,null,'text 2');
insert into B7590_T2 values(14,6,'text 2');
insert into B7590_T2 values(15,null,'text 2');
insert into B7590_T2 values(16,8,'text 2');
insert into B7590_T2 values(17,null,'text 2');
insert into B7590_T2 values(18,9,'text 2');
insert into B7590_T2 values(19,null,'text 2');
insert into B7590_T2 values(21,11,'text 2');
insert into B7590_T2 values(22,null,'text 2');
insert into B7590_T2 values(23,12,'text 2');
insert into B7590_T2 values(24,null,'text 2');
insert into B7590_T2 values(25,3,'text 2');
insert into B7590_T2 values(26,null,'text 2');
insert into B7590_T2 values(27,13,'text 2');
insert into B7590_T2 values(28,null,'text 2');
insert into B7590_T2 values(29,21,'text 2');
insert into B7590_T2 values(31,null,'text 2');
insert into B7590_T2 values(32,32,'text 2');
insert into B7590_T2 values(33,null,'text 2');
insert into B7590_T2 values(34,12,'text 2');
insert into B7590_T2 values(35,null,'text 2');
insert into B7590_T2 values(36,16,'text 2');
insert into B7590_T2 values(37,null,'text 2');
insert into B7590_T2 values(38,19,'text 2');
insert into B7590_T2 values(39,null,'text 2');
insert into B7590_T2 values(41,10,'text 2');
insert into B7590_T2 values(42,null,'text 2');
insert into B7590_T2 values(43,11,'text 2');
insert into B7590_T2 values(44,null,'text 2');
insert into B7590_T2 values(45,12,'text 2');
insert into B7590_T2 values(46,null,'text 2');
insert into B7590_T2 values(47,14,'text 2');
insert into B7590_T2 values(48,null,'text 2');
insert into B7590_T2 values(49,15,'text 2');
insert into B7590_T2 values(51,null,'text 2');
insert into B7590_T2 values(52,17,'text 2');
insert into B7590_T2 values(53,null,'text 2');
insert into B7590_T2 values(54,21,'text 2');
insert into B7590_T2 values(55,null,'text 2');
insert into B7590_T2 values(56,31,'text 2');
insert into B7590_T2 values(57,null,'text 2');
insert into B7590_T2 values(58,14,'text 2');
insert into B7590_T2 values(59,null,'text 2');
insert into B7590_T2 values(61,10,'text 2');
insert into B7590_T2 values(62,null,'text 2');


create view B7590_V1 (ID,T2_TXT, T1_TXT)
as
select B7590_T2.ID,B7590_T2.TXT,(select TXT from B7590_T1 where B7590_T1.ID = B7590_T2.t1_id)
  from B7590_T2;

-- XXX
select top 11,1 ID,T1_TXT from B7590_V1 order by T1_TXT;
--ECHO BOTH $IF $EQU $LAST[2] NULL "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": BUG5790: nulls sort as normal values (on top) in TOP memsort LAST[2]=" $LAST[2] "\n";

set timeout = 60;
select serialize (xml_tree_doc (concat ('<a>', repeat ('abc', 1000), '&#222;', repeat ('def', 1000), '</a>')));
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": the web hang on myopenlink STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
set timeout = 0;

drop table B8512;
create table B8512 (ID integer primary key, DATA varchar (50));
insert into B8512 values (1, 'Krali Marko');

--select XMLELEMENT ('person',
--		XMLATTRIBUTES (DATA as "name"),
--		XMLAGG  (XMLELEMENT ('sdfd', 'hello'))
--	)
--  from B8512 group by DATA;
--ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": B8512 : XMLATTRIBUTES in a sort hash  STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table CASE_EXISTS1;
create table CASE_EXISTS1 (PK_ID int primary key, DATA varchar (10));
insert into CASE_EXISTS1 (PK_ID, DATA) values (1, 'OK');

drop table CASE_EXISTS2;
create table CASE_EXISTS2 (ID int primary key, FK_ID int);
insert into CASE_EXISTS2 (ID, FK_ID) values (1, 1);
insert into CASE_EXISTS2 (ID, FK_ID) values (2, 2);

select case when (exists (select 1 from CASE_EXISTS1 where PK_ID = FK_ID)) then 1 else 0 end
  from CASE_EXISTS2 where ID = 1;
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": exists in a searched case LAST[1]=" $LAST[1] "\n";

select case when (exists (select 1 from CASE_EXISTS1 where PK_ID = FK_ID)) then 1 else 0 end
  from CASE_EXISTS2 where ID = 2;
ECHO BOTH $IF $EQU $LAST[1] 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": exists in a searched case no match LAST[1]=" $LAST[1] "\n";

select case when (FK_ID < 2 and exists (select 1 from CASE_EXISTS1 where PK_ID = FK_ID) and FK_ID > 0) then 1 else 0 end
  from CASE_EXISTS2 where ID = 1;
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": exists in a searched case with other conds LAST[1]=" $LAST[1] "\n";

select case when (FK_ID > 2 and exists (select 1 from CASE_EXISTS1 where PK_ID = FK_ID) and FK_ID < 0) then 1 else 0 end
  from CASE_EXISTS2 where ID = 1;
ECHO BOTH $IF $EQU $LAST[1] 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": exists in a searched case with other false conds LAST[1]=" $LAST[1] "\n";

drop table B9151_1;
drop table B9151_2;
drop table B9151_3;

create table B9151_1 (ID1 integer primary key, DATA1 integer);
create table B9151_2 (ID2 integer primary key, DATA2 integer);
create table B9151_3 (ID3 integer primary key, DATA3 integer);

explain ('select 1 from B9151_1, B9151_2 table option (hash) where DATA2 = (select 12 from B9151_3) and DATA1 = DATA2 option (order)');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B9151 : hash with merged preds dfe STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B7074;
create table B7074 (ID int primary key, DATA long varchar, DT2 int);

insert into B7074 (ID, DATA, DT2) values (1, repeat ('x', 60000), 1);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B7074-1 : table prepared STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select blob_to_string (DATA) from B7074 order by 1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B7074-3 : can't put long string in a temp tb STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--XXX
--select * from (select blob_to_string (DATA) as DATA long varchar, DT2 from B7074 order by ID) dummy order by DT2;
--ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": B7074-3 : workaround for B7074-2 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B9383;
create table B9383 (ID int primary key, DATA varchar);

insert into B9383 (ID, DATA) values (1, 'cat');
insert into B9383 (ID, DATA) values (2, 'cat');
insert into B9383 (ID, DATA) values (3, 'fish');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B9383-1 : table prepared STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

select ID from B9383 where ID = 1 or DATA = 'cat';
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B9383-2 : OR->UNION, not UNION ALL returned " $ROWCNT " rows\n";


DROP TABLE B9399_1;
DROP TABLE B9399_2;

CREATE TABLE B9399_1(
  ID       INTEGER    NOT NULL,
  NAME     NVARCHAR(255)  NULL,

  CONSTRAINT B9399_1_PK PRIMARY KEY(ID)
);

CREATE TABLE B9399_2(
  ID       INTEGER    NOT NULL,
  NAME       NVARCHAR(30),

  CONSTRAINT B9399_2_PK PRIMARY KEY(ID)
);

INSERT INTO B9399_1(ID,NAME) VALUES(1,N'test');
INSERT INTO B9399_2(ID,NAME) VALUES(1,N'test');

SELECT * FROM B9399_1 T1 left JOIN B9399_2 T2 ON T1.ID = T2.ID and locate ('B', 'A');
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B9399-1 : no outer join preds in contr check returned " $ROWCNT " rows\n";

drop user MIS;
drop table MIS..ORDERS;
create user MIS;
user_set_qualifier ('MIS', 'MIS');
reconnect MIS;

create table ORDERS (ID integer primary key, DATA varchar (200));
reconnect dba;

create index MIS_MIS_ORDERS on MIS..ORDERS (DATA);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": new_tb_name->q_table_name for CREATE INDEX STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- bug #9929
drop table B9929;
create table B9929 (ID integer, TXT varchar);

--select ID from
--  B9929 x1 where exists (
--    select 1 from B9929 x2
--    join B9929 x3 on (x2.ID = x3.ID)
--    join B9929 x4 on (x3.ID = x4.ID)
--    where
--    x2.ID = x1.ID
--    )
--    ;
--ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
--SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
--ECHO BOTH ": B9929 test case STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop procedure B10017;
create procedure B10017 (in x integer)
{
   signal ('22023', 'gotcha');
};

select case when 1 = 2 then B10017 (12) else B10017 (12) end;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B10017 test case STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B10105;
create table B10105 (ID int primary key, DATA varchar);

select 1 as opsys_name  from B10105 where left ('abc', 1)  LIKE  'clr%' and ((0  and  left ('abc', 1)  LIKE  'jvm%' ) or  (12 and left ('abc', 1)  LIKE  'clr%' ));
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B10105 test case STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

drop table B10317;
create table B10317 (DATA varchar);

insert into B10317 (DATA) values (NULL);
select count(*), MIN (DATA), MAX(DATA) from B10317;
ECHO BOTH $IF $EQU $LAST[1] 1 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B10317-1 there is " $LAST[1] " row\n";
ECHO BOTH $IF $EQU $LAST[2] NULL "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B10317-2 MIN is " $LAST[2] "\n";
ECHO BOTH $IF $EQU $LAST[3] NULL "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": B10317-3 MAX is " $LAST[3] "\n";


create view t1order as select row_no, string1, string2 from t1 order by row_no;

select top 2 * from t1order where row_no is null or row_no > 111;

echo both $if $equ $last[1] 113 "PASSED" "***FAILED";
echo both "or of known false in dt predf import\n";

select top 2 * from t1order a where row_no is null or exists (select 1 from t1order b where a.row_no = 1 + b.row_no);

select count (*) from t1 where row_no = 111 or (row_no  is not null and (row_no is null or row_no = 222));
select count (*) from t1 where row_no = 111 or (row_no  is null and (row_no is null or row_no = 222));


-- hash fillers with hash joined existences
explain ('select count (*) from t1 a, t1 b where a.row_no = b.row_no and exists (select * from t1 c table option (hash) where c.row_no = b.row_no and c.string1 like ''1%'') option (order, hash)');
select count (*) from t1 a, t1 b where a.row_no = b.row_no and exists (select * from t1 c table option (hash) where c.row_no = b.row_no and c.string1 like '1%') option (order, hash);
echo both $if $equ $last[1] 353 "PASSED" "***FAILED";
echo both ": hash join with filter with hash filler with hashed exists\n";

select count (*) from t1 a, t1 b where a.row_no = b.row_no and exists (select * from t1 c table option (loop) where c.row_no = b.row_no and c.string1 like '1%') option (order, loop);
echo both $if $equ $last[1] 353 "PASSED" "***FAILED";
echo both ": verify above with ibid with loop\n";


sparql insert into <urn:test> { <#s> <#p> <#o> };
create procedure sslvar_test()
{
  declare var any;
  var := 'test';
  result_names (var);
  for (sparql select distinct ?test from <urn:test> where { ?s ?p ?o . BIND(?:var as ?test) . } order by ?s) do
    {
      result ("test");
    }
}
;

sslvar_test();
ECHO BOTH $IF $EQU $LAST[1] 'test' "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": var out of query scope in distinct/oby: " $LAST[1] "\n";


-- 1117.sql
-- XXX: SELECT table_name as name, 'TABLE' as type, '' as parentname FROM information_schema.tables UNION SELECT column_name as name, data_type as type, table_name as parentname FROM information_schema.columns;
select 1;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1117 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

-- 1118.sql
drop table test_table_t2 if exists;
CREATE TABLE test_table_t2(x VARCHAR, y VARCHAR, c VARCHAR);
CREATE VIEW test_table_t2 AS SELECT * FROM test_table_t2;
INSERT INTO test_table_t2 VALUES(8,8,RDF_SYS.xsd_hexBinary_fromBinary(SYSTEM_BASE64_ENCODE(zeroblob(200))));
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1118 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1119.sql
CREATE TABLE hist (
  cnt VARCHAR NOT NULL,
  y VARCHAR NOT NULL,
  z VARCHAR,
  PRIMARY KEY (cnt,y)
);
CREATE TABLE t19d AS (SELECT * FROM hist UNION ALL SELECT 1234);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1119 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1120.sql
CREATE TABLE test_table_t1(x VARCHAR, k VARCHAR);
CREATE INDEX t1i1 ON test_table_t1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255,c256,c257,c258,c259,c260,c261,c262,c263,c264,c265,c266,c267,c268,c269,c270,c271,c272,c273,c274,c275,c276,c277,c278,c279,c280,c281,c282,c283,c284,c285,c286,c287,c288,c289,c290,c291,c292,c293,c294,c295,c296,c297,c298,c299,c300,c301,c302,c303,c304,c305,c306,c307,c308,c309,c310,c311,c312,c313,c314,c315,c316,c317,c318,c319,c320,c321,c322,c323,c324,c325,c326,c327,c328,c329,c330,c331,c332,c333,c334,c335,c336,c337,c338,c339,c340,c341,c342,c343,c344,c345,c346,c347,c348,c349,c350,c351,c352,c353,c354,c355,c356,c357,c358,c359,c360,c361,c362,c363,c364,c365,c366,c367,c368,c369,c370,c371,c372,c373,c374,c375,c376,c377,c378,c379,c380,c381,c382,c383,c384,c385,c386,c387,c388,c389,c390,c391,c392,c393,c394,c395,c396,c397,c398,c399,c400,c401,c402,c403,c404,c405,c406,c407,c408,c409,c410,c411,c412,c413,c414,c415,c416,c417,c418,c419,c420,c421,c422,c423,c424,c425,c426,c427,c428,c429,c430,c431,c432,c433,c434,c435,c436,c437,c438,c439,c440,c441,c442,c443,c444,c445,c446,c447,c448,c449,c450,c451,c452,c453,c454,c455,c456,c457,c458,c459,c460,c461,c462,c463,c464,c465,c466,c467,c468,c469,c470,c471,c472,c473,c474,c475,c476,c477,c478,c479,c480,c481,c482,c483,c484,c485,c486,c487,c488,c489,c490,c491,c492,c493,c494,c495,c496,c497,c498,c499,c500,c501,c502,c503,c504,c505,c506,c507,c508,c509,c510,c511,c512,c513,c514,c515,c516,c517,c518,c519,c520,c521,c522,c523,c524,c525,c526,c527,c528,c529,c530,c531,c532,c533,c534,c535,c536,c537,c538,c539,c540,c541,c542,c543,c544,c545,c546,c547,c548,c549,c550,c551,c552,c553,c554,c555,c556,c557,c558,c559,c560,c561,c562,c563,c564,c565,c566,c567,c568,c569,c570,c571,c572,c573,c574,c575,c576,c577,c578,c579,c580,c581,c582,c583,c584,c585,c586,c587,c588,c589,c590,c591,c592,c593,c594,c595,c596,c597,c598,c599,c600,c601,c602,c603,c604,c605,c606,c607,c608,c609,c610,c611,c612,c613,c614,c615,c616,c617,c618,c619,c620,c621,c622,c623,c624,c625,c626,c627,c628,c629,c630,c631,c632,c633,c634,c635,c636,c637,c638,c639,c640,c641,c642,c643,c644,c645,c646,c647,c648,c649,c650,c651,c652,c653,c654,c655,c656,c657,c658,c659,c660,c661,c662,c663,c664,c665,c666,c667,c668,c669,c670,c671,c672,c673,c674,c675,c676,c677,c678,c679,c680,c681,c682,c683,c684,c685,c686,c687,c688,c689,c690,c691,c692,c693,c694,c695,c696,c697,c698,c699,c700,c701,c702,c703,c704,c705,c706,c707,c708,c709,c710,c711,c712,c713,c714,c715,c716,c717,c718,c719,c720,c721,c722,c723,c724,c725,c726,c727,c728,c729,c730,c731,c732,c733,c734,c735,c736,c737,c738,c739,c740,c741,c742,c743,c744,c745,c746,c747,c748,c749,c750,c751,c752,c753,c754,c755,c756,c757,c758,c759,c760,c761,c762,c763,c764,c765,c766,c767,c768,c769,c770,c771,c772,c773,c774,c775,c776,c777,c778,c779,c780,c781,c782,c783,c784,c785,c786,c787,c788,c789,c790,c791,c792,c793,c794,c795,c796,c797,c798,c799,c800,c801,c802,c803,c804,c805,c806,c807,c808,c809,c810,c811,c812,c813,c814,c815,c816,c817,c818,c819,c820,c821,c822,c823,c824,c825,c826,c827,c828,c829,c830,c831,c832,c833,c834,c835,c836,c837,c838,c839,c840,c841,c842,c843,c844,c845,c846,c847,c848,c849,c850,c851,c852,c853,c854,c855,c856,c857,c858,c859,c860,c861,c862,c863,c864,c865,c866,c867,c868,c869,c870,c871,c872,c873,c874,c875,c876,c877,c878,c879,c880,c881,c882,c883,c884,c885,c886,c887,c888,c889,c890,c891,c892,c893,c894,c895,c896,c897,c898,c899,c900,c901,c902,c903,c904,c905,c906,c907,c908,c909,c910,c911,c912,c913,c914,c915,c916,c917,c918,c919,c920,c921,c922,c923,c924,c925,c926,c927,c928,c929,c930,c931,c932,c933,c934,c935,c936,c937,c938,c939,c940,c941,c942,c943,c944,c945,c946,c947,c948,c949,c950,c951,c952,c953,c954,c955,c956,c957,c958,c959,c960,c961,c962,c963,c964,c965,c966,c967,c968,c969,c970,c971,c972,c973,c974,c975,c976,c977,c978,c979,c980,c981,c982,c983,c984,c985,c986,c987,c988,c989,c990,c991,c992,c993,c994,c995,c996,c997,c998,c999,c1000);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1120 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1121.sql
drop table test_table_t1 if exists;
drop table test_table_t2 if exists;
CREATE TABLE test_table_t1 (c1 INT, c2 BINARY(100),c3 FLOAT);
INSERT INTO test_table_t1 VALUES (100,'abcdefghij',3.0);
CREATE TABLE test_table_t2 (c1 INT, c2 VARCHAR(100));
INSERT INTO test_table_t2 VALUES (2,'abcde');
UPDATE test_table_t1 SET c2 = (SELECT MAX(c1) FROM test_table_t2);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1121 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1122.sql
SELECT MOD(-9223372036854775808, -1);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1122 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1123.sql
SELECT CAST('-9223372036854775808' AS INTEGER) / CAST('-1' AS SMALLINT);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1123 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1124.sql
drop table test_table_t1 if exists;
drop table test_table_k if exists;
CREATE TABLE test_table_t1(x INTEGER UNIQUE);
CREATE TABLE test_table_k(v varchar(255), excluded varchar(255));

INSERT INTO test_table_t1(x, x, x, x, x, x, x) VALUES(16183,15638,6,0,5,2,0);
-- XXX: SELECT 'one', test_table_t1.* FROM test_table_t1 LEFT JOIN test_table_k ON test_table_t1.x=test_table_k.v WHERE test_table_k.v IS NULL;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1124 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1125.sql
drop table test_table_t1 if exists;
CREATE TABLE test_table_t1 (
    x VARCHAR,
    y VARCHAR
 );
SELECT IFNULL(MIN(x), -1), IFNULL(MAX(x), -1)
FROM (
  SELECT x FROM test_table_t1 UNION ALL
  SELECT NULL
) AS temp;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1125 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1126.sql
drop table test_table_b if exists;
CREATE TABLE test_table_b (
      folders VARCHAR(80),
      folderid VARCHAR(80),
      parentid VARCHAR(80),
      rootid VARCHAR(80),
      c INTEGER,
      path VARCHAR(80),
      id VARCHAR(80),
      i VARCHAR(80),
      d VARCHAR(80),
      e VARCHAR(80),
      f VARCHAR(80)
    );

SELECT case test_table_b.d when coalesce((select max(17+coalesce((select max(coalesce((select (select count(distinct case f when 19 then coalesce((select coalesce((select max(11-(abs(d)/abs(11))) from test_table_b where not  -c in (19,test_table_b.d,17)),17) from test_table_b where (f in (d,f,test_table_b.c))),d) else d end) from test_table_b) from test_table_b where 17 between e and test_table_b.f),test_table_b.c)) from test_table_b where 13>=e),d)) from test_table_b where test_table_b.f>test_table_b.f),test_table_b.d) then 17 else test_table_b.f end FROM test_table_b WHERE not exists(select 1 from test_table_b where 13 between c+17 and (test_table_b.id));
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1126 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1127.sql
drop table test_table_b if exists;
CREATE TABLE test_table_b (
      folders VARCHAR(80),
      folderid VARCHAR(80),
      parentid VARCHAR(80),
      rootid VARCHAR(80),
      c INTEGER,
      path VARCHAR(80),
      id VARCHAR(80),
      i VARCHAR(80),
      d VARCHAR(80),
      e VARCHAR(80),
      f VARCHAR(80)
    );
SELECT  -(coalesce((select max(coalesce((select test_table_b.f from test_table_b where not exists(select 1 from test_table_b where (abs(+rootid+19+19)/abs(test_table_b.rootid))<test_table_b.rootid) or 19+f>=(select  -max(19) from test_table_b)+test_table_b.f),test_table_b.e+test_table_b.f)* -test_table_b.e+19-f) from test_table_b where (( -test_table_b.id<19) or d>=id)),test_table_b.id))*id*((test_table_b.rootid))-17 FROM test_table_b WHERE NOT (test_table_b.e not between test_table_b.f*id and test_table_b.f+ -d);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1127 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1128.sql
drop table element if exists;
CREATE TABLE element (
      name VARCHAR(80),
      test1 VARCHAR(80),
      f1 VARCHAR(80),
      f2 VARCHAR(80),
      code INTEGER,
      test_table_t1 VARCHAR(80),
      a VARCHAR(80),
      example VARCHAR(80),
      b VARCHAR(80),
      c VARCHAR(80),
      folders VARCHAR(80)
    );
INSERT INTO element(b,b) VALUES(38,1444);
-- XXX: SELECT (select ( -count(distinct case case code when b then c*case when b<=element.b+b then code when (abs(element.c)/abs(case when b-coalesce((select max(element.c-element.b) from element where not exists(select 1 from element where 17 in (b,13,(b)) or b in (b,c,element.b))),element.b) not in (b,((c)),element.b) then  -19 when c between code and 13 then 19 else element.c end))=13 then c else 13 end else 17 end when 13 then element.c else element.b end-element.c)) from element) FROM element WHERE coalesce((select max(element.b) from element where element.c<>element.c-13),element.code)>=b or b*coalesce((select max((b)) from element where c not between +coalesce((select max(13) from element where b between  -(abs(( -coalesce((select max(case c when element.c then b else  -element.c end) from element where 11>b and element.b<element.b),element.c)))/abs(b)) and b),code) and element.b),element.b)* -19 not between (17) and element.c and (element.b<=code);
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1128 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1129.sql
drop table test_table_t4 if exists;
CREATE TABLE test_table_t4 (
  a VARCHAR,
  b VARCHAR
);
SELECT MIN(b), MIN(b) FROM test_table_t4;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1129 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1130.sql
drop table brin_test if exists;
CREATE TABLE brin_test(a INTEGER NOT NULL);
INSERT INTO brin_test (a) VALUES(5);
INSERT INTO brin_test (a) VALUES(5); 
ALTER TABLE brin_test ADD c1 VARCHAR(20)  NOT NULL ;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1130 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
UPDATE brin_test SET a = a + 1 WHERE a = 5;
-- 1131.sql
drop table test_table_t1 if exists;
CREATE TABLE test_table_t1(
    x INTEGER PRIMARY KEY,
    k VARCHAR
  );
CREATE VIEW test_table_t1 AS SELECT k, k FROM test_table_t1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1131 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
UPDATE test_table_t1 SET k = k-1 WHERE k > 100 AND x = 128;
-- 1132.sql
drop table test_table_t1 if exists;
CREATE TABLE test_table_t1 (
    x LONG VARCHAR,
    a INTEGER DEFAULT 0,
    b LONG VARCHAR,
    test_table_t2 LONG VARCHAR
);
CREATE VIEW test_table_t1 AS SELECT * FROM test_table_t1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1132 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
INSERT INTO test_table_t1(test_table_t2, x, x) VALUES('one-toasted,one-null', '', repeat('1234567890',50000));
-- 1133.sql
drop table test_table_t1 if exists;
CREATE TABLE test_table_t1(x VARCHAR, k VARCHAR, v VARCHAR);
CREATE VIEW test_table_t1 AS SELECT x, x FROM test_table_t1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1133 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
UPDATE test_table_t1 SET x = x + 100;
-- 1134.sql
drop table base_tbl if exists;
drop view rw_view1;
CREATE TABLE base_tbl (a int, b int);
CREATE VIEW rw_view1 AS SELECT * FROM base_tbl;
INSERT INTO rw_view1 VALUES (15);
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1134 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1135.sql
DELETE FROM ucview WHERE CURRENT OF c1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1135 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1136.sql
SELECT SUM(v), COUNT(*) FROM gstest_empty
UNION ALL
SELECT SUM(v), NULL FROM gstest_empty
UNION ALL
SELECT NULL, COUNT(*) FROM gstest_empty
UNION ALL
SELECT NULL, NULL
;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1136 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1137.sql
drop table test_table_t1 if exists;
CREATE VIEW test_table_t1(a) AS SELECT 1;
SELECT a, a, a FROM test_table_t1 WHERE a IN (1,5) AND a IN (9,8,3025,1000,3969)
       ORDER BY a, a DESC;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1137 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1138.sql
drop table mvtest_pdt1 if exists;
CREATE TABLE mvtest_pdt1 AS (SELECT 1 AS col1) WITH DATA;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1138 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1139.sql
drop table test_table_t2 if exists;
create table test_table_t2 (x int, y int);
SELECT CASE WHEN EXISTS (SELECT 1 FROM test_table_t2 WHERE x=1 INTERSECT SELECT 1 FROM test_table_t2 WHERE y=2) THEN 1 ELSE 0 END;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1139 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1140.sql
CREATE TABLE test_table_t1 (
  a varchar(255) DEFAULT NULL
);
SELECT * FROM test_table_t1 WHERE CONTAINS(*, 'tutorial & (mysql & -VÐƷWİ)');
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1140 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
-- 1141.sql
drop table test_table_t1 if exists;
CREATE TABLE test_table_t1 (
  x VARCHAR,
  k VARCHAR
);
CREATE VIEW test_table_t1 AS SELECT x, k FROM test_table_t1;
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": #1141 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";
INSERT INTO test_table_t1 VALUES ('x', 'y');

sparql clear graph <urn:gby:flt>;

ttlp('
<http://dbpedia.org/resource/Tryggve_Point>	<http://www.w3.org/2003/01/geo/wgs84_pos#lat>	"-77.65"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Boyle_Mountains>	<http://www.w3.org/2003/01/geo/wgs84_pos#lat>	"-67.35"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Boyle_Mountains>	<http://www.w3.org/2003/01/geo/wgs84_pos#long>	"-66.6333"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Museum_of_Geology,_Tashkent>	<http://www.w3.org/2003/01/geo/wgs84_pos#lat>	"41.3004"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Cassini_Glacier>	<http://www.w3.org/2003/01/geo/wgs84_pos#long>	"163.817"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Botijas>	<http://www.w3.org/2003/01/geo/wgs84_pos#lat>	"18.2243"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Cassini_Glacier>	<http://www.w3.org/2003/01/geo/wgs84_pos#lat>	"-77.9"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Tryggve_Point>	<http://www.w3.org/2003/01/geo/wgs84_pos#long>	"166.7"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Museum_of_Geology,_Tashkent>	<http://www.w3.org/2003/01/geo/wgs84_pos#long>	"69.2785"^^<http://www.w3.org/2001/XMLSchema#float> .
<http://dbpedia.org/resource/Botijas>	<http://www.w3.org/2003/01/geo/wgs84_pos#long>	"-66.3634"^^<http://www.w3.org/2001/XMLSchema#float> .
', '', 'urn:gby:flt');


SPARQL
SELECT ?subject ?float1 (sum(?float2) as ?float2Sum)
FROM <urn:gby:flt>
WHERE {
  {
    select ?subject where {
      ?subject <http://www.w3.org/2003/01/geo/wgs84_pos#lat> []
    } group by ?subject HAVING(count(*) = 1)
  }
  ?subject <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?float1 ,
      ?float2 .
}
GROUP BY ?subject ?float1 ORDER BY ?subject
LIMIT 4
;

ECHO BOTH $IF $EQU $LAST[2] $LAST[3] "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": gby/float \n";

drop table tstr;
drop type tp1;
create type tp1 as (x any) self as ref
constructor method tp1(i int);
create constructor method tp1 (in i int) for tp1 {
  self.x := i;
};
create table tstr (id varchar primary key, dt varchar);
insert soft tstr values ('1', 'xx');

select dt from tstr where id = tp1(1).x;
ECHO BOTH $IF $EQU $LAST[1] "xx" "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": any param cast to string col match \n";
select dt from tstr where id = tp1(2).x;
ECHO BOTH $IF $EQU $ROWCNT 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": any param cast to string col not match returned " $ROWCNT " rows\n";
select dt from tstr where id = tp1(null).x;
ECHO BOTH $IF $EQU $ROWCNT 0 "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": any null param cast to string col not match returned " $ROWCNT " rows\n";

create table utfflag (id bigint primary key, str0 varchar, str1 varchar, str2 varchar);
insert into utfflag values (1, xenc_rand_bytes(16,1), null, null);
update utfflag set str0 = xenc_rand_bytes(10,1), str1 = __box_flags_tweak (xenc_rand_bytes(16,1),2), str2 = __box_flags_tweak(xenc_rand_bytes(16,1),2) 
    where id = 1;
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": update with box_flags=2 STATE=" $STATE " MESSAGE=" $MESSAGE "\n";


select count(*) from WS.WS.SYS_DAV_RES where contains(RES_CONTENT,
        'Lite and (jdbc or odbc) and (installation and not "configur*" and (windows or macos))');
ECHO BOTH $IF $EQU $STATE OK "PASSED" "***FAILED";
SET ARGV[$LIF] $+ $ARGV[$LIF] 1;
ECHO BOTH ": not-mergeble NOT text pred STATE=" $STATE " MESSAGE=" $MESSAGE "\n";

--
-- End of test
--
ECHO BOTH "COMPLETED: SQL Optimizer tests part 2 (sqlo2.sql) WITH " $ARGV[0] " FAILED, " $ARGV[1] " PASSED\n\n";
