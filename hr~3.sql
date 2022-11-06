drop table alunos cascade constraint;
CREATE TABLE alunos(
    id      number(6)    not null, 
    nome    varchar2(50) not null,
    status  varchar2(1)  default 'N' constraint alunos_status_ck CHECK (status in ('S', 'N')) not null 
);

ALTER TABLE alunos
ADD CONSTRAINT pk_alunos PRIMARY KEY (id);

drop sequence seq_alunos;
CREATE SEQUENCE seq_alunos
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 99999
    MINVALUE 1
;

drop table usuarios cascade constraint;
CREATE TABLE usuarios(
    username varchar2(10) not null,
    permissao varchar2(1) default 'c' constraint usuarios_permissao_pk CHECK (permissao in ('C', 'A')) not null
);

ALTER TABLE usuarios
ADD CONSTRAINT pk_usuarios PRIMARY KEY (username);

insert into usuarios values ('HR', 'C');
insert into usuarios values ('ADMIN', 'A');

CREATE OR REPLACE TRIGGER alunos_id 
BEFORE INSERT ON alunos
FOR EACH ROW
BEGIN
    :new.id := seq_alunos.nextval;
END;
/

create or replace NONEDITIONABLE TRIGGER STATUS_ALUNO
BEFORE DELETE OR UPDATE ON alunos
FOR EACH ROW
DECLARE
    v_permissao varchar2(1);

BEGIN
    SELECT permissao INTO v_permissao FROM usuarios WHERE upper(username) = upper(user);

    IF v_permissao = 'C' AND :old.status = 'S' then
        raise_application_error(-20000,'Não é possivel modificar os dados de um aluno Finalizado');
    ELSIF v_permissao = 'A' AND :old.status = 'S' AND DELETING then 
        raise_application_error(-20000,'Não é possivel deletar os dados de um aluno Finalizado');
    END IF;

END;
/

DROP USER "ADMIN" CASCADE;
CREATE USER "ADMIN" IDENTIFIED BY "123"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

GRANT "DBA" TO "ADMIN" ;
GRANT "CONNECT" TO "ADMIN" ;
GRANT "RESOURCE" TO "ADMIN" ;

GRANT CREATE ROLE TO "ADMIN" ;
GRANT CREATE TRIGGER TO "ADMIN" ;
GRANT ALTER SESSION TO "ADMIN" ;
GRANT CREATE VIEW TO "ADMIN" ;
GRANT CREATE SESSION TO "ADMIN" ;
GRANT CREATE RULE TO "ADMIN" ;
GRANT CREATE TABLE TO "ADMIN" ;
GRANT CREATE TYPE TO "ADMIN" ;
GRANT CREATE TABLESPACE TO "ADMIN" ;
GRANT ALTER USER TO "ADMIN" ;
GRANT CREATE SEQUENCE TO "ADMIN" ;
GRANT CREATE USER TO "ADMIN" ;
GRANT ALTER TABLESPACE TO "ADMIN" ;
GRANT DROP USER TO "ADMIN" ;
GRANT ALTER SYSTEM TO "ADMIN" ;
GRANT DROP TABLESPACE TO "ADMIN" ;

connect ADMIN/123@localhost:1521/xepdb1

insert into alunos(nome) values('roberto');
insert into alunos(nome) values('daniel');

update alunos set status= 'S' where id = 2; 

select * from alunos;

delete alunos where id = 2;