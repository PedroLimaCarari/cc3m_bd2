CREATE TABLE alunos(
    id      number(6)    not null, 
    nome    varchar2(50) not null,
    status  varchar2(1)  default 'N' constraint alunos_status_ck CHECK (status in ('S', 'N')) not null 
);

ALTER TABLE alunos
ADD CONSTRAINT pk_alunos PRIMARY KEY (id);

CREATE SEQUENCE seq_alunos
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 99999
    MINVALUE 1
;

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

CREATE USER "ADMIN" IDENTIFIED BY "123";
GRANT SELECT, UPDATE, INSERT, DELETE ON system.alunos to ADMIN;
GRANT CREATE SESSION TO "ADMIN";

insert into alunos(nome) values('roberto');
insert into alunos(nome) values('daniel');

connect ADMIN/123@localhost:1521/xepdb1

update system.alunos set status= 'S' where id = 2; 

select * from system.alunos;

delete system.alunos where id = 2;