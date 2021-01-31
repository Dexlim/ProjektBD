CREATE TABLE dane_kontaktowe (
    id_danych_kontaktowych  NUMBER NOT NULL,
    telefon                 VARCHAR2(25),
    email                   VARCHAR2(100),
    wojewodztwo             VARCHAR2(50),
    miejscowosc                  VARCHAR2(100) NOT NULL,
    adres                   VARCHAR2(150) NOT NULL,
    kod_pocztowy            VARCHAR2(15)
);

ALTER TABLE dane_kontaktowe ADD CONSTRAINT dane_kontaktowe_pk PRIMARY KEY ( id_danych_kontaktowych );

CREATE TABLE dostawa (
    id_dostawy       NUMBER NOT NULL,
    data_dostawy     DATE DEFAULT sysdate NOT NULL,
    cena_dostawy     NUMERIC(12, 2) NOT NULL,
    ilosc_produktow  NUMBER NOT NULL,
    id_sklepu        NUMBER NOT NULL
);

ALTER TABLE dostawa ADD CONSTRAINT dostawa_pk PRIMARY KEY ( id_dostawy );

CREATE TABLE kategoria (
    id_kategorii     NUMBER NOT NULL,
    nazwa_kategorii  VARCHAR2(100) NOT NULL
);

ALTER TABLE kategoria ADD CONSTRAINT kategoria_pk PRIMARY KEY ( id_kategorii );

CREATE TABLE klient (
    id_klienta    NUMBER NOT NULL,
    imie          VARCHAR2(150) NOT NULL,
    nazwisko      VARCHAR2(150) NOT NULL,
    miejscowosc        VARCHAR2(150) NOT NULL,
    adres         VARCHAR2(250) NOT NULL,
    kod_pocztowy  VARCHAR2(20) NOT NULL,
    telefon       VARCHAR2(25),
    email         VARCHAR2(100) NOT NULL
);

ALTER TABLE klient ADD CONSTRAINT klient_pk PRIMARY KEY ( id_klienta );

CREATE TABLE pracownik (
    id_pracownika  NUMBER NOT NULL,
    imie           VARCHAR2(50) NOT NULL,
    nazwisko       VARCHAR2(50) NOT NULL,
    status         VARCHAR2(20) NOT NULL,
    pracowal_od    DATE DEFAULT '2019/01/01' NOT NULL,
    pracowal_do    DATE DEFAULT NULL,
    wynagrodzenie  NUMERIC(12, 2),
    telefon        VARCHAR2(25),
    email          VARCHAR2(100),
    id_sklepu      NUMBER NOT NULL
);
ALTER TABLE pracownik ADD CONSTRAINT pracownik_pk PRIMARY KEY ( id_pracownika );
ALTER TABLE pracownik ADD CONSTRAINT status_chk CHECK(status in ('Nie pracujacy','Pracujacy'));

CREATE TABLE producent (
    id_producenta     NUMBER NOT NULL,
    nazwa_producenta  VARCHAR2(100) NOT NULL
);

ALTER TABLE producent ADD CONSTRAINT producent_pk PRIMARY KEY ( id_producenta );

CREATE TABLE produkt (
    id_produktu         NUMBER NOT NULL,
    nazwa_produktu      VARCHAR2(150) NOT NULL,
    cena                NUMERIC(12, 2) NOT NULL,
    id_kategorii        NUMBER,
    id_producenta       NUMBER,
    marza               NUMERIC(3,2) DEFAULT 0.30 NOT NULL
);

ALTER TABLE produkt ADD CONSTRAINT produkt_pk PRIMARY KEY ( id_produktu );

CREATE TABLE Produkt_dostawa (
    id_produktu  NUMBER NOT NULL,
    id_dostawy   NUMBER NOT NULL
);

ALTER TABLE Produkt_dostawa ADD CONSTRAINT "Produkt-Dostawa_PK" PRIMARY KEY ( id_produktu,
                                                                                id_dostawy );

CREATE TABLE sklep (
    id_sklepu               NUMBER NOT NULL,
    nazwa_sklepu            VARCHAR2(200),
    id_danych_kontaktowych  NUMBER NOT NULL
);

CREATE UNIQUE INDEX sklep__idx ON
    sklep (
        id_danych_kontaktowych
    ASC );

ALTER TABLE sklep ADD CONSTRAINT sklep_pk PRIMARY KEY ( id_sklepu );

CREATE TABLE zamowienie (
    id_zamowienia              NUMBER NOT NULL,
    data_zamowienia            DATE DEFAULT SYSDATE NOT NULL,
    przewidywana_data_dostawy  DATE DEFAULT SYSDATE+3,
    data_dostawy               DATE,
    status                     VARCHAR2(20) DEFAULT 'Nie dostarczono' NOT NULL,
    id_klienta                 NUMBER NOT NULL,
    id_sklepu                  NUMBER NOT NULL,
    id_pracownika              NUMBER
);

ALTER TABLE zamowienie ADD CONSTRAINT zamowienie_pk PRIMARY KEY ( id_zamowienia );
ALTER TABLE zamowienie ADD CONSTRAINT status_chk2 CHECK(status in ('Nie dostarczono','Dostarczono'));

CREATE TABLE zamowienie_produkt (
    id_zamowienia  NUMBER NOT NULL,
    id_produktu       NUMBER NOT NULL
);


CREATE TABLE zapas (
    ilosc        NUMBER DEFAULT 0 NOT NULL,
    id_sklepu     NUMBER NOT NULL,
    id_produktu  NUMBER NOT NULL
);
alter table zapas
add constraint zapas_pk primary key (id_sklepu,id_produktu);

ALTER TABLE sklep
    ADD CONSTRAINT dane_kontaktowe_fk FOREIGN KEY ( id_danych_kontaktowych )
        REFERENCES dane_kontaktowe ( id_danych_kontaktowych );

ALTER TABLE produkt
    ADD CONSTRAINT kategoria_fk FOREIGN KEY ( id_kategorii )
        REFERENCES kategoria ( id_kategorii )
            ON DELETE SET NULL;
            

ALTER TABLE zamowienie
    ADD CONSTRAINT klient_fk FOREIGN KEY ( id_klienta )
        REFERENCES klient ( id_klienta )
            ON DELETE CASCADE;

ALTER TABLE zamowienie
    ADD CONSTRAINT pracownik_fk FOREIGN KEY ( id_pracownika )
        REFERENCES pracownik ( id_pracownika )
            ON DELETE SET NULL;

ALTER TABLE produkt
    ADD CONSTRAINT producent_fk FOREIGN KEY ( id_producenta )
        REFERENCES producent ( id_producenta )
            ON DELETE SET NULL;

ALTER TABLE zapas
    ADD CONSTRAINT produkt_fk FOREIGN KEY ( id_produktu )
        REFERENCES produkt ( id_produktu )
            ON DELETE CASCADE;

ALTER TABLE produkt_dostawa
    ADD CONSTRAINT produkt_dostawa_dostawa_fk FOREIGN KEY ( id_dostawy )
        REFERENCES dostawa ( id_dostawy )
            ON DELETE CASCADE;

ALTER TABLE produkt_dostawa
    ADD CONSTRAINT produkt_dostawa_produkt_fk FOREIGN KEY ( id_produktu )
        REFERENCES produkt ( id_produktu );


ALTER TABLE dostawa
    ADD CONSTRAINT sklep_fk FOREIGN KEY ( id_sklepu )
        REFERENCES sklep ( id_sklepu )
            ON DELETE CASCADE;

ALTER TABLE pracownik
    ADD CONSTRAINT sklep_fkv1 FOREIGN KEY ( id_sklepu )
        REFERENCES sklep ( id_sklepu )
            ON DELETE CASCADE;

ALTER TABLE zapas
    ADD CONSTRAINT sklep_fkv2 FOREIGN KEY ( id_sklepu )
        REFERENCES sklep ( id_sklepu )
            ON DELETE CASCADE;

ALTER TABLE zamowienie
    ADD CONSTRAINT sklep_fkv3 FOREIGN KEY ( id_sklepu )
        REFERENCES sklep ( id_sklepu )
            ON DELETE CASCADE;

ALTER TABLE zamowienie_produkt
    ADD CONSTRAINT zamowienie_posr_produkt_fk FOREIGN KEY ( id_zamowienia )
        REFERENCES zamowienie ( id_zamowienia )
            ON DELETE CASCADE;

ALTER TABLE zamowienie_produkt
    ADD CONSTRAINT zamowienie_produkt_produkt_fk FOREIGN KEY ( id_produktu )
        REFERENCES produkt ( id_produktu );
            
create or replace FUNCTION get_quarter (p_date IN DATE)
RETURN VARCHAR2
AS
l_qtr VARCHAR2(3);
l_month NUMBER;
BEGIN
l_month := TO_CHAR (p_date, 'mm');
IF l_month IN (1, 2, 3)
THEN
l_qtr := 'I';
ELSIF l_month IN (4, 5, 6)
THEN
l_qtr := 'II';
ELSIF l_month IN (7, 8, 9)
THEN
l_qtr := 'III';
ELSIF l_month IN (10, 11, 12)
THEN
l_qtr := 'IV';
END IF;
RETURN l_qtr;
END get_quarter;
/
create or replace function get_month_name(p_date in date)
return varchar2
as
l_month_name varchar2(20);
l_month number;
begin
l_month := to_char(p_date,'mm');
if l_month = 1
then
l_month_name := 'Styczen';
elsif l_month = 2
then
l_month_name := 'Luty';
elsif l_month = 3
then
l_month_name := 'Marzec';
elsif l_month = 4
then
l_month_name := 'Kwiecien';
elsif l_month = 5
then
l_month_name := 'Maj';
elsif l_month = 6
then
l_month_name := 'Czerwiec';
elsif l_month = 7
then
l_month_name := 'Lipiec';
elsif l_month = 8
then
l_month_name := 'Sierpien';
elsif l_month = 9
then
l_month_name := 'Wrzesien';
elsif l_month = 10
then
l_month_name := 'Pazdziernik';
elsif l_month = 11
then
l_month_name := 'Listopad';
elsif l_month = 12
then
l_month_name := 'Grudzien';
end if;
return l_month_name;
end get_month_name;
/
create or replace function czy_pracowal(p_date in date,od_date in date,do_date in date,wynagrodzenie in number)
return number
as
val_return number;
begin
    if p_date between od_date and do_date then
        val_return := wynagrodzenie;
    elsif p_date >= od_date and do_date is NULL then
        val_return := wynagrodzenie;
    else
        val_return := 0;
    end if;
return val_return;    
end;
/
create or replace function get_okrag(kod_pocztowy in varchar)
return varchar
as
val_return varchar(20);
begin
        val_return := substr(kod_pocztowy,1,1);
        val_return := case val_return
            when '0' then 'Okreg warszawski'
            when '1' then 'Okreg olsztynski'
            when '2' then 'Okreg lubelski'
            when '3' then 'Okreg krakowski'
            when '4' then 'Okreg katowicki'
            when '5' then 'Okreg wroclawski'
            when '6' then 'Okreg poznanski'
            when '7' then 'Okreg szczecinski'
            when '8' then 'Okreg gdanski'
            when '9' then 'Okreg lodzki' end;
return val_return;
end;
/
CREATE SEQUENCE  SEQ_NEW_DANE_KONTAKTOWE  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_DOSTAWA  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_KATEGORIA  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_KLIENT  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_PRACOWNIK  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_PRODUCENT  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_PRODUKT  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_SKLEP  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  SEQ_NEW_ZAMOWIENIE  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

CREATE OR REPLACE TRIGGER TR_INS_DANE_KONTAKTOWE
BEFORE INSERT ON DANE_KONTAKTOWE
FOR EACH ROW
BEGIN
    :NEW.ID_DANYCH_KONTAKTOWYCH := SEQ_NEW_DANE_KONTAKTOWE.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_DOSTAWA
BEFORE INSERT ON DOSTAWA
FOR EACH ROW
BEGIN
    :NEW.ID_DOSTAWY := SEQ_NEW_DOSTAWA.NEXTVAL;      
END;
/
CREATE OR REPLACE TRIGGER TR_UPDATE_ZAPAS
BEFORE INSERT ON PRODUKT_DOSTAWA
FOR EACH ROW
DECLARE
var_id_produktu number;
var_id_sklepu number;
var_ilosc_produktow number;
BEGIN
    select ilosc_produktow into var_ilosc_produktow
    from dostawa d where d.id_dostawy = :NEW.id_dostawy;
    select id_produktu into var_id_produktu from produkt where id_produktu = :NEW.id_produktu;
    select id_sklepu into var_id_sklepu
    from dostawa where dostawa.id_dostawy=:NEW.id_dostawy;
    
    update zapas
        set ilosc = ilosc+var_ilosc_produktow
        where id_sklepu = var_id_sklepu
        and id_produktu = var_id_produktu;
END;
/

CREATE OR REPLACE TRIGGER TR_UPDATE_ZAPAS2
BEFORE INSERT ON ZAMOWIENIE_PRODUKT
FOR EACH ROW
DECLARE
var_id_sklepu number;
BEGIN
    select id_sklepu into var_id_sklepu from zamowienie where id_zamowienia = :NEW.id_zamowienia;
    update zapas
        set ilosc = ilosc-1
        where id_sklepu = var_id_sklepu
        and id_produktu=:NEW.id_produktu;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_KATEGORIA
BEFORE INSERT ON KATEGORIA
FOR EACH ROW
BEGIN
    :NEW.ID_KATEGORII := SEQ_NEW_KATEGORIA.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_KLIENT
BEFORE INSERT ON KLIENT
FOR EACH ROW
BEGIN
    :NEW.ID_KLIENTA := SEQ_NEW_KLIENT.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_PRACOWNIK
BEFORE INSERT ON PRACOWNIK
FOR EACH ROW
BEGIN
    :NEW.ID_PRACOWNIKA := SEQ_NEW_PRACOWNIK.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_PRODUCENT
BEFORE INSERT ON PRODUCENT
FOR EACH ROW
BEGIN
    :NEW.ID_PRODUCENTA := SEQ_NEW_PRODUCENT.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_PRODUKT
BEFORE INSERT ON PRODUKT
FOR EACH ROW
BEGIN
    :NEW.ID_PRODUKTU := SEQ_NEW_PRODUKT.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TR_INS_SKLEP
BEFORE INSERT ON SKLEP
FOR EACH ROW
BEGIN
    :NEW.ID_SKLEPU := SEQ_NEW_SKLEP.NEXTVAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INS_ZAMOWIENIE
BEFORE INSERT ON ZAMOWIENIE
FOR EACH ROW
BEGIN
    :NEW.ID_ZAMOWIENIA := SEQ_NEW_ZAMOWIENIE.NEXTVAL;
END;
/
create or replace view ilosc_dostarczona as
select p.id_produktu,sum(ilosc_produktow) as "Ilosc dostarczona"
from dostawa d,produkt_dostawa pd, produkt p
where d.id_dostawy = pd.id_dostawy
and pd.id_produktu = p.id_produktu
group by p.id_produktu;

create or replace view ilosc_wyprzedana as
select p.id_produktu,count(*) as "Ilosc wyprzedana"
from zamowienie z,zamowienie_produkt zp,produkt p
where z.id_zamowienia=zp.id_zamowienia
and zp.id_produktu = p.id_produktu
group by p.id_produktu;

create or replace view ilosc_produktow as
select ilosc_dostarczona.id_produktu,"Ilosc dostarczona"-"Ilosc wyprzedana" as "Ilosc"
from ilosc_wyprzedana,ilosc_dostarczona
where ilosc_wyprzedana.id_produktu = ilosc_dostarczona.id_produktu;

create or replace view kalendarz as
select extract(year from data_zamowienia) as "Rok",extract(month from data_zamowienia) as "Miesiac",1 as "Dzien"
from zamowienie
group by extract(year from data_zamowienia),extract(month from data_zamowienia)
order by "Rok" desc,"Miesiac" desc;

create or replace view kalendarz2 as
select cast(cast("Rok"*10000 + "Miesiac"*100 + "Dzien" as varchar(255)) as date) as "Data" from kalendarz;

create or replace view place_dla_pracownikow as
select "Data",sum(czy_pracowal("Data",pracowal_od,pracowal_do,wynagrodzenie)) as "Place dla pracownikow"
from kalendarz2,pracownik
group by "Data"
order by "Data" desc;

create or replace view Bilans as
select extract(year from data_zamowienia) as "Rok",get_month_name(data_zamowienia) as "Miesiac",sum(cena)||'zl' as "Cena sprzedazy",round(sum((1-marza)*cena),2)||'zl'
as "Cena kupna",sum(cena_dostawy)||'zl' as "Koszty dostaw",
(select "Place dla pracownikow" from place_dla_pracownikow where extract(year from "Data")=extract(year from data_zamowienia) and get_month_name("Data")=get_month_name(data_zamowienia))||'zl' as "Oplata pracownikow",
sum(cena)-round(sum((1-marza)*cena),2)-sum(cena_dostawy)-(select "Place dla pracownikow" from place_dla_pracownikow where extract(year from "Data")=extract(year from data_zamowienia) and get_month_name("Data")=get_month_name(data_zamowienia))||'zl' as "Zarobek"
from zamowienie z, zamowienie_produkt zp, produkt p,dostawa d,produkt_dostawa pd
where z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
and extract(year from data_zamowienia) = extract(year from d.data_dostawy)
and get_month_name(data_zamowienia) = get_month_name(d.data_dostawy)
and pd.id_produktu = p.id_produktu
and pd.id_dostawy = d.id_dostawy
group by extract(year from data_zamowienia),get_month_name(data_zamowienia)
order by "Rok" desc, case "Miesiac"
when 'Styczen' then 1 
when 'Luty' then 2
when 'Marzec' then 3
when 'Kwiecien' then 4
when 'Maj' then 5
when 'Czerwiec' then 6
when 'Lipiec' then 7
when 'Sierpien' then 8
when 'Wrzesien' then 9
when 'Pazdziernik' then 10
when 'Listopad' then 11
when 'Grudzien' then 12
end
desc;

create or replace view ilosc_sprzedanych_sztuk as
select extract(year from data_zamowienia) as "Rok",get_quarter(data_zamowienia) as "Kwartal",nazwa_kategorii as "Kategoria",nazwa_producenta as "Producent",nazwa_produktu as "Produkt",count(z.id_zamowienia) as "Ilosc sprzedanych sztuk"
from zamowienie z,kategoria k,producent pr, produkt p,zamowienie_produkt zp
where z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
and p.id_producenta = pr.id_producenta
and p.id_kategorii = k.id_kategorii
group by extract(year from data_zamowienia),get_quarter(data_zamowienia),nazwa_kategorii,nazwa_producenta,nazwa_produktu
order by "Rok" desc, "Kwartal" desc,"Ilosc sprzedanych sztuk" desc;

create or replace view porownanie_sprzedazy_w_sklepach as
select nazwa_sklepu as "Sklep",miejscowosc as "Miejscowosc",adres as "Adres",sum(cena)||'zl' as "Suma ze sprzedazy"
from sklep s,dane_kontaktowe dk,zamowienie z,zamowienie_produkt zp,produkt p
where s.id_danych_kontaktowych = dk.id_danych_kontaktowych
and s.id_sklepu = z.id_sklepu
and zp.id_zamowienia = z.id_zamowienia
and p.id_produktu = zp.id_produktu
group by nazwa_sklepu,miejscowosc,adres
order by "Suma ze sprzedazy" desc;

create or replace view porownanie_klientow as
select imie as "Imie",nazwisko as "Nazwisko",email as "E-mail",sum(cena)||'zl' as "Wydatki"
from klient k,zamowienie z,zamowienie_produkt zp,produkt p
where k.id_klienta = z.id_klienta
and z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
group by imie,nazwisko,email
order by sum(cena) desc;

create or replace view porownanie_regionow as
select get_okrag(kod_pocztowy) as "Region",count(p.id_produktu) as "Zamowionych produktow"
from klient k,zamowienie z, zamowienie_produkt zp, produkt p
where k.id_klienta = z.id_klienta
and z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
group by get_okrag(kod_pocztowy)
order by count(p.id_produktu) desc;
insert into dane_kontaktowe
(telefon,email,wojewodztwo,miejscowosc,adres,kod_pocztowy)
VALUES
(
    '651243851',
    'sqlelectronics_warszawa@sqlelectronics.pl',
    'Mazowieckie',
    'Warszawa',
    'ul. Ksiecia Janusza 39',
    '01-452'
);
insert into dane_kontaktowe
(telefon,email,wojewodztwo,miejscowosc,adres,kod_pocztowy)
VALUES
(
    '651243852',
    'sqlelectronics_bialystok@sqlelectronics.pl',
    'Podlaskie',
    'Bialystok',
    'ul. Szkolna 17',
    '15-640'
);
insert into dane_kontaktowe
(telefon,email,wojewodztwo,miejscowosc,adres,kod_pocztowy)
VALUES
(
    '651243853',
    'sqlelectronics_szczecin@sqlelectronics.pl',
    'Zachodniopomorskie',
    'Szczecin',
    'ul. Rozowa 56',
    '70-781'
);
insert into sklep
(nazwa_sklepu,id_danych_kontaktowych)
VALUES
(
    'SQL-Electronics Warszawa',
    1
);
insert into sklep
(nazwa_sklepu,id_danych_kontaktowych)
VALUES
(
    'SQL-Electronics Bialystok',
    2
);
insert into sklep
(nazwa_sklepu,id_danych_kontaktowych)
VALUES
(
    'SQL-Electronics Szczecin',
    3
);

insert into producent
(nazwa_producenta)
values('Intel');
insert into producent
(nazwa_producenta)
values('AMD');
insert into producent
(nazwa_producenta)
values('Nvidia');
insert into producent
(nazwa_producenta)
values('SilentiumPC');
insert into producent
(nazwa_producenta)
values('Corsair');

insert into Kategoria
(nazwa_kategorii)
values('Procesor');
insert into Kategoria
(nazwa_kategorii)
values('Karta graficzna');
insert into Kategoria
(nazwa_kategorii)
values('Obudowa');

insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Marian',
    'Matuszewski',
    'Pracujacy',
    2400,
    '900231438',
    1
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,email,id_sklepu)
values
(
    'Agata',
    'Kowalczuk',
    'Pracujacy',
    2700,
    '600200301',
    'agaciuch94@gmail.com',
    3
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,email,id_sklepu)
values
(
    'Tadeusz',
    'Czarodziej',
    'Pracujacy',
    2200,
    'magiczny_tadzio@wp.pl',
    2
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Zbigniew',
    'Kanapa',
    'Pracujacy',
    2500,
    '999671243',
    1
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,email,id_sklepu)
values
(
    'Michal',
    'Malysz',
    'Pracujacy',
    2800,
    '900231438',
    'michal_mal84@gmail.com',
    1
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,pracowal_do,email,id_sklepu)
values
(
    'Janusz',
    'Zlodziej',
    'Nie pracujacy',
    2400,
    '2019/12/18',
    'passat1_9tdi@gmail.com',
    3
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Mateusz',
    'Boss',
    'Pracujacy',
    3500,
    '421639444',
    1
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Franciszek',
    'Kisiel',
    'Pracujacy',
    3300,
    '965421994',
    2
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,email,id_sklepu)
values
(
    'Adam',
    'Pudzianowski',
    'Pracujacy',
    3100,
    'elektryka_prad_nie_bije@gmail.com',
    3
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Marta',
    'Chomik',
    'Pracujacy',
    2500,
    '321123456',
    2
);
insert into Pracownik
(imie,nazwisko,status,wynagrodzenie,telefon,id_sklepu)
values
(
    'Jan',
    'Grekanczuk',
    'Pracujacy',
    2300,
    '555222891',
    3
);


INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gabriel', 'Jasinski', 'Korzenno', 'ul. Browarna 74', '06-307', '959535471', 'Gabriel_Jas96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Damian', 'Kazmierczak', 'Rusiniec', 'ul. Bankowa 57', '66-448', '579149732', 'Damian_Kaz96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dobromil', 'Blaszczyk', 'Gotelp', 'ul. Kwiatowa 99', '49-919', '687732025', 'Dobromil_Bla75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Allan', 'Maciejewski', 'Ujazdow', 'ul. Bohaterow Monte Cassino 56', '63-125', '575107877', 'Allan_Mac88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominik', 'Witkowski', 'Pogobie', 'ul. Chmielna 16', '85-260', '671534082', 'Dominik_Wit80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gniewomir', 'Andrzejewski', 'Bociniec', 'ul. 1 Maja 44', '10-874', '388149156', 'Gniewomir_And97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bartlomiej', 'Wlodarczyk', 'Witawa', 'ul. Lipowa 51', '51-016', '165607784', 'Bartlomiej_Wlo74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Krzysztof', 'Szymanski', 'Czartolomie', 'ul. Bohaterow Monte Cassino 79', '95-079', '317731162', 'Krzysztof_Szy77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ireneusz', 'Mroz', 'Pawonkow', 'ul. Lesna 7', '08-475', '162659029', 'Ireneusz_Mro94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Amadeusz', 'Krawczyk', 'Woronie', 'ul. Lipowa 63', '32-908', '931243890', 'Amadeusz_Kra96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Konstanty', 'Wiœniewski', 'Krymlawki', 'ul. Browarna 98', '76-786', '165044567', 'Konstanty_Wiœ80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Boleslaw', 'Sawicki', 'Piaseczno', 'ul. 3 Maja 30', '38-302', '832158569', 'Boleslaw_Saw81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ksawery', 'Brzezinski', 'Podlindowo', 'ul. Stefana Czarnieckiego 79', '82-248', '151706182', 'Ksawery_Brz97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Leonardo', 'Michalak', 'Krejwince', 'ul. Sloneczna 86', '04-579', '287083057', 'Leonardo_Mic73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Albert', 'Zalewski', 'Wiatrak', 'ul. lakowa 20', '50-206', '414416655', 'Albert_Zal97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Martin', 'Czarnecki', 'Koziel', 'ul. Stefana Czarnieckiego 91', '60-788', '799905984', 'Martin_Cza74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Przemyslaw', 'Pietrzak', 'Dworzec', 'ul. Lesna 48', '93-835', '759831720', 'Przemyslaw_Pie97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alfred', 'Szczepanski', 'Przytoka', 'ul. Ogrodowa 83', '78-036', '180795835', 'Alfred_Szc79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Artur', 'Kwiatkowski', 'Stradomka', 'ul. Lesna 7', '79-539', '147366350', 'Artur_Kwi90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bronislaw', 'Szymczak', 'Kormanice', 'ul. Krotka 9', '28-762', '379999279', 'Bronislaw_Szy91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alfred', 'Kolodziej', 'Trzemesna', 'ul. Chmielna 16', '61-520', '555204384', 'Alfred_Kol82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Robert', 'Chmielewski', 'Winna', 'ul. Bytomska 72', '79-856', '842602694', 'Robert_Chm79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gabriel', 'Piotrowski', 'Cieciorka', 'ul. Michala Baluckiego 92', '78-029', '741407704', 'Gabriel_Pio84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Daniel', 'Makowski', 'Wielawino', 'ul. Bielska 34', '16-549', '112709298', 'Daniel_Mak79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Blazej', 'Kaminski', 'Dusznica', 'ul. Chmielna 69', '81-482', '527631140', 'Blazej_Kam88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olgierd', 'Szczepanski', 'Regnow', 'ul. Jozefa Bema 11', '87-973', '411695087', 'Olgierd_Szc85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kajetan', 'Szczepanski', 'Skuly', 'ul. lakowa 88', '22-398', '826878727', 'Kajetan_Szc78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Edward', 'Kubiak', 'Dominek', 'ul. Brzozowa 1', '73-782', '899178843', 'Edward_Kub98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Damian', 'Szulc', 'Suchanowko', 'ul. Ciasna 67', '87-874', '105368096', 'Damian_Szu99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ireneusz', 'Baran', 'zalinowo', 'ul. Armii Krajowej 66', '71-593', '211899796', 'Ireneusz_Bar80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Przemyslaw', 'Blaszczyk', 'Lekarcice', 'ul. Brzozowa 15', '25-402', '864163258', 'Przemyslaw_Bla80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatol', 'Wasilewska', 'Czochryn', 'ul. Brzeska 90', '55-392', '975380613', 'Anatol_Was83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Miroslaw', 'Sawicki', 'Golczew', 'ul. Michala Baluckiego 20', '52-825', '464386540', 'Miroslaw_Saw90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aureliusz', 'Szulc', 'Radwanka', 'ul. Boleslawa Chrobrego 60', '20-354', '545579882', 'Aureliusz_Szu82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Blazej', 'Duda', 'Szernie', 'ul. Kwiatowa 37', '12-158', '204682885', 'Blazej_Dud74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Radoslaw', 'Zalewski', 'Chronow', 'ul. Brzeska 39', '51-251', '634365718', 'Radoslaw_Zal91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alexander', 'Kazmierczak', 'Surbajny', 'ul. Beskidzka 56', '35-478', '489149562', 'Alexander_Kaz77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ariel', 'Maciejewski', 'Ogorzelnik', 'ul. Chlodna 84', '49-050', '822026030', 'Ariel_Mac97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dobromil', 'Wiœniewski', 'Matule', 'ul. Krotka 58', '83-568', '236328115', 'Dobromil_Wiœ99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Radoslaw', 'Jasinski', 'Podgajew', 'ul. Bytomska 15', '81-502', '556892153', 'Radoslaw_Jas88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Damian', 'Walczak', 'Jarzebiec', 'ul. lakowa 19', '36-881', '965188076', 'Damian_Wal75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcel', 'Kazmierczak', 'Okolusz', 'ul. Polna 93', '48-474', '419879608', 'Marcel_Kaz97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julian', 'Urbanska', 'Skorcz', 'ul. Sloneczna 58', '95-942', '226509621', 'Julian_Urb90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Czeslaw', 'Blaszczyk', 'Grzybowa', 'ul. Bohaterow Monte Cassino 51', '64-554', '610292903', 'Czeslaw_Bla91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Przemyslaw', 'Kwiatkowski', 'Cieniawa', 'ul. Michala Baluckiego 45', '38-214', '152196127', 'Przemyslaw_Kwi98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mateusz', 'Sikorska', 'Czernin', 'ul. Beskidzka 14', '05-315', '510371861', 'Mateusz_Sik99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Remigiusz', 'Sobczak', 'Kalonka', 'ul. Czestochowska 39', '74-815', '626046481', 'Remigiusz_Sob90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mariusz', 'Kozlowski', 'Wielbark', 'ul. Bankowa 38', '28-226', '796543452', 'Mariusz_Koz78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcin', 'Sadowska', 'Coldanki', 'ul. Brzeska 7', '62-051', '300776244', 'Marcin_Sad94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alexander', 'Bak', 'Kroblice', 'ul. Bohaterow Monte Cassino 68', '30-452', '856169958', 'Alexander_Bak75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Arkadiusz', 'Duda', 'Skibin', 'ul. 3 Maja 45', '37-823', '776899830', 'Arkadiusz_Dud84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Allan', 'Maciejewski', 'Kosowka', 'ul. Szkolna 29', '68-719', '763724621', 'Allan_Mac76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Konstanty', 'Krajewska', 'Borcuchy', 'ul. Bankowa 99', '95-910', '294208190', 'Konstanty_Kra85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Blazej', 'Wasilewska', 'Sigla', 'ul. Lesna 25', '01-430', '256764724', 'Blazej_Was83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ireneusz', 'Bak', 'Cichowo', 'ul. gen. Wladyslawa Andersa 33', '22-004', '593629077', 'Ireneusz_Bak97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hubert', 'Cieœlak', 'Chwalkow', 'ul. Chorzowska 43', '48-414', '916904653', 'Hubert_Cie77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alojzy', 'Sokolowski', 'Slojniki', 'ul. Browarna 2', '47-191', '392405934', 'Alojzy_Sok88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Remigiusz', 'Sawicki', 'Zareby', 'ul. Czestochowska 52', '72-251', '908999514', 'Remigiusz_Saw76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bronislaw', 'Wiœniewski', 'Lubaczow', 'ul. Jozefa Bema 69', '40-923', '512557803', 'Bronislaw_Wiœ84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Korneliusz', 'Sokolowski', 'Ostrozne', 'ul. Michala Baluckiego 11', '28-392', '840853146', 'Korneliusz_Sok80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mieszko', 'Cieœlak', 'Domanin', 'ul. Bankowa 89', '20-350', '163143790', 'Mieszko_Cie74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcel', 'Kaczmarczyk', 'Dluzec', 'ul. Czestochowska 20', '70-641', '592834995', 'Marcel_Kac82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Korneliusz', 'Zielinski', 'Rybieniec', 'ul. Bracka 10', '66-540', '862903658', 'Korneliusz_Zie83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Borys', 'Sobczak', 'Rakowicze', 'ul. Piastowska 85', '90-011', '661206959', 'Borys_Sob77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ksawery', 'Kalinowski', 'Ostrozki', 'ul. gen. Wladyslawa Andersa 80', '69-310', '569680642', 'Ksawery_Kal99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Joachim', 'Michalak', 'Paluszyce', 'ul. Bohaterow Monte Cassino 8', '22-105', '278361793', 'Joachim_Mic97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Piotr', 'Zakrzewska', 'Plesy', 'ul. Bohaterow Monte Cassino 81', '02-144', '474800968', 'Piotr_Zak93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Przemyslaw', 'Krupa', 'Jamna', 'ul. 1 Maja 84', '01-329', '202317584', 'Przemyslaw_Kru88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mariusz', 'Ostrowski', 'Mankowice', 'ul. Brzeska 99', '61-537', '430191680', 'Mariusz_Ost84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Konrad', 'Zalewski', 'Szydlowiec', 'ul. Lipowa 8', '56-518', '423071465', 'Konrad_Zal75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gniewomir', 'Wozniak', 'Imionek', 'ul. Chlodna 64', '42-122', '904045464', 'Gniewomir_Woz73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olgierd', 'Jakubowski', 'Chroberz', 'ul. Chorzowska 46', '56-025', '453946093', 'Olgierd_Jak80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Cyprian', 'Kucharski', 'Kamienczyk', 'ul. Bracka 48', '11-431', '801614726', 'Cyprian_Kuc99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Antoni', 'Tomaszewski', 'Wygwizdow', 'ul. Browarna 30', '08-631', '954857623', 'Antoni_Tom96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mikolaj', 'Bak', 'Wikrowo', 'ul. Beskidzka 94', '95-877', '490761895', 'Mikolaj_Bak99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Oskar', 'Cieœlak', 'Bialosuknia', 'ul. Kwiatowa 5', '66-176', '978314255', 'Oskar_Cie94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Cyprian', 'Zawadzki', 'Soboszow', 'ul. Jozefa Bema 13', '61-582', '855416532', 'Cyprian_Zaw78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Damian', 'Laskowska', 'Murowaniec', 'ul. Bozego Ciala 98', '27-166', '258758600', 'Damian_Las93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bronislaw', 'Bak', 'Sulinowo', 'ul. Chlodna 31', '69-352', '174219316', 'Bronislaw_Bak70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Janusz', 'Sobczak', 'Kudrycze', 'ul. Dluga 40', '24-032', '861280613', 'Janusz_Sob86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gniewomir', 'Zalewski', 'Pieszcz', 'ul. Balonowa 13', '62-180', '809248805', 'Gniewomir_Zal76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Miron', 'Szymczak', 'Krosnowa', 'ul. Czestochowska 48', '86-377', '929208323', 'Miron_Szy84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julian', 'Czarnecki', 'Niechobrz', 'ul. Dluga 3', '24-656', '987053157', 'Julian_Cza97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Roman', 'Krajewska', 'Dziewulin', 'ul. Kwiatowa 48', '56-178', '558028403', 'Roman_Kra80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Kwiatkowski', 'Szumirad', 'ul. Balonowa 57', '81-414', '169448864', 'Norbert_Kwi78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Krystian', 'Zielinski', 'Sedzislaw', 'ul. Chorzowska 16', '56-018', '660058732', 'Krystian_Zie75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Joachim', 'Pawlak', 'Trzciano', 'ul. Chmielna 64', '09-484', '928287343', 'Joachim_Paw78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Arkadiusz', 'Ziolkowska', 'Wawrochy', 'ul. Bielska 21', '73-166', '686960024', 'Arkadiusz_Zio88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Grzegorz', 'Witkowski', 'Marszew', 'ul. lakowa 41', '84-250', '438055917', 'Grzegorz_Wit79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bruno', 'Kalinowski', 'Lorenki', 'ul. Stefana Czarnieckiego 54', '81-057', '175571034', 'Bruno_Kal72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Diego', 'Krajewska', 'Kocury', 'ul. 11 Listopada 62', '60-179', '994601253', 'Diego_Kra84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcel', 'Gorecki', 'Chyby', 'ul. Brzeska 88', '08-674', '166321981', 'Marcel_Gor95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Filip', 'Sikora', 'Felinow', 'ul. Beskidzka 26', '85-707', '262129400', 'Filip_Sik71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Henryk', 'Rutkowski', 'Makowiska', 'ul. Browarna 44', '27-727', '969307146', 'Henryk_Rut99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Oskar', 'Krawczyk', 'Wolny', 'ul. Bytomska 16', '09-484', '440815451', 'Oskar_Kra86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamil', 'Gorski', 'Glupianka', 'ul. Szkolna 28', '21-174', '152076509', 'Kamil_Gor98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcel', 'Kozlowski', 'Grzeska', 'ul. Krotka 23', '91-593', '522905627', 'Marcel_Koz83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Krzysztof', 'Cieœlak', 'Zgnilka', 'ul. lakowa 66', '16-677', '938741873', 'Krzysztof_Cie99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Janusz', 'Marciniak', 'Korzekwice', 'ul. Bozego Ciala 78', '54-333', '768669595', 'Janusz_Mar93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kryspin', 'Wozniak', 'Opinogora', 'ul. Dluga 43', '56-344', '530347503', 'Kryspin_Woz72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Konrad', 'Michalak', 'Sarnow', 'ul. Michala Baluckiego 42', '27-129', '987499941', 'Konrad_Mic84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Piotr', 'Dabrowski', 'Œwierzbienie', 'ul. 11 Listopada 14', '75-442', '521798127', 'Piotr_Dab90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mateusz', 'Zielinski', 'Potrzymiech', 'ul. Boleslawa Chrobrego 35', '04-169', '836940768', 'Mateusz_Zie95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Daniel', 'Malinowski', 'Domanice', 'ul. Bytomska 44', '87-516', '366893715', 'Daniel_Mal73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marek', 'Mroz', 'Kowanowo', 'ul. Czestochowska 32', '27-933', '434103395', 'Marek_Mro87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julian', 'Mroz', 'Kolecin', 'ul. Chmielna 2', '59-083', '262431203', 'Julian_Mro75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gustaw', 'Zalewski', 'Bustryk', 'ul. Czestochowska 77', '38-409', '283772350', 'Gustaw_Zal80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Czeslaw', 'Wysocki', 'Wyskok', 'ul. lakowa 68', '94-739', '171841175', 'Czeslaw_Wys98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Karol', 'Mazurek', 'Pogorzyce', 'ul. Lipowa 1', '23-427', '512923684', 'Karol_Maz92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mieszko', 'Pawlak', 'Maze', 'ul. Bernadynska 33', '36-115', '579864818', 'Mieszko_Paw77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Patryk', 'Wojcik', 'Mietkie', 'ul. Michala Baluckiego 22', '06-119', '316511161', 'Patryk_Woj98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Leszek', 'Laskowska', 'Olszyn', 'ul. Kwiatowa 71', '23-549', '124417566', 'Leszek_Las99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Damian', 'Wojciechowski', 'Plocin', 'ul. Michala Baluckiego 69', '05-200', '263558338', 'Damian_Woj70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jozef', 'Czarnecki', 'Czeremcha', 'ul. Bielska 53', '76-383', '865207853', 'Jozef_Cza71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Boleslaw', 'Czarnecki', 'Solarnia', 'ul. Balonowa 45', '49-973', '154566837', 'Boleslaw_Cza72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bartosz', 'Baran', 'Zagorzyce', 'ul. Bielska 17', '40-894', '190526559', 'Bartosz_Bar74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Kaczmarczyk', 'Kawnice', 'ul. Browarna 68', '41-604', '263150339', 'Norbert_Kac91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcin', 'Kolodziej', 'Nielep', 'ul. Lesna 8', '23-302', '843167321', 'Marcin_Kol95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Kubiak', 'Liwa', 'ul. Kwiatowa 85', '84-277', '400884905', 'Norbert_Kub93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emanuel', 'Maciejewski', 'Drogoradz', 'ul. Czestochowska 1', '53-841', '394847238', 'Emanuel_Mac79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jaroslaw', 'Wysocki', 'Pucolowo', 'ul. Browarna 53', '18-897', '834617808', 'Jaroslaw_Wys96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jacek', 'Krajewska', 'Lipka', 'ul. Bernadynska 89', '21-200', '635378044', 'Jacek_Kra80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bartlomiej', 'Jankowski', 'Zalesiczki', 'ul. Krotka 21', '41-815', '285973156', 'Bartlomiej_Jan95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Michalak', 'Kosowa', 'ul. Bozego Ciala 55', '68-710', '625186421', 'Norbert_Mic95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Amir', 'Lis', 'Koloniec', 'ul. Armii Krajowej 54', '31-767', '124323390', 'Amir_Lis96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olaf', 'Kubiak', 'Korabina', 'ul. Stefana Czarnieckiego 4', '05-049', '913606829', 'Olaf_Kub74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bronislaw', 'Borkowski', 'Kruczaj', 'ul. Piastowska 50', '06-981', '968753249', 'Bronislaw_Bor97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emanuel', 'Szczepanski', 'Upale', 'ul. Boleslawa Chrobrego 2', '07-257', '201357548', 'Emanuel_Szc78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lucjan', 'Sokolowski', 'Wancerzow', 'ul. 1 Maja 97', '86-150', '623457077', 'Lucjan_Sok91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Albert', 'Baran', 'Gnatowice', 'ul. Bankowa 85', '75-914', '117831474', 'Albert_Bar82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Czeslaw', 'Kazmierczak', 'Zagorzyce', 'ul. Chmielna 47', '07-870', '248448825', 'Czeslaw_Kaz86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ireneusz', 'Kucharski', 'Kryg', 'ul. Chlodna 3', '93-702', '622151006', 'Ireneusz_Kuc99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alex', 'Lis', 'Kukly', 'ul. Kwiatowa 91', '53-029', '452597403', 'Alex_Lis99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ireneusz', 'Blaszczyk', 'Fanislawice', 'ul. Jozefa Bema 67', '84-845', '378504252', 'Ireneusz_Bla88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Franciszek', 'Sikorska', 'Piestrzec', 'ul. Szkolna 75', '75-594', '564263954', 'Franciszek_Sik92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Sikora', 'Knapowka', 'ul. Michala Baluckiego 98', '71-949', '768221188', 'Norbert_Sik98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominik', 'Jasinski', 'Habdzin', 'ul. Bankowa 35', '04-485', '634589487', 'Dominik_Jas77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jozef', 'Cieœlak', 'Goluszowice', 'ul. 1 Maja 58', '80-379', '671865914', 'Jozef_Cie79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Albert', 'Duda', 'Lubkowice', 'ul. Browarna 51', '60-073', '573887106', 'Albert_Dud88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Karol', 'Baran', 'Galiszewo', 'ul. Lesna 91', '09-346', '858728639', 'Karol_Bar98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Robert', 'Borkowski', 'Hulanka', 'ul. Polna 28', '48-382', '646845430', 'Robert_Bor74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jaroslaw', 'Makowski', 'Parciaki', 'ul. Brzozowa 99', '20-577', '835179530', 'Jaroslaw_Mak72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adrian', 'Duda', 'Czeœniki', 'ul. Bozego Ciala 11', '33-046', '993797916', 'Adrian_Dud93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alan', 'Laskowska', 'Modrzew', 'ul. Stefana Czarnieckiego 69', '88-693', '785546385', 'Alan_Las77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hubert', 'Wysocki', 'Babin', 'ul. lakowa 51', '27-924', '940668985', 'Hubert_Wys87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alex', 'Gajewska', 'Kleczanow', 'ul. Sloneczna 45', '54-611', '368834995', 'Alex_Gaj91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marek', 'Szewczyk', 'Szczepanowice', 'ul. Lesna 71', '37-171', '993895306', 'Marek_Sze80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Przemyslaw', 'Gajewska', 'Lady', 'ul. Lesna 8', '61-632', '191703619', 'Przemyslaw_Gaj89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Milan', 'Zakrzewska', 'Sierakow', 'ul. Bozego Ciala 24', '31-233', '545463436', 'Milan_Zak90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Mikolaj', 'Nowak', 'Nadwiœlanka', 'ul. Piastowska 74', '65-192', '685431180', 'Mikolaj_Now94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Radoslaw', 'Szymanski', 'Œwierzbienie', 'ul. Szkolna 85', '83-999', '165685367', 'Radoslaw_Szy90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatol', 'Szulc', 'Kraszyn', 'ul. Bankowa 34', '22-600', '986399442', 'Anatol_Szu88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jozef', 'Kolodziej', 'Sepiot', 'ul. Balonowa 34', '57-149', '209417866', 'Jozef_Kol87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Leonardo', 'Baran', 'Terlikow', 'ul. Balonowa 7', '05-051', '324390713', 'Leonardo_Bar98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Fryderyk', 'Kwiatkowski', 'Lulinek', 'ul. Brzozowa 98', '47-612', '979506423', 'Fryderyk_Kwi74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bruno', 'Gorecki', 'Romanowce', 'ul. Michala Baluckiego 31', '56-807', '640977801', 'Bruno_Gor88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aleks', 'Kowalczyk', 'Nerwik', 'ul. Bielska 58', '77-476', '540059075', 'Aleks_Kow90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jozef', 'Sokolowski', 'Zla', 'ul. Polna 12', '77-495', '452918585', 'Jozef_Sok82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Natan', 'Malinowski', 'Koconia', 'ul. Lipowa 15', '45-942', '982724298', 'Natan_Mal84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Pawel', 'Marciniak', 'Antoniow', 'ul. Stefana Czarnieckiego 89', '76-067', '820076337', 'Pawel_Mar85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Andrzej', 'Pietrzak', 'Poniatowo', 'ul. Kwiatowa 73', '25-379', '756846666', 'Andrzej_Pie73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emil', 'Gajewska', 'zdzarow', 'ul. Krotka 12', '38-689', '227173140', 'Emil_Gaj73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatol', 'Jakubowski', 'Chwaliszowice', 'ul. Balonowa 42', '93-964', '691629495', 'Anatol_Jak96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatol', 'Kowalczyk', 'Talar', 'ul. Bielska 58', '36-244', '730129244', 'Anatol_Kow73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kuba', 'Ziolkowska', 'Ostrowce', 'ul. Akademicka 85', '95-312', '311491253', 'Kuba_Zio95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hubert', 'Krupa', 'Garwolewo', 'ul. Sloneczna 85', '33-967', '828273289', 'Hubert_Kru81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Filip', 'Kaminski', 'Kalisty', 'ul. Stefana Czarnieckiego 24', '48-017', '622254858', 'Filip_Kam99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jerzy', 'Laskowska', 'Chwalimie', 'ul. Piastowska 67', '22-880', '992261983', 'Jerzy_Las94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maksymilian', 'Kaminski', 'Œledzie', 'ul. Bankowa 51', '65-645', '369700073', 'Maksymilian_Kam73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olaf', 'Witkowski', 'Miloszyce', 'ul. Bozego Ciala 14', '60-372', '905708751', 'Olaf_Wit95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Miron', 'Blaszczyk', 'Metow', 'ul. Michala Baluckiego 65', '47-348', '136043143', 'Miron_Bla77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Franciszek', 'Kozlowski', 'Mikowiec', 'ul. gen. Wladyslawa Andersa 36', '07-826', '121881874', 'Franciszek_Koz81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Pawel', 'Zawadzki', 'Ciochowice', 'ul. Bielska 79', '90-729', '272109441', 'Pawel_Zaw97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emil', 'Wozniak', 'Babin', 'ul. Lipowa 6', '56-318', '154034596', 'Emil_Woz87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Leonardo', 'Bak', 'Borzymy', 'ul. lakowa 45', '48-441', '130528382', 'Leonardo_Bak71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Radoslaw', 'Lewandowski', 'Stojcino', 'ul. Beskidzka 9', '54-218', '691418905', 'Radoslaw_Lew80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Edward', 'Lis', 'Mogowo', 'ul. Ciasna 77', '70-383', '900477452', 'Edward_Lis70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Milan', 'Wojciechowski', 'Sitowa', 'ul. Fryderyka Chopina 25', '20-644', '291546337', 'Milan_Woj89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ksawery', 'Mazurek', 'Szymanowizna', 'ul. Piastowska 43', '52-359', '402704602', 'Ksawery_Maz77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olgierd', 'Chmielewski', 'Konstantynowo', 'ul. Ogrodowa 93', '73-073', '809161787', 'Olgierd_Chm78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maciej', 'Kowalczyk', 'Radomka', 'ul. 11 Listopada 70', '86-032', '842862116', 'Maciej_Kow94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Michal', 'Lis', 'Szastarka', 'ul. Browarna 47', '67-740', '685448013', 'Michal_Lis74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Eryk', 'Wlodarczyk', 'Bogacko', 'ul. Piastowska 32', '60-381', '961794155', 'Eryk_Wlo83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Miron', 'Sikorska', 'Kukinia', 'ul. Szkolna 34', '01-150', '412289377', 'Miron_Sik91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Henryk', 'Szulc', 'Mocarzewo', 'ul. Bernadynska 73', '48-255', '146595613', 'Henryk_Szu81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Heronim', 'Czarnecki', 'Trzcinka', 'ul. Bohaterow Monte Cassino 65', '56-733', '933007200', 'Heronim_Cza81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marian', 'Szymanski', 'Koœcian', 'ul. gen. Wladyslawa Andersa 49', '70-755', '326865323', 'Marian_Szy77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominik', 'Kowalski', 'Trojnia', 'ul. lakowa 5', '59-737', '313442581', 'Dominik_Kow80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aleksy', 'Zakrzewska', 'Mironow', 'ul. Bohaterow Monte Cassino 59', '56-174', '432620672', 'Aleksy_Zak80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maciej', 'Sikorska', 'Klobuczyn', 'ul. Brzeska 55', '76-295', '378306517', 'Maciej_Sik96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klaudiusz', 'Zielinski', 'Librantowa', 'ul. Czestochowska 73', '65-913', '192840927', 'Klaudiusz_Zie86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Joachim', 'Michalak', 'Wyszecice', 'ul. Chorzowska 57', '56-492', '715754456', 'Joachim_Mic89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emanuel', 'Krajewska', 'Podgorze', 'ul. Balonowa 2', '89-383', '459441503', 'Emanuel_Kra91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Franciszek', 'Kalinowski', 'losienek', 'ul. Sloneczna 86', '93-781', '910786607', 'Franciszek_Kal96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dobromil', 'Kucharski', 'Wadag', 'ul. gen. Wladyslawa Andersa 5', '66-774', '867670683', 'Dobromil_Kuc95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Arkadiusz', 'Blaszczyk', 'Folgowo', 'ul. Bohaterow Monte Cassino 40', '36-406', '999203106', 'Arkadiusz_Bla86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jaroslaw', 'Stepien', 'Tarnowczyn', 'ul. Dluga 96', '36-938', '723803016', 'Jaroslaw_Ste77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Milan', 'Krawczyk', 'Kosarzew', 'ul. Krotka 2', '16-701', '568291451', 'Milan_Kra80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcel', 'Michalak', 'Zimnice', 'ul. Stefana Czarnieckiego 88', '74-306', '589356882', 'Marcel_Mic71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alexander', 'Kolodziej', 'Adamierz', 'ul. Krotka 48', '65-965', '867764825', 'Alexander_Kol79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bartlomiej', 'Wozniak', 'Bluszczow', 'ul. Dluga 26', '50-758', '958951071', 'Bartlomiej_Woz95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ernest', 'Wlodarczyk', 'Falknowo', 'ul. Chorzowska 70', '20-869', '368556491', 'Ernest_Wlo86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Korneliusz', 'Krajewska', 'zelewiec', 'ul. Sloneczna 88', '04-478', '128393494', 'Korneliusz_Kra81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Robert', 'Mroz', 'Longinowka', 'ul. Bytomska 30', '62-260', '138123408', 'Robert_Mro80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Pawel', 'Gorski', 'Smarglin', 'ul. Bozego Ciala 3', '87-581', '888649360', 'Pawel_Gor76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornel', 'Jankowski', 'Lacka', 'ul. Stefana Czarnieckiego 53', '91-761', '246964675', 'Kornel_Jan73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jakub', 'Kowalczyk', 'Karwin', 'ul. Czestochowska 38', '69-339', '918757422', 'Jakub_Kow97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gabriel', 'Jaworski', 'Klenica', 'ul. Bracka 51', '92-643', '775958237', 'Gabriel_Jaw72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anastazy', 'Urbanska', 'Gawin', 'ul. Bankowa 42', '42-229', '103804801', 'Anastazy_Urb77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alan', 'Baranowski', 'Gaczkowo', 'ul. Ciasna 31', '18-683', '536070248', 'Alan_Bar83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatol', 'Wiœniewski', 'Przypki', 'ul. Kwiatowa 47', '67-512', '361710279', 'Anatol_Wiœ89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Fryderyk', 'Andrzejewski', 'Dzielawy', 'ul. Brzeska 14', '28-137', '364880944', 'Fryderyk_And73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Fabian', 'Wlodarczyk', 'zydow', 'ul. Beskidzka 13', '03-111', '652185473', 'Fabian_Wlo78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Piotr', 'Kowalczyk', 'Pruskie', 'ul. Bohaterow Monte Cassino 46', '62-874', '499521162', 'Piotr_Kow92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Daniel', 'Makowski', 'Rejczuchy', 'ul. Sloneczna 46', '08-210', '625788130', 'Daniel_Mak77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Diego', 'Kubiak', 'Wielboki', 'ul. Boleslawa Chrobrego 10', '88-166', '272734963', 'Diego_Kub96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Oskar', 'Gorski', 'Wagrodno', 'ul. Lipowa 95', '53-045', '724408956', 'Oskar_Gor75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julian', 'Pietrzak', 'Czarnochowice', 'ul. Armii Krajowej 64', '00-848', '338316599', 'Julian_Pie93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jaroslaw', 'Zawadzki', 'Jarychowo', 'ul. Bracka 17', '44-978', '208283267', 'Jaroslaw_Zaw82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Miroslaw', 'Gajewska', 'Budyn', 'ul. Bernadynska 75', '00-317', '921332240', 'Miroslaw_Gaj97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Emil', 'Glowacka', 'Kwielice', 'ul. Bytomska 11', '89-797', '447958347', 'Emil_Glo93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominik', 'Kowalski', 'Placzkowice', 'ul. Ciasna 1', '71-520', '519441137', 'Dominik_Kow91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ryszard', 'Gorecki', 'Dunkowa', 'ul. 3 Maja 84', '11-990', '108270305', 'Ryszard_Gor97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominik', 'Przybylski', 'Rozdrazew', 'ul. lakowa 86', '63-760', '946314785', 'Dominik_Prz94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumil', 'Bak', 'Bonowice', 'ul. Jozefa Bema 87', '68-931', '996825395', 'Bogumil_Bak87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Laskowska', 'Kleszczewko', 'ul. Polna 26', '82-815', '700042413', 'Norbert_Las73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olaf', 'Szczepanski', 'Bronow', 'ul. Akademicka 6', '24-137', '889237778', 'Olaf_Szc86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maurycy', 'Sokolowski', 'Gorlice', 'ul. Brzeska 73', '35-248', '916330288', 'Maurycy_Sok82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kryspin', 'Nowak', 'Kocewo', 'ul. Brzozowa 21', '22-450', '897103052', 'Kryspin_Now79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dobromil', 'Zakrzewska', 'Barczyzna', 'ul. Kwiatowa 36', '91-385', '710660157', 'Dobromil_Zak77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Piotr', 'Czerwinski', 'Trzcianiec', 'ul. Bozego Ciala 50', '40-623', '923244301', 'Piotr_Cze76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adrian', 'Jankowski', 'Chlebno', 'ul. Brzeska 67', '88-291', '289889262', 'Adrian_Jan99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aureliusz', 'Maciejewski', 'Minkowice', 'ul. Bielska 61', '76-630', '198978333', 'Aureliusz_Mac85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Natan', 'Sokolowski', 'Chlopiny', 'ul. 1 Maja 12', '53-491', '725631855', 'Natan_Sok92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Robert', 'Wroblewski', 'Borowskie', 'ul. Boleslawa Chrobrego 7', '10-322', '881108843', 'Robert_Wro96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bartosz', 'Jaworski', 'Zapowiednia', 'ul. lakowa 92', '46-273', '414768659', 'Bartosz_Jaw79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Robert', 'Kubiak', 'Marcowka', 'ul. lakowa 21', '61-932', '173949677', 'Robert_Kub73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Blazej', 'Baranowski', 'Jezierzany', 'ul. Bracka 20', '69-503', '117896397', 'Blazej_Bar83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kuba', 'Gajewska', 'Borzyslaw', 'ul. Lipowa 43', '99-005', '693172311', 'Kuba_Gaj97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aleksander', 'Baran', 'Koszelowka', 'ul. Ogrodowa 38', '56-574', '929082125', 'Aleksander_Bar97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Cezary', 'Bak', 'Wojtokiemie', 'ul. Stefana Czarnieckiego 14', '62-206', '367599523', 'Cezary_Bak73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Karol', 'Przybylski', 'Rybna', 'ul. Lipowa 38', '83-380', '188503286', 'Karol_Prz79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Janusz', 'Wojcik', 'Zarebow', 'ul. Bohaterow Monte Cassino 32', '48-694', '964201170', 'Janusz_Woj91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hubert', 'Jakubowski', 'Wawrzkowizna', 'ul. Polna 6', '00-073', '753864951', 'Hubert_Jak95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kuba', 'Jakubowski', 'Zagloba', 'ul. Stefana Czarnieckiego 61', '74-903', '506225236', 'Kuba_Jak99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aleksander', 'Zakrzewska', 'Alwernia', 'ul. Kwiatowa 74', '18-132', '467720338', 'Aleksander_Zak77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Leszek', 'Cieœlak', 'Sarnow', 'ul. Stefana Czarnieckiego 40', '10-969', '659451379', 'Leszek_Cie80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Norbert', 'Wroblewski', 'Drazek', 'ul. Armii Krajowej 38', '23-465', '336583806', 'Norbert_Wro81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aureliusz', 'Kucharski', 'Bierkowo', 'ul. Kwiatowa 39', '92-947', '695523363', 'Aureliusz_Kuc79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kryspin', 'Wojciechowski', 'Siennow', 'ul. Brzeska 53', '01-673', '552435804', 'Kryspin_Woj96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Sobczak', 'Œciechow', 'ul. 1 Maja 52', '34-176', '995416368', 'Bogumila_Sob98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alice', 'Urbanska', 'Drzymalowice', 'ul. Akademicka 22', '66-040', '458065438', 'Alice_Urb88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anna', 'Sawicka', 'Pakawie', 'ul. Beskidzka 49', '15-848', '506355591', 'Anna_Saw91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jola', 'Sobczak', 'Powalczyn', 'ul. Bozego Ciala 51', '77-281', '726464331', 'Jola_Sob78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornelia', 'Wojciechowska', 'Grabiny', 'ul. Bytomska 19', '79-684', '353164112', 'Kornelia_Woj86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ola', 'Sobczak', 'Kolecko', 'ul. Brzeska 9', '35-247', '295473075', 'Ola_Sob70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Agata', 'Rutkowska', 'Popowlany', 'ul. Bracka 83', '01-101', '481031377', 'Agata_Rut93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornelia', 'Maciejewska', 'Stroszowice', 'ul. Ciasna 94', '32-160', '212967490', 'Kornelia_Mac96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Pamela', 'Ostrowska', 'Dobromierz', 'ul. Stefana Czarnieckiego 76', '19-327', '305915984', 'Pamela_Ost76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Berenika', 'Sikorska', 'Rogienice', 'ul. Krotka 43', '94-283', '809265405', 'Berenika_Sik93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zofia', 'Bak', 'Golaczow', 'ul. Bozego Ciala 85', '77-586', '801282965', 'Zofia_Bak72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Regina', 'Tomaszewska', 'Liskowo', 'ul. Boleslawa Chrobrego 23', '76-096', '950314140', 'Regina_Tom89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Felicja', 'Zielinska', 'Krasice', 'ul. Jozefa Bema 63', '78-215', '549842771', 'Felicja_Zie76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Andzelika', 'Szymczak', 'Centrala', 'ul. 11 Listopada 16', '98-913', '870495939', 'Andzelika_Szy86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Kazmierczak', 'Nielegowo', 'ul. gen. Wladyslawa Andersa 45', '21-472', '368756113', 'Kamila_Kaz82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klara', 'Pietrzak', 'Rybnik', 'ul. Sloneczna 8', '56-804', '955767833', 'Klara_Pie82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Felicja', 'Rutkowska', 'laszkow', 'ul. Brzozowa 39', '21-881', '259595563', 'Felicja_Rut71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lila', 'Borkowska', 'legno', 'ul. Bytomska 45', '62-771', '666971382', 'Lila_Bor79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alana', 'Zakrzewska', 'Podule', 'ul. Stefana Czarnieckiego 10', '52-158', '533828002', 'Alana_Zak74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Felicja', 'Blaszczyk', 'Rumy', 'ul. Brzozowa 44', '57-881', '336911713', 'Felicja_Bla71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Celina', 'Wlodarczyk', 'Lewkow', 'ul. Bankowa 71', '67-243', '534794629', 'Celina_Wlo80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alisa', 'Czerwinska', 'Strubno', 'ul. Beskidzka 3', '88-078', '906387782', 'Alisa_Cze81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anatolia', 'Blaszczyk', 'Kazmierzow', 'ul. Browarna 36', '49-495', '190490475', 'Anatolia_Bla71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alisa', 'Bak', 'Hadle', 'ul. Fryderyka Chopina 44', '70-307', '818769830', 'Alisa_Bak89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jola', 'Brzezinska', 'Kuklin', 'ul. Brzeska 82', '05-069', '717512939', 'Jola_Brz72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dorota', 'Mazur', 'Lisno', 'ul. Boleslawa Chrobrego 91', '76-708', '509033314', 'Dorota_Maz88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Daria', 'Borkowska', 'lankowice', 'ul. Bozego Ciala 63', '17-416', '614822555', 'Daria_Bor92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aisha', 'Maciejewska', 'Topolno', 'ul. Balonowa 30', '60-304', '286469747', 'Aisha_Mac97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Martyna', 'Borkowska', 'Zofian', 'ul. Szkolna 45', '52-256', '208922361', 'Martyna_Bor98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Danuta', 'Stepien', 'Baranow', 'ul. Chorzowska 78', '41-703', '429958142', 'Danuta_Ste95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dorota', 'Jaworska', 'Wyrzeka', 'ul. Balonowa 39', '08-948', '284168909', 'Dorota_Jaw92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Karolina', 'Kucharska', 'Wrotkowo', 'ul. Polna 61', '54-024', '489219656', 'Karolina_Kuc79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Honorata', 'Bak', 'Walentynow', 'ul. Bohaterow Monte Cassino 60', '87-659', '384119605', 'Honorata_Bak96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aniela', 'Chmielewska', 'Kacprowek', 'ul. Bohaterow Monte Cassino 56', '18-610', '276043257', 'Aniela_Chm82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Irena', 'Blaszczyk', 'Strzeczona', 'ul. Piastowska 53', '37-753', '624032606', 'Irena_Bla98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Katarzyna', 'Wojcik', 'Woclawy', 'ul. Fryderyka Chopina 16', '80-637', '589234243', 'Katarzyna_Woj95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Wanda', 'Baran', 'Chruszczewo', 'ul. Piastowska 51', '42-539', '351733253', 'Wanda_Bar88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klara', 'Blaszczyk', 'Malkow', 'ul. Brzozowa 81', '18-977', '459688256', 'Klara_Bla92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Iga', 'Kwiatkowska', 'Dziewietlin', 'ul. Piastowska 66', '93-380', '170061404', 'Iga_Kwi78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alice', 'Sikora', 'Sobienice', 'ul. Brzeska 53', '11-477', '245073024', 'Alice_Sik72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Idalia', 'Dabrowska', 'Byszewice', 'ul. Chlodna 50', '03-129', '826118373', 'Idalia_Dab99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olga', 'Zakrzewska', 'Brda', 'ul. Czestochowska 60', '62-876', '260806334', 'Olga_Zak93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Gabriela', 'Kaczmarczyk', 'Olszowe', 'ul. Bielska 18', '83-586', '604753551', 'Gabriela_Kac98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Idalia', 'Mazur', 'Ostrowce', 'ul. Ciasna 21', '67-470', '647571981', 'Idalia_Maz98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Stanislawa', 'Krupa', 'Klementynowo', 'ul. Brzozowa 79', '29-213', '735786729', 'Stanislawa_Kru75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Angelika', 'Szewczyk', 'Karp', 'ul. Michala Baluckiego 90', '43-387', '667888120', 'Angelika_Sze89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Marciniak', 'Franciszkany', 'ul. Fryderyka Chopina 56', '23-164', '532777163', 'Bogumila_Mar72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aneta', 'Lis', 'Lutogniew', 'ul. Armii Krajowej 48', '75-503', '273682966', 'Aneta_Lis96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Florentyna', 'Malinowska', 'Gomunice', 'ul. Chmielna 64', '57-605', '808075337', 'Florentyna_Mal97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marlena', 'Krajewska', 'Aleksandrowo', 'ul. Stefana Czarnieckiego 95', '81-722', '359467758', 'Marlena_Kra93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Katarzyna', 'Baranowska', 'Korniaktow', 'ul. Michala Baluckiego 67', '85-741', '710841975', 'Katarzyna_Bar80@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marysia', 'Jankowska', 'Osowno', 'ul. Chmielna 95', '38-292', '698494173', 'Marysia_Jan78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Eleonora', 'Lis', 'Mstow', 'ul. 11 Listopada 50', '06-002', '404846926', 'Eleonora_Lis77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ewelina', 'Sokolowska', 'Waliny', 'ul. Kwiatowa 19', '00-629', '402530523', 'Ewelina_Sok84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ada', 'Kaczmarczyk', 'Boreczno', 'ul. Fryderyka Chopina 89', '21-613', '264783659', 'Ada_Kac77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Barbara', 'Zalewska', 'Gwizdanow', 'ul. Stefana Czarnieckiego 85', '88-319', '461911880', 'Barbara_Zal77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Magdalena', 'Brzezinska', 'Boroszewko', 'ul. Akademicka 72', '72-404', '760573372', 'Magdalena_Brz86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Natalia', 'Marciniak', 'zegoty', 'ul. Brzeska 5', '97-379', '586954330', 'Natalia_Mar82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Olga', 'Kaczmarczyk', 'Korzekwin', 'ul. Ciasna 23', '96-032', '579852614', 'Olga_Kac77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Walczak', 'Sawin', 'ul. Bozego Ciala 4', '20-490', '897247950', 'Hortensja_Wal98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Wasilewska', 'Matejki', 'ul. Boleslawa Chrobrego 19', '37-833', '534296568', 'Beata_Was93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Patrycja', 'Krupa', 'Klodawka', 'ul. Browarna 6', '42-692', '841706247', 'Patrycja_Kru81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lara', 'Wojcik', 'Miekowo', 'ul. 1 Maja 55', '29-366', '889735006', 'Lara_Woj81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julianna', 'Lewandowska', 'Podlas', 'ul. Bankowa 9', '45-920', '539739709', 'Julianna_Lew77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Idalia', 'Jakubowska', 'Komaszowka', 'ul. Stefana Czarnieckiego 32', '18-539', '445688678', 'Idalia_Jak72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Antonina', 'Malinowska', 'Piechoty', 'ul. Kwiatowa 81', '84-415', '605266647', 'Antonina_Mal92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Otylia', 'Kaminska', 'Sieganow', 'ul. Sloneczna 46', '98-359', '777221433', 'Otylia_Kam78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alana', 'Maciejewska', 'Pniewki', 'ul. Beskidzka 34', '31-549', '261024963', 'Alana_Mac72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Izabela', 'Kwiatkowska', 'Matyldzin', 'ul. Beskidzka 57', '32-163', '159508519', 'Izabela_Kwi77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jola', 'Jankowska', 'Maruszkowo', 'ul. Chorzowska 75', '71-310', '462053734', 'Jola_Jan91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Weronika', 'Lewandowska', 'Wojtkowizna', 'ul. Brzeska 95', '03-601', '490070780', 'Weronika_Lew70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Izyda', 'Baranowska', 'Koclin', 'ul. Bielska 40', '32-875', '467312479', 'Izyda_Bar76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kaja', 'Chmielewska', 'Stawiguda', 'ul. Krotka 20', '40-630', '275042044', 'Kaja_Chm94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aniela', 'Stepien', 'Wichrowice', 'ul. Michala Baluckiego 69', '38-982', '558207410', 'Aniela_Ste84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bianka', 'Sokolowska', 'Maslonskie', 'ul. Jozefa Bema 24', '26-546', '297765837', 'Bianka_Sok75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Jakubowska', 'Krajenki', 'ul. 3 Maja 41', '92-295', '999760616', 'Beata_Jak75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Matylda', 'Zawadzka', 'Grobla', 'ul. Browarna 69', '40-640', '868439839', 'Matylda_Zaw79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Sylwia', 'Tomaszewska', 'Ryczki', 'ul. Lipowa 88', '09-558', '102660100', 'Sylwia_Tom94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ewelina', 'Baranowska', 'Marulew', 'ul. Ciasna 58', '33-058', '889512077', 'Ewelina_Bar91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julia', 'Zakrzewska', 'Brzyszewo', 'ul. Lipowa 78', '83-891', '433686136', 'Julia_Zak98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jagoda', 'Glowacka', 'Jedrzejki', 'ul. Jozefa Bema 71', '49-937', '562334809', 'Jagoda_Glo82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Gajewska', 'Oporow', 'ul. Bohaterow Monte Cassino 47', '35-124', '296229122', 'Kamila_Gaj97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornelia', 'Baran', 'Rogiedle', 'ul. Chorzowska 9', '28-630', '540213069', 'Kornelia_Bar89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominika', 'Adamska', 'Golawin', 'ul. Kwiatowa 29', '05-039', '671334296', 'Dominika_Ada91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('zaneta', 'Wysocka', 'Drybus', 'ul. 3 Maja 50', '19-231', '475551075', 'zaneta_Wys87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Malwina', 'Krajewska', 'Redociny', 'ul. Ciasna 22', '45-626', '140589856', 'Malwina_Kra81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornelia', 'Borkowska', 'Salino', 'ul. Dluga 98', '24-704', '521740079', 'Kornelia_Bor97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Paula', 'Kucharska', 'Parezki', 'ul. Dluga 36', '13-743', '266359083', 'Paula_Kuc87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Martyna', 'Baran', 'Synogac', 'ul. Bernadynska 7', '84-753', '891958766', 'Martyna_Bar70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lucyna', 'Gorska', 'Wrocikowo', 'ul. Lipowa 77', '37-221', '742873974', 'Lucyna_Gor72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lila', 'Stepien', 'Pruchna', 'ul. Chorzowska 87', '93-117', '995081188', 'Lila_Ste97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maja', 'Baranowska', 'Jerutki', 'ul. Armii Krajowej 43', '06-484', '818467514', 'Maja_Bar70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lila', 'Andrzejewska', 'Golejewko', 'ul. Bozego Ciala 94', '30-651', '871763434', 'Lila_And76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jowita', 'Jaworska', 'Chojecin', 'ul. Balonowa 62', '30-526', '106955425', 'Jowita_Jaw74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klara', 'Bak', 'Koszelew', 'ul. 11 Listopada 10', '28-928', '821593784', 'Klara_Bak95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Weronika', 'Krawczyk', 'Kantorowka', 'ul. Bernadynska 10', '81-452', '613744389', 'Weronika_Kra94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kinga', 'Jankowska', 'Jastrzebsko', 'ul. Polna 43', '77-013', '254275109', 'Kinga_Jan76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Joanna', 'Kowalska', 'Wadochowice', 'ul. Dluga 70', '05-925', '732763347', 'Joanna_Kow74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jola', 'Pietrzak', 'Suliszewo', 'ul. Ciasna 94', '24-838', '434468513', 'Jola_Pie72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alana', 'Laskowska', 'Klonna', 'ul. Fryderyka Chopina 8', '69-531', '598706743', 'Alana_Las95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Oksana', 'Zakrzewska', 'Otalazka', 'ul. Bernadynska 26', '61-956', '977396672', 'Oksana_Zak99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogna', 'Blaszczyk', 'Dalecino', 'ul. Kwiatowa 49', '10-629', '746104124', 'Bogna_Bla71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jozefa', 'Kucharska', 'Jablonowo', 'ul. Bozego Ciala 7', '12-411', '739583636', 'Jozefa_Kuc93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kaja', 'Andrzejewska', 'Klebanowice', 'ul. Czestochowska 80', '41-796', '137513805', 'Kaja_And70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ewa', 'Kucharska', 'Tuszyn', 'ul. Bozego Ciala 99', '83-359', '690396549', 'Ewa_Kuc75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogna', 'Makowska', 'Goledzin', 'ul. Bracka 42', '56-392', '518414594', 'Bogna_Mak88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Czeslawa', 'Urbanska', 'Tlukawy', 'ul. Chmielna 1', '24-750', '342201325', 'Czeslawa_Urb73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Aleksandra', 'Mazur', 'Julianka', 'ul. Boleslawa Chrobrego 45', '23-355', '773527978', 'Aleksandra_Maz89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Nikola', 'Dabrowska', 'Radosze', 'ul. Bernadynska 85', '70-360', '252773794', 'Nikola_Dab98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Florencja', 'Kowalczyk', 'Plotno', 'ul. Ciasna 18', '72-147', '214407480', 'Florencja_Kow81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kaja', 'Witkowska', 'Topor', 'ul. Bracka 95', '52-288', '969402277', 'Kaja_Wit88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Makowska', 'Skokowa', 'ul. Dluga 85', '32-577', '532018514', 'Kamila_Mak88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Wioletta', 'Szymczak', 'Baranowo', 'ul. Lesna 41', '05-146', '991375604', 'Wioletta_Szy93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcela', 'Bak', 'Szczelatyn', 'ul. Polna 50', '41-921', '591420864', 'Marcela_Bak82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcela', 'Sadowska', 'Uniechow', 'ul. Brzeska 68', '71-853', '375713319', 'Marcela_Sad93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maja', 'Szymczak', 'Bawernica', 'ul. Michala Baluckiego 48', '78-996', '582464311', 'Maja_Szy83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jolanta', 'Krupa', 'Studzionki', 'ul. Chmielna 45', '21-190', '593997602', 'Jolanta_Kru81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Malgorzata', 'Zakrzewska', 'Galki', 'ul. Czestochowska 43', '21-895', '827917865', 'Malgorzata_Zak78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Eliza', 'Gorecka', 'Ronica', 'ul. Boleslawa Chrobrego 74', '20-801', '376030349', 'Eliza_Gor70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kornelia', 'Wojcik', 'zuraw', 'ul. Bracka 71', '09-200', '686768828', 'Kornelia_Woj93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Idalia', 'Nowak', 'Witoroz', 'ul. Lipowa 87', '76-725', '300496332', 'Idalia_Now97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jagoda', 'Cieœlak', 'Plutniki', 'ul. Kwiatowa 24', '06-303', '603423900', 'Jagoda_Cie94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Agata', 'Wojciechowska', 'Bialoborze', 'ul. Bytomska 71', '32-399', '510897486', 'Agata_Woj73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dominika', 'Baran', 'Chlopowko', 'ul. Bankowa 16', '49-993', '641127051', 'Dominika_Bar72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Patrycja', 'Glowacka', 'Duba', 'ul. Polna 26', '76-812', '204352443', 'Patrycja_Glo77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klara', 'Marciniak', 'Wielki', 'ul. Fryderyka Chopina 29', '15-872', '398737663', 'Klara_Mar82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Irena', 'Czarnecka', 'Sokolowy', 'ul. Akademicka 38', '76-109', '728487766', 'Irena_Cza96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zofia', 'Jankowska', 'Gasawa', 'ul. Kwiatowa 10', '00-093', '469410961', 'Zofia_Jan82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Justyna', 'Urbanska', 'Bukownica', 'ul. Bohaterow Monte Cassino 32', '29-325', '693463620', 'Justyna_Urb73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Roksana', 'Wiœniewska', 'Tomiszewo', 'ul. Ogrodowa 11', '91-906', '111258638', 'Roksana_Wiœ86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Teresa', 'Bak', 'Grodyslawice', 'ul. Szkolna 70', '30-857', '842739556', 'Teresa_Bak88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Matylda', 'Kaminska', 'Jarochowek', 'ul. Bankowa 64', '67-912', '461293408', 'Matylda_Kam95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zofia', 'Kowalska', 'Piasecznia', 'ul. Akademicka 8', '90-467', '137267380', 'Zofia_Kow76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Szymczak', 'Slowienkowo', 'ul. Kwiatowa 24', '25-389', '226377275', 'Beata_Szy96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Elzbieta', 'Wroblewska', 'Kryszkowice', 'ul. 3 Maja 11', '67-434', '922509572', 'Elzbieta_Wro87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Michalak', 'Braszczok', 'ul. Fryderyka Chopina 12', '44-884', '353414635', 'Beata_Mic71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dagmara', 'Bak', 'Blednica', 'ul. Fryderyka Chopina 38', '21-439', '367302179', 'Dagmara_Bak98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klara', 'Michalak', 'Przaslaw', 'ul. Boleslawa Chrobrego 42', '72-240', '788063404', 'Klara_Mic84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Edyta', 'Sokolowska', 'Myœleta', 'ul. Ciasna 78', '42-099', '840123749', 'Edyta_Sok96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ewa', 'Wroblewska', 'Tuczna', 'ul. Kwiatowa 78', '46-999', '426964094', 'Ewa_Wro76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alice', 'Zalewska', 'Bielen', 'ul. Bozego Ciala 3', '00-933', '963176251', 'Alice_Zal87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Konstancja', 'Czarnecka', 'Brodzce', 'ul. Lipowa 39', '96-434', '982968417', 'Konstancja_Cza94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maria', 'Kowalska', 'Obarzym', 'ul. gen. Wladyslawa Andersa 41', '77-171', '161871997', 'Maria_Kow97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Liliana', 'Kolodziej', 'Miszkieniki', 'ul. Krotka 31', '71-894', '708424046', 'Liliana_Kol73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lucyna', 'Sokolowska', 'Skowronno', 'ul. Michala Baluckiego 28', '88-636', '735285832', 'Lucyna_Sok99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Florencja', 'Kaminska', 'Ksawerow', 'ul. Michala Baluckiego 20', '89-541', '861925495', 'Florencja_Kam93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anna', 'Baran', 'Siecieborowice', 'ul. Akademicka 19', '09-583', '809469947', 'Anna_Bar96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcelina', 'Lis', 'Wietrzychowo', 'ul. Ciasna 29', '27-878', '107780060', 'Marcelina_Lis94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Magdalena', 'Kubiak', 'Lubieszow', 'ul. Bracka 47', '77-975', '928410344', 'Magdalena_Kub76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Asia', 'Zawadzka', 'Kowrozek', 'ul. Czestochowska 84', '93-613', '251038122', 'Asia_Zaw74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Kazmierczak', 'lubiana', 'ul. Boleslawa Chrobrego 5', '83-453', '558169400', 'Bogumila_Kaz76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dagmara', 'Andrzejewska', 'Koniecmosty', 'ul. Czestochowska 68', '17-648', '407716987', 'Dagmara_And90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Wiktoria', 'Sadowska', 'Kryry', 'ul. Polna 21', '21-233', '437928755', 'Wiktoria_Sad77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adrianna', 'Bak', 'Chodubka', 'ul. Chorzowska 54', '21-848', '415283426', 'Adrianna_Bak79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Julianna', 'Witkowska', 'Ksiazniczki', 'ul. 1 Maja 67', '95-114', '234283026', 'Julianna_Wit98@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Roksana', 'Borkowska', 'Kolaki', 'ul. Ogrodowa 87', '25-167', '847102362', 'Roksana_Bor95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Jadwiga', 'Sadowska', 'Borkowo', 'ul. Dluga 58', '02-440', '339671616', 'Jadwiga_Sad89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adela', 'Baranowska', 'Zabinowice', 'ul. Michala Baluckiego 64', '82-928', '351406049', 'Adela_Bar89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ewa', 'Dabrowska', 'Trabki', 'ul. Bracka 86', '35-311', '923144885', 'Ewa_Dab85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Liliana', 'Lis', 'Stojowice', 'ul. Chmielna 92', '56-685', '204232304', 'Liliana_Lis77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Izyda', 'Wozniak', 'Œwierczynek', 'ul. Armii Krajowej 58', '99-459', '584864742', 'Izyda_Woz77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Amanda', 'Zalewska', 'Celiny', 'ul. Balonowa 43', '06-721', '267538769', 'Amanda_Zal85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alice', 'Stepien', 'Godziszow', 'ul. gen. Wladyslawa Andersa 38', '01-823', '206232519', 'Alice_Ste77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Czeslawa', 'Zakrzewska', 'Adamusy', 'ul. Bielska 92', '06-851', '437370308', 'Czeslawa_Zak95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Helena', 'Szczepanska', 'Nieglawki', 'ul. Brzeska 87', '02-988', '101314381', 'Helena_Szc82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marlena', 'Kwiatkowska', 'Promno', 'ul. 1 Maja 34', '76-477', '415667566', 'Marlena_Kwi90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Stefania', 'Zielinska', 'Kotarszyn', 'ul. Lesna 88', '71-887', '868134841', 'Stefania_Zie72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adriana', 'Baranowska', 'Sudolek', 'ul. Chlodna 92', '58-409', '208982336', 'Adriana_Bar81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Berenika', 'Nowak', 'Olszewnik', 'ul. Brzeska 74', '06-833', '832866849', 'Berenika_Now77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Otylia', 'Zalewska', 'Cygow', 'ul. Stefana Czarnieckiego 95', '56-474', '805151464', 'Otylia_Zal84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Kwiatkowska', 'Kruglo', 'ul. Dluga 83', '86-741', '421271320', 'Hortensja_Kwi90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Adriana', 'Adamska', 'Bialorzeczka', 'ul. Michala Baluckiego 9', '20-564', '930239584', 'Adriana_Ada77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Judyta', 'Gorska', 'Wychowaniec', 'ul. Balonowa 67', '53-266', '852964196', 'Judyta_Gor96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Matylda', 'Jakubowska', 'Koœcieleczki', 'ul. Balonowa 60', '02-515', '775461382', 'Matylda_Jak96@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Amelia', 'Wojcik', 'Dzielec', 'ul. Michala Baluckiego 4', '29-074', '484255965', 'Amelia_Woj79@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zuzanna', 'Zielinska', 'Brenik', 'ul. 11 Listopada 38', '05-699', '993217120', 'Zuzanna_Zie72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Liliana', 'Andrzejewska', 'lawszowa', 'ul. Akademicka 96', '21-163', '221699868', 'Liliana_And81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcela', 'Makowska', 'Gutanow', 'ul. Michala Baluckiego 76', '96-006', '176174803', 'Marcela_Mak82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Balbina', 'Witkowska', 'Krasow', 'ul. Boleslawa Chrobrego 11', '40-248', '216736284', 'Balbina_Wit81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klementyna', 'Wozniak', 'Szczerbin', 'ul. gen. Wladyslawa Andersa 41', '22-780', '261665626', 'Klementyna_Woz70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Franciszka', 'Rutkowska', 'Zbory', 'ul. Bankowa 45', '64-210', '738972013', 'Franciszka_Rut71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Kalinowska', 'Golebin', 'ul. Bankowa 16', '58-840', '736989752', 'Hortensja_Kal75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marcelina', 'Ziolkowska', 'Bobrowiska', 'ul. Czestochowska 81', '34-196', '207860556', 'Marcelina_Zio81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bianka', 'Krawczyk', 'Wojtowce', 'ul. Krotka 28', '90-492', '400998425', 'Bianka_Kra99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Helena', 'Piotrowska', 'Liza', 'ul. Browarna 68', '59-051', '328829626', 'Helena_Pio85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Maja', 'Urbanska', 'Szczurkowo', 'ul. Fryderyka Chopina 13', '14-927', '149005027', 'Maja_Urb76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Kowalska', 'Zajma', 'ul. Michala Baluckiego 33', '74-658', '188721046', 'Bogumila_Kow74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dagmara', 'Zakrzewska', 'Litwinowicze', 'ul. Balonowa 7', '57-638', '324369319', 'Dagmara_Zak76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Dagmara', 'Kaczmarczyk', 'Strzelino', 'ul. 3 Maja 14', '68-834', '913431493', 'Dagmara_Kac92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Elwira', 'Wlodarczyk', 'Rogozino', 'ul. 11 Listopada 41', '53-821', '898437905', 'Elwira_Wlo78@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Milena', 'Walczak', 'Puchaczow', 'ul. Bozego Ciala 17', '19-342', '911642373', 'Milena_Wal86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Judyta', 'Kazmierczak', 'Waszkowo', 'ul. Stefana Czarnieckiego 22', '30-533', '325863704', 'Judyta_Kaz99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klaudia', 'Brzezinska', 'Niemstow', 'ul. Armii Krajowej 53', '43-063', '757387338', 'Klaudia_Brz97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Krawczyk', 'Przerab', 'ul. Bozego Ciala 66', '84-329', '409652734', 'Beata_Kra85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Kaczmarczyk', 'Keblowice', 'ul. Fryderyka Chopina 61', '45-508', '507211237', 'Bogumila_Kac95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Diana', 'Kubiak', 'Petrykozy', 'ul. Jozefa Bema 41', '96-126', '151161310', 'Diana_Kub77@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alisa', 'Kubiak', 'Szeligowo', 'ul. Michala Baluckiego 21', '88-773', '306340478', 'Alisa_Kub92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Matylda', 'Kaczmarczyk', 'Zgorze', 'ul. Browarna 41', '30-080', '654730826', 'Matylda_Kac86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Weronika', 'Walczak', 'Humin', 'ul. gen. Wladyslawa Andersa 15', '40-607', '400284513', 'Weronika_Wal75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Mazurek', 'Glinik', 'ul. Bytomska 98', '61-586', '930255488', 'Kamila_Maz87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Nina', 'Jakubowska', 'Malonowo', 'ul. Chlodna 51', '27-122', '526235726', 'Nina_Jak86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Paula', 'Czerwinska', 'Dzwonowice', 'ul. lakowa 35', '32-279', '355548337', 'Paula_Cze70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Faustyna', 'Duda', 'Bietowo', 'ul. Ogrodowa 82', '57-458', '584279998', 'Faustyna_Dud84@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anastazja', 'Baranowska', 'Przytyk', 'ul. Armii Krajowej 98', '00-183', '143092915', 'Anastazja_Bar89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Angelika', 'Brzezinska', 'Biskupice', 'ul. Lesna 67', '63-259', '744605269', 'Angelika_Brz75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Berenika', 'Sikorska', 'Liwin', 'ul. 1 Maja 80', '70-974', '904694263', 'Berenika_Sik82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Celina', 'Czerwinska', 'Orla', 'ul. Lesna 89', '92-591', '300379337', 'Celina_Cze87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marzanna', 'Piotrowska', 'Greboszow', 'ul. Bozego Ciala 88', '62-930', '888062439', 'Marzanna_Pio72@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Elena', 'Blaszczyk', 'Jesionowiec', 'ul. Beskidzka 41', '67-344', '999818919', 'Elena_Bla71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Malgorzata', 'Wasilewska', 'Parcele', 'ul. Chorzowska 52', '21-975', '251660274', 'Malgorzata_Was83@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Roza', 'Michalak', 'Buczkowice', 'ul. Stefana Czarnieckiego 7', '16-166', '325222325', 'Roza_Mic87@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anita', 'Sikorska', 'Zbyszyno', 'ul. Sloneczna 90', '60-220', '185773899', 'Anita_Sik81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Blanka', 'Glowacka', 'Krzyczew', 'ul. Balonowa 85', '51-612', '938199668', 'Blanka_Glo88@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Amanda', 'Walczak', 'zdzarki', 'ul. Chorzowska 3', '08-878', '252756106', 'Amanda_Wal89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Elena', 'Kubiak', 'Rzesna', 'ul. Czestochowska 93', '90-985', '467991751', 'Elena_Kub81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Halina', 'Gajewska', 'Szpon', 'ul. lakowa 33', '94-161', '547688332', 'Halina_Gaj74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Magda', 'Nowak', 'Bierzglinek', 'ul. Bracka 37', '87-354', '252758890', 'Magda_Now97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Irena', 'Wojcik', 'Koroszczyn', 'ul. Chmielna 47', '16-658', '285420952', 'Irena_Woj81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Krystyna', 'Maciejewska', 'Pockuny', 'ul. Bernadynska 65', '67-021', '690721460', 'Krystyna_Mac75@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Maciejewska', 'Jedrzychowiczki', 'ul. Bernadynska 14', '71-233', '624158963', 'Kamila_Mac94@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Szczepanska', 'Stregoborzyce', 'ul. Chlodna 90', '84-513', '558455922', 'Hortensja_Szc73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Balbina', 'Piotrowska', 'Nieboczowy', 'ul. Piastowska 21', '64-266', '509667520', 'Balbina_Pio92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Malwina', 'Tomaszewska', 'Repetajka', 'ul. Balonowa 95', '46-193', '305038479', 'Malwina_Tom74@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Daniela', 'Borkowska', 'Sieburczyn', 'ul. Bielska 41', '00-602', '177421601', 'Daniela_Bor81@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Anna', 'Sadowska', 'Kronowo', 'ul. Balonowa 56', '78-563', '987807997', 'Anna_Sad89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Dabrowska', 'Sadkowski', 'ul. Piastowska 27', '94-359', '802070886', 'Hortensja_Dab99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Magda', 'Kazmierczak', 'Skopow', 'ul. Chmielna 97', '51-238', '477569161', 'Magda_Kaz73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Marta', 'Piotrowska', 'Andrzejewo', 'ul. Lipowa 94', '46-726', '460061160', 'Marta_Pio86@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Alana', 'Przybylska', 'Chrapczew', 'ul. Chorzowska 2', '23-981', '698207775', 'Alana_Prz76@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Katarzyna', 'Marciniak', 'Przymiarki', 'ul. Piastowska 80', '92-671', '456339204', 'Katarzyna_Mar89@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kinga', 'Szczepanska', 'Rypin', 'ul. lakowa 14', '08-267', '455944991', 'Kinga_Szc95@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Ola', 'Nowak', 'Krzyzanowka', 'ul. Ciasna 29', '84-909', '147152627', 'Ola_Now70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogna', 'Krawczyk', 'Orzechowce', 'ul. Browarna 36', '95-029', '943103239', 'Bogna_Kra91@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Boguslawa', 'Zakrzewska', 'Kuligowo', 'ul. Beskidzka 70', '43-279', '176118633', 'Boguslawa_Zak82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Otylia', 'Brzezinska', 'Stama', 'ul. 3 Maja 93', '66-263', '686281083', 'Otylia_Brz99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Hortensja', 'Piotrowska', 'Przeryty', 'ul. Szkolna 20', '86-722', '668081360', 'Hortensja_Pio82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zofia', 'Czarnecka', 'Stojewsko', 'ul. Armii Krajowej 80', '34-761', '189346786', 'Zofia_Cza73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Beata', 'Stepien', 'Junoszyn', 'ul. 1 Maja 32', '30-080', '407660842', 'Beata_Ste99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Kamila', 'Sawicka', 'Blogoslawie', 'ul. Balonowa 20', '82-119', '882692108', 'Kamila_Saw90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Roksana', 'Witkowska', 'Grabiazek', 'ul. Bankowa 82', '95-451', '681052086', 'Roksana_Wit85@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Sylwia', 'Zielinska', 'Kossaki', 'ul. Beskidzka 18', '70-191', '698774316', 'Sylwia_Zie97@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Lara', 'Gorecka', 'lazow', 'ul. Chorzowska 84', '67-243', '214221277', 'Lara_Gor82@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Otylia', 'Kalinowska', 'Krepa', 'ul. 3 Maja 72', '97-828', '888168723', 'Otylia_Kal93@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Brzezinska', 'Oporowo', 'ul. Stefana Czarnieckiego 56', '09-835', '821106610', 'Bogumila_Brz99@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Wiktoria', 'Gorska', 'Malczew', 'ul. Polna 76', '50-265', '972867408', 'Wiktoria_Gor70@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Zuza', 'Baran', 'Komilowo', 'ul. Balonowa 52', '37-234', '816394813', 'Zuza_Bar90@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Klaudia', 'Baranowska', 'Szwaruny', 'ul. Bracka 9', '05-032', '811359864', 'Klaudia_Bar92@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Bogumila', 'Kalinowska', 'Plecewice', 'ul. Sloneczna 48', '66-087', '244647086', 'Bogumila_Kal73@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Natasza', 'Baran', 'Dobropole', 'ul. Bankowa 74', '71-712', '804474627', 'Natasza_Bar71@gmail.com');

INSERT INTO KLIENT (IMIE, NAZWISKO, miejscowosc, ADRES, KOD_POCZTOWY, TELEFON, EMAIL) 
VALUES ('Natasza', 'Sokolowska', 'Szerenosy', 'ul. Akademicka 33', '14-101', '848433505', 'Natasza_Sok91@gmail.com');

insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Core i5 10400F, 2.9GHz, 12 MB, BOX',
    719.99,
    0.40,
    1,
    1
);

insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Core i7 10700K, 3.8GHz, 16 MB, BOX',
    1649.99,
    0.45,
    1,
    1
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Ryzen 5 3600, 3.6GHz, 32MB, BOX',
    935.00,
    0.40,
    1,
    2
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Ryzen 5 3500X, 3.6GHz, 32MB, BOX',
    779.99,
    0.42,
    1,
    2
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Ryzen 7 3700X, 3.6GHz, 32MB, BOX',
    1429.99,
    0.50,
    1,
    2
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Radeon RX 570',
    1989.99,
    0.40,
    2,
    2
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Radeon RX 6800',
    5199.99,
    0.30,
    2,
    2
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'GeForce RTX 2060',
    2199.99,
    0.35,
    2,
    3
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'GeForce GTX 1050Ti',
    1199.99,
    0.40,
    2,
    3
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'GeForce RTX 3090',
    9999.99,
    0.25,
    2,
    3
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Signum SG7V TG',
    359.99,
    0.40,
    3,
    4
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Regnum RG4 Pure Black',
    179.99,
    0.45,
    3,
    4
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Armis AR1',
    119.99,
    0.40,
    3,
    4
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Obsidian 500D Premium TG',
    749.99,
    0.35,
    3,
    5
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'Carbide 270R',
    299.99,
    0.30,
    3,
    5
);
insert into produkt
(nazwa_produktu,cena,marza,id_kategorii,id_producenta)
values
(
    'SPEC-04',
    344.99,
    0.35,
    3,
    5
);
SET DEFINE OFF

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 1);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 1);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 1);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 2);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 2);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 2);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 3);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 3);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 3);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 4);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 4);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 4);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 5);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 5);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 5);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 6);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 6);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 6);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 7);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 7);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 7);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 8);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 8);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 8);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 9);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 9);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 9);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 10);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 10);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 10);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 11);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 11);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 11);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 12);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 12);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 12);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 13);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 13);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 13);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 14);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 14);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 14);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 15);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 15);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 15);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (1, 16);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (2, 16);

INSERT INTO ZAPAS (ID_SKLEPU, ID_PRODUKTU) 
VALUES (3, 16);


SET DEFINE OFF

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/14', 'RRRR-MM-DD'), to_date('2020/07/17', 'RRRR-MM-DD'), to_date('2020/07/17', 'RRRR-MM-DD'), 'Dostarczono', 410, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/06', 'RRRR-MM-DD'), to_date('2020/11/09', 'RRRR-MM-DD'), to_date('2020/11/11', 'RRRR-MM-DD'), 'Dostarczono', 412, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/03', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), to_date('2019/01/08', 'RRRR-MM-DD'), 'Dostarczono', 418, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/11', 'RRRR-MM-DD'), to_date('2019/06/14', 'RRRR-MM-DD'), to_date('2019/06/17', 'RRRR-MM-DD'), 'Dostarczono', 160, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/13', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), to_date('2020/03/19', 'RRRR-MM-DD'), 'Dostarczono', 332, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/04', 'RRRR-MM-DD'), to_date('2020/03/07', 'RRRR-MM-DD'), to_date('2020/03/08', 'RRRR-MM-DD'), 'Dostarczono', 451, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/18', 'RRRR-MM-DD'), to_date('2020/11/21', 'RRRR-MM-DD'), to_date('2020/11/23', 'RRRR-MM-DD'), 'Dostarczono', 48, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/09', 'RRRR-MM-DD'), to_date('2019/03/12', 'RRRR-MM-DD'), to_date('2019/03/14', 'RRRR-MM-DD'), 'Dostarczono', 19, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/21', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), 'Dostarczono', 359, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/21', 'RRRR-MM-DD'), to_date('2020/11/24', 'RRRR-MM-DD'), to_date('2020/11/23', 'RRRR-MM-DD'), 'Dostarczono', 39, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/05', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), 'Dostarczono', 358, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/25', 'RRRR-MM-DD'), to_date('2020/02/28', 'RRRR-MM-DD'), to_date('2020/02/28', 'RRRR-MM-DD'), 'Dostarczono', 46, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/25', 'RRRR-MM-DD'), to_date('2020/10/28', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), 'Dostarczono', 139, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/22', 'RRRR-MM-DD'), to_date('2020/11/21', 'RRRR-MM-DD'), 'Dostarczono', 482, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), 'Dostarczono', 473, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/03', 'RRRR-MM-DD'), to_date('2019/12/06', 'RRRR-MM-DD'), to_date('2019/12/05', 'RRRR-MM-DD'), 'Dostarczono', 30, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/12', 'RRRR-MM-DD'), to_date('2020/12/15', 'RRRR-MM-DD'), to_date('2020/12/16', 'RRRR-MM-DD'), 'Dostarczono', 11, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/27', 'RRRR-MM-DD'), to_date('2019/08/30', 'RRRR-MM-DD'), to_date('2019/09/01', 'RRRR-MM-DD'), 'Dostarczono', 23, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/28', 'RRRR-MM-DD'), to_date('2019/07/01', 'RRRR-MM-DD'), to_date('2019/07/04', 'RRRR-MM-DD'), 'Dostarczono', 417, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/24', 'RRRR-MM-DD'), to_date('2019/09/27', 'RRRR-MM-DD'), to_date('2019/09/26', 'RRRR-MM-DD'), 'Dostarczono', 183, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/21', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/25', 'RRRR-MM-DD'), 'Dostarczono', 276, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/16', 'RRRR-MM-DD'), to_date('2020/06/19', 'RRRR-MM-DD'), to_date('2020/06/21', 'RRRR-MM-DD'), 'Dostarczono', 293, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/19', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), to_date('2020/02/21', 'RRRR-MM-DD'), 'Dostarczono', 497, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/17', 'RRRR-MM-DD'), to_date('2019/09/20', 'RRRR-MM-DD'), to_date('2019/09/19', 'RRRR-MM-DD'), 'Dostarczono', 173, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/16', 'RRRR-MM-DD'), to_date('2019/05/19', 'RRRR-MM-DD'), to_date('2019/05/22', 'RRRR-MM-DD'), 'Dostarczono', 319, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/02', 'RRRR-MM-DD'), to_date('2019/08/05', 'RRRR-MM-DD'), to_date('2019/08/04', 'RRRR-MM-DD'), 'Dostarczono', 422, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/27', 'RRRR-MM-DD'), to_date('2020/11/30', 'RRRR-MM-DD'), to_date('2020/12/03', 'RRRR-MM-DD'), 'Dostarczono', 433, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/08', 'RRRR-MM-DD'), to_date('2020/03/11', 'RRRR-MM-DD'), to_date('2020/03/14', 'RRRR-MM-DD'), 'Dostarczono', 322, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/26', 'RRRR-MM-DD'), to_date('2019/08/29', 'RRRR-MM-DD'), to_date('2019/08/28', 'RRRR-MM-DD'), 'Dostarczono', 32, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/04', 'RRRR-MM-DD'), to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/09', 'RRRR-MM-DD'), 'Dostarczono', 125, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/07', 'RRRR-MM-DD'), to_date('2019/07/10', 'RRRR-MM-DD'), to_date('2019/07/12', 'RRRR-MM-DD'), 'Dostarczono', 335, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/21', 'RRRR-MM-DD'), to_date('2020/09/24', 'RRRR-MM-DD'), to_date('2020/09/27', 'RRRR-MM-DD'), 'Dostarczono', 211, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/18', 'RRRR-MM-DD'), to_date('2019/03/21', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), 'Dostarczono', 423, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/08', 'RRRR-MM-DD'), to_date('2020/01/11', 'RRRR-MM-DD'), to_date('2020/01/12', 'RRRR-MM-DD'), 'Dostarczono', 317, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/25', 'RRRR-MM-DD'), to_date('2020/10/28', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), 'Dostarczono', 351, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/02', 'RRRR-MM-DD'), to_date('2020/02/05', 'RRRR-MM-DD'), to_date('2020/02/07', 'RRRR-MM-DD'), 'Dostarczono', 404, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/07', 'RRRR-MM-DD'), to_date('2019/10/10', 'RRRR-MM-DD'), to_date('2019/10/12', 'RRRR-MM-DD'), 'Dostarczono', 18, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/19', 'RRRR-MM-DD'), to_date('2019/05/22', 'RRRR-MM-DD'), to_date('2019/05/24', 'RRRR-MM-DD'), 'Dostarczono', 87, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/12', 'RRRR-MM-DD'), to_date('2020/07/15', 'RRRR-MM-DD'), to_date('2020/07/17', 'RRRR-MM-DD'), 'Dostarczono', 228, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/19', 'RRRR-MM-DD'), to_date('2019/06/22', 'RRRR-MM-DD'), to_date('2019/06/22', 'RRRR-MM-DD'), 'Dostarczono', 190, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/21', 'RRRR-MM-DD'), 'Dostarczono', 101, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/05', 'RRRR-MM-DD'), to_date('2019/09/08', 'RRRR-MM-DD'), to_date('2019/09/08', 'RRRR-MM-DD'), 'Dostarczono', 349, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/16', 'RRRR-MM-DD'), to_date('2019/02/19', 'RRRR-MM-DD'), to_date('2019/02/22', 'RRRR-MM-DD'), 'Dostarczono', 182, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/24', 'RRRR-MM-DD'), to_date('2019/04/27', 'RRRR-MM-DD'), to_date('2019/04/30', 'RRRR-MM-DD'), 'Dostarczono', 166, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/11', 'RRRR-MM-DD'), to_date('2019/10/14', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), 'Dostarczono', 442, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/02', 'RRRR-MM-DD'), to_date('2020/08/05', 'RRRR-MM-DD'), to_date('2020/08/05', 'RRRR-MM-DD'), 'Dostarczono', 337, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/24', 'RRRR-MM-DD'), to_date('2020/08/27', 'RRRR-MM-DD'), to_date('2020/08/30', 'RRRR-MM-DD'), 'Dostarczono', 53, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/09', 'RRRR-MM-DD'), to_date('2019/12/12', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), 'Dostarczono', 307, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/04', 'RRRR-MM-DD'), to_date('2019/11/07', 'RRRR-MM-DD'), to_date('2019/11/06', 'RRRR-MM-DD'), 'Dostarczono', 15, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/05', 'RRRR-MM-DD'), to_date('2020/02/08', 'RRRR-MM-DD'), to_date('2020/02/07', 'RRRR-MM-DD'), 'Dostarczono', 282, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), to_date('2020/04/21', 'RRRR-MM-DD'), 'Dostarczono', 445, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/01', 'RRRR-MM-DD'), to_date('2020/07/04', 'RRRR-MM-DD'), to_date('2020/07/03', 'RRRR-MM-DD'), 'Dostarczono', 262, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/12', 'RRRR-MM-DD'), to_date('2020/09/15', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), 'Dostarczono', 272, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/23', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/29', 'RRRR-MM-DD'), 'Dostarczono', 296, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/27', 'RRRR-MM-DD'), to_date('2019/10/30', 'RRRR-MM-DD'), to_date('2019/11/01', 'RRRR-MM-DD'), 'Dostarczono', 223, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/04', 'RRRR-MM-DD'), to_date('2020/10/07', 'RRRR-MM-DD'), to_date('2020/10/08', 'RRRR-MM-DD'), 'Dostarczono', 202, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/26', 'RRRR-MM-DD'), to_date('2019/12/29', 'RRRR-MM-DD'), to_date('2019/12/30', 'RRRR-MM-DD'), 'Dostarczono', 18, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/19', 'RRRR-MM-DD'), to_date('2020/05/22', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), 'Dostarczono', 62, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/10', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), 'Dostarczono', 469, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/23', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/25', 'RRRR-MM-DD'), 'Dostarczono', 25, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/26', 'RRRR-MM-DD'), to_date('2019/03/01', 'RRRR-MM-DD'), to_date('2019/03/04', 'RRRR-MM-DD'), 'Dostarczono', 174, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/08', 'RRRR-MM-DD'), to_date('2019/03/11', 'RRRR-MM-DD'), to_date('2019/03/11', 'RRRR-MM-DD'), 'Dostarczono', 347, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/11', 'RRRR-MM-DD'), to_date('2019/06/14', 'RRRR-MM-DD'), to_date('2019/06/15', 'RRRR-MM-DD'), 'Dostarczono', 429, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), 'Dostarczono', 247, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/27', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), 'Dostarczono', 444, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/17', 'RRRR-MM-DD'), to_date('2019/10/20', 'RRRR-MM-DD'), to_date('2019/10/21', 'RRRR-MM-DD'), 'Dostarczono', 435, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/11', 'RRRR-MM-DD'), to_date('2020/07/14', 'RRRR-MM-DD'), to_date('2020/07/16', 'RRRR-MM-DD'), 'Dostarczono', 140, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/01', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), 'Dostarczono', 94, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/18', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), 'Dostarczono', 59, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/02', 'RRRR-MM-DD'), to_date('2019/06/05', 'RRRR-MM-DD'), to_date('2019/06/04', 'RRRR-MM-DD'), 'Dostarczono', 415, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/12', 'RRRR-MM-DD'), to_date('2019/01/15', 'RRRR-MM-DD'), to_date('2019/01/15', 'RRRR-MM-DD'), 'Dostarczono', 340, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), to_date('2020/10/28', 'RRRR-MM-DD'), 'Dostarczono', 347, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/04', 'RRRR-MM-DD'), to_date('2020/11/07', 'RRRR-MM-DD'), to_date('2020/11/10', 'RRRR-MM-DD'), 'Dostarczono', 62, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/07', 'RRRR-MM-DD'), to_date('2020/02/10', 'RRRR-MM-DD'), to_date('2020/02/10', 'RRRR-MM-DD'), 'Dostarczono', 102, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/13', 'RRRR-MM-DD'), to_date('2020/06/16', 'RRRR-MM-DD'), to_date('2020/06/16', 'RRRR-MM-DD'), 'Dostarczono', 257, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/15', 'RRRR-MM-DD'), to_date('2020/11/18', 'RRRR-MM-DD'), to_date('2020/11/17', 'RRRR-MM-DD'), 'Dostarczono', 277, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/05', 'RRRR-MM-DD'), to_date('2020/09/08', 'RRRR-MM-DD'), to_date('2020/09/07', 'RRRR-MM-DD'), 'Dostarczono', 396, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/21', 'RRRR-MM-DD'), to_date('2020/08/24', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), 'Dostarczono', 489, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/25', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), 'Dostarczono', 35, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/09', 'RRRR-MM-DD'), to_date('2020/06/12', 'RRRR-MM-DD'), to_date('2020/06/13', 'RRRR-MM-DD'), 'Dostarczono', 153, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/09', 'RRRR-MM-DD'), to_date('2019/08/12', 'RRRR-MM-DD'), to_date('2019/08/12', 'RRRR-MM-DD'), 'Dostarczono', 205, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/08', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), 'Dostarczono', 250, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/14', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), to_date('2019/10/19', 'RRRR-MM-DD'), 'Dostarczono', 96, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/13', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), to_date('2020/05/17', 'RRRR-MM-DD'), 'Dostarczono', 304, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/29', 'RRRR-MM-DD'), 'Dostarczono', 12, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/09', 'RRRR-MM-DD'), to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/13', 'RRRR-MM-DD'), 'Dostarczono', 422, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/22', 'RRRR-MM-DD'), to_date('2020/11/25', 'RRRR-MM-DD'), 'Dostarczono', 336, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/06', 'RRRR-MM-DD'), to_date('2019/12/09', 'RRRR-MM-DD'), to_date('2019/12/08', 'RRRR-MM-DD'), 'Dostarczono', 366, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/27', 'RRRR-MM-DD'), to_date('2019/03/30', 'RRRR-MM-DD'), to_date('2019/03/30', 'RRRR-MM-DD'), 'Dostarczono', 116, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/12', 'RRRR-MM-DD'), to_date('2019/07/15', 'RRRR-MM-DD'), to_date('2019/07/17', 'RRRR-MM-DD'), 'Dostarczono', 100, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/28', 'RRRR-MM-DD'), to_date('2019/12/30', 'RRRR-MM-DD'), 'Dostarczono', 336, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/01', 'RRRR-MM-DD'), to_date('2019/12/04', 'RRRR-MM-DD'), to_date('2019/12/04', 'RRRR-MM-DD'), 'Dostarczono', 147, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/19', 'RRRR-MM-DD'), to_date('2020/08/22', 'RRRR-MM-DD'), to_date('2020/08/24', 'RRRR-MM-DD'), 'Dostarczono', 231, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/16', 'RRRR-MM-DD'), to_date('2020/12/19', 'RRRR-MM-DD'), to_date('2020/12/21', 'RRRR-MM-DD'), 'Dostarczono', 329, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/03', 'RRRR-MM-DD'), to_date('2020/10/06', 'RRRR-MM-DD'), to_date('2020/10/08', 'RRRR-MM-DD'), 'Dostarczono', 10, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/22', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), 'Dostarczono', 172, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/18', 'RRRR-MM-DD'), to_date('2019/07/21', 'RRRR-MM-DD'), to_date('2019/07/22', 'RRRR-MM-DD'), 'Dostarczono', 13, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/20', 'RRRR-MM-DD'), to_date('2020/09/23', 'RRRR-MM-DD'), to_date('2020/09/26', 'RRRR-MM-DD'), 'Dostarczono', 368, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/28', 'RRRR-MM-DD'), to_date('2019/08/31', 'RRRR-MM-DD'), to_date('2019/09/01', 'RRRR-MM-DD'), 'Dostarczono', 379, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/14', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), 'Dostarczono', 438, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/01', 'RRRR-MM-DD'), to_date('2019/12/04', 'RRRR-MM-DD'), to_date('2019/12/05', 'RRRR-MM-DD'), 'Dostarczono', 295, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/06', 'RRRR-MM-DD'), to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/11', 'RRRR-MM-DD'), 'Dostarczono', 51, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/10', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), 'Dostarczono', 55, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/19', 'RRRR-MM-DD'), to_date('2020/12/22', 'RRRR-MM-DD'), to_date('2020/12/23', 'RRRR-MM-DD'), 'Dostarczono', 289, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/26', 'RRRR-MM-DD'), to_date('2019/11/29', 'RRRR-MM-DD'), to_date('2019/11/30', 'RRRR-MM-DD'), 'Dostarczono', 69, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/22', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/24', 'RRRR-MM-DD'), 'Dostarczono', 159, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/24', 'RRRR-MM-DD'), to_date('2019/07/27', 'RRRR-MM-DD'), to_date('2019/07/28', 'RRRR-MM-DD'), 'Dostarczono', 286, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/02', 'RRRR-MM-DD'), to_date('2019/07/05', 'RRRR-MM-DD'), to_date('2019/07/04', 'RRRR-MM-DD'), 'Dostarczono', 151, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/27', 'RRRR-MM-DD'), to_date('2020/06/28', 'RRRR-MM-DD'), 'Dostarczono', 315, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/05', 'RRRR-MM-DD'), to_date('2020/01/08', 'RRRR-MM-DD'), to_date('2020/01/08', 'RRRR-MM-DD'), 'Dostarczono', 449, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/28', 'RRRR-MM-DD'), to_date('2019/07/31', 'RRRR-MM-DD'), to_date('2019/07/30', 'RRRR-MM-DD'), 'Dostarczono', 238, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/20', 'RRRR-MM-DD'), to_date('2019/04/23', 'RRRR-MM-DD'), to_date('2019/04/23', 'RRRR-MM-DD'), 'Dostarczono', 234, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/02', 'RRRR-MM-DD'), to_date('2020/08/05', 'RRRR-MM-DD'), to_date('2020/08/08', 'RRRR-MM-DD'), 'Dostarczono', 414, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/08', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), to_date('2020/05/13', 'RRRR-MM-DD'), 'Dostarczono', 57, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/03', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), 'Dostarczono', 161, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), 'Dostarczono', 472, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/20', 'RRRR-MM-DD'), to_date('2019/09/23', 'RRRR-MM-DD'), to_date('2019/09/26', 'RRRR-MM-DD'), 'Dostarczono', 217, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/26', 'RRRR-MM-DD'), to_date('2020/12/29', 'RRRR-MM-DD'), to_date('2021/01/01', 'RRRR-MM-DD'), 'Dostarczono', 165, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/28', 'RRRR-MM-DD'), to_date('2019/05/27', 'RRRR-MM-DD'), 'Dostarczono', 279, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/05', 'RRRR-MM-DD'), to_date('2019/03/08', 'RRRR-MM-DD'), to_date('2019/03/08', 'RRRR-MM-DD'), 'Dostarczono', 41, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/18', 'RRRR-MM-DD'), to_date('2020/11/21', 'RRRR-MM-DD'), to_date('2020/11/24', 'RRRR-MM-DD'), 'Dostarczono', 4, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/03', 'RRRR-MM-DD'), to_date('2019/12/06', 'RRRR-MM-DD'), to_date('2019/12/08', 'RRRR-MM-DD'), 'Dostarczono', 218, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/06', 'RRRR-MM-DD'), to_date('2020/12/09', 'RRRR-MM-DD'), to_date('2020/12/11', 'RRRR-MM-DD'), 'Dostarczono', 490, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/23', 'RRRR-MM-DD'), to_date('2020/11/26', 'RRRR-MM-DD'), to_date('2020/11/29', 'RRRR-MM-DD'), 'Dostarczono', 480, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/01', 'RRRR-MM-DD'), to_date('2020/08/04', 'RRRR-MM-DD'), to_date('2020/08/04', 'RRRR-MM-DD'), 'Dostarczono', 229, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/19', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), 'Dostarczono', 80, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/14', 'RRRR-MM-DD'), to_date('2019/03/17', 'RRRR-MM-DD'), to_date('2019/03/19', 'RRRR-MM-DD'), 'Dostarczono', 365, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/12', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), to_date('2020/11/18', 'RRRR-MM-DD'), 'Dostarczono', 80, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/23', 'RRRR-MM-DD'), to_date('2019/10/26', 'RRRR-MM-DD'), to_date('2019/10/29', 'RRRR-MM-DD'), 'Dostarczono', 491, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/07', 'RRRR-MM-DD'), to_date('2019/08/10', 'RRRR-MM-DD'), to_date('2019/08/13', 'RRRR-MM-DD'), 'Dostarczono', 315, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/09', 'RRRR-MM-DD'), to_date('2019/03/12', 'RRRR-MM-DD'), to_date('2019/03/12', 'RRRR-MM-DD'), 'Dostarczono', 156, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/23', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/28', 'RRRR-MM-DD'), 'Dostarczono', 318, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), 'Dostarczono', 126, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/17', 'RRRR-MM-DD'), to_date('2020/04/20', 'RRRR-MM-DD'), to_date('2020/04/22', 'RRRR-MM-DD'), 'Dostarczono', 361, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/04', 'RRRR-MM-DD'), to_date('2020/09/07', 'RRRR-MM-DD'), to_date('2020/09/08', 'RRRR-MM-DD'), 'Dostarczono', 196, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/08', 'RRRR-MM-DD'), to_date('2020/12/11', 'RRRR-MM-DD'), to_date('2020/12/11', 'RRRR-MM-DD'), 'Dostarczono', 105, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), 'Dostarczono', 440, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/12', 'RRRR-MM-DD'), to_date('2020/08/15', 'RRRR-MM-DD'), to_date('2020/08/15', 'RRRR-MM-DD'), 'Dostarczono', 130, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/12', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), to_date('2020/11/17', 'RRRR-MM-DD'), 'Dostarczono', 496, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/23', 'RRRR-MM-DD'), to_date('2020/09/26', 'RRRR-MM-DD'), to_date('2020/09/29', 'RRRR-MM-DD'), 'Dostarczono', 399, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/04', 'RRRR-MM-DD'), to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/08', 'RRRR-MM-DD'), 'Dostarczono', 360, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/25', 'RRRR-MM-DD'), to_date('2019/02/28', 'RRRR-MM-DD'), to_date('2019/03/02', 'RRRR-MM-DD'), 'Dostarczono', 121, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/03', 'RRRR-MM-DD'), to_date('2019/05/06', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), 'Dostarczono', 181, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/17', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), to_date('2020/11/21', 'RRRR-MM-DD'), 'Dostarczono', 275, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/04', 'RRRR-MM-DD'), to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), 'Dostarczono', 341, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/20', 'RRRR-MM-DD'), to_date('2020/05/23', 'RRRR-MM-DD'), to_date('2020/05/23', 'RRRR-MM-DD'), 'Dostarczono', 377, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/03', 'RRRR-MM-DD'), to_date('2019/07/06', 'RRRR-MM-DD'), to_date('2019/07/05', 'RRRR-MM-DD'), 'Dostarczono', 62, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/01', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), 'Dostarczono', 209, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/27', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), 'Dostarczono', 280, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/03', 'RRRR-MM-DD'), to_date('2020/01/06', 'RRRR-MM-DD'), to_date('2020/01/06', 'RRRR-MM-DD'), 'Dostarczono', 138, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/20', 'RRRR-MM-DD'), to_date('2020/01/23', 'RRRR-MM-DD'), to_date('2020/01/23', 'RRRR-MM-DD'), 'Dostarczono', 261, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/05', 'RRRR-MM-DD'), to_date('2019/01/08', 'RRRR-MM-DD'), to_date('2019/01/08', 'RRRR-MM-DD'), 'Dostarczono', 35, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/04', 'RRRR-MM-DD'), to_date('2020/09/07', 'RRRR-MM-DD'), to_date('2020/09/08', 'RRRR-MM-DD'), 'Dostarczono', 365, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/13', 'RRRR-MM-DD'), to_date('2020/12/16', 'RRRR-MM-DD'), to_date('2020/12/19', 'RRRR-MM-DD'), 'Dostarczono', 380, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/15', 'RRRR-MM-DD'), to_date('2019/06/18', 'RRRR-MM-DD'), to_date('2019/06/21', 'RRRR-MM-DD'), 'Dostarczono', 100, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/11', 'RRRR-MM-DD'), to_date('2019/07/14', 'RRRR-MM-DD'), to_date('2019/07/17', 'RRRR-MM-DD'), 'Dostarczono', 383, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/05', 'RRRR-MM-DD'), to_date('2019/06/08', 'RRRR-MM-DD'), to_date('2019/06/07', 'RRRR-MM-DD'), 'Dostarczono', 85, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/23', 'RRRR-MM-DD'), to_date('2020/09/26', 'RRRR-MM-DD'), to_date('2020/09/26', 'RRRR-MM-DD'), 'Dostarczono', 348, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/27', 'RRRR-MM-DD'), to_date('2019/03/02', 'RRRR-MM-DD'), to_date('2019/03/02', 'RRRR-MM-DD'), 'Dostarczono', 284, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/29', 'RRRR-MM-DD'), to_date('2020/04/30', 'RRRR-MM-DD'), 'Dostarczono', 33, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/02', 'RRRR-MM-DD'), to_date('2020/05/05', 'RRRR-MM-DD'), to_date('2020/05/05', 'RRRR-MM-DD'), 'Dostarczono', 321, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/15', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), 'Dostarczono', 347, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/12', 'RRRR-MM-DD'), to_date('2019/02/15', 'RRRR-MM-DD'), to_date('2019/02/16', 'RRRR-MM-DD'), 'Dostarczono', 114, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), to_date('2020/04/17', 'RRRR-MM-DD'), 'Dostarczono', 130, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/28', 'RRRR-MM-DD'), to_date('2019/05/31', 'RRRR-MM-DD'), to_date('2019/06/02', 'RRRR-MM-DD'), 'Dostarczono', 24, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/17', 'RRRR-MM-DD'), to_date('2020/03/20', 'RRRR-MM-DD'), to_date('2020/03/21', 'RRRR-MM-DD'), 'Dostarczono', 394, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/27', 'RRRR-MM-DD'), to_date('2019/12/30', 'RRRR-MM-DD'), to_date('2020/01/02', 'RRRR-MM-DD'), 'Dostarczono', 154, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/06', 'RRRR-MM-DD'), to_date('2020/07/09', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), 'Dostarczono', 465, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/14', 'RRRR-MM-DD'), to_date('2020/03/17', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), 'Dostarczono', 477, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/14', 'RRRR-MM-DD'), to_date('2019/08/15', 'RRRR-MM-DD'), 'Dostarczono', 241, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/13', 'RRRR-MM-DD'), to_date('2020/08/16', 'RRRR-MM-DD'), to_date('2020/08/18', 'RRRR-MM-DD'), 'Dostarczono', 66, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/14', 'RRRR-MM-DD'), to_date('2019/08/16', 'RRRR-MM-DD'), 'Dostarczono', 352, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/27', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), to_date('2020/10/01', 'RRRR-MM-DD'), 'Dostarczono', 111, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/22', 'RRRR-MM-DD'), to_date('2020/10/25', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), 'Dostarczono', 410, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/12', 'RRRR-MM-DD'), to_date('2019/12/15', 'RRRR-MM-DD'), to_date('2019/12/16', 'RRRR-MM-DD'), 'Dostarczono', 96, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/25', 'RRRR-MM-DD'), to_date('2020/11/28', 'RRRR-MM-DD'), to_date('2020/11/30', 'RRRR-MM-DD'), 'Dostarczono', 124, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/13', 'RRRR-MM-DD'), to_date('2019/10/16', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), 'Dostarczono', 171, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/08', 'RRRR-MM-DD'), to_date('2020/09/11', 'RRRR-MM-DD'), to_date('2020/09/11', 'RRRR-MM-DD'), 'Dostarczono', 356, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/14', 'RRRR-MM-DD'), to_date('2020/05/17', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), 'Dostarczono', 83, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/27', 'RRRR-MM-DD'), to_date('2020/03/01', 'RRRR-MM-DD'), to_date('2020/02/29', 'RRRR-MM-DD'), 'Dostarczono', 59, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/14', 'RRRR-MM-DD'), to_date('2019/06/17', 'RRRR-MM-DD'), to_date('2019/06/18', 'RRRR-MM-DD'), 'Dostarczono', 180, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/22', 'RRRR-MM-DD'), to_date('2020/02/25', 'RRRR-MM-DD'), to_date('2020/02/28', 'RRRR-MM-DD'), 'Dostarczono', 347, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/05', 'RRRR-MM-DD'), to_date('2019/01/08', 'RRRR-MM-DD'), to_date('2019/01/08', 'RRRR-MM-DD'), 'Dostarczono', 482, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/14', 'RRRR-MM-DD'), to_date('2019/02/17', 'RRRR-MM-DD'), to_date('2019/02/18', 'RRRR-MM-DD'), 'Dostarczono', 234, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/10', 'RRRR-MM-DD'), to_date('2019/07/13', 'RRRR-MM-DD'), to_date('2019/07/14', 'RRRR-MM-DD'), 'Dostarczono', 445, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/16', 'RRRR-MM-DD'), to_date('2020/12/19', 'RRRR-MM-DD'), to_date('2020/12/20', 'RRRR-MM-DD'), 'Dostarczono', 317, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/17', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), 'Dostarczono', 273, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/18', 'RRRR-MM-DD'), to_date('2020/01/21', 'RRRR-MM-DD'), to_date('2020/01/23', 'RRRR-MM-DD'), 'Dostarczono', 390, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/05', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), to_date('2020/07/09', 'RRRR-MM-DD'), 'Dostarczono', 278, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/23', 'RRRR-MM-DD'), 'Dostarczono', 124, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/09', 'RRRR-MM-DD'), to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/11', 'RRRR-MM-DD'), 'Dostarczono', 246, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/12', 'RRRR-MM-DD'), to_date('2020/03/15', 'RRRR-MM-DD'), to_date('2020/03/18', 'RRRR-MM-DD'), 'Dostarczono', 345, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/08', 'RRRR-MM-DD'), to_date('2019/06/11', 'RRRR-MM-DD'), to_date('2019/06/12', 'RRRR-MM-DD'), 'Dostarczono', 464, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/25', 'RRRR-MM-DD'), 'Dostarczono', 261, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/28', 'RRRR-MM-DD'), to_date('2020/10/31', 'RRRR-MM-DD'), to_date('2020/11/01', 'RRRR-MM-DD'), 'Dostarczono', 266, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/08', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), 'Dostarczono', 445, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/27', 'RRRR-MM-DD'), to_date('2019/01/30', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), 'Dostarczono', 476, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/24', 'RRRR-MM-DD'), to_date('2019/03/27', 'RRRR-MM-DD'), to_date('2019/03/29', 'RRRR-MM-DD'), 'Dostarczono', 242, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/16', 'RRRR-MM-DD'), to_date('2020/01/19', 'RRRR-MM-DD'), to_date('2020/01/21', 'RRRR-MM-DD'), 'Dostarczono', 39, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/16', 'RRRR-MM-DD'), to_date('2020/02/19', 'RRRR-MM-DD'), to_date('2020/02/19', 'RRRR-MM-DD'), 'Dostarczono', 309, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/04', 'RRRR-MM-DD'), to_date('2020/05/07', 'RRRR-MM-DD'), to_date('2020/05/08', 'RRRR-MM-DD'), 'Dostarczono', 288, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/28', 'RRRR-MM-DD'), to_date('2019/12/31', 'RRRR-MM-DD'), to_date('2020/01/02', 'RRRR-MM-DD'), 'Dostarczono', 370, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/12', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), 'Dostarczono', 196, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/24', 'RRRR-MM-DD'), to_date('2019/08/27', 'RRRR-MM-DD'), to_date('2019/08/29', 'RRRR-MM-DD'), 'Dostarczono', 76, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/14', 'RRRR-MM-DD'), to_date('2019/06/17', 'RRRR-MM-DD'), to_date('2019/06/19', 'RRRR-MM-DD'), 'Dostarczono', 1, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/24', 'RRRR-MM-DD'), to_date('2020/12/27', 'RRRR-MM-DD'), to_date('2020/12/28', 'RRRR-MM-DD'), 'Dostarczono', 307, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/17', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), to_date('2019/07/21', 'RRRR-MM-DD'), 'Dostarczono', 463, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/22', 'RRRR-MM-DD'), to_date('2020/01/25', 'RRRR-MM-DD'), to_date('2020/01/24', 'RRRR-MM-DD'), 'Dostarczono', 381, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/05', 'RRRR-MM-DD'), to_date('2019/05/08', 'RRRR-MM-DD'), to_date('2019/05/11', 'RRRR-MM-DD'), 'Dostarczono', 380, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/09', 'RRRR-MM-DD'), to_date('2019/08/12', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), 'Dostarczono', 389, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/07', 'RRRR-MM-DD'), to_date('2020/12/10', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), 'Dostarczono', 380, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/18', 'RRRR-MM-DD'), to_date('2020/08/21', 'RRRR-MM-DD'), to_date('2020/08/23', 'RRRR-MM-DD'), 'Dostarczono', 59, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/22', 'RRRR-MM-DD'), 'Dostarczono', 361, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/03', 'RRRR-MM-DD'), to_date('2020/02/06', 'RRRR-MM-DD'), to_date('2020/02/07', 'RRRR-MM-DD'), 'Dostarczono', 255, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/27', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), 'Dostarczono', 67, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/08', 'RRRR-MM-DD'), to_date('2020/01/11', 'RRRR-MM-DD'), to_date('2020/01/12', 'RRRR-MM-DD'), 'Dostarczono', 469, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/22', 'RRRR-MM-DD'), to_date('2019/09/25', 'RRRR-MM-DD'), to_date('2019/09/25', 'RRRR-MM-DD'), 'Dostarczono', 315, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/12', 'RRRR-MM-DD'), to_date('2019/11/15', 'RRRR-MM-DD'), to_date('2019/11/17', 'RRRR-MM-DD'), 'Dostarczono', 28, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/14', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), to_date('2019/10/18', 'RRRR-MM-DD'), 'Dostarczono', 267, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/03', 'RRRR-MM-DD'), to_date('2020/01/06', 'RRRR-MM-DD'), to_date('2020/01/09', 'RRRR-MM-DD'), 'Dostarczono', 334, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/20', 'RRRR-MM-DD'), 'Dostarczono', 419, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/16', 'RRRR-MM-DD'), 'Dostarczono', 243, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/25', 'RRRR-MM-DD'), to_date('2020/09/28', 'RRRR-MM-DD'), to_date('2020/09/28', 'RRRR-MM-DD'), 'Dostarczono', 317, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/15', 'RRRR-MM-DD'), to_date('2020/01/18', 'RRRR-MM-DD'), to_date('2020/01/21', 'RRRR-MM-DD'), 'Dostarczono', 80, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/16', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), 'Dostarczono', 202, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/13', 'RRRR-MM-DD'), to_date('2020/12/16', 'RRRR-MM-DD'), to_date('2020/12/17', 'RRRR-MM-DD'), 'Dostarczono', 75, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/06', 'RRRR-MM-DD'), to_date('2019/03/09', 'RRRR-MM-DD'), to_date('2019/03/11', 'RRRR-MM-DD'), 'Dostarczono', 20, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), to_date('2019/05/06', 'RRRR-MM-DD'), 'Dostarczono', 296, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/03', 'RRRR-MM-DD'), to_date('2020/03/06', 'RRRR-MM-DD'), to_date('2020/03/09', 'RRRR-MM-DD'), 'Dostarczono', 13, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/18', 'RRRR-MM-DD'), to_date('2019/08/21', 'RRRR-MM-DD'), to_date('2019/08/21', 'RRRR-MM-DD'), 'Dostarczono', 116, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), 'Dostarczono', 461, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/16', 'RRRR-MM-DD'), to_date('2020/03/19', 'RRRR-MM-DD'), to_date('2020/03/18', 'RRRR-MM-DD'), 'Dostarczono', 238, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/25', 'RRRR-MM-DD'), to_date('2019/04/28', 'RRRR-MM-DD'), to_date('2019/04/28', 'RRRR-MM-DD'), 'Dostarczono', 3, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/05', 'RRRR-MM-DD'), to_date('2020/02/08', 'RRRR-MM-DD'), to_date('2020/02/07', 'RRRR-MM-DD'), 'Dostarczono', 344, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/06', 'RRRR-MM-DD'), to_date('2019/03/09', 'RRRR-MM-DD'), to_date('2019/03/10', 'RRRR-MM-DD'), 'Dostarczono', 54, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/02', 'RRRR-MM-DD'), to_date('2019/04/05', 'RRRR-MM-DD'), to_date('2019/04/07', 'RRRR-MM-DD'), 'Dostarczono', 433, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/17', 'RRRR-MM-DD'), to_date('2019/01/20', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), 'Dostarczono', 499, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/07', 'RRRR-MM-DD'), to_date('2019/12/10', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), 'Dostarczono', 160, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/04', 'RRRR-MM-DD'), to_date('2020/01/07', 'RRRR-MM-DD'), to_date('2020/01/06', 'RRRR-MM-DD'), 'Dostarczono', 480, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/01', 'RRRR-MM-DD'), to_date('2020/12/04', 'RRRR-MM-DD'), to_date('2020/12/05', 'RRRR-MM-DD'), 'Dostarczono', 265, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/06', 'RRRR-MM-DD'), to_date('2019/08/09', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), 'Dostarczono', 500, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/05', 'RRRR-MM-DD'), to_date('2020/04/08', 'RRRR-MM-DD'), to_date('2020/04/11', 'RRRR-MM-DD'), 'Dostarczono', 238, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/16', 'RRRR-MM-DD'), to_date('2019/10/19', 'RRRR-MM-DD'), to_date('2019/10/19', 'RRRR-MM-DD'), 'Dostarczono', 11, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/16', 'RRRR-MM-DD'), to_date('2019/07/19', 'RRRR-MM-DD'), to_date('2019/07/19', 'RRRR-MM-DD'), 'Dostarczono', 384, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/29', 'RRRR-MM-DD'), 'Dostarczono', 461, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/17', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), 'Dostarczono', 482, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/14', 'RRRR-MM-DD'), 'Dostarczono', 464, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/18', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/24', 'RRRR-MM-DD'), 'Dostarczono', 330, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/12', 'RRRR-MM-DD'), 'Dostarczono', 141, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/22', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), 'Dostarczono', 464, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/22', 'RRRR-MM-DD'), 'Dostarczono', 28, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/03', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), 'Dostarczono', 43, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/10', 'RRRR-MM-DD'), to_date('2019/01/13', 'RRRR-MM-DD'), to_date('2019/01/13', 'RRRR-MM-DD'), 'Dostarczono', 201, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/04', 'RRRR-MM-DD'), to_date('2020/01/07', 'RRRR-MM-DD'), to_date('2020/01/08', 'RRRR-MM-DD'), 'Dostarczono', 103, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/29', 'RRRR-MM-DD'), to_date('2019/04/01', 'RRRR-MM-DD'), 'Dostarczono', 455, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/19', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), 'Dostarczono', 129, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/20', 'RRRR-MM-DD'), to_date('2020/05/23', 'RRRR-MM-DD'), to_date('2020/05/22', 'RRRR-MM-DD'), 'Dostarczono', 108, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/19', 'RRRR-MM-DD'), to_date('2019/12/22', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), 'Dostarczono', 368, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/17', 'RRRR-MM-DD'), to_date('2019/10/20', 'RRRR-MM-DD'), to_date('2019/10/20', 'RRRR-MM-DD'), 'Dostarczono', 352, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/12', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), to_date('2019/09/16', 'RRRR-MM-DD'), 'Dostarczono', 286, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/04', 'RRRR-MM-DD'), to_date('2020/08/07', 'RRRR-MM-DD'), to_date('2020/08/07', 'RRRR-MM-DD'), 'Dostarczono', 113, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/08', 'RRRR-MM-DD'), to_date('2019/02/11', 'RRRR-MM-DD'), to_date('2019/02/12', 'RRRR-MM-DD'), 'Dostarczono', 451, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/29', 'RRRR-MM-DD'), to_date('2019/04/01', 'RRRR-MM-DD'), 'Dostarczono', 53, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/25', 'RRRR-MM-DD'), 'Dostarczono', 448, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/20', 'RRRR-MM-DD'), to_date('2019/11/23', 'RRRR-MM-DD'), to_date('2019/11/26', 'RRRR-MM-DD'), 'Dostarczono', 468, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/11', 'RRRR-MM-DD'), to_date('2020/03/14', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), 'Dostarczono', 66, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/23', 'RRRR-MM-DD'), to_date('2020/06/26', 'RRRR-MM-DD'), to_date('2020/06/25', 'RRRR-MM-DD'), 'Dostarczono', 463, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/06', 'RRRR-MM-DD'), to_date('2019/04/09', 'RRRR-MM-DD'), to_date('2019/04/09', 'RRRR-MM-DD'), 'Dostarczono', 469, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/04', 'RRRR-MM-DD'), to_date('2020/09/07', 'RRRR-MM-DD'), to_date('2020/09/07', 'RRRR-MM-DD'), 'Dostarczono', 326, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/25', 'RRRR-MM-DD'), to_date('2019/09/28', 'RRRR-MM-DD'), to_date('2019/10/01', 'RRRR-MM-DD'), 'Dostarczono', 49, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/07', 'RRRR-MM-DD'), to_date('2020/02/10', 'RRRR-MM-DD'), to_date('2020/02/12', 'RRRR-MM-DD'), 'Dostarczono', 309, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/06', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), to_date('2019/06/11', 'RRRR-MM-DD'), 'Dostarczono', 76, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/09', 'RRRR-MM-DD'), to_date('2019/11/12', 'RRRR-MM-DD'), to_date('2019/11/12', 'RRRR-MM-DD'), 'Dostarczono', 459, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/05', 'RRRR-MM-DD'), to_date('2020/10/08', 'RRRR-MM-DD'), to_date('2020/10/10', 'RRRR-MM-DD'), 'Dostarczono', 461, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/01', 'RRRR-MM-DD'), to_date('2020/05/04', 'RRRR-MM-DD'), to_date('2020/05/03', 'RRRR-MM-DD'), 'Dostarczono', 302, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/03', 'RRRR-MM-DD'), to_date('2020/07/06', 'RRRR-MM-DD'), to_date('2020/07/05', 'RRRR-MM-DD'), 'Dostarczono', 274, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/06', 'RRRR-MM-DD'), to_date('2019/11/09', 'RRRR-MM-DD'), to_date('2019/11/09', 'RRRR-MM-DD'), 'Dostarczono', 442, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/28', 'RRRR-MM-DD'), to_date('2019/05/27', 'RRRR-MM-DD'), 'Dostarczono', 447, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/26', 'RRRR-MM-DD'), to_date('2019/11/29', 'RRRR-MM-DD'), to_date('2019/12/02', 'RRRR-MM-DD'), 'Dostarczono', 225, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/13', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), 'Dostarczono', 101, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/10', 'RRRR-MM-DD'), to_date('2020/09/13', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), 'Dostarczono', 448, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/21', 'RRRR-MM-DD'), to_date('2019/09/24', 'RRRR-MM-DD'), to_date('2019/09/25', 'RRRR-MM-DD'), 'Dostarczono', 165, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/05', 'RRRR-MM-DD'), to_date('2020/03/08', 'RRRR-MM-DD'), to_date('2020/03/07', 'RRRR-MM-DD'), 'Dostarczono', 381, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/21', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), 'Dostarczono', 305, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/25', 'RRRR-MM-DD'), to_date('2019/07/28', 'RRRR-MM-DD'), to_date('2019/07/27', 'RRRR-MM-DD'), 'Dostarczono', 408, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/26', 'RRRR-MM-DD'), to_date('2019/11/29', 'RRRR-MM-DD'), to_date('2019/12/01', 'RRRR-MM-DD'), 'Dostarczono', 170, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/22', 'RRRR-MM-DD'), to_date('2020/10/25', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), 'Dostarczono', 35, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/24', 'RRRR-MM-DD'), to_date('2020/07/27', 'RRRR-MM-DD'), to_date('2020/07/29', 'RRRR-MM-DD'), 'Dostarczono', 15, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/23', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), 'Dostarczono', 494, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/04', 'RRRR-MM-DD'), to_date('2020/11/07', 'RRRR-MM-DD'), to_date('2020/11/10', 'RRRR-MM-DD'), 'Dostarczono', 375, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/14', 'RRRR-MM-DD'), 'Dostarczono', 88, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/16', 'RRRR-MM-DD'), to_date('2019/11/19', 'RRRR-MM-DD'), to_date('2019/11/22', 'RRRR-MM-DD'), 'Dostarczono', 97, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/08', 'RRRR-MM-DD'), to_date('2020/04/11', 'RRRR-MM-DD'), to_date('2020/04/13', 'RRRR-MM-DD'), 'Dostarczono', 289, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/14', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), 'Dostarczono', 216, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/11', 'RRRR-MM-DD'), to_date('2019/04/14', 'RRRR-MM-DD'), to_date('2019/04/14', 'RRRR-MM-DD'), 'Dostarczono', 96, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/06', 'RRRR-MM-DD'), to_date('2020/06/09', 'RRRR-MM-DD'), to_date('2020/06/09', 'RRRR-MM-DD'), 'Dostarczono', 225, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), to_date('2019/01/11', 'RRRR-MM-DD'), 'Dostarczono', 314, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/01', 'RRRR-MM-DD'), to_date('2020/10/04', 'RRRR-MM-DD'), to_date('2020/10/03', 'RRRR-MM-DD'), 'Dostarczono', 186, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/22', 'RRRR-MM-DD'), to_date('2020/04/25', 'RRRR-MM-DD'), to_date('2020/04/27', 'RRRR-MM-DD'), 'Dostarczono', 23, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/16', 'RRRR-MM-DD'), to_date('2020/06/19', 'RRRR-MM-DD'), to_date('2020/06/21', 'RRRR-MM-DD'), 'Dostarczono', 415, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/09', 'RRRR-MM-DD'), to_date('2019/02/12', 'RRRR-MM-DD'), to_date('2019/02/14', 'RRRR-MM-DD'), 'Dostarczono', 90, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/07', 'RRRR-MM-DD'), to_date('2019/11/10', 'RRRR-MM-DD'), to_date('2019/11/09', 'RRRR-MM-DD'), 'Dostarczono', 278, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/24', 'RRRR-MM-DD'), to_date('2020/05/27', 'RRRR-MM-DD'), to_date('2020/05/27', 'RRRR-MM-DD'), 'Dostarczono', 383, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/12', 'RRRR-MM-DD'), to_date('2020/09/15', 'RRRR-MM-DD'), 'Dostarczono', 22, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/09', 'RRRR-MM-DD'), to_date('2019/06/12', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), 'Dostarczono', 232, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/03', 'RRRR-MM-DD'), to_date('2020/09/06', 'RRRR-MM-DD'), to_date('2020/09/08', 'RRRR-MM-DD'), 'Dostarczono', 70, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/26', 'RRRR-MM-DD'), to_date('2019/07/29', 'RRRR-MM-DD'), to_date('2019/08/01', 'RRRR-MM-DD'), 'Dostarczono', 475, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/08', 'RRRR-MM-DD'), to_date('2019/10/11', 'RRRR-MM-DD'), to_date('2019/10/11', 'RRRR-MM-DD'), 'Dostarczono', 210, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/23', 'RRRR-MM-DD'), to_date('2019/05/26', 'RRRR-MM-DD'), to_date('2019/05/27', 'RRRR-MM-DD'), 'Dostarczono', 81, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/15', 'RRRR-MM-DD'), to_date('2019/11/18', 'RRRR-MM-DD'), to_date('2019/11/19', 'RRRR-MM-DD'), 'Dostarczono', 53, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/18', 'RRRR-MM-DD'), to_date('2019/02/21', 'RRRR-MM-DD'), to_date('2019/02/20', 'RRRR-MM-DD'), 'Dostarczono', 456, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/17', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), 'Dostarczono', 74, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/03', 'RRRR-MM-DD'), to_date('2020/10/06', 'RRRR-MM-DD'), to_date('2020/10/09', 'RRRR-MM-DD'), 'Dostarczono', 374, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/20', 'RRRR-MM-DD'), 'Dostarczono', 98, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/04', 'RRRR-MM-DD'), to_date('2020/07/07', 'RRRR-MM-DD'), to_date('2020/07/06', 'RRRR-MM-DD'), 'Dostarczono', 429, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/17', 'RRRR-MM-DD'), to_date('2019/08/20', 'RRRR-MM-DD'), to_date('2019/08/22', 'RRRR-MM-DD'), 'Dostarczono', 7, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/14', 'RRRR-MM-DD'), to_date('2020/05/17', 'RRRR-MM-DD'), to_date('2020/05/18', 'RRRR-MM-DD'), 'Dostarczono', 352, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/14', 'RRRR-MM-DD'), 'Dostarczono', 390, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/19', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), 'Dostarczono', 2, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/23', 'RRRR-MM-DD'), to_date('2019/11/26', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), 'Dostarczono', 2, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/23', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), 'Dostarczono', 297, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/16', 'RRRR-MM-DD'), to_date('2019/05/19', 'RRRR-MM-DD'), to_date('2019/05/21', 'RRRR-MM-DD'), 'Dostarczono', 124, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/27', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), to_date('2020/10/03', 'RRRR-MM-DD'), 'Dostarczono', 143, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/10', 'RRRR-MM-DD'), to_date('2020/02/13', 'RRRR-MM-DD'), to_date('2020/02/12', 'RRRR-MM-DD'), 'Dostarczono', 477, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/24', 'RRRR-MM-DD'), to_date('2019/09/27', 'RRRR-MM-DD'), to_date('2019/09/29', 'RRRR-MM-DD'), 'Dostarczono', 278, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/06', 'RRRR-MM-DD'), to_date('2020/05/09', 'RRRR-MM-DD'), to_date('2020/05/10', 'RRRR-MM-DD'), 'Dostarczono', 264, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), to_date('2019/01/09', 'RRRR-MM-DD'), 'Dostarczono', 416, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/10', 'RRRR-MM-DD'), to_date('2020/07/13', 'RRRR-MM-DD'), to_date('2020/07/15', 'RRRR-MM-DD'), 'Dostarczono', 435, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/10', 'RRRR-MM-DD'), to_date('2020/03/13', 'RRRR-MM-DD'), to_date('2020/03/15', 'RRRR-MM-DD'), 'Dostarczono', 208, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/18', 'RRRR-MM-DD'), to_date('2020/04/21', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), 'Dostarczono', 403, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/14', 'RRRR-MM-DD'), to_date('2019/09/17', 'RRRR-MM-DD'), to_date('2019/09/20', 'RRRR-MM-DD'), 'Dostarczono', 401, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/06', 'RRRR-MM-DD'), to_date('2020/12/09', 'RRRR-MM-DD'), to_date('2020/12/09', 'RRRR-MM-DD'), 'Dostarczono', 168, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/19', 'RRRR-MM-DD'), to_date('2020/08/22', 'RRRR-MM-DD'), to_date('2020/08/23', 'RRRR-MM-DD'), 'Dostarczono', 151, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/10', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), 'Dostarczono', 257, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/22', 'RRRR-MM-DD'), to_date('2020/04/25', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), 'Dostarczono', 65, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/22', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/28', 'RRRR-MM-DD'), 'Dostarczono', 4, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/15', 'RRRR-MM-DD'), to_date('2020/12/18', 'RRRR-MM-DD'), to_date('2020/12/19', 'RRRR-MM-DD'), 'Dostarczono', 358, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/04', 'RRRR-MM-DD'), to_date('2019/11/07', 'RRRR-MM-DD'), to_date('2019/11/09', 'RRRR-MM-DD'), 'Dostarczono', 79, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/25', 'RRRR-MM-DD'), 'Dostarczono', 107, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/08', 'RRRR-MM-DD'), to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/11', 'RRRR-MM-DD'), 'Dostarczono', 396, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/04', 'RRRR-MM-DD'), to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/09', 'RRRR-MM-DD'), 'Dostarczono', 314, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/22', 'RRRR-MM-DD'), to_date('2019/06/25', 'RRRR-MM-DD'), to_date('2019/06/26', 'RRRR-MM-DD'), 'Dostarczono', 106, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/04', 'RRRR-MM-DD'), to_date('2020/12/07', 'RRRR-MM-DD'), to_date('2020/12/09', 'RRRR-MM-DD'), 'Dostarczono', 32, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/14', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), 'Dostarczono', 217, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/03', 'RRRR-MM-DD'), to_date('2019/10/06', 'RRRR-MM-DD'), to_date('2019/10/08', 'RRRR-MM-DD'), 'Dostarczono', 154, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/01', 'RRRR-MM-DD'), to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/03', 'RRRR-MM-DD'), 'Dostarczono', 82, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/20', 'RRRR-MM-DD'), to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/25', 'RRRR-MM-DD'), 'Dostarczono', 143, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/21', 'RRRR-MM-DD'), to_date('2019/01/24', 'RRRR-MM-DD'), to_date('2019/01/24', 'RRRR-MM-DD'), 'Dostarczono', 147, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/22', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), 'Dostarczono', 236, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/19', 'RRRR-MM-DD'), to_date('2020/07/22', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), 'Dostarczono', 232, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/28', 'RRRR-MM-DD'), to_date('2020/10/01', 'RRRR-MM-DD'), to_date('2020/10/03', 'RRRR-MM-DD'), 'Dostarczono', 371, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/03', 'RRRR-MM-DD'), to_date('2020/05/06', 'RRRR-MM-DD'), to_date('2020/05/08', 'RRRR-MM-DD'), 'Dostarczono', 201, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), 'Dostarczono', 232, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/25', 'RRRR-MM-DD'), to_date('2020/01/28', 'RRRR-MM-DD'), to_date('2020/01/30', 'RRRR-MM-DD'), 'Dostarczono', 25, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), to_date('2019/06/15', 'RRRR-MM-DD'), 'Dostarczono', 198, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/01', 'RRRR-MM-DD'), to_date('2019/12/04', 'RRRR-MM-DD'), to_date('2019/12/03', 'RRRR-MM-DD'), 'Dostarczono', 469, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/13', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), to_date('2020/03/18', 'RRRR-MM-DD'), 'Dostarczono', 76, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), to_date('2020/10/28', 'RRRR-MM-DD'), 'Dostarczono', 271, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/20', 'RRRR-MM-DD'), to_date('2020/10/23', 'RRRR-MM-DD'), to_date('2020/10/25', 'RRRR-MM-DD'), 'Dostarczono', 128, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/24', 'RRRR-MM-DD'), to_date('2019/01/27', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), 'Dostarczono', 393, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/20', 'RRRR-MM-DD'), to_date('2019/06/23', 'RRRR-MM-DD'), to_date('2019/06/22', 'RRRR-MM-DD'), 'Dostarczono', 99, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/27', 'RRRR-MM-DD'), to_date('2019/08/30', 'RRRR-MM-DD'), to_date('2019/08/30', 'RRRR-MM-DD'), 'Dostarczono', 442, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/28', 'RRRR-MM-DD'), to_date('2019/12/01', 'RRRR-MM-DD'), to_date('2019/12/02', 'RRRR-MM-DD'), 'Dostarczono', 407, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/17', 'RRRR-MM-DD'), to_date('2020/01/20', 'RRRR-MM-DD'), to_date('2020/01/20', 'RRRR-MM-DD'), 'Dostarczono', 402, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/21', 'RRRR-MM-DD'), to_date('2019/02/24', 'RRRR-MM-DD'), to_date('2019/02/23', 'RRRR-MM-DD'), 'Dostarczono', 47, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/21', 'RRRR-MM-DD'), to_date('2020/06/20', 'RRRR-MM-DD'), 'Dostarczono', 474, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/04', 'RRRR-MM-DD'), to_date('2019/12/07', 'RRRR-MM-DD'), to_date('2019/12/06', 'RRRR-MM-DD'), 'Dostarczono', 234, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/27', 'RRRR-MM-DD'), to_date('2020/03/01', 'RRRR-MM-DD'), to_date('2020/03/03', 'RRRR-MM-DD'), 'Dostarczono', 446, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/23', 'RRRR-MM-DD'), to_date('2019/08/26', 'RRRR-MM-DD'), to_date('2019/08/27', 'RRRR-MM-DD'), 'Dostarczono', 212, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/16', 'RRRR-MM-DD'), to_date('2020/10/19', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), 'Dostarczono', 159, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/12', 'RRRR-MM-DD'), to_date('2019/05/15', 'RRRR-MM-DD'), to_date('2019/05/16', 'RRRR-MM-DD'), 'Dostarczono', 268, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/10', 'RRRR-MM-DD'), 'Dostarczono', 428, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/06', 'RRRR-MM-DD'), to_date('2020/02/09', 'RRRR-MM-DD'), to_date('2020/02/11', 'RRRR-MM-DD'), 'Dostarczono', 357, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/15', 'RRRR-MM-DD'), to_date('2019/08/18', 'RRRR-MM-DD'), to_date('2019/08/17', 'RRRR-MM-DD'), 'Dostarczono', 274, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/02', 'RRRR-MM-DD'), to_date('2020/04/05', 'RRRR-MM-DD'), to_date('2020/04/06', 'RRRR-MM-DD'), 'Dostarczono', 15, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/17', 'RRRR-MM-DD'), to_date('2020/07/20', 'RRRR-MM-DD'), to_date('2020/07/23', 'RRRR-MM-DD'), 'Dostarczono', 227, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/21', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), 'Dostarczono', 86, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/28', 'RRRR-MM-DD'), to_date('2019/07/31', 'RRRR-MM-DD'), to_date('2019/07/31', 'RRRR-MM-DD'), 'Dostarczono', 156, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/14', 'RRRR-MM-DD'), to_date('2019/01/17', 'RRRR-MM-DD'), to_date('2019/01/16', 'RRRR-MM-DD'), 'Dostarczono', 4, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/27', 'RRRR-MM-DD'), to_date('2020/07/30', 'RRRR-MM-DD'), to_date('2020/07/31', 'RRRR-MM-DD'), 'Dostarczono', 118, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/07', 'RRRR-MM-DD'), to_date('2019/06/10', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), 'Dostarczono', 263, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/16', 'RRRR-MM-DD'), to_date('2020/05/19', 'RRRR-MM-DD'), to_date('2020/05/21', 'RRRR-MM-DD'), 'Dostarczono', 435, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/08', 'RRRR-MM-DD'), to_date('2019/07/11', 'RRRR-MM-DD'), to_date('2019/07/13', 'RRRR-MM-DD'), 'Dostarczono', 307, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/16', 'RRRR-MM-DD'), to_date('2019/04/19', 'RRRR-MM-DD'), to_date('2019/04/21', 'RRRR-MM-DD'), 'Dostarczono', 306, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), 'Dostarczono', 57, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/03', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), 'Dostarczono', 121, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/27', 'RRRR-MM-DD'), to_date('2019/10/30', 'RRRR-MM-DD'), to_date('2019/10/31', 'RRRR-MM-DD'), 'Dostarczono', 26, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/23', 'RRRR-MM-DD'), to_date('2020/03/26', 'RRRR-MM-DD'), to_date('2020/03/28', 'RRRR-MM-DD'), 'Dostarczono', 257, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/27', 'RRRR-MM-DD'), to_date('2020/05/30', 'RRRR-MM-DD'), to_date('2020/06/02', 'RRRR-MM-DD'), 'Dostarczono', 35, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/13', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), 'Dostarczono', 457, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/13', 'RRRR-MM-DD'), to_date('2019/01/16', 'RRRR-MM-DD'), to_date('2019/01/18', 'RRRR-MM-DD'), 'Dostarczono', 468, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/08', 'RRRR-MM-DD'), to_date('2019/05/11', 'RRRR-MM-DD'), to_date('2019/05/13', 'RRRR-MM-DD'), 'Dostarczono', 388, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/27', 'RRRR-MM-DD'), to_date('2019/04/30', 'RRRR-MM-DD'), to_date('2019/04/29', 'RRRR-MM-DD'), 'Dostarczono', 386, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/28', 'RRRR-MM-DD'), to_date('2020/05/01', 'RRRR-MM-DD'), to_date('2020/05/02', 'RRRR-MM-DD'), 'Dostarczono', 449, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/23', 'RRRR-MM-DD'), to_date('2019/12/26', 'RRRR-MM-DD'), to_date('2019/12/27', 'RRRR-MM-DD'), 'Dostarczono', 165, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/12', 'RRRR-MM-DD'), to_date('2020/03/15', 'RRRR-MM-DD'), to_date('2020/03/17', 'RRRR-MM-DD'), 'Dostarczono', 50, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/11', 'RRRR-MM-DD'), to_date('2019/03/14', 'RRRR-MM-DD'), to_date('2019/03/15', 'RRRR-MM-DD'), 'Dostarczono', 104, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/03', 'RRRR-MM-DD'), to_date('2019/07/06', 'RRRR-MM-DD'), to_date('2019/07/07', 'RRRR-MM-DD'), 'Dostarczono', 209, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/05', 'RRRR-MM-DD'), to_date('2020/06/08', 'RRRR-MM-DD'), to_date('2020/06/11', 'RRRR-MM-DD'), 'Dostarczono', 390, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/03', 'RRRR-MM-DD'), to_date('2020/09/06', 'RRRR-MM-DD'), to_date('2020/09/06', 'RRRR-MM-DD'), 'Dostarczono', 40, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/01', 'RRRR-MM-DD'), to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/03', 'RRRR-MM-DD'), 'Dostarczono', 392, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/07', 'RRRR-MM-DD'), to_date('2020/08/10', 'RRRR-MM-DD'), to_date('2020/08/09', 'RRRR-MM-DD'), 'Dostarczono', 190, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/25', 'RRRR-MM-DD'), to_date('2020/01/28', 'RRRR-MM-DD'), to_date('2020/01/27', 'RRRR-MM-DD'), 'Dostarczono', 42, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), to_date('2020/04/18', 'RRRR-MM-DD'), 'Dostarczono', 71, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/11', 'RRRR-MM-DD'), to_date('2020/07/14', 'RRRR-MM-DD'), to_date('2020/07/13', 'RRRR-MM-DD'), 'Dostarczono', 454, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/27', 'RRRR-MM-DD'), to_date('2019/12/30', 'RRRR-MM-DD'), to_date('2019/12/29', 'RRRR-MM-DD'), 'Dostarczono', 245, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/14', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), 'Dostarczono', 174, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/12', 'RRRR-MM-DD'), to_date('2020/07/15', 'RRRR-MM-DD'), to_date('2020/07/14', 'RRRR-MM-DD'), 'Dostarczono', 429, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/03', 'RRRR-MM-DD'), to_date('2020/10/06', 'RRRR-MM-DD'), to_date('2020/10/09', 'RRRR-MM-DD'), 'Dostarczono', 91, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/10', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), to_date('2019/12/16', 'RRRR-MM-DD'), 'Dostarczono', 355, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/25', 'RRRR-MM-DD'), to_date('2020/12/28', 'RRRR-MM-DD'), to_date('2020/12/27', 'RRRR-MM-DD'), 'Dostarczono', 351, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/15', 'RRRR-MM-DD'), to_date('2019/07/18', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), 'Dostarczono', 47, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/11', 'RRRR-MM-DD'), to_date('2020/11/14', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), 'Dostarczono', 92, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/22', 'RRRR-MM-DD'), to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/28', 'RRRR-MM-DD'), 'Dostarczono', 161, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/10', 'RRRR-MM-DD'), to_date('2020/05/13', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), 'Dostarczono', 125, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), to_date('2020/06/19', 'RRRR-MM-DD'), 'Dostarczono', 247, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/27', 'RRRR-MM-DD'), to_date('2020/03/01', 'RRRR-MM-DD'), to_date('2020/03/02', 'RRRR-MM-DD'), 'Dostarczono', 91, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/14', 'RRRR-MM-DD'), to_date('2020/09/17', 'RRRR-MM-DD'), to_date('2020/09/19', 'RRRR-MM-DD'), 'Dostarczono', 339, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/17', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), to_date('2019/07/22', 'RRRR-MM-DD'), 'Dostarczono', 428, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/28', 'RRRR-MM-DD'), to_date('2020/08/31', 'RRRR-MM-DD'), to_date('2020/09/03', 'RRRR-MM-DD'), 'Dostarczono', 370, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/09', 'RRRR-MM-DD'), to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), 'Dostarczono', 187, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/27', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), 'Dostarczono', 250, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/02', 'RRRR-MM-DD'), to_date('2019/08/05', 'RRRR-MM-DD'), to_date('2019/08/05', 'RRRR-MM-DD'), 'Dostarczono', 142, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/23', 'RRRR-MM-DD'), to_date('2019/08/26', 'RRRR-MM-DD'), to_date('2019/08/27', 'RRRR-MM-DD'), 'Dostarczono', 500, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/04', 'RRRR-MM-DD'), to_date('2019/09/07', 'RRRR-MM-DD'), to_date('2019/09/08', 'RRRR-MM-DD'), 'Dostarczono', 266, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/03', 'RRRR-MM-DD'), to_date('2019/12/06', 'RRRR-MM-DD'), to_date('2019/12/06', 'RRRR-MM-DD'), 'Dostarczono', 214, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/02', 'RRRR-MM-DD'), to_date('2019/01/05', 'RRRR-MM-DD'), to_date('2019/01/06', 'RRRR-MM-DD'), 'Dostarczono', 221, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/24', 'RRRR-MM-DD'), to_date('2019/09/27', 'RRRR-MM-DD'), to_date('2019/09/26', 'RRRR-MM-DD'), 'Dostarczono', 98, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/07', 'RRRR-MM-DD'), to_date('2019/12/10', 'RRRR-MM-DD'), to_date('2019/12/10', 'RRRR-MM-DD'), 'Dostarczono', 418, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), 'Dostarczono', 452, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/06', 'RRRR-MM-DD'), to_date('2019/02/09', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), 'Dostarczono', 278, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/20', 'RRRR-MM-DD'), to_date('2020/11/23', 'RRRR-MM-DD'), to_date('2020/11/25', 'RRRR-MM-DD'), 'Dostarczono', 422, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/02', 'RRRR-MM-DD'), to_date('2019/02/05', 'RRRR-MM-DD'), to_date('2019/02/05', 'RRRR-MM-DD'), 'Dostarczono', 427, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/07', 'RRRR-MM-DD'), to_date('2019/03/10', 'RRRR-MM-DD'), to_date('2019/03/12', 'RRRR-MM-DD'), 'Dostarczono', 499, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/23', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), 'Dostarczono', 22, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/28', 'RRRR-MM-DD'), to_date('2020/12/31', 'RRRR-MM-DD'), to_date('2020/12/30', 'RRRR-MM-DD'), 'Dostarczono', 225, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), to_date('2020/06/19', 'RRRR-MM-DD'), 'Dostarczono', 1, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/13', 'RRRR-MM-DD'), to_date('2019/10/16', 'RRRR-MM-DD'), to_date('2019/10/18', 'RRRR-MM-DD'), 'Dostarczono', 56, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/22', 'RRRR-MM-DD'), to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/27', 'RRRR-MM-DD'), 'Dostarczono', 25, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/21', 'RRRR-MM-DD'), 'Dostarczono', 342, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/11', 'RRRR-MM-DD'), to_date('2019/07/14', 'RRRR-MM-DD'), to_date('2019/07/13', 'RRRR-MM-DD'), 'Dostarczono', 264, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/07', 'RRRR-MM-DD'), to_date('2020/09/10', 'RRRR-MM-DD'), to_date('2020/09/09', 'RRRR-MM-DD'), 'Dostarczono', 2, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/28', 'RRRR-MM-DD'), to_date('2019/07/01', 'RRRR-MM-DD'), to_date('2019/07/02', 'RRRR-MM-DD'), 'Dostarczono', 339, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/28', 'RRRR-MM-DD'), to_date('2019/08/31', 'RRRR-MM-DD'), to_date('2019/09/03', 'RRRR-MM-DD'), 'Dostarczono', 383, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/11', 'RRRR-MM-DD'), to_date('2019/01/14', 'RRRR-MM-DD'), to_date('2019/01/15', 'RRRR-MM-DD'), 'Dostarczono', 398, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/06', 'RRRR-MM-DD'), to_date('2020/02/09', 'RRRR-MM-DD'), to_date('2020/02/10', 'RRRR-MM-DD'), 'Dostarczono', 403, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/19', 'RRRR-MM-DD'), to_date('2019/02/22', 'RRRR-MM-DD'), to_date('2019/02/23', 'RRRR-MM-DD'), 'Dostarczono', 162, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/17', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), to_date('2019/03/21', 'RRRR-MM-DD'), 'Dostarczono', 150, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/07', 'RRRR-MM-DD'), to_date('2020/10/10', 'RRRR-MM-DD'), to_date('2020/10/09', 'RRRR-MM-DD'), 'Dostarczono', 22, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/02', 'RRRR-MM-DD'), to_date('2020/06/05', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), 'Dostarczono', 472, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/26', 'RRRR-MM-DD'), to_date('2020/07/29', 'RRRR-MM-DD'), to_date('2020/07/29', 'RRRR-MM-DD'), 'Dostarczono', 402, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), to_date('2020/05/18', 'RRRR-MM-DD'), 'Dostarczono', 472, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/18', 'RRRR-MM-DD'), to_date('2019/09/21', 'RRRR-MM-DD'), to_date('2019/09/24', 'RRRR-MM-DD'), 'Dostarczono', 21, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/10', 'RRRR-MM-DD'), to_date('2019/05/13', 'RRRR-MM-DD'), to_date('2019/05/16', 'RRRR-MM-DD'), 'Dostarczono', 91, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/17', 'RRRR-MM-DD'), to_date('2019/05/20', 'RRRR-MM-DD'), to_date('2019/05/19', 'RRRR-MM-DD'), 'Dostarczono', 448, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/09', 'RRRR-MM-DD'), to_date('2019/07/12', 'RRRR-MM-DD'), to_date('2019/07/13', 'RRRR-MM-DD'), 'Dostarczono', 251, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/21', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), 'Dostarczono', 352, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/01', 'RRRR-MM-DD'), to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/03', 'RRRR-MM-DD'), 'Dostarczono', 245, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/05', 'RRRR-MM-DD'), to_date('2019/11/08', 'RRRR-MM-DD'), to_date('2019/11/10', 'RRRR-MM-DD'), 'Dostarczono', 15, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), 'Dostarczono', 452, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/17', 'RRRR-MM-DD'), to_date('2019/06/20', 'RRRR-MM-DD'), to_date('2019/06/22', 'RRRR-MM-DD'), 'Dostarczono', 205, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/02', 'RRRR-MM-DD'), to_date('2020/05/05', 'RRRR-MM-DD'), to_date('2020/05/04', 'RRRR-MM-DD'), 'Dostarczono', 484, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/15', 'RRRR-MM-DD'), to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/17', 'RRRR-MM-DD'), 'Dostarczono', 284, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/21', 'RRRR-MM-DD'), to_date('2020/03/24', 'RRRR-MM-DD'), to_date('2020/03/25', 'RRRR-MM-DD'), 'Dostarczono', 291, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/26', 'RRRR-MM-DD'), to_date('2019/08/29', 'RRRR-MM-DD'), to_date('2019/09/01', 'RRRR-MM-DD'), 'Dostarczono', 144, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/08', 'RRRR-MM-DD'), to_date('2019/04/11', 'RRRR-MM-DD'), to_date('2019/04/10', 'RRRR-MM-DD'), 'Dostarczono', 14, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/27', 'RRRR-MM-DD'), to_date('2019/07/30', 'RRRR-MM-DD'), to_date('2019/07/31', 'RRRR-MM-DD'), 'Dostarczono', 500, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/14', 'RRRR-MM-DD'), to_date('2019/07/17', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), 'Dostarczono', 25, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/01', 'RRRR-MM-DD'), to_date('2019/10/04', 'RRRR-MM-DD'), to_date('2019/10/03', 'RRRR-MM-DD'), 'Dostarczono', 154, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/11', 'RRRR-MM-DD'), to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/15', 'RRRR-MM-DD'), 'Dostarczono', 312, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/26', 'RRRR-MM-DD'), to_date('2020/07/29', 'RRRR-MM-DD'), to_date('2020/07/28', 'RRRR-MM-DD'), 'Dostarczono', 417, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/25', 'RRRR-MM-DD'), to_date('2019/04/28', 'RRRR-MM-DD'), to_date('2019/04/30', 'RRRR-MM-DD'), 'Dostarczono', 277, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/17', 'RRRR-MM-DD'), to_date('2020/02/20', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), 'Dostarczono', 269, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/24', 'RRRR-MM-DD'), to_date('2020/04/27', 'RRRR-MM-DD'), to_date('2020/04/29', 'RRRR-MM-DD'), 'Dostarczono', 201, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/09', 'RRRR-MM-DD'), to_date('2019/11/12', 'RRRR-MM-DD'), to_date('2019/11/13', 'RRRR-MM-DD'), 'Dostarczono', 441, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/23', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/27', 'RRRR-MM-DD'), 'Dostarczono', 307, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/24', 'RRRR-MM-DD'), to_date('2020/07/26', 'RRRR-MM-DD'), 'Dostarczono', 432, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/07', 'RRRR-MM-DD'), to_date('2020/08/10', 'RRRR-MM-DD'), to_date('2020/08/12', 'RRRR-MM-DD'), 'Dostarczono', 421, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/17', 'RRRR-MM-DD'), to_date('2020/01/20', 'RRRR-MM-DD'), to_date('2020/01/20', 'RRRR-MM-DD'), 'Dostarczono', 191, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/11', 'RRRR-MM-DD'), to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), 'Dostarczono', 138, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/23', 'RRRR-MM-DD'), to_date('2020/06/26', 'RRRR-MM-DD'), to_date('2020/06/27', 'RRRR-MM-DD'), 'Dostarczono', 241, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/20', 'RRRR-MM-DD'), to_date('2019/09/23', 'RRRR-MM-DD'), to_date('2019/09/25', 'RRRR-MM-DD'), 'Dostarczono', 178, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/12', 'RRRR-MM-DD'), to_date('2019/07/15', 'RRRR-MM-DD'), to_date('2019/07/15', 'RRRR-MM-DD'), 'Dostarczono', 131, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/06', 'RRRR-MM-DD'), to_date('2019/08/09', 'RRRR-MM-DD'), to_date('2019/08/08', 'RRRR-MM-DD'), 'Dostarczono', 220, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/04', 'RRRR-MM-DD'), to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), 'Dostarczono', 29, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/15', 'RRRR-MM-DD'), to_date('2020/02/18', 'RRRR-MM-DD'), to_date('2020/02/20', 'RRRR-MM-DD'), 'Dostarczono', 349, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/12', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), to_date('2019/09/17', 'RRRR-MM-DD'), 'Dostarczono', 327, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/06', 'RRRR-MM-DD'), to_date('2020/03/09', 'RRRR-MM-DD'), to_date('2020/03/08', 'RRRR-MM-DD'), 'Dostarczono', 150, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/06', 'RRRR-MM-DD'), to_date('2019/08/09', 'RRRR-MM-DD'), to_date('2019/08/08', 'RRRR-MM-DD'), 'Dostarczono', 203, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/20', 'RRRR-MM-DD'), to_date('2019/07/23', 'RRRR-MM-DD'), to_date('2019/07/25', 'RRRR-MM-DD'), 'Dostarczono', 292, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/23', 'RRRR-MM-DD'), to_date('2020/05/26', 'RRRR-MM-DD'), to_date('2020/05/28', 'RRRR-MM-DD'), 'Dostarczono', 234, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/24', 'RRRR-MM-DD'), to_date('2019/10/27', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), 'Dostarczono', 144, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/18', 'RRRR-MM-DD'), to_date('2019/10/21', 'RRRR-MM-DD'), to_date('2019/10/22', 'RRRR-MM-DD'), 'Dostarczono', 144, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/16', 'RRRR-MM-DD'), to_date('2019/10/19', 'RRRR-MM-DD'), to_date('2019/10/21', 'RRRR-MM-DD'), 'Dostarczono', 338, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/27', 'RRRR-MM-DD'), to_date('2020/11/30', 'RRRR-MM-DD'), to_date('2020/11/29', 'RRRR-MM-DD'), 'Dostarczono', 491, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/22', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/24', 'RRRR-MM-DD'), 'Dostarczono', 92, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/07', 'RRRR-MM-DD'), to_date('2020/03/10', 'RRRR-MM-DD'), to_date('2020/03/09', 'RRRR-MM-DD'), 'Dostarczono', 324, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/19', 'RRRR-MM-DD'), to_date('2019/04/22', 'RRRR-MM-DD'), to_date('2019/04/23', 'RRRR-MM-DD'), 'Dostarczono', 135, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/05', 'RRRR-MM-DD'), to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/07', 'RRRR-MM-DD'), 'Dostarczono', 347, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/16', 'RRRR-MM-DD'), to_date('2020/09/19', 'RRRR-MM-DD'), to_date('2020/09/21', 'RRRR-MM-DD'), 'Dostarczono', 452, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/22', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), 'Dostarczono', 155, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/25', 'RRRR-MM-DD'), to_date('2020/03/28', 'RRRR-MM-DD'), to_date('2020/03/29', 'RRRR-MM-DD'), 'Dostarczono', 416, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/16', 'RRRR-MM-DD'), to_date('2019/06/19', 'RRRR-MM-DD'), to_date('2019/06/21', 'RRRR-MM-DD'), 'Dostarczono', 397, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/13', 'RRRR-MM-DD'), to_date('2019/05/16', 'RRRR-MM-DD'), to_date('2019/05/16', 'RRRR-MM-DD'), 'Dostarczono', 23, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), 'Dostarczono', 351, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/27', 'RRRR-MM-DD'), to_date('2020/07/30', 'RRRR-MM-DD'), to_date('2020/08/01', 'RRRR-MM-DD'), 'Dostarczono', 415, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/01', 'RRRR-MM-DD'), to_date('2020/02/04', 'RRRR-MM-DD'), to_date('2020/02/04', 'RRRR-MM-DD'), 'Dostarczono', 30, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/20', 'RRRR-MM-DD'), to_date('2019/12/23', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), 'Dostarczono', 449, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/09', 'RRRR-MM-DD'), to_date('2020/12/12', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), 'Dostarczono', 255, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/04', 'RRRR-MM-DD'), to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), 'Dostarczono', 340, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/10', 'RRRR-MM-DD'), to_date('2019/04/13', 'RRRR-MM-DD'), to_date('2019/04/12', 'RRRR-MM-DD'), 'Dostarczono', 306, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/17', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), to_date('2020/05/21', 'RRRR-MM-DD'), 'Dostarczono', 68, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/07', 'RRRR-MM-DD'), to_date('2020/03/10', 'RRRR-MM-DD'), to_date('2020/03/13', 'RRRR-MM-DD'), 'Dostarczono', 63, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/20', 'RRRR-MM-DD'), to_date('2019/06/23', 'RRRR-MM-DD'), to_date('2019/06/23', 'RRRR-MM-DD'), 'Dostarczono', 239, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/25', 'RRRR-MM-DD'), to_date('2019/07/28', 'RRRR-MM-DD'), to_date('2019/07/28', 'RRRR-MM-DD'), 'Dostarczono', 227, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/22', 'RRRR-MM-DD'), to_date('2020/12/25', 'RRRR-MM-DD'), to_date('2020/12/27', 'RRRR-MM-DD'), 'Dostarczono', 353, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/01', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/03', 'RRRR-MM-DD'), 'Dostarczono', 316, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/22', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/27', 'RRRR-MM-DD'), 'Dostarczono', 250, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/17', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), to_date('2020/05/23', 'RRRR-MM-DD'), 'Dostarczono', 299, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/03', 'RRRR-MM-DD'), to_date('2020/11/06', 'RRRR-MM-DD'), to_date('2020/11/09', 'RRRR-MM-DD'), 'Dostarczono', 195, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/18', 'RRRR-MM-DD'), to_date('2019/10/21', 'RRRR-MM-DD'), to_date('2019/10/22', 'RRRR-MM-DD'), 'Dostarczono', 36, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/14', 'RRRR-MM-DD'), to_date('2020/08/16', 'RRRR-MM-DD'), 'Dostarczono', 184, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/24', 'RRRR-MM-DD'), to_date('2020/07/27', 'RRRR-MM-DD'), 'Dostarczono', 195, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/09', 'RRRR-MM-DD'), to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/12', 'RRRR-MM-DD'), 'Dostarczono', 226, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/05', 'RRRR-MM-DD'), to_date('2019/06/08', 'RRRR-MM-DD'), to_date('2019/06/08', 'RRRR-MM-DD'), 'Dostarczono', 286, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/27', 'RRRR-MM-DD'), to_date('2019/06/30', 'RRRR-MM-DD'), to_date('2019/07/03', 'RRRR-MM-DD'), 'Dostarczono', 137, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/18', 'RRRR-MM-DD'), to_date('2019/06/21', 'RRRR-MM-DD'), to_date('2019/06/23', 'RRRR-MM-DD'), 'Dostarczono', 433, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/05', 'RRRR-MM-DD'), to_date('2019/02/08', 'RRRR-MM-DD'), to_date('2019/02/09', 'RRRR-MM-DD'), 'Dostarczono', 350, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/06', 'RRRR-MM-DD'), to_date('2020/08/09', 'RRRR-MM-DD'), to_date('2020/08/09', 'RRRR-MM-DD'), 'Dostarczono', 463, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/21', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), 'Dostarczono', 435, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/02', 'RRRR-MM-DD'), to_date('2019/02/05', 'RRRR-MM-DD'), to_date('2019/02/06', 'RRRR-MM-DD'), 'Dostarczono', 297, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/22', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/27', 'RRRR-MM-DD'), 'Dostarczono', 234, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/03', 'RRRR-MM-DD'), to_date('2019/02/06', 'RRRR-MM-DD'), to_date('2019/02/08', 'RRRR-MM-DD'), 'Dostarczono', 402, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/22', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/26', 'RRRR-MM-DD'), 'Dostarczono', 309, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/17', 'RRRR-MM-DD'), to_date('2020/02/20', 'RRRR-MM-DD'), to_date('2020/02/20', 'RRRR-MM-DD'), 'Dostarczono', 154, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/12', 'RRRR-MM-DD'), to_date('2020/03/15', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), 'Dostarczono', 395, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/15', 'RRRR-MM-DD'), to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/19', 'RRRR-MM-DD'), 'Dostarczono', 289, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/13', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), 'Dostarczono', 287, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/13', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), to_date('2020/03/17', 'RRRR-MM-DD'), 'Dostarczono', 107, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/07', 'RRRR-MM-DD'), to_date('2020/10/10', 'RRRR-MM-DD'), to_date('2020/10/13', 'RRRR-MM-DD'), 'Dostarczono', 49, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/04', 'RRRR-MM-DD'), to_date('2020/08/07', 'RRRR-MM-DD'), to_date('2020/08/07', 'RRRR-MM-DD'), 'Dostarczono', 115, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/10', 'RRRR-MM-DD'), to_date('2020/04/13', 'RRRR-MM-DD'), to_date('2020/04/13', 'RRRR-MM-DD'), 'Dostarczono', 10, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/20', 'RRRR-MM-DD'), to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/24', 'RRRR-MM-DD'), 'Dostarczono', 362, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/02', 'RRRR-MM-DD'), to_date('2019/08/05', 'RRRR-MM-DD'), to_date('2019/08/05', 'RRRR-MM-DD'), 'Dostarczono', 418, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), to_date('2020/11/01', 'RRRR-MM-DD'), 'Dostarczono', 470, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/09', 'RRRR-MM-DD'), to_date('2020/01/12', 'RRRR-MM-DD'), to_date('2020/01/12', 'RRRR-MM-DD'), 'Dostarczono', 102, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/28', 'RRRR-MM-DD'), to_date('2020/05/01', 'RRRR-MM-DD'), to_date('2020/04/30', 'RRRR-MM-DD'), 'Dostarczono', 228, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/14', 'RRRR-MM-DD'), to_date('2020/12/17', 'RRRR-MM-DD'), to_date('2020/12/18', 'RRRR-MM-DD'), 'Dostarczono', 337, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/14', 'RRRR-MM-DD'), to_date('2020/08/16', 'RRRR-MM-DD'), 'Dostarczono', 90, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/15', 'RRRR-MM-DD'), to_date('2020/09/18', 'RRRR-MM-DD'), to_date('2020/09/18', 'RRRR-MM-DD'), 'Dostarczono', 351, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/22', 'RRRR-MM-DD'), to_date('2019/01/25', 'RRRR-MM-DD'), to_date('2019/01/24', 'RRRR-MM-DD'), 'Dostarczono', 309, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/13', 'RRRR-MM-DD'), to_date('2019/09/16', 'RRRR-MM-DD'), to_date('2019/09/16', 'RRRR-MM-DD'), 'Dostarczono', 11, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/29', 'RRRR-MM-DD'), to_date('2020/05/02', 'RRRR-MM-DD'), 'Dostarczono', 351, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/28', 'RRRR-MM-DD'), to_date('2019/05/29', 'RRRR-MM-DD'), 'Dostarczono', 388, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/20', 'RRRR-MM-DD'), to_date('2020/03/23', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), 'Dostarczono', 296, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/13', 'RRRR-MM-DD'), to_date('2020/06/16', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), 'Dostarczono', 399, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/22', 'RRRR-MM-DD'), to_date('2020/04/25', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), 'Dostarczono', 327, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/10', 'RRRR-MM-DD'), to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), 'Dostarczono', 97, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/10', 'RRRR-MM-DD'), to_date('2019/09/13', 'RRRR-MM-DD'), to_date('2019/09/14', 'RRRR-MM-DD'), 'Dostarczono', 396, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/05', 'RRRR-MM-DD'), to_date('2019/12/08', 'RRRR-MM-DD'), to_date('2019/12/07', 'RRRR-MM-DD'), 'Dostarczono', 309, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/11', 'RRRR-MM-DD'), to_date('2020/07/14', 'RRRR-MM-DD'), to_date('2020/07/14', 'RRRR-MM-DD'), 'Dostarczono', 449, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/15', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), 'Dostarczono', 452, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/03', 'RRRR-MM-DD'), to_date('2020/04/06', 'RRRR-MM-DD'), to_date('2020/04/05', 'RRRR-MM-DD'), 'Dostarczono', 227, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/04', 'RRRR-MM-DD'), to_date('2020/03/07', 'RRRR-MM-DD'), to_date('2020/03/06', 'RRRR-MM-DD'), 'Dostarczono', 157, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), 'Dostarczono', 422, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/27', 'RRRR-MM-DD'), to_date('2019/07/30', 'RRRR-MM-DD'), to_date('2019/07/30', 'RRRR-MM-DD'), 'Dostarczono', 367, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/08', 'RRRR-MM-DD'), to_date('2019/05/11', 'RRRR-MM-DD'), to_date('2019/05/14', 'RRRR-MM-DD'), 'Dostarczono', 243, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/09', 'RRRR-MM-DD'), to_date('2020/08/12', 'RRRR-MM-DD'), to_date('2020/08/13', 'RRRR-MM-DD'), 'Dostarczono', 426, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/25', 'RRRR-MM-DD'), to_date('2020/02/28', 'RRRR-MM-DD'), to_date('2020/03/02', 'RRRR-MM-DD'), 'Dostarczono', 474, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/04', 'RRRR-MM-DD'), to_date('2020/10/07', 'RRRR-MM-DD'), to_date('2020/10/08', 'RRRR-MM-DD'), 'Dostarczono', 148, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/18', 'RRRR-MM-DD'), to_date('2019/08/21', 'RRRR-MM-DD'), to_date('2019/08/24', 'RRRR-MM-DD'), 'Dostarczono', 470, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/10', 'RRRR-MM-DD'), to_date('2019/09/13', 'RRRR-MM-DD'), to_date('2019/09/12', 'RRRR-MM-DD'), 'Dostarczono', 308, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), 'Dostarczono', 397, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/23', 'RRRR-MM-DD'), to_date('2019/03/26', 'RRRR-MM-DD'), to_date('2019/03/25', 'RRRR-MM-DD'), 'Dostarczono', 184, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/18', 'RRRR-MM-DD'), 'Dostarczono', 69, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/14', 'RRRR-MM-DD'), to_date('2020/01/17', 'RRRR-MM-DD'), to_date('2020/01/18', 'RRRR-MM-DD'), 'Dostarczono', 256, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/24', 'RRRR-MM-DD'), to_date('2020/05/27', 'RRRR-MM-DD'), to_date('2020/05/30', 'RRRR-MM-DD'), 'Dostarczono', 488, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/08', 'RRRR-MM-DD'), to_date('2020/11/11', 'RRRR-MM-DD'), to_date('2020/11/14', 'RRRR-MM-DD'), 'Dostarczono', 395, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/22', 'RRRR-MM-DD'), to_date('2020/03/25', 'RRRR-MM-DD'), to_date('2020/03/24', 'RRRR-MM-DD'), 'Dostarczono', 25, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/21', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), 'Dostarczono', 154, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/27', 'RRRR-MM-DD'), to_date('2020/06/29', 'RRRR-MM-DD'), 'Dostarczono', 273, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/07', 'RRRR-MM-DD'), to_date('2020/05/10', 'RRRR-MM-DD'), to_date('2020/05/12', 'RRRR-MM-DD'), 'Dostarczono', 492, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/28', 'RRRR-MM-DD'), 'Dostarczono', 73, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/24', 'RRRR-MM-DD'), to_date('2019/01/27', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), 'Dostarczono', 378, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), to_date('2020/05/14', 'RRRR-MM-DD'), 'Dostarczono', 433, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/11', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), 'Dostarczono', 11, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/10', 'RRRR-MM-DD'), to_date('2019/05/13', 'RRRR-MM-DD'), to_date('2019/05/12', 'RRRR-MM-DD'), 'Dostarczono', 181, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/11', 'RRRR-MM-DD'), to_date('2019/01/14', 'RRRR-MM-DD'), to_date('2019/01/14', 'RRRR-MM-DD'), 'Dostarczono', 500, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/02', 'RRRR-MM-DD'), to_date('2020/06/05', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), 'Dostarczono', 301, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/04', 'RRRR-MM-DD'), to_date('2019/07/07', 'RRRR-MM-DD'), to_date('2019/07/10', 'RRRR-MM-DD'), 'Dostarczono', 357, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/15', 'RRRR-MM-DD'), to_date('2020/04/14', 'RRRR-MM-DD'), 'Dostarczono', 376, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/18', 'RRRR-MM-DD'), to_date('2019/07/21', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), 'Dostarczono', 127, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/12', 'RRRR-MM-DD'), to_date('2020/08/15', 'RRRR-MM-DD'), to_date('2020/08/16', 'RRRR-MM-DD'), 'Dostarczono', 22, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/02', 'RRRR-MM-DD'), to_date('2020/04/05', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), 'Dostarczono', 389, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/07', 'RRRR-MM-DD'), to_date('2020/09/10', 'RRRR-MM-DD'), to_date('2020/09/13', 'RRRR-MM-DD'), 'Dostarczono', 261, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/12', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), to_date('2020/11/14', 'RRRR-MM-DD'), 'Dostarczono', 303, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/06', 'RRRR-MM-DD'), to_date('2019/09/09', 'RRRR-MM-DD'), to_date('2019/09/12', 'RRRR-MM-DD'), 'Dostarczono', 242, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/21', 'RRRR-MM-DD'), to_date('2020/01/24', 'RRRR-MM-DD'), to_date('2020/01/23', 'RRRR-MM-DD'), 'Dostarczono', 210, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/27', 'RRRR-MM-DD'), to_date('2020/03/01', 'RRRR-MM-DD'), to_date('2020/03/01', 'RRRR-MM-DD'), 'Dostarczono', 338, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/13', 'RRRR-MM-DD'), to_date('2019/05/16', 'RRRR-MM-DD'), to_date('2019/05/17', 'RRRR-MM-DD'), 'Dostarczono', 385, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/15', 'RRRR-MM-DD'), to_date('2019/04/18', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), 'Dostarczono', 455, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/06', 'RRRR-MM-DD'), to_date('2020/05/09', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), 'Dostarczono', 18, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/08', 'RRRR-MM-DD'), to_date('2020/04/11', 'RRRR-MM-DD'), to_date('2020/04/10', 'RRRR-MM-DD'), 'Dostarczono', 61, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), 'Dostarczono', 294, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/22', 'RRRR-MM-DD'), to_date('2019/08/25', 'RRRR-MM-DD'), to_date('2019/08/26', 'RRRR-MM-DD'), 'Dostarczono', 395, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/05', 'RRRR-MM-DD'), to_date('2020/03/08', 'RRRR-MM-DD'), to_date('2020/03/09', 'RRRR-MM-DD'), 'Dostarczono', 277, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/25', 'RRRR-MM-DD'), to_date('2020/04/28', 'RRRR-MM-DD'), to_date('2020/04/28', 'RRRR-MM-DD'), 'Dostarczono', 238, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/13', 'RRRR-MM-DD'), to_date('2020/02/16', 'RRRR-MM-DD'), to_date('2020/02/19', 'RRRR-MM-DD'), 'Dostarczono', 199, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/09', 'RRRR-MM-DD'), to_date('2020/07/12', 'RRRR-MM-DD'), to_date('2020/07/12', 'RRRR-MM-DD'), 'Dostarczono', 450, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), 'Dostarczono', 63, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/21', 'RRRR-MM-DD'), to_date('2019/07/24', 'RRRR-MM-DD'), to_date('2019/07/26', 'RRRR-MM-DD'), 'Dostarczono', 28, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/26', 'RRRR-MM-DD'), to_date('2019/12/29', 'RRRR-MM-DD'), to_date('2020/01/01', 'RRRR-MM-DD'), 'Dostarczono', 209, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/01', 'RRRR-MM-DD'), to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/07', 'RRRR-MM-DD'), 'Dostarczono', 333, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/25', 'RRRR-MM-DD'), to_date('2019/04/28', 'RRRR-MM-DD'), to_date('2019/04/27', 'RRRR-MM-DD'), 'Dostarczono', 452, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/13', 'RRRR-MM-DD'), to_date('2020/02/16', 'RRRR-MM-DD'), to_date('2020/02/18', 'RRRR-MM-DD'), 'Dostarczono', 215, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/15', 'RRRR-MM-DD'), to_date('2019/01/18', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), 'Dostarczono', 251, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/08', 'RRRR-MM-DD'), to_date('2020/06/11', 'RRRR-MM-DD'), to_date('2020/06/10', 'RRRR-MM-DD'), 'Dostarczono', 383, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/17', 'RRRR-MM-DD'), to_date('2020/03/20', 'RRRR-MM-DD'), to_date('2020/03/23', 'RRRR-MM-DD'), 'Dostarczono', 306, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/27', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), to_date('2020/10/03', 'RRRR-MM-DD'), 'Dostarczono', 49, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/07', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), 'Dostarczono', 195, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/22', 'RRRR-MM-DD'), to_date('2019/10/25', 'RRRR-MM-DD'), to_date('2019/10/27', 'RRRR-MM-DD'), 'Dostarczono', 259, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/07', 'RRRR-MM-DD'), to_date('2019/07/10', 'RRRR-MM-DD'), to_date('2019/07/09', 'RRRR-MM-DD'), 'Dostarczono', 18, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/23', 'RRRR-MM-DD'), to_date('2019/07/26', 'RRRR-MM-DD'), to_date('2019/07/26', 'RRRR-MM-DD'), 'Dostarczono', 78, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/14', 'RRRR-MM-DD'), to_date('2019/03/17', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), 'Dostarczono', 73, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/19', 'RRRR-MM-DD'), to_date('2020/09/22', 'RRRR-MM-DD'), to_date('2020/09/24', 'RRRR-MM-DD'), 'Dostarczono', 494, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/02', 'RRRR-MM-DD'), to_date('2019/04/05', 'RRRR-MM-DD'), to_date('2019/04/08', 'RRRR-MM-DD'), 'Dostarczono', 367, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/03', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), to_date('2020/06/08', 'RRRR-MM-DD'), 'Dostarczono', 269, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/21', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), 'Dostarczono', 476, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/06', 'RRRR-MM-DD'), to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/08', 'RRRR-MM-DD'), 'Dostarczono', 186, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/22', 'RRRR-MM-DD'), to_date('2020/12/25', 'RRRR-MM-DD'), to_date('2020/12/26', 'RRRR-MM-DD'), 'Dostarczono', 209, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/05', 'RRRR-MM-DD'), to_date('2019/05/08', 'RRRR-MM-DD'), to_date('2019/05/09', 'RRRR-MM-DD'), 'Dostarczono', 94, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/05', 'RRRR-MM-DD'), to_date('2020/08/08', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), 'Dostarczono', 30, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/14', 'RRRR-MM-DD'), to_date('2019/11/17', 'RRRR-MM-DD'), to_date('2019/11/17', 'RRRR-MM-DD'), 'Dostarczono', 155, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/16', 'RRRR-MM-DD'), to_date('2020/10/19', 'RRRR-MM-DD'), to_date('2020/10/22', 'RRRR-MM-DD'), 'Dostarczono', 435, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/18', 'RRRR-MM-DD'), to_date('2020/05/21', 'RRRR-MM-DD'), to_date('2020/05/22', 'RRRR-MM-DD'), 'Dostarczono', 444, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), to_date('2019/05/10', 'RRRR-MM-DD'), 'Dostarczono', 36, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/25', 'RRRR-MM-DD'), to_date('2020/09/28', 'RRRR-MM-DD'), to_date('2020/09/27', 'RRRR-MM-DD'), 'Dostarczono', 106, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/14', 'RRRR-MM-DD'), to_date('2019/06/17', 'RRRR-MM-DD'), to_date('2019/06/19', 'RRRR-MM-DD'), 'Dostarczono', 497, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/11', 'RRRR-MM-DD'), to_date('2020/03/14', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), 'Dostarczono', 68, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/13', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), 'Dostarczono', 81, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), 'Dostarczono', 398, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), 'Dostarczono', 96, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/08', 'RRRR-MM-DD'), to_date('2020/04/11', 'RRRR-MM-DD'), to_date('2020/04/14', 'RRRR-MM-DD'), 'Dostarczono', 322, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/05', 'RRRR-MM-DD'), to_date('2019/03/08', 'RRRR-MM-DD'), to_date('2019/03/07', 'RRRR-MM-DD'), 'Dostarczono', 416, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/20', 'RRRR-MM-DD'), to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/24', 'RRRR-MM-DD'), 'Dostarczono', 72, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/24', 'RRRR-MM-DD'), to_date('2019/02/27', 'RRRR-MM-DD'), to_date('2019/03/01', 'RRRR-MM-DD'), 'Dostarczono', 287, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/09', 'RRRR-MM-DD'), to_date('2020/12/12', 'RRRR-MM-DD'), to_date('2020/12/12', 'RRRR-MM-DD'), 'Dostarczono', 421, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/22', 'RRRR-MM-DD'), to_date('2019/08/25', 'RRRR-MM-DD'), to_date('2019/08/28', 'RRRR-MM-DD'), 'Dostarczono', 324, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/10', 'RRRR-MM-DD'), to_date('2019/05/13', 'RRRR-MM-DD'), to_date('2019/05/12', 'RRRR-MM-DD'), 'Dostarczono', 269, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/05', 'RRRR-MM-DD'), to_date('2019/11/08', 'RRRR-MM-DD'), to_date('2019/11/09', 'RRRR-MM-DD'), 'Dostarczono', 428, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/17', 'RRRR-MM-DD'), to_date('2020/04/20', 'RRRR-MM-DD'), to_date('2020/04/20', 'RRRR-MM-DD'), 'Dostarczono', 466, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/12', 'RRRR-MM-DD'), to_date('2020/10/15', 'RRRR-MM-DD'), to_date('2020/10/16', 'RRRR-MM-DD'), 'Dostarczono', 21, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/20', 'RRRR-MM-DD'), to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/24', 'RRRR-MM-DD'), 'Dostarczono', 325, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/23', 'RRRR-MM-DD'), to_date('2019/02/26', 'RRRR-MM-DD'), to_date('2019/03/01', 'RRRR-MM-DD'), 'Dostarczono', 182, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/12', 'RRRR-MM-DD'), to_date('2019/05/15', 'RRRR-MM-DD'), to_date('2019/05/15', 'RRRR-MM-DD'), 'Dostarczono', 362, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/11', 'RRRR-MM-DD'), to_date('2019/07/14', 'RRRR-MM-DD'), to_date('2019/07/15', 'RRRR-MM-DD'), 'Dostarczono', 88, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/03', 'RRRR-MM-DD'), to_date('2019/03/06', 'RRRR-MM-DD'), to_date('2019/03/08', 'RRRR-MM-DD'), 'Dostarczono', 73, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/23', 'RRRR-MM-DD'), to_date('2019/09/26', 'RRRR-MM-DD'), to_date('2019/09/27', 'RRRR-MM-DD'), 'Dostarczono', 318, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/25', 'RRRR-MM-DD'), to_date('2019/05/28', 'RRRR-MM-DD'), to_date('2019/05/31', 'RRRR-MM-DD'), 'Dostarczono', 285, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/22', 'RRRR-MM-DD'), to_date('2019/09/25', 'RRRR-MM-DD'), to_date('2019/09/28', 'RRRR-MM-DD'), 'Dostarczono', 162, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/26', 'RRRR-MM-DD'), to_date('2020/03/29', 'RRRR-MM-DD'), to_date('2020/03/28', 'RRRR-MM-DD'), 'Dostarczono', 246, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/01', 'RRRR-MM-DD'), to_date('2019/10/04', 'RRRR-MM-DD'), to_date('2019/10/07', 'RRRR-MM-DD'), 'Dostarczono', 70, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/12', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), 'Dostarczono', 204, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/15', 'RRRR-MM-DD'), to_date('2019/07/18', 'RRRR-MM-DD'), to_date('2019/07/21', 'RRRR-MM-DD'), 'Dostarczono', 247, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/12', 'RRRR-MM-DD'), to_date('2019/01/15', 'RRRR-MM-DD'), to_date('2019/01/15', 'RRRR-MM-DD'), 'Dostarczono', 448, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/26', 'RRRR-MM-DD'), to_date('2020/11/29', 'RRRR-MM-DD'), to_date('2020/11/28', 'RRRR-MM-DD'), 'Dostarczono', 68, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/28', 'RRRR-MM-DD'), to_date('2019/03/03', 'RRRR-MM-DD'), to_date('2019/03/04', 'RRRR-MM-DD'), 'Dostarczono', 147, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/18', 'RRRR-MM-DD'), to_date('2019/11/21', 'RRRR-MM-DD'), to_date('2019/11/21', 'RRRR-MM-DD'), 'Dostarczono', 79, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/17', 'RRRR-MM-DD'), to_date('2019/12/20', 'RRRR-MM-DD'), to_date('2019/12/23', 'RRRR-MM-DD'), 'Dostarczono', 89, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/17', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), 'Dostarczono', 298, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/19', 'RRRR-MM-DD'), to_date('2020/08/22', 'RRRR-MM-DD'), to_date('2020/08/22', 'RRRR-MM-DD'), 'Dostarczono', 384, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/04', 'RRRR-MM-DD'), to_date('2019/03/07', 'RRRR-MM-DD'), to_date('2019/03/08', 'RRRR-MM-DD'), 'Dostarczono', 260, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/26', 'RRRR-MM-DD'), to_date('2019/10/29', 'RRRR-MM-DD'), to_date('2019/11/01', 'RRRR-MM-DD'), 'Dostarczono', 238, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/08', 'RRRR-MM-DD'), to_date('2019/01/11', 'RRRR-MM-DD'), to_date('2019/01/13', 'RRRR-MM-DD'), 'Dostarczono', 91, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/16', 'RRRR-MM-DD'), to_date('2019/08/19', 'RRRR-MM-DD'), to_date('2019/08/18', 'RRRR-MM-DD'), 'Dostarczono', 2, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/12', 'RRRR-MM-DD'), to_date('2019/06/15', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), 'Dostarczono', 111, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), 'Dostarczono', 414, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/15', 'RRRR-MM-DD'), to_date('2019/01/18', 'RRRR-MM-DD'), to_date('2019/01/21', 'RRRR-MM-DD'), 'Dostarczono', 462, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/07', 'RRRR-MM-DD'), to_date('2020/08/10', 'RRRR-MM-DD'), to_date('2020/08/10', 'RRRR-MM-DD'), 'Dostarczono', 308, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/06', 'RRRR-MM-DD'), to_date('2019/04/09', 'RRRR-MM-DD'), to_date('2019/04/08', 'RRRR-MM-DD'), 'Dostarczono', 216, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/14', 'RRRR-MM-DD'), to_date('2020/12/17', 'RRRR-MM-DD'), to_date('2020/12/19', 'RRRR-MM-DD'), 'Dostarczono', 303, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/03', 'RRRR-MM-DD'), to_date('2019/07/06', 'RRRR-MM-DD'), to_date('2019/07/09', 'RRRR-MM-DD'), 'Dostarczono', 148, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/05', 'RRRR-MM-DD'), to_date('2019/04/08', 'RRRR-MM-DD'), to_date('2019/04/10', 'RRRR-MM-DD'), 'Dostarczono', 186, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/24', 'RRRR-MM-DD'), to_date('2020/03/27', 'RRRR-MM-DD'), to_date('2020/03/29', 'RRRR-MM-DD'), 'Dostarczono', 446, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/16', 'RRRR-MM-DD'), to_date('2019/12/19', 'RRRR-MM-DD'), to_date('2019/12/19', 'RRRR-MM-DD'), 'Dostarczono', 337, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/25', 'RRRR-MM-DD'), 'Dostarczono', 313, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/23', 'RRRR-MM-DD'), to_date('2019/04/26', 'RRRR-MM-DD'), to_date('2019/04/27', 'RRRR-MM-DD'), 'Dostarczono', 144, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/08', 'RRRR-MM-DD'), to_date('2019/04/11', 'RRRR-MM-DD'), to_date('2019/04/14', 'RRRR-MM-DD'), 'Dostarczono', 188, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/24', 'RRRR-MM-DD'), to_date('2019/12/27', 'RRRR-MM-DD'), to_date('2019/12/28', 'RRRR-MM-DD'), 'Dostarczono', 243, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/14', 'RRRR-MM-DD'), to_date('2019/09/17', 'RRRR-MM-DD'), to_date('2019/09/18', 'RRRR-MM-DD'), 'Dostarczono', 203, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/27', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), to_date('2020/11/02', 'RRRR-MM-DD'), 'Dostarczono', 499, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/08', 'RRRR-MM-DD'), to_date('2019/10/11', 'RRRR-MM-DD'), to_date('2019/10/10', 'RRRR-MM-DD'), 'Dostarczono', 360, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/18', 'RRRR-MM-DD'), to_date('2019/03/21', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), 'Dostarczono', 144, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/25', 'RRRR-MM-DD'), to_date('2020/01/28', 'RRRR-MM-DD'), to_date('2020/01/30', 'RRRR-MM-DD'), 'Dostarczono', 343, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/19', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), to_date('2020/03/21', 'RRRR-MM-DD'), 'Dostarczono', 78, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/20', 'RRRR-MM-DD'), to_date('2019/02/23', 'RRRR-MM-DD'), to_date('2019/02/25', 'RRRR-MM-DD'), 'Dostarczono', 87, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/07', 'RRRR-MM-DD'), to_date('2019/12/10', 'RRRR-MM-DD'), to_date('2019/12/09', 'RRRR-MM-DD'), 'Dostarczono', 429, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/14', 'RRRR-MM-DD'), to_date('2020/04/17', 'RRRR-MM-DD'), to_date('2020/04/20', 'RRRR-MM-DD'), 'Dostarczono', 337, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/01', 'RRRR-MM-DD'), to_date('2020/09/04', 'RRRR-MM-DD'), to_date('2020/09/04', 'RRRR-MM-DD'), 'Dostarczono', 441, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/16', 'RRRR-MM-DD'), to_date('2019/05/19', 'RRRR-MM-DD'), to_date('2019/05/22', 'RRRR-MM-DD'), 'Dostarczono', 68, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/23', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/25', 'RRRR-MM-DD'), 'Dostarczono', 482, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/23', 'RRRR-MM-DD'), to_date('2020/01/26', 'RRRR-MM-DD'), to_date('2020/01/29', 'RRRR-MM-DD'), 'Dostarczono', 337, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/22', 'RRRR-MM-DD'), to_date('2020/07/25', 'RRRR-MM-DD'), to_date('2020/07/25', 'RRRR-MM-DD'), 'Dostarczono', 113, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/24', 'RRRR-MM-DD'), to_date('2019/07/27', 'RRRR-MM-DD'), to_date('2019/07/30', 'RRRR-MM-DD'), 'Dostarczono', 416, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/04', 'RRRR-MM-DD'), to_date('2020/12/07', 'RRRR-MM-DD'), to_date('2020/12/10', 'RRRR-MM-DD'), 'Dostarczono', 166, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/15', 'RRRR-MM-DD'), to_date('2020/09/18', 'RRRR-MM-DD'), to_date('2020/09/17', 'RRRR-MM-DD'), 'Dostarczono', 458, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/03', 'RRRR-MM-DD'), to_date('2020/11/06', 'RRRR-MM-DD'), to_date('2020/11/05', 'RRRR-MM-DD'), 'Dostarczono', 31, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/20', 'RRRR-MM-DD'), to_date('2020/02/23', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), 'Dostarczono', 412, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/13', 'RRRR-MM-DD'), to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/17', 'RRRR-MM-DD'), 'Dostarczono', 28, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/16', 'RRRR-MM-DD'), to_date('2020/05/19', 'RRRR-MM-DD'), to_date('2020/05/20', 'RRRR-MM-DD'), 'Dostarczono', 69, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/08', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/13', 'RRRR-MM-DD'), 'Dostarczono', 178, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/27', 'RRRR-MM-DD'), to_date('2019/03/02', 'RRRR-MM-DD'), to_date('2019/03/05', 'RRRR-MM-DD'), 'Dostarczono', 27, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/07', 'RRRR-MM-DD'), to_date('2020/10/10', 'RRRR-MM-DD'), to_date('2020/10/12', 'RRRR-MM-DD'), 'Dostarczono', 192, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/28', 'RRRR-MM-DD'), to_date('2020/12/01', 'RRRR-MM-DD'), to_date('2020/12/01', 'RRRR-MM-DD'), 'Dostarczono', 51, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/21', 'RRRR-MM-DD'), to_date('2019/05/24', 'RRRR-MM-DD'), to_date('2019/05/27', 'RRRR-MM-DD'), 'Dostarczono', 497, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/10', 'RRRR-MM-DD'), to_date('2020/09/13', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), 'Dostarczono', 499, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/06', 'RRRR-MM-DD'), to_date('2019/02/09', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), 'Dostarczono', 442, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/02', 'RRRR-MM-DD'), to_date('2020/06/05', 'RRRR-MM-DD'), to_date('2020/06/06', 'RRRR-MM-DD'), 'Dostarczono', 413, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), 'Dostarczono', 21, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/15', 'RRRR-MM-DD'), to_date('2020/11/18', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), 'Dostarczono', 477, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/02', 'RRRR-MM-DD'), to_date('2020/10/05', 'RRRR-MM-DD'), to_date('2020/10/06', 'RRRR-MM-DD'), 'Dostarczono', 257, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/25', 'RRRR-MM-DD'), to_date('2019/08/28', 'RRRR-MM-DD'), to_date('2019/08/30', 'RRRR-MM-DD'), 'Dostarczono', 405, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/01', 'RRRR-MM-DD'), to_date('2019/12/04', 'RRRR-MM-DD'), to_date('2019/12/03', 'RRRR-MM-DD'), 'Dostarczono', 41, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/02', 'RRRR-MM-DD'), to_date('2020/08/05', 'RRRR-MM-DD'), to_date('2020/08/08', 'RRRR-MM-DD'), 'Dostarczono', 146, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/26', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), to_date('2020/11/01', 'RRRR-MM-DD'), 'Dostarczono', 171, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/15', 'RRRR-MM-DD'), to_date('2019/01/18', 'RRRR-MM-DD'), to_date('2019/01/17', 'RRRR-MM-DD'), 'Dostarczono', 213, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/20', 'RRRR-MM-DD'), to_date('2020/11/23', 'RRRR-MM-DD'), to_date('2020/11/25', 'RRRR-MM-DD'), 'Dostarczono', 232, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/04', 'RRRR-MM-DD'), to_date('2020/03/07', 'RRRR-MM-DD'), to_date('2020/03/08', 'RRRR-MM-DD'), 'Dostarczono', 155, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/25', 'RRRR-MM-DD'), to_date('2020/05/28', 'RRRR-MM-DD'), to_date('2020/05/30', 'RRRR-MM-DD'), 'Dostarczono', 156, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/24', 'RRRR-MM-DD'), to_date('2019/09/27', 'RRRR-MM-DD'), to_date('2019/09/30', 'RRRR-MM-DD'), 'Dostarczono', 466, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), to_date('2019/01/21', 'RRRR-MM-DD'), 'Dostarczono', 256, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/08', 'RRRR-MM-DD'), to_date('2019/03/11', 'RRRR-MM-DD'), to_date('2019/03/11', 'RRRR-MM-DD'), 'Dostarczono', 147, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/11', 'RRRR-MM-DD'), to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/13', 'RRRR-MM-DD'), 'Dostarczono', 112, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/10', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), 'Dostarczono', 458, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/12', 'RRRR-MM-DD'), to_date('2019/04/15', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), 'Dostarczono', 413, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/21', 'RRRR-MM-DD'), to_date('2019/06/24', 'RRRR-MM-DD'), to_date('2019/06/27', 'RRRR-MM-DD'), 'Dostarczono', 377, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/13', 'RRRR-MM-DD'), to_date('2019/07/16', 'RRRR-MM-DD'), to_date('2019/07/17', 'RRRR-MM-DD'), 'Dostarczono', 200, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/06', 'RRRR-MM-DD'), to_date('2020/07/09', 'RRRR-MM-DD'), to_date('2020/07/09', 'RRRR-MM-DD'), 'Dostarczono', 253, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/15', 'RRRR-MM-DD'), to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), 'Dostarczono', 192, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/05', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), to_date('2020/07/08', 'RRRR-MM-DD'), 'Dostarczono', 461, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/14', 'RRRR-MM-DD'), to_date('2020/08/17', 'RRRR-MM-DD'), 'Dostarczono', 392, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/11', 'RRRR-MM-DD'), to_date('2020/02/14', 'RRRR-MM-DD'), to_date('2020/02/13', 'RRRR-MM-DD'), 'Dostarczono', 211, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), to_date('2020/04/08', 'RRRR-MM-DD'), 'Dostarczono', 183, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/18', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), 'Dostarczono', 208, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/05', 'RRRR-MM-DD'), to_date('2020/05/08', 'RRRR-MM-DD'), to_date('2020/05/10', 'RRRR-MM-DD'), 'Dostarczono', 139, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/08', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), to_date('2020/08/10', 'RRRR-MM-DD'), 'Dostarczono', 40, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/13', 'RRRR-MM-DD'), 'Dostarczono', 422, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/25', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), to_date('2019/10/30', 'RRRR-MM-DD'), 'Dostarczono', 412, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), to_date('2019/05/07', 'RRRR-MM-DD'), 'Dostarczono', 172, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), to_date('2019/06/18', 'RRRR-MM-DD'), 'Dostarczono', 224, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/28', 'RRRR-MM-DD'), to_date('2020/12/31', 'RRRR-MM-DD'), to_date('2021/01/03', 'RRRR-MM-DD'), 'Dostarczono', 105, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/06', 'RRRR-MM-DD'), to_date('2020/09/09', 'RRRR-MM-DD'), to_date('2020/09/09', 'RRRR-MM-DD'), 'Dostarczono', 230, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/02', 'RRRR-MM-DD'), to_date('2020/03/05', 'RRRR-MM-DD'), to_date('2020/03/07', 'RRRR-MM-DD'), 'Dostarczono', 47, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/09', 'RRRR-MM-DD'), to_date('2020/06/12', 'RRRR-MM-DD'), to_date('2020/06/13', 'RRRR-MM-DD'), 'Dostarczono', 459, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/17', 'RRRR-MM-DD'), to_date('2019/10/20', 'RRRR-MM-DD'), to_date('2019/10/23', 'RRRR-MM-DD'), 'Dostarczono', 214, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/13', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), to_date('2020/09/16', 'RRRR-MM-DD'), 'Dostarczono', 166, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/22', 'RRRR-MM-DD'), to_date('2019/02/25', 'RRRR-MM-DD'), to_date('2019/02/28', 'RRRR-MM-DD'), 'Dostarczono', 7, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/23', 'RRRR-MM-DD'), to_date('2020/12/26', 'RRRR-MM-DD'), to_date('2020/12/26', 'RRRR-MM-DD'), 'Dostarczono', 163, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/19', 'RRRR-MM-DD'), 'Dostarczono', 400, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/26', 'RRRR-MM-DD'), to_date('2020/05/29', 'RRRR-MM-DD'), to_date('2020/06/01', 'RRRR-MM-DD'), 'Dostarczono', 217, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/04', 'RRRR-MM-DD'), to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), 'Dostarczono', 129, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/09', 'RRRR-MM-DD'), to_date('2020/10/12', 'RRRR-MM-DD'), to_date('2020/10/13', 'RRRR-MM-DD'), 'Dostarczono', 402, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/06', 'RRRR-MM-DD'), to_date('2020/10/09', 'RRRR-MM-DD'), to_date('2020/10/12', 'RRRR-MM-DD'), 'Dostarczono', 143, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/18', 'RRRR-MM-DD'), to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/24', 'RRRR-MM-DD'), 'Dostarczono', 13, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/01', 'RRRR-MM-DD'), to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), 'Dostarczono', 351, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/16', 'RRRR-MM-DD'), to_date('2019/11/19', 'RRRR-MM-DD'), to_date('2019/11/21', 'RRRR-MM-DD'), 'Dostarczono', 66, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/25', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), to_date('2019/10/27', 'RRRR-MM-DD'), 'Dostarczono', 434, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/18', 'RRRR-MM-DD'), to_date('2020/05/21', 'RRRR-MM-DD'), to_date('2020/05/22', 'RRRR-MM-DD'), 'Dostarczono', 295, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/19', 'RRRR-MM-DD'), to_date('2019/10/22', 'RRRR-MM-DD'), to_date('2019/10/23', 'RRRR-MM-DD'), 'Dostarczono', 177, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/17', 'RRRR-MM-DD'), to_date('2020/07/20', 'RRRR-MM-DD'), to_date('2020/07/22', 'RRRR-MM-DD'), 'Dostarczono', 433, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/08', 'RRRR-MM-DD'), to_date('2020/09/11', 'RRRR-MM-DD'), to_date('2020/09/12', 'RRRR-MM-DD'), 'Dostarczono', 328, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/10', 'RRRR-MM-DD'), to_date('2020/05/13', 'RRRR-MM-DD'), to_date('2020/05/16', 'RRRR-MM-DD'), 'Dostarczono', 37, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/11', 'RRRR-MM-DD'), to_date('2020/11/14', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), 'Dostarczono', 97, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/01', 'RRRR-MM-DD'), to_date('2020/12/04', 'RRRR-MM-DD'), to_date('2020/12/04', 'RRRR-MM-DD'), 'Dostarczono', 121, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/27', 'RRRR-MM-DD'), to_date('2019/05/30', 'RRRR-MM-DD'), to_date('2019/05/29', 'RRRR-MM-DD'), 'Dostarczono', 254, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/03', 'RRRR-MM-DD'), to_date('2019/10/06', 'RRRR-MM-DD'), to_date('2019/10/05', 'RRRR-MM-DD'), 'Dostarczono', 277, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/06', 'RRRR-MM-DD'), to_date('2020/08/09', 'RRRR-MM-DD'), to_date('2020/08/11', 'RRRR-MM-DD'), 'Dostarczono', 199, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/07', 'RRRR-MM-DD'), to_date('2019/11/10', 'RRRR-MM-DD'), to_date('2019/11/12', 'RRRR-MM-DD'), 'Dostarczono', 18, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/24', 'RRRR-MM-DD'), to_date('2019/02/27', 'RRRR-MM-DD'), to_date('2019/03/01', 'RRRR-MM-DD'), 'Dostarczono', 31, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/26', 'RRRR-MM-DD'), to_date('2019/10/29', 'RRRR-MM-DD'), to_date('2019/10/31', 'RRRR-MM-DD'), 'Dostarczono', 151, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/23', 'RRRR-MM-DD'), to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), 'Dostarczono', 333, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/26', 'RRRR-MM-DD'), to_date('2019/05/29', 'RRRR-MM-DD'), to_date('2019/06/01', 'RRRR-MM-DD'), 'Dostarczono', 11, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/18', 'RRRR-MM-DD'), to_date('2020/08/21', 'RRRR-MM-DD'), to_date('2020/08/20', 'RRRR-MM-DD'), 'Dostarczono', 459, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/17', 'RRRR-MM-DD'), to_date('2020/04/20', 'RRRR-MM-DD'), to_date('2020/04/23', 'RRRR-MM-DD'), 'Dostarczono', 235, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/09', 'RRRR-MM-DD'), to_date('2020/05/12', 'RRRR-MM-DD'), to_date('2020/05/15', 'RRRR-MM-DD'), 'Dostarczono', 491, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), to_date('2019/01/22', 'RRRR-MM-DD'), 'Dostarczono', 124, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/14', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), to_date('2020/10/19', 'RRRR-MM-DD'), 'Dostarczono', 416, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/12', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), 'Dostarczono', 156, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/13', 'RRRR-MM-DD'), to_date('2020/04/16', 'RRRR-MM-DD'), to_date('2020/04/16', 'RRRR-MM-DD'), 'Dostarczono', 172, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/02', 'RRRR-MM-DD'), to_date('2019/07/05', 'RRRR-MM-DD'), to_date('2019/07/06', 'RRRR-MM-DD'), 'Dostarczono', 35, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/20', 'RRRR-MM-DD'), to_date('2020/12/23', 'RRRR-MM-DD'), to_date('2020/12/25', 'RRRR-MM-DD'), 'Dostarczono', 478, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/06', 'RRRR-MM-DD'), to_date('2020/02/09', 'RRRR-MM-DD'), to_date('2020/02/12', 'RRRR-MM-DD'), 'Dostarczono', 103, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/13', 'RRRR-MM-DD'), to_date('2019/03/16', 'RRRR-MM-DD'), to_date('2019/03/16', 'RRRR-MM-DD'), 'Dostarczono', 436, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/20', 'RRRR-MM-DD'), to_date('2019/05/23', 'RRRR-MM-DD'), to_date('2019/05/26', 'RRRR-MM-DD'), 'Dostarczono', 333, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/16', 'RRRR-MM-DD'), to_date('2020/02/19', 'RRRR-MM-DD'), to_date('2020/02/18', 'RRRR-MM-DD'), 'Dostarczono', 9, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), 'Dostarczono', 392, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/16', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), 'Dostarczono', 252, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/09', 'RRRR-MM-DD'), to_date('2019/09/12', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), 'Dostarczono', 27, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/22', 'RRRR-MM-DD'), to_date('2019/07/25', 'RRRR-MM-DD'), to_date('2019/07/28', 'RRRR-MM-DD'), 'Dostarczono', 303, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/05', 'RRRR-MM-DD'), to_date('2019/07/08', 'RRRR-MM-DD'), to_date('2019/07/11', 'RRRR-MM-DD'), 'Dostarczono', 471, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/18', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/20', 'RRRR-MM-DD'), 'Dostarczono', 140, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/02', 'RRRR-MM-DD'), to_date('2020/11/05', 'RRRR-MM-DD'), to_date('2020/11/05', 'RRRR-MM-DD'), 'Dostarczono', 269, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/20', 'RRRR-MM-DD'), to_date('2019/10/23', 'RRRR-MM-DD'), to_date('2019/10/26', 'RRRR-MM-DD'), 'Dostarczono', 246, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/09', 'RRRR-MM-DD'), to_date('2019/05/12', 'RRRR-MM-DD'), to_date('2019/05/15', 'RRRR-MM-DD'), 'Dostarczono', 392, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/18', 'RRRR-MM-DD'), to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/22', 'RRRR-MM-DD'), 'Dostarczono', 363, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/09', 'RRRR-MM-DD'), to_date('2020/11/12', 'RRRR-MM-DD'), to_date('2020/11/13', 'RRRR-MM-DD'), 'Dostarczono', 189, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/11', 'RRRR-MM-DD'), to_date('2019/05/14', 'RRRR-MM-DD'), to_date('2019/05/14', 'RRRR-MM-DD'), 'Dostarczono', 131, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/06', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), to_date('2019/06/08', 'RRRR-MM-DD'), 'Dostarczono', 24, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/26', 'RRRR-MM-DD'), to_date('2020/12/29', 'RRRR-MM-DD'), to_date('2020/12/29', 'RRRR-MM-DD'), 'Dostarczono', 448, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/08', 'RRRR-MM-DD'), to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/11', 'RRRR-MM-DD'), 'Dostarczono', 345, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/21', 'RRRR-MM-DD'), to_date('2020/09/24', 'RRRR-MM-DD'), to_date('2020/09/23', 'RRRR-MM-DD'), 'Dostarczono', 248, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/02', 'RRRR-MM-DD'), to_date('2019/05/05', 'RRRR-MM-DD'), to_date('2019/05/06', 'RRRR-MM-DD'), 'Dostarczono', 177, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/14', 'RRRR-MM-DD'), to_date('2020/02/17', 'RRRR-MM-DD'), to_date('2020/02/17', 'RRRR-MM-DD'), 'Dostarczono', 86, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/20', 'RRRR-MM-DD'), to_date('2019/12/23', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), 'Dostarczono', 328, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/12', 'RRRR-MM-DD'), to_date('2019/06/15', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), 'Dostarczono', 457, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/02', 'RRRR-MM-DD'), to_date('2019/05/05', 'RRRR-MM-DD'), to_date('2019/05/08', 'RRRR-MM-DD'), 'Dostarczono', 275, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/22', 'RRRR-MM-DD'), to_date('2020/12/25', 'RRRR-MM-DD'), to_date('2020/12/27', 'RRRR-MM-DD'), 'Dostarczono', 370, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/16', 'RRRR-MM-DD'), to_date('2019/07/19', 'RRRR-MM-DD'), to_date('2019/07/21', 'RRRR-MM-DD'), 'Dostarczono', 217, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/28', 'RRRR-MM-DD'), to_date('2020/01/31', 'RRRR-MM-DD'), to_date('2020/02/01', 'RRRR-MM-DD'), 'Dostarczono', 417, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/08', 'RRRR-MM-DD'), to_date('2020/10/11', 'RRRR-MM-DD'), to_date('2020/10/11', 'RRRR-MM-DD'), 'Dostarczono', 176, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/07', 'RRRR-MM-DD'), to_date('2019/11/10', 'RRRR-MM-DD'), to_date('2019/11/11', 'RRRR-MM-DD'), 'Dostarczono', 181, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/22', 'RRRR-MM-DD'), to_date('2019/06/25', 'RRRR-MM-DD'), to_date('2019/06/27', 'RRRR-MM-DD'), 'Dostarczono', 123, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/27', 'RRRR-MM-DD'), to_date('2019/11/30', 'RRRR-MM-DD'), to_date('2019/12/01', 'RRRR-MM-DD'), 'Dostarczono', 467, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/25', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), to_date('2019/10/29', 'RRRR-MM-DD'), 'Dostarczono', 314, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/24', 'RRRR-MM-DD'), to_date('2019/12/27', 'RRRR-MM-DD'), 'Dostarczono', 206, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/07', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), to_date('2019/01/10', 'RRRR-MM-DD'), 'Dostarczono', 156, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/01', 'RRRR-MM-DD'), to_date('2019/05/04', 'RRRR-MM-DD'), to_date('2019/05/03', 'RRRR-MM-DD'), 'Dostarczono', 308, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/02', 'RRRR-MM-DD'), to_date('2020/04/05', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), 'Dostarczono', 223, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/07', 'RRRR-MM-DD'), to_date('2020/01/10', 'RRRR-MM-DD'), to_date('2020/01/12', 'RRRR-MM-DD'), 'Dostarczono', 140, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/16', 'RRRR-MM-DD'), to_date('2020/09/19', 'RRRR-MM-DD'), to_date('2020/09/19', 'RRRR-MM-DD'), 'Dostarczono', 455, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/14', 'RRRR-MM-DD'), to_date('2020/11/17', 'RRRR-MM-DD'), to_date('2020/11/18', 'RRRR-MM-DD'), 'Dostarczono', 248, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/22', 'RRRR-MM-DD'), to_date('2019/04/25', 'RRRR-MM-DD'), to_date('2019/04/25', 'RRRR-MM-DD'), 'Dostarczono', 327, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/23', 'RRRR-MM-DD'), to_date('2020/11/26', 'RRRR-MM-DD'), to_date('2020/11/25', 'RRRR-MM-DD'), 'Dostarczono', 367, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/09', 'RRRR-MM-DD'), to_date('2019/01/12', 'RRRR-MM-DD'), to_date('2019/01/14', 'RRRR-MM-DD'), 'Dostarczono', 378, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/24', 'RRRR-MM-DD'), to_date('2020/09/27', 'RRRR-MM-DD'), to_date('2020/09/30', 'RRRR-MM-DD'), 'Dostarczono', 85, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/23', 'RRRR-MM-DD'), to_date('2020/03/26', 'RRRR-MM-DD'), to_date('2020/03/26', 'RRRR-MM-DD'), 'Dostarczono', 86, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/16', 'RRRR-MM-DD'), to_date('2020/04/19', 'RRRR-MM-DD'), to_date('2020/04/21', 'RRRR-MM-DD'), 'Dostarczono', 45, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/22', 'RRRR-MM-DD'), to_date('2019/02/25', 'RRRR-MM-DD'), to_date('2019/02/28', 'RRRR-MM-DD'), 'Dostarczono', 241, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/16', 'RRRR-MM-DD'), to_date('2019/03/19', 'RRRR-MM-DD'), to_date('2019/03/20', 'RRRR-MM-DD'), 'Dostarczono', 21, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/28', 'RRRR-MM-DD'), to_date('2020/07/31', 'RRRR-MM-DD'), to_date('2020/08/02', 'RRRR-MM-DD'), 'Dostarczono', 279, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/11', 'RRRR-MM-DD'), to_date('2020/06/14', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), 'Dostarczono', 39, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/20', 'RRRR-MM-DD'), to_date('2020/02/23', 'RRRR-MM-DD'), to_date('2020/02/25', 'RRRR-MM-DD'), 'Dostarczono', 379, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/14', 'RRRR-MM-DD'), to_date('2020/08/17', 'RRRR-MM-DD'), to_date('2020/08/19', 'RRRR-MM-DD'), 'Dostarczono', 191, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/11', 'RRRR-MM-DD'), to_date('2019/09/14', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), 'Dostarczono', 86, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/20', 'RRRR-MM-DD'), to_date('2020/03/23', 'RRRR-MM-DD'), to_date('2020/03/26', 'RRRR-MM-DD'), 'Dostarczono', 371, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/25', 'RRRR-MM-DD'), to_date('2019/08/28', 'RRRR-MM-DD'), to_date('2019/08/31', 'RRRR-MM-DD'), 'Dostarczono', 283, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/26', 'RRRR-MM-DD'), to_date('2019/04/29', 'RRRR-MM-DD'), to_date('2019/04/29', 'RRRR-MM-DD'), 'Dostarczono', 204, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/06', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), to_date('2019/06/08', 'RRRR-MM-DD'), 'Dostarczono', 53, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/08', 'RRRR-MM-DD'), to_date('2020/12/11', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), 'Dostarczono', 88, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/02', 'RRRR-MM-DD'), to_date('2020/11/05', 'RRRR-MM-DD'), to_date('2020/11/08', 'RRRR-MM-DD'), 'Dostarczono', 348, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/21', 'RRRR-MM-DD'), to_date('2020/06/24', 'RRRR-MM-DD'), to_date('2020/06/25', 'RRRR-MM-DD'), 'Dostarczono', 176, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/04', 'RRRR-MM-DD'), to_date('2019/07/07', 'RRRR-MM-DD'), to_date('2019/07/06', 'RRRR-MM-DD'), 'Dostarczono', 443, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/15', 'RRRR-MM-DD'), to_date('2020/03/18', 'RRRR-MM-DD'), to_date('2020/03/21', 'RRRR-MM-DD'), 'Dostarczono', 378, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/26', 'RRRR-MM-DD'), to_date('2020/06/29', 'RRRR-MM-DD'), to_date('2020/07/01', 'RRRR-MM-DD'), 'Dostarczono', 254, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/10', 'RRRR-MM-DD'), to_date('2019/07/13', 'RRRR-MM-DD'), to_date('2019/07/12', 'RRRR-MM-DD'), 'Dostarczono', 256, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/02', 'RRRR-MM-DD'), to_date('2019/04/05', 'RRRR-MM-DD'), to_date('2019/04/06', 'RRRR-MM-DD'), 'Dostarczono', 372, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/24', 'RRRR-MM-DD'), to_date('2019/07/27', 'RRRR-MM-DD'), to_date('2019/07/29', 'RRRR-MM-DD'), 'Dostarczono', 441, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/20', 'RRRR-MM-DD'), to_date('2020/10/23', 'RRRR-MM-DD'), to_date('2020/10/26', 'RRRR-MM-DD'), 'Dostarczono', 71, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/23', 'RRRR-MM-DD'), to_date('2019/02/26', 'RRRR-MM-DD'), to_date('2019/02/26', 'RRRR-MM-DD'), 'Dostarczono', 244, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/23', 'RRRR-MM-DD'), to_date('2019/02/26', 'RRRR-MM-DD'), to_date('2019/03/01', 'RRRR-MM-DD'), 'Dostarczono', 109, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/03', 'RRRR-MM-DD'), to_date('2019/06/06', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), 'Dostarczono', 103, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/16', 'RRRR-MM-DD'), to_date('2020/06/19', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), 'Dostarczono', 214, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/05', 'RRRR-MM-DD'), to_date('2019/10/08', 'RRRR-MM-DD'), to_date('2019/10/11', 'RRRR-MM-DD'), 'Dostarczono', 159, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/14', 'RRRR-MM-DD'), to_date('2019/02/17', 'RRRR-MM-DD'), to_date('2019/02/17', 'RRRR-MM-DD'), 'Dostarczono', 308, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/05', 'RRRR-MM-DD'), to_date('2020/02/08', 'RRRR-MM-DD'), to_date('2020/02/11', 'RRRR-MM-DD'), 'Dostarczono', 433, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/10', 'RRRR-MM-DD'), to_date('2020/03/13', 'RRRR-MM-DD'), to_date('2020/03/16', 'RRRR-MM-DD'), 'Dostarczono', 11, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/22', 'RRRR-MM-DD'), to_date('2019/08/25', 'RRRR-MM-DD'), to_date('2019/08/26', 'RRRR-MM-DD'), 'Dostarczono', 367, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/15', 'RRRR-MM-DD'), to_date('2019/11/18', 'RRRR-MM-DD'), to_date('2019/11/17', 'RRRR-MM-DD'), 'Dostarczono', 212, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/06', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), to_date('2019/06/09', 'RRRR-MM-DD'), 'Dostarczono', 140, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/01', 'RRRR-MM-DD'), to_date('2020/10/04', 'RRRR-MM-DD'), to_date('2020/10/06', 'RRRR-MM-DD'), 'Dostarczono', 45, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/23', 'RRRR-MM-DD'), to_date('2020/05/26', 'RRRR-MM-DD'), to_date('2020/05/26', 'RRRR-MM-DD'), 'Dostarczono', 195, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/14', 'RRRR-MM-DD'), to_date('2019/12/16', 'RRRR-MM-DD'), 'Dostarczono', 259, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/10', 'RRRR-MM-DD'), to_date('2019/04/13', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), 'Dostarczono', 145, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/26', 'RRRR-MM-DD'), to_date('2019/10/29', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), 'Dostarczono', 398, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/01', 'RRRR-MM-DD'), to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/04', 'RRRR-MM-DD'), 'Dostarczono', 453, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/14', 'RRRR-MM-DD'), to_date('2019/08/17', 'RRRR-MM-DD'), to_date('2019/08/17', 'RRRR-MM-DD'), 'Dostarczono', 304, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/26', 'RRRR-MM-DD'), to_date('2019/06/29', 'RRRR-MM-DD'), to_date('2019/07/02', 'RRRR-MM-DD'), 'Dostarczono', 239, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/24', 'RRRR-MM-DD'), to_date('2019/03/27', 'RRRR-MM-DD'), to_date('2019/03/30', 'RRRR-MM-DD'), 'Dostarczono', 334, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/14', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), to_date('2019/04/20', 'RRRR-MM-DD'), 'Dostarczono', 392, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/13', 'RRRR-MM-DD'), to_date('2019/06/16', 'RRRR-MM-DD'), to_date('2019/06/18', 'RRRR-MM-DD'), 'Dostarczono', 18, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/01', 'RRRR-MM-DD'), to_date('2020/10/04', 'RRRR-MM-DD'), to_date('2020/10/03', 'RRRR-MM-DD'), 'Dostarczono', 454, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/01', 'RRRR-MM-DD'), to_date('2019/01/04', 'RRRR-MM-DD'), to_date('2019/01/07', 'RRRR-MM-DD'), 'Dostarczono', 314, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/12', 'RRRR-MM-DD'), to_date('2019/02/15', 'RRRR-MM-DD'), to_date('2019/02/16', 'RRRR-MM-DD'), 'Dostarczono', 289, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/17', 'RRRR-MM-DD'), to_date('2019/07/20', 'RRRR-MM-DD'), to_date('2019/07/19', 'RRRR-MM-DD'), 'Dostarczono', 241, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/26', 'RRRR-MM-DD'), to_date('2020/07/29', 'RRRR-MM-DD'), to_date('2020/07/30', 'RRRR-MM-DD'), 'Dostarczono', 379, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/26', 'RRRR-MM-DD'), to_date('2019/07/29', 'RRRR-MM-DD'), to_date('2019/08/01', 'RRRR-MM-DD'), 'Dostarczono', 45, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/01', 'RRRR-MM-DD'), to_date('2019/09/04', 'RRRR-MM-DD'), to_date('2019/09/04', 'RRRR-MM-DD'), 'Dostarczono', 466, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/23', 'RRRR-MM-DD'), to_date('2020/03/26', 'RRRR-MM-DD'), to_date('2020/03/25', 'RRRR-MM-DD'), 'Dostarczono', 455, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/09', 'RRRR-MM-DD'), to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/11', 'RRRR-MM-DD'), 'Dostarczono', 190, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/15', 'RRRR-MM-DD'), to_date('2020/10/18', 'RRRR-MM-DD'), to_date('2020/10/21', 'RRRR-MM-DD'), 'Dostarczono', 185, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/02', 'RRRR-MM-DD'), to_date('2019/06/05', 'RRRR-MM-DD'), to_date('2019/06/07', 'RRRR-MM-DD'), 'Dostarczono', 325, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/11', 'RRRR-MM-DD'), to_date('2020/10/14', 'RRRR-MM-DD'), to_date('2020/10/17', 'RRRR-MM-DD'), 'Dostarczono', 39, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/26', 'RRRR-MM-DD'), to_date('2020/02/29', 'RRRR-MM-DD'), to_date('2020/03/02', 'RRRR-MM-DD'), 'Dostarczono', 27, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/26', 'RRRR-MM-DD'), to_date('2019/08/29', 'RRRR-MM-DD'), to_date('2019/08/31', 'RRRR-MM-DD'), 'Dostarczono', 498, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/19', 'RRRR-MM-DD'), to_date('2020/06/22', 'RRRR-MM-DD'), to_date('2020/06/22', 'RRRR-MM-DD'), 'Dostarczono', 198, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/01', 'RRRR-MM-DD'), to_date('2020/04/04', 'RRRR-MM-DD'), to_date('2020/04/07', 'RRRR-MM-DD'), 'Dostarczono', 117, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/21', 'RRRR-MM-DD'), to_date('2019/04/24', 'RRRR-MM-DD'), to_date('2019/04/23', 'RRRR-MM-DD'), 'Dostarczono', 158, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/14', 'RRRR-MM-DD'), to_date('2020/04/17', 'RRRR-MM-DD'), to_date('2020/04/19', 'RRRR-MM-DD'), 'Dostarczono', 87, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/02', 'RRRR-MM-DD'), to_date('2020/07/05', 'RRRR-MM-DD'), to_date('2020/07/06', 'RRRR-MM-DD'), 'Dostarczono', 454, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/25', 'RRRR-MM-DD'), to_date('2019/01/28', 'RRRR-MM-DD'), to_date('2019/01/31', 'RRRR-MM-DD'), 'Dostarczono', 286, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/17', 'RRRR-MM-DD'), to_date('2019/08/20', 'RRRR-MM-DD'), to_date('2019/08/20', 'RRRR-MM-DD'), 'Dostarczono', 239, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/15', 'RRRR-MM-DD'), to_date('2019/12/18', 'RRRR-MM-DD'), to_date('2019/12/21', 'RRRR-MM-DD'), 'Dostarczono', 288, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/16', 'RRRR-MM-DD'), to_date('2020/10/19', 'RRRR-MM-DD'), to_date('2020/10/21', 'RRRR-MM-DD'), 'Dostarczono', 237, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/22', 'RRRR-MM-DD'), to_date('2020/05/25', 'RRRR-MM-DD'), to_date('2020/05/27', 'RRRR-MM-DD'), 'Dostarczono', 486, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/18', 'RRRR-MM-DD'), to_date('2020/06/17', 'RRRR-MM-DD'), 'Dostarczono', 423, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/28', 'RRRR-MM-DD'), to_date('2019/11/29', 'RRRR-MM-DD'), 'Dostarczono', 333, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/23', 'RRRR-MM-DD'), to_date('2020/04/26', 'RRRR-MM-DD'), to_date('2020/04/25', 'RRRR-MM-DD'), 'Dostarczono', 451, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), 'Dostarczono', 312, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/27', 'RRRR-MM-DD'), to_date('2019/12/30', 'RRRR-MM-DD'), to_date('2019/12/31', 'RRRR-MM-DD'), 'Dostarczono', 368, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/21', 'RRRR-MM-DD'), to_date('2019/12/24', 'RRRR-MM-DD'), to_date('2019/12/25', 'RRRR-MM-DD'), 'Dostarczono', 285, 2, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/28', 'RRRR-MM-DD'), to_date('2019/10/31', 'RRRR-MM-DD'), to_date('2019/10/31', 'RRRR-MM-DD'), 'Dostarczono', 211, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/06', 'RRRR-MM-DD'), to_date('2020/10/09', 'RRRR-MM-DD'), to_date('2020/10/12', 'RRRR-MM-DD'), 'Dostarczono', 178, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/15', 'RRRR-MM-DD'), to_date('2019/10/18', 'RRRR-MM-DD'), to_date('2019/10/17', 'RRRR-MM-DD'), 'Dostarczono', 487, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/08', 'RRRR-MM-DD'), to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/13', 'RRRR-MM-DD'), 'Dostarczono', 333, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/04', 'RRRR-MM-DD'), to_date('2020/01/07', 'RRRR-MM-DD'), to_date('2020/01/08', 'RRRR-MM-DD'), 'Dostarczono', 394, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/27', 'RRRR-MM-DD'), to_date('2020/10/30', 'RRRR-MM-DD'), to_date('2020/10/29', 'RRRR-MM-DD'), 'Dostarczono', 65, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/07', 'RRRR-MM-DD'), to_date('2020/04/10', 'RRRR-MM-DD'), to_date('2020/04/10', 'RRRR-MM-DD'), 'Dostarczono', 218, 2, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/08', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), to_date('2020/05/11', 'RRRR-MM-DD'), 'Dostarczono', 72, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/14', 'RRRR-MM-DD'), to_date('2019/12/14', 'RRRR-MM-DD'), 'Dostarczono', 490, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/17', 'RRRR-MM-DD'), to_date('2019/12/20', 'RRRR-MM-DD'), to_date('2019/12/20', 'RRRR-MM-DD'), 'Dostarczono', 406, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/08', 'RRRR-MM-DD'), to_date('2020/12/11', 'RRRR-MM-DD'), to_date('2020/12/13', 'RRRR-MM-DD'), 'Dostarczono', 433, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/19', 'RRRR-MM-DD'), to_date('2020/11/22', 'RRRR-MM-DD'), to_date('2020/11/22', 'RRRR-MM-DD'), 'Dostarczono', 468, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/03', 'RRRR-MM-DD'), to_date('2020/11/06', 'RRRR-MM-DD'), to_date('2020/11/08', 'RRRR-MM-DD'), 'Dostarczono', 140, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/16', 'RRRR-MM-DD'), to_date('2019/11/19', 'RRRR-MM-DD'), to_date('2019/11/20', 'RRRR-MM-DD'), 'Dostarczono', 114, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/16', 'RRRR-MM-DD'), to_date('2019/03/19', 'RRRR-MM-DD'), to_date('2019/03/22', 'RRRR-MM-DD'), 'Dostarczono', 164, 1, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/07', 'RRRR-MM-DD'), to_date('2020/06/08', 'RRRR-MM-DD'), 'Dostarczono', 3, 2, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/08', 'RRRR-MM-DD'), to_date('2019/04/11', 'RRRR-MM-DD'), to_date('2019/04/12', 'RRRR-MM-DD'), 'Dostarczono', 152, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), 'Dostarczono', 185, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/21', 'RRRR-MM-DD'), to_date('2019/03/24', 'RRRR-MM-DD'), to_date('2019/03/25', 'RRRR-MM-DD'), 'Dostarczono', 14, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/12', 'RRRR-MM-DD'), to_date('2020/06/15', 'RRRR-MM-DD'), to_date('2020/06/14', 'RRRR-MM-DD'), 'Dostarczono', 292, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/26', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), to_date('2019/01/30', 'RRRR-MM-DD'), 'Dostarczono', 291, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/12', 'RRRR-MM-DD'), to_date('2019/10/15', 'RRRR-MM-DD'), to_date('2019/10/14', 'RRRR-MM-DD'), 'Dostarczono', 8, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/16', 'RRRR-MM-DD'), to_date('2019/10/19', 'RRRR-MM-DD'), to_date('2019/10/21', 'RRRR-MM-DD'), 'Dostarczono', 337, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/21', 'RRRR-MM-DD'), to_date('2019/06/24', 'RRRR-MM-DD'), to_date('2019/06/24', 'RRRR-MM-DD'), 'Dostarczono', 195, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/17', 'RRRR-MM-DD'), to_date('2019/02/20', 'RRRR-MM-DD'), to_date('2019/02/20', 'RRRR-MM-DD'), 'Dostarczono', 100, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/09/08', 'RRRR-MM-DD'), to_date('2020/09/11', 'RRRR-MM-DD'), to_date('2020/09/14', 'RRRR-MM-DD'), 'Dostarczono', 206, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/22', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), to_date('2019/11/24', 'RRRR-MM-DD'), 'Dostarczono', 11, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/11', 'RRRR-MM-DD'), to_date('2020/02/14', 'RRRR-MM-DD'), to_date('2020/02/17', 'RRRR-MM-DD'), 'Dostarczono', 33, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/03', 'RRRR-MM-DD'), to_date('2020/02/06', 'RRRR-MM-DD'), to_date('2020/02/09', 'RRRR-MM-DD'), 'Dostarczono', 245, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/13', 'RRRR-MM-DD'), to_date('2020/11/16', 'RRRR-MM-DD'), to_date('2020/11/15', 'RRRR-MM-DD'), 'Dostarczono', 456, 3, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/28', 'RRRR-MM-DD'), to_date('2020/03/02', 'RRRR-MM-DD'), to_date('2020/03/04', 'RRRR-MM-DD'), 'Dostarczono', 405, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/11', 'RRRR-MM-DD'), to_date('2019/02/14', 'RRRR-MM-DD'), to_date('2019/02/16', 'RRRR-MM-DD'), 'Dostarczono', 164, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/06/04', 'RRRR-MM-DD'), to_date('2020/06/07', 'RRRR-MM-DD'), to_date('2020/06/10', 'RRRR-MM-DD'), 'Dostarczono', 283, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/08', 'RRRR-MM-DD'), to_date('2019/08/11', 'RRRR-MM-DD'), to_date('2019/08/10', 'RRRR-MM-DD'), 'Dostarczono', 192, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/01', 'RRRR-MM-DD'), to_date('2019/09/04', 'RRRR-MM-DD'), to_date('2019/09/06', 'RRRR-MM-DD'), 'Dostarczono', 210, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/09', 'RRRR-MM-DD'), to_date('2019/04/12', 'RRRR-MM-DD'), to_date('2019/04/15', 'RRRR-MM-DD'), 'Dostarczono', 66, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/14', 'RRRR-MM-DD'), to_date('2019/04/17', 'RRRR-MM-DD'), to_date('2019/04/16', 'RRRR-MM-DD'), 'Dostarczono', 174, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/21', 'RRRR-MM-DD'), to_date('2020/01/24', 'RRRR-MM-DD'), to_date('2020/01/24', 'RRRR-MM-DD'), 'Dostarczono', 447, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/19', 'RRRR-MM-DD'), to_date('2020/08/22', 'RRRR-MM-DD'), to_date('2020/08/24', 'RRRR-MM-DD'), 'Dostarczono', 175, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/10', 'RRRR-MM-DD'), to_date('2019/04/13', 'RRRR-MM-DD'), to_date('2019/04/14', 'RRRR-MM-DD'), 'Dostarczono', 309, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/28', 'RRRR-MM-DD'), to_date('2020/12/01', 'RRRR-MM-DD'), to_date('2020/11/30', 'RRRR-MM-DD'), 'Dostarczono', 130, 3, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/05', 'RRRR-MM-DD'), to_date('2020/11/08', 'RRRR-MM-DD'), to_date('2020/11/09', 'RRRR-MM-DD'), 'Dostarczono', 225, 3, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/11/05', 'RRRR-MM-DD'), to_date('2020/11/08', 'RRRR-MM-DD'), to_date('2020/11/07', 'RRRR-MM-DD'), 'Dostarczono', 195, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/14', 'RRRR-MM-DD'), to_date('2020/02/17', 'RRRR-MM-DD'), to_date('2020/02/17', 'RRRR-MM-DD'), 'Dostarczono', 477, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), to_date('2020/08/25', 'RRRR-MM-DD'), 'Dostarczono', 114, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/16', 'RRRR-MM-DD'), to_date('2020/03/19', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), 'Dostarczono', 198, 2, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/17', 'RRRR-MM-DD'), to_date('2020/07/20', 'RRRR-MM-DD'), to_date('2020/07/20', 'RRRR-MM-DD'), 'Dostarczono', 29, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/27', 'RRRR-MM-DD'), to_date('2019/01/30', 'RRRR-MM-DD'), to_date('2019/01/29', 'RRRR-MM-DD'), 'Dostarczono', 80, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/02', 'RRRR-MM-DD'), to_date('2020/10/05', 'RRRR-MM-DD'), to_date('2020/10/04', 'RRRR-MM-DD'), 'Dostarczono', 331, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/12', 'RRRR-MM-DD'), to_date('2019/07/15', 'RRRR-MM-DD'), to_date('2019/07/16', 'RRRR-MM-DD'), 'Dostarczono', 310, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/18', 'RRRR-MM-DD'), to_date('2019/11/21', 'RRRR-MM-DD'), to_date('2019/11/24', 'RRRR-MM-DD'), 'Dostarczono', 321, 2, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/09/12', 'RRRR-MM-DD'), to_date('2019/09/15', 'RRRR-MM-DD'), to_date('2019/09/16', 'RRRR-MM-DD'), 'Dostarczono', 93, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/20', 'RRRR-MM-DD'), to_date('2019/08/23', 'RRRR-MM-DD'), to_date('2019/08/24', 'RRRR-MM-DD'), 'Dostarczono', 328, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/09', 'RRRR-MM-DD'), to_date('2019/01/12', 'RRRR-MM-DD'), to_date('2019/01/14', 'RRRR-MM-DD'), 'Dostarczono', 406, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/20', 'RRRR-MM-DD'), to_date('2019/11/23', 'RRRR-MM-DD'), to_date('2019/11/25', 'RRRR-MM-DD'), 'Dostarczono', 53, 3, 4);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/23', 'RRRR-MM-DD'), to_date('2019/07/26', 'RRRR-MM-DD'), to_date('2019/07/29', 'RRRR-MM-DD'), 'Dostarczono', 42, 2, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/04', 'RRRR-MM-DD'), to_date('2019/08/07', 'RRRR-MM-DD'), to_date('2019/08/09', 'RRRR-MM-DD'), 'Dostarczono', 215, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/05/05', 'RRRR-MM-DD'), to_date('2020/05/08', 'RRRR-MM-DD'), to_date('2020/05/07', 'RRRR-MM-DD'), 'Dostarczono', 157, 3, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/16', 'RRRR-MM-DD'), to_date('2019/01/19', 'RRRR-MM-DD'), to_date('2019/01/21', 'RRRR-MM-DD'), 'Dostarczono', 137, 2, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), 'Dostarczono', 331, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/11', 'RRRR-MM-DD'), to_date('2019/12/14', 'RRRR-MM-DD'), to_date('2019/12/15', 'RRRR-MM-DD'), 'Dostarczono', 402, 3, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/21', 'RRRR-MM-DD'), to_date('2020/07/24', 'RRRR-MM-DD'), to_date('2020/07/25', 'RRRR-MM-DD'), 'Dostarczono', 382, 1, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/07', 'RRRR-MM-DD'), to_date('2019/02/10', 'RRRR-MM-DD'), to_date('2019/02/11', 'RRRR-MM-DD'), 'Dostarczono', 326, 1, 8);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/05/19', 'RRRR-MM-DD'), to_date('2019/05/22', 'RRRR-MM-DD'), to_date('2019/05/22', 'RRRR-MM-DD'), 'Dostarczono', 216, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/22', 'RRRR-MM-DD'), to_date('2020/08/25', 'RRRR-MM-DD'), to_date('2020/08/27', 'RRRR-MM-DD'), 'Dostarczono', 253, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/03', 'RRRR-MM-DD'), to_date('2019/10/06', 'RRRR-MM-DD'), to_date('2019/10/09', 'RRRR-MM-DD'), 'Dostarczono', 34, 3, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/06', 'RRRR-MM-DD'), to_date('2019/12/09', 'RRRR-MM-DD'), to_date('2019/12/10', 'RRRR-MM-DD'), 'Dostarczono', 318, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/12/25', 'RRRR-MM-DD'), to_date('2019/12/28', 'RRRR-MM-DD'), to_date('2019/12/29', 'RRRR-MM-DD'), 'Dostarczono', 199, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/04/09', 'RRRR-MM-DD'), to_date('2020/04/12', 'RRRR-MM-DD'), to_date('2020/04/13', 'RRRR-MM-DD'), 'Dostarczono', 335, 2, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/04/21', 'RRRR-MM-DD'), to_date('2019/04/24', 'RRRR-MM-DD'), to_date('2019/04/27', 'RRRR-MM-DD'), 'Dostarczono', 283, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/26', 'RRRR-MM-DD'), to_date('2019/06/29', 'RRRR-MM-DD'), to_date('2019/06/30', 'RRRR-MM-DD'), 'Dostarczono', 202, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/03/15', 'RRRR-MM-DD'), to_date('2019/03/18', 'RRRR-MM-DD'), to_date('2019/03/17', 'RRRR-MM-DD'), 'Dostarczono', 19, 1, 6);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/10/24', 'RRRR-MM-DD'), to_date('2019/10/27', 'RRRR-MM-DD'), to_date('2019/10/28', 'RRRR-MM-DD'), 'Dostarczono', 318, 2, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/28', 'RRRR-MM-DD'), to_date('2019/07/31', 'RRRR-MM-DD'), to_date('2019/08/03', 'RRRR-MM-DD'), 'Dostarczono', 224, 1, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/01/05', 'RRRR-MM-DD'), to_date('2020/01/08', 'RRRR-MM-DD'), to_date('2020/01/11', 'RRRR-MM-DD'), 'Dostarczono', 495, 3, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/12/20', 'RRRR-MM-DD'), to_date('2020/12/23', 'RRRR-MM-DD'), to_date('2020/12/22', 'RRRR-MM-DD'), 'Dostarczono', 329, 3, 7);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/08/20', 'RRRR-MM-DD'), to_date('2020/08/23', 'RRRR-MM-DD'), to_date('2020/08/26', 'RRRR-MM-DD'), 'Dostarczono', 487, 3, 5);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/03/17', 'RRRR-MM-DD'), to_date('2020/03/20', 'RRRR-MM-DD'), to_date('2020/03/22', 'RRRR-MM-DD'), 'Dostarczono', 280, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/02/21', 'RRRR-MM-DD'), to_date('2020/02/24', 'RRRR-MM-DD'), to_date('2020/02/26', 'RRRR-MM-DD'), 'Dostarczono', 387, 1, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/10/19', 'RRRR-MM-DD'), to_date('2020/10/22', 'RRRR-MM-DD'), to_date('2020/10/24', 'RRRR-MM-DD'), 'Dostarczono', 280, 1, 11);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/22', 'RRRR-MM-DD'), to_date('2019/06/25', 'RRRR-MM-DD'), to_date('2019/06/27', 'RRRR-MM-DD'), 'Dostarczono', 483, 3, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/08', 'RRRR-MM-DD'), to_date('2019/06/11', 'RRRR-MM-DD'), to_date('2019/06/12', 'RRRR-MM-DD'), 'Dostarczono', 259, 1, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/07/01', 'RRRR-MM-DD'), to_date('2019/07/04', 'RRRR-MM-DD'), to_date('2019/07/04', 'RRRR-MM-DD'), 'Dostarczono', 383, 2, 9);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2020/07/16', 'RRRR-MM-DD'), to_date('2020/07/19', 'RRRR-MM-DD'), to_date('2020/07/20', 'RRRR-MM-DD'), 'Dostarczono', 68, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/07', 'RRRR-MM-DD'), to_date('2019/08/10', 'RRRR-MM-DD'), to_date('2019/08/10', 'RRRR-MM-DD'), 'Dostarczono', 261, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/08/17', 'RRRR-MM-DD'), to_date('2019/08/20', 'RRRR-MM-DD'), to_date('2019/08/22', 'RRRR-MM-DD'), 'Dostarczono', 179, 2, 1);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/01/14', 'RRRR-MM-DD'), to_date('2019/01/17', 'RRRR-MM-DD'), to_date('2019/01/20', 'RRRR-MM-DD'), 'Dostarczono', 426, 1, 10);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/06/02', 'RRRR-MM-DD'), to_date('2019/06/05', 'RRRR-MM-DD'), to_date('2019/06/05', 'RRRR-MM-DD'), 'Dostarczono', 344, 1, 3);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/02/21', 'RRRR-MM-DD'), to_date('2019/02/24', 'RRRR-MM-DD'), to_date('2019/02/25', 'RRRR-MM-DD'), 'Dostarczono', 450, 1, 2);

INSERT INTO ZAMOWIENIE (DATA_ZAMOWIENIA, PRZEWIDYWANA_DATA_DOSTAWY, DATA_DOSTAWY, STATUS, ID_KLIENTA, ID_SKLEPU, ID_PRACOWNIKA) 
VALUES (to_date('2019/11/09', 'RRRR-MM-DD'), to_date('2019/11/12', 'RRRR-MM-DD'), to_date('2019/11/13', 'RRRR-MM-DD'), 'Dostarczono', 163, 3, 4);

SET DEFINE OFF

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (1, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (2, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (3, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (4, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (5, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (6, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (7, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (8, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (9, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (10, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (11, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (12, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (13, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (14, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (15, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (16, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (17, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (18, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (19, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (20, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (21, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (22, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (23, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (24, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (25, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (26, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (27, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (28, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (29, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (30, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (31, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (32, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (33, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (34, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (35, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (36, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (37, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (38, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (39, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (40, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (41, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (42, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (43, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (44, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (45, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (46, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (47, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (48, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (49, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (50, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (51, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (52, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (53, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (54, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (55, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (56, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (57, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (58, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (59, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (60, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (61, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (62, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (63, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (64, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (65, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (66, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (67, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (68, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (69, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (70, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (71, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (72, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (73, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (74, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (75, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (76, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (77, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (78, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (79, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (80, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (81, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (82, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (83, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (84, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (85, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (86, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (87, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (88, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (89, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (90, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (91, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (92, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (93, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (94, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (95, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (96, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (97, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (98, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (99, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (100, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (101, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (102, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (103, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (104, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (105, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (106, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (107, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (108, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (109, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (110, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (111, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (112, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (113, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (114, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (115, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (116, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (117, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (118, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (119, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (120, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (121, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (122, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (123, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (124, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (125, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (126, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (127, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (128, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (129, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (130, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (131, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (132, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (133, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (134, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (135, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (136, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (137, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (138, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (139, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (140, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (141, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (142, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (143, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (144, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (145, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (146, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (147, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (148, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (149, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (150, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (151, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (152, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (153, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (154, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (155, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (156, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (157, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (158, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (159, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (160, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (161, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (162, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (163, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (164, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (165, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (166, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (167, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (168, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (169, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (170, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (171, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (172, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (173, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (174, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (175, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (176, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (177, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (178, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (179, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (180, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (181, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (182, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (183, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (184, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (185, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (186, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (187, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (188, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (189, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (190, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (191, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (192, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (193, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (194, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (195, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (196, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (197, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (198, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (199, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (200, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (201, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (202, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (203, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (204, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (205, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (206, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (207, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (208, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (209, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (210, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (211, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (212, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (213, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (214, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (215, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (216, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (217, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (218, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (219, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (220, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (221, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (222, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (223, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (224, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (225, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (226, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (227, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (228, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (229, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (230, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (231, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (232, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (233, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (234, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (235, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (236, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (237, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (238, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (239, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (240, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (241, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (242, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (243, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (244, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (245, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (246, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (247, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (248, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (249, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (250, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (251, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (252, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (253, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (254, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (255, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (256, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (257, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (258, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (259, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (260, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (261, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (262, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (263, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (264, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (265, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (266, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (267, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (268, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (269, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (270, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (271, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (272, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (273, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (274, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (275, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (277, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (278, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (279, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (280, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (281, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (282, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (283, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (284, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (285, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (286, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (287, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (288, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (289, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (290, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (291, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (292, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (293, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (294, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (295, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (296, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (297, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (298, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (299, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (300, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (301, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (302, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (303, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (304, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (305, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (306, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (307, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (308, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (309, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (310, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (311, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (312, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (313, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (314, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (315, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (316, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (317, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (318, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (319, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (320, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (321, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (322, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (323, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (324, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (325, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (326, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (327, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (328, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (329, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (330, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (331, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (332, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (333, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (334, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (335, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (336, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (337, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (338, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (339, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (340, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (341, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (342, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (343, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (344, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (345, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (346, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (347, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (348, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (349, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (350, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (351, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (352, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (353, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (354, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (355, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (356, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (357, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (358, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (359, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (360, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (361, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (362, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (363, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (364, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (365, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (366, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (367, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (368, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (369, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (370, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (371, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (372, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (373, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (374, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (375, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (376, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (377, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (378, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (379, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (380, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (381, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (382, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (383, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (384, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (385, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (386, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (387, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (388, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (389, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (390, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (391, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (392, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (393, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (394, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (395, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (396, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (397, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (398, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (399, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (400, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (401, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (402, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (403, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (404, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (405, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (406, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (407, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (408, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (409, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (410, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (411, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (412, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (413, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (414, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (415, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (416, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (417, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (418, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (419, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (420, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (421, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (422, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (423, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (424, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (425, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (426, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (427, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (428, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (429, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (430, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (431, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (432, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (433, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (434, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (435, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (436, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (437, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (438, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (439, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (440, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (441, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (442, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (443, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (444, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (445, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (446, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (447, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (448, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (449, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (450, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (451, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (452, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (453, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (454, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (455, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (456, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (457, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (458, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (459, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (460, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (461, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (462, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (463, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (464, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (465, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (466, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (467, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (468, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (469, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (470, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (471, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (472, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (473, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (474, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (475, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (476, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (477, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (478, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (479, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (480, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (481, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (482, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (483, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (484, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (485, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (486, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (487, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (488, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (489, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (490, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (491, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (492, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (493, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (494, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (495, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (496, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (497, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (498, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (499, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (500, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (37, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (109, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (425, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (167, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (163, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (376, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (262, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (326, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (445, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (291, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (9, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (247, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (453, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (144, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (288, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (265, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (464, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (408, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (30, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (492, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (108, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (59, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (95, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (19, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (77, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (323, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (330, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (119, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (87, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (121, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (332, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (207, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (147, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (182, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (155, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (73, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (499, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (311, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (105, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (96, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (452, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (107, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (406, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (102, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (103, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (186, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (265, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (454, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (231, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (52, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (201, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (191, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (151, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (89, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (384, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (190, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (306, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (2, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (271, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (53, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (406, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (140, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (327, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (342, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (4, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (81, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (349, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (110, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (360, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (87, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (217, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (64, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (352, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (24, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (146, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (68, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (214, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (132, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (317, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (268, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (382, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (447, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (315, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (238, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (245, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (288, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (9, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (308, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (283, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (197, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (429, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (345, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (59, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (50, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (253, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (35, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (11, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (109, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (360, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (54, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (141, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (284, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (196, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (438, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (292, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (174, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (468, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (210, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (395, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (141, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (274, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (290, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (261, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (451, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (368, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (104, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (44, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (431, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (145, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (244, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (294, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (8, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (370, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (463, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (185, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (99, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (330, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (152, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (488, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (176, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (196, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (30, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (485, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (328, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (283, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (498, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (176, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (475, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (372, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (456, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (465, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (16, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (367, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (31, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (488, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (10, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (116, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (469, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (15, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (360, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (320, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (331, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (398, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (68, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (480, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (446, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (340, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (44, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (304, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (190, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (496, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (284, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (86, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (6, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (379, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (183, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (13, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (353, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (292, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (415, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (448, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (13, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (424, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (171, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (222, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (191, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (474, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (79, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (121, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (411, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (312, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (174, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (211, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (274, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (101, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (388, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (185, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (367, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (407, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (134, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (254, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (290, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (44, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (98, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (221, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (102, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (368, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (98, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (231, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (487, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (216, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (154, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (314, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (246, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (277, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (34, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (86, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (34, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (457, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (125, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (369, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (473, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (291, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (440, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (6, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (327, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (312, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (162, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (133, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (383, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (305, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (326, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (434, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (6, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (27, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (113, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (368, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (12, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (398, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (62, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (143, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (232, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (355, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (19, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (449, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (437, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (66, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (259, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (153, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (447, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (493, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (427, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (108, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (370, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (458, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (159, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (211, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (390, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (270, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (127, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (401, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (146, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (116, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (323, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (106, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (371, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (304, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (452, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (163, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (141, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (336, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (290, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (14, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (92, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (58, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (49, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (441, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (103, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (425, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (210, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (435, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (132, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (432, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (340, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (439, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (86, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (276, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (428, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (12, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (418, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (191, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (205, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (488, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (313, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (3, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (148, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (375, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (298, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (77, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (165, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (79, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (495, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (450, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (265, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (141, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (363, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (406, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (139, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (337, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (453, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (296, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (424, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (430, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (260, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (367, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (132, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (353, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (4, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (267, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (332, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (62, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (159, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (328, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (247, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (272, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (136, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (385, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (59, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (489, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (485, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (3, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (418, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (24, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (320, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (111, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (54, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (28, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (17, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (56, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (294, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (159, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (114, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (43, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (487, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (373, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (200, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (222, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (340, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (499, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (99, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (380, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (139, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (24, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (237, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (499, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (464, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (405, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (310, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (297, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (60, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (194, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (495, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (45, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (27, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (495, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (487, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (371, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (95, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (247, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (85, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (193, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (249, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (219, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (3, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (13, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (454, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (486, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (46, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (231, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (390, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (216, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (222, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (464, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (264, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (407, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (489, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (158, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (140, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (243, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (352, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (92, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (378, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (457, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (465, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (451, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (466, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (378, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (181, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (154, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (43, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (341, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (422, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (467, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (74, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (317, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (438, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (142, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (164, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (160, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (76, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (395, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (269, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (470, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (116, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (155, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (325, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (112, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (101, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (331, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (296, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (378, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (494, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (210, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (264, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (200, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (232, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (49, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (88, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (477, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (111, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (148, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (253, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (137, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (165, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (346, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (314, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (159, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (430, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (202, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (217, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (190, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (497, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (59, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (247, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (488, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (89, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (44, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (259, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (363, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (158, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (215, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (30, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (326, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (333, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (219, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (175, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (101, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (315, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (316, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (186, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (260, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (38, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (397, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (54, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (468, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (40, 15);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (68, 12);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (204, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (381, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (392, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (296, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (347, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (292, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (117, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (156, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (98, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (72, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (385, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (451, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (181, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (234, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (132, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (434, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (340, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (75, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (108, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (429, 11);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (251, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (372, 16);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (352, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (476, 3);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (163, 2);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (39, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (298, 8);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (41, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (438, 10);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (285, 7);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (449, 6);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (64, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (129, 5);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (214, 9);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (384, 14);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (139, 4);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (343, 13);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (84, 1);

INSERT INTO ZAMOWIENIE_PRODUKT (id_zamowienia, id_produktu) 
VALUES (242, 11);

SET DEFINE OFF


INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 939, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 441, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 491, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 563, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 780, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 988, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 594, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 523, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 546, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 599, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 506, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 505, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 677, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 809, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 695, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 481, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 853, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 478, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 550, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 517, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 537, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 820, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 408, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 726, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 775, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 789, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 552, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 894, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 470, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 513, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 766, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 871, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 758, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 468, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 692, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 672, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 518, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 467, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 433, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 523, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 470, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 742, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 988, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 831, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 911, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 832, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 586, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 877, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 873, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 730, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 793, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 716, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 465, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 521, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 839, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 669, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 996, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 827, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 685, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 941, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 472, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 988, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 742, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 672, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 855, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 845, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 845, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 541, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 822, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 427, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 776, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 447, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 959, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 705, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 832, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 712, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 871, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 532, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 618, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 724, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 879, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 448, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 993, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 508, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 637, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 416, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 725, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 972, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 942, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 986, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 531, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 881, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 498, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 551, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 621, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 675, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 948, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 545, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 981, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 823, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 898, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 541, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 648, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 697, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 882, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 663, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 801, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 428, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 473, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 515, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 873, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 808, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 467, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 571, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 923, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 777, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 729, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 971, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 947, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 635, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 764, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 896, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 964, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 982, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 433, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 855, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 490, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 901, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 765, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 715, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 934, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 686, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 831, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 691, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 708, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 885, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 881, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 985, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 749, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 953, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 625, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 589, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 670, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 536, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 970, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 704, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 679, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 532, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 924, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 935, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 870, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 502, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 623, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 900, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 852, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 919, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 835, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 707, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 824, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 966, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 973, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 638, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 921, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 573, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 608, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 474, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 839, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 624, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 531, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 608, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 971, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 840, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 849, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 716, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 933, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 451, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 510, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 561, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 760, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 576, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 723, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 892, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 661, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 740, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 817, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 530, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 812, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 464, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 864, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 980, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 533, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 936, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 577, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 614, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 657, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 978, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 906, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 603, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 827, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 795, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 719, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 870, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 700, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 940, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 930, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 951, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 885, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 510, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 851, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 487, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 991, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 456, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 672, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 412, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 632, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 838, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 853, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 730, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 481, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 555, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 546, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 625, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 801, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 795, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 901, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 472, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 558, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 793, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 958, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 472, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 477, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 925, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 717, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 914, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 532, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 511, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 631, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 581, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 871, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 969, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 516, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 700, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 974, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 969, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 419, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 590, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 401, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 459, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 847, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 618, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 974, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 978, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 736, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 844, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 589, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 566, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 658, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 805, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 565, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 611, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 893, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 427, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 586, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 641, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 414, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 796, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 823, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 788, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 818, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 785, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 635, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 535, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 600, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 500, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 625, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 768, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 970, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 693, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 594, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 881, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 430, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 1000, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 783, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 456, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 915, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 853, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 999, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 614, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 413, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 920, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 741, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 823, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 667, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 621, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 536, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 405, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 826, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 994, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 963, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 762, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 1000, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 523, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 662, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 646, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 707, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 698, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 582, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 567, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 884, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 763, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 482, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 777, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 900, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 597, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 505, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 628, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 668, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 933, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 726, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 491, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 702, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 532, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 958, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 663, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 741, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 782, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 588, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 437, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 588, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 713, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 664, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 993, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 635, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 873, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 808, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 814, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 648, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 438, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 889, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 599, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 753, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 602, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 814, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 471, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 812, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 926, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 643, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 609, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 605, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 961, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 767, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 658, 6, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 721, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 497, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 415, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 505, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 917, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 501, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 512, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 556, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 772, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 475, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 767, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 927, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 450, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 713, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 822, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 943, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 807, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 866, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 978, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 977, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 968, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 848, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 440, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 996, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 577, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 655, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 640, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 985, 13, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 794, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 769, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 575, 5, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 629, 11, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 924, 2, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 574, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 582, 3, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 678, 4, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 714, 12, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 942, 9, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 686, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 570, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 848, 15, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 753, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 411, 7, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 952, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 991, 1, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 794, 8, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 654, 14, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 772, 10, 1);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 473, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 555, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 780, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 803, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 727, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 664, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 948, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 993, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 476, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 404, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 991, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 929, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 426, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 629, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 757, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 806, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 508, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 444, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 570, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 966, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 875, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 817, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 735, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 691, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 782, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 988, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 501, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 823, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 944, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 748, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 450, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 985, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 588, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 610, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 555, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 767, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 818, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 757, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 979, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 868, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 499, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 558, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 879, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 714, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 864, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 643, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 731, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 610, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 708, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 414, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 819, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 635, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 829, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 761, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 627, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 842, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 869, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 627, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 760, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 629, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 905, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 892, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 569, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 906, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 894, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 659, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 833, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 846, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 970, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 778, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 917, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 619, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 982, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 500, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 534, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 495, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 970, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 753, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 415, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 605, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 484, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 886, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 912, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 700, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 675, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 411, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 903, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 646, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 884, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 515, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 417, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 737, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 972, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 833, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 796, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 427, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 738, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 578, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 615, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 950, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 744, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 441, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 738, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 749, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 923, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 576, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 408, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 620, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 953, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 437, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 739, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 772, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 544, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 731, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 745, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 504, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 730, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 486, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 557, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 968, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 676, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 943, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 402, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 868, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 538, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 831, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 732, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 672, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 893, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 910, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 587, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 721, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 727, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 604, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 620, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 852, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 977, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 750, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 468, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 810, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 614, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 684, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 560, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 936, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 639, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 666, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 862, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 628, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 819, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 944, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 981, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 584, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 764, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 597, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 694, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 687, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 936, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 483, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 543, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 404, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 420, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 921, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 638, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 774, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 721, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 739, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 459, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 633, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 911, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 607, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 527, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 544, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 756, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 698, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 498, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 654, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 938, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 725, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 998, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 711, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 457, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 891, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 667, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 790, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 562, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 699, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 911, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 800, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 461, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 563, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 446, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 681, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 499, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 728, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 896, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 645, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 537, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 778, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 635, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 862, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 887, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 740, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 943, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 650, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 515, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 487, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 938, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 651, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 961, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 801, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 556, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 823, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 608, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 777, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 695, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 725, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 781, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 987, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 454, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 963, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 687, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 639, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 954, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 539, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 594, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 479, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 634, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 594, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 453, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 622, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 456, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 645, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 716, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 752, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 419, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 597, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 785, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 701, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 643, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 631, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 599, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 919, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 457, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 871, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 925, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 760, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 500, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 548, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 993, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 955, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 771, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 846, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 935, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 526, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 767, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 819, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 819, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 974, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 421, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 597, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 809, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 584, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 742, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 533, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 630, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 740, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 486, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 697, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 968, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 563, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 581, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 720, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 769, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 436, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 492, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 519, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 806, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 691, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 670, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 807, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 802, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 970, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 878, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 457, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 441, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 420, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 614, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 874, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 823, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 473, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 436, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 546, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 578, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 805, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 631, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 585, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 851, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 845, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 581, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 528, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 733, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 482, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 643, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 661, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 723, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 721, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 438, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 704, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 522, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 588, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 771, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 751, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 763, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 423, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 950, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 416, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 954, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 463, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 624, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 679, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 828, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 576, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 776, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 487, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 847, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 532, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 699, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 930, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 497, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 426, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 635, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 648, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 584, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 808, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 489, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 602, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 470, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 761, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 951, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 447, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 747, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 943, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 844, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 563, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 755, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 906, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 515, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 431, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 618, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 822, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 857, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 440, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 749, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 834, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 556, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 697, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 986, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 664, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 759, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 732, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 729, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 880, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 519, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 436, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 740, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 480, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 889, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 946, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 973, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 689, 10, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 763, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 946, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 552, 8, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 637, 5, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 924, 6, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 874, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 968, 1, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 948, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 970, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 712, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 923, 3, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 954, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 516, 14, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 815, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 508, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 872, 13, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 665, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 746, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 725, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 534, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 590, 12, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 489, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 600, 7, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 931, 9, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 716, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 924, 11, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 693, 15, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 410, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 740, 2, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 688, 4, 2);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 526, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 472, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 795, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 613, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 969, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 453, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 427, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 751, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 942, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 880, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 620, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 998, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 693, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 453, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 837, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2019', 'dd/mm/rrrr'), 474, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 785, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 647, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 658, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 775, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 871, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 663, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 792, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 850, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 551, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 648, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 577, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 989, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 747, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 974, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 678, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2019', 'dd/mm/rrrr'), 429, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 814, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 787, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 706, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 897, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 678, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 588, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 465, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 543, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 462, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 727, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 692, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 492, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 783, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 482, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 651, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2019', 'dd/mm/rrrr'), 999, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 531, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 573, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 793, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 667, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 918, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 450, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 469, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 428, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 973, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 516, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 656, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 667, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 701, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 808, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 896, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2019', 'dd/mm/rrrr'), 855, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 973, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 583, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 722, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 609, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 599, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 833, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 914, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 540, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 887, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 557, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 572, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 545, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 990, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 652, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 677, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2019', 'dd/mm/rrrr'), 980, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 592, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 858, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 991, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 407, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 858, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 529, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 633, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 811, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 567, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 913, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 929, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 700, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 662, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 626, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 567, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2019', 'dd/mm/rrrr'), 759, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 746, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 897, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 586, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 801, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 527, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 827, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 776, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 732, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 885, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 438, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 527, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 627, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 505, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 969, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 845, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2019', 'dd/mm/rrrr'), 471, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 872, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 493, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 853, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 964, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 445, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 787, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 780, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 773, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 682, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 590, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 492, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 723, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 783, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 753, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 568, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2019', 'dd/mm/rrrr'), 691, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 413, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 820, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 605, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 868, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 924, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 688, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 951, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 603, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 467, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 562, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 455, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 588, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 844, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 912, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 478, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2019', 'dd/mm/rrrr'), 442, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 439, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 578, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 740, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 469, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 731, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 773, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 594, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 427, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 982, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 954, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 940, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 612, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 552, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 582, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 476, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2019', 'dd/mm/rrrr'), 938, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 615, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 780, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 541, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 932, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 693, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 743, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 814, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 877, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 983, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 901, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 598, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 695, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 941, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 419, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 582, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2019', 'dd/mm/rrrr'), 950, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 555, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 482, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 467, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 915, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 683, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 516, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 609, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 609, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 816, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 983, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 595, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 890, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 995, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 951, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 798, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2019', 'dd/mm/rrrr'), 545, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 773, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 964, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 915, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 816, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 575, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 952, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 564, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 574, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 571, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 793, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 904, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 993, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 443, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 961, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 726, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/01/2020', 'dd/mm/rrrr'), 908, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 861, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 536, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 872, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 823, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 720, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 889, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 406, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 548, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 744, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 703, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 424, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 644, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 778, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 573, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 808, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/02/2020', 'dd/mm/rrrr'), 908, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 1000, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 701, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 515, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 989, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 988, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 760, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 844, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 746, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 452, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 926, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 873, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 953, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 850, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 514, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 756, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/03/2020', 'dd/mm/rrrr'), 900, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 525, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 554, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 440, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 842, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 964, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 861, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 928, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 439, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 825, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 539, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 690, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 541, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 861, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 656, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 945, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/04/2020', 'dd/mm/rrrr'), 784, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 785, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 916, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 530, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 923, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 615, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 646, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 536, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 813, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 844, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 789, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 786, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 829, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 887, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 716, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 773, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/05/2020', 'dd/mm/rrrr'), 666, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 755, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 823, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 458, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 737, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 521, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 635, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 448, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 410, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 632, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 779, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 839, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 626, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 467, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 424, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 865, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 454, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 709, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 558, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 495, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 988, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 896, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 402, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 659, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 644, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 779, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 817, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 917, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 598, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 874, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 843, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 410, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/06/2020', 'dd/mm/rrrr'), 525, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 957, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 682, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 688, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 526, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 834, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 755, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 618, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 578, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 976, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 630, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 734, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 830, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 407, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 594, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 429, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/07/2020', 'dd/mm/rrrr'), 505, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 531, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 751, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 598, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 690, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 751, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 434, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 980, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 554, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 810, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 634, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 461, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 578, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 706, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 733, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 951, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/08/2020', 'dd/mm/rrrr'), 595, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 641, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 954, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 545, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 875, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 906, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 426, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 774, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 523, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 808, 3, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 827, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 833, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 947, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 455, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 709, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 964, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/09/2020', 'dd/mm/rrrr'), 493, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 940, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 510, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 526, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 865, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 965, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 699, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 469, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 807, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 838, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 729, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 446, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 983, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 652, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 746, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 418, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/10/2020', 'dd/mm/rrrr'), 750, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 828, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 474, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 830, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 847, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 501, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 716, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 819, 7, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 944, 2, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 583, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 420, 10, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 822, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 677, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 887, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 858, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 905, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/11/2020', 'dd/mm/rrrr'), 800, 12, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 417, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 810, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 895, 9, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 616, 13, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 989, 11, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 941, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 984, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 694, 5, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 517, 15, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 691, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 565, 8, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 469, 4, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 734, 1, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 408, 14, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 719, 6, 3);

INSERT INTO DOSTAWA (DATA_DOSTAWY, CENA_DOSTAWY, ILOSC_PRODUKTOW, ID_SKLEPU) 
VALUES (to_date('26/12/2020', 'dd/mm/rrrr'), 907, 14, 3);

SET DEFINE OFF

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 2);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 3);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 4);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 5);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 6);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 7);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 8);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 9);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 10);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 11);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 12);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 13);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 14);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 15);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 16);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 17);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 18);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 19);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 20);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 21);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 22);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 23);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 24);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 25);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 26);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 27);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 28);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 29);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 30);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 31);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 32);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 33);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 34);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 35);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 36);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 37);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 38);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 39);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 40);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 41);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 42);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 43);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 44);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 45);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 46);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 47);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 48);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 49);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 50);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 51);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 52);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 53);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 54);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 55);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 56);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 57);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 58);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 59);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 60);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 61);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 62);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 63);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 64);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 65);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 66);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 67);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 68);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 69);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 70);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 71);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 72);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 73);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 74);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 75);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 76);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 77);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 78);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 79);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 80);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 81);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 82);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 83);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 84);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 85);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 86);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 87);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 88);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 89);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 90);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 91);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 92);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 93);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 94);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 95);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 96);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 97);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 98);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 99);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 100);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 101);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 102);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 103);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 104);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 105);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 106);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 107);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 108);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 109);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 110);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 111);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 112);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 113);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 114);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 115);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 116);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 117);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 118);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 119);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 120);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 121);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 122);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 123);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 124);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 125);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 126);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 127);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 128);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 129);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 130);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 131);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 132);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 133);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 134);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 135);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 136);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 137);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 138);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 139);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 140);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 141);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 142);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 143);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 144);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 145);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 146);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 147);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 148);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 149);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 150);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 151);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 152);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 153);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 154);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 155);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 156);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 157);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 158);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 159);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 160);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 161);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 162);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 163);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 164);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 165);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 166);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 167);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 168);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 169);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 170);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 171);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 172);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 173);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 174);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 175);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 176);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 177);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 178);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 179);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 180);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 181);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 182);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 183);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 184);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 185);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 186);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 187);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 188);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 189);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 190);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 191);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 192);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 193);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 194);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 195);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 196);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 197);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 198);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 199);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 200);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 201);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 202);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 203);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 204);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 205);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 206);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 207);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 208);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 209);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 210);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 211);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 212);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 213);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 214);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 215);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 216);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 217);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 218);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 219);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 220);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 221);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 222);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 223);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 224);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 225);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 226);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 227);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 228);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 229);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 230);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 231);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 232);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 233);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 234);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 235);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 236);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 237);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 238);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 239);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 240);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 241);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 242);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 243);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 244);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 245);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 246);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 247);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 248);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 249);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 250);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 251);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 252);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 253);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 254);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 255);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 256);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 257);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 258);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 259);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 260);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 261);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 262);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 263);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 264);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 265);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 266);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 267);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 268);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 269);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 270);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 271);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 272);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 273);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 274);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 275);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 276);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 277);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 278);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 279);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 280);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 281);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 282);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 283);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 284);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 285);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 286);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 287);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 288);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 289);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 290);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 291);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 292);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 293);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 294);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 295);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 296);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 297);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 298);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 299);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 300);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 301);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 302);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 303);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 304);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 305);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 306);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 307);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 308);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 309);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 310);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 311);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 312);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 313);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 314);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 315);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 316);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 317);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 318);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 319);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 320);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 321);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 322);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 323);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 324);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 325);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 326);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 327);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 328);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 329);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 330);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 331);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 332);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 333);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 334);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 335);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 336);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 337);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 338);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 339);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 340);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 341);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 342);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 343);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 344);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 345);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 346);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 347);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 348);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 349);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 350);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 351);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 352);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 353);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 354);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 355);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 356);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 357);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 358);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 359);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 360);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 361);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 362);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 363);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 364);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 365);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 366);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 367);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 368);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 369);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 370);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 371);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 372);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 373);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 374);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 375);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 376);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 377);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 378);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 379);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 380);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 381);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 382);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 383);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 384);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 385);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 386);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 387);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 388);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 389);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 390);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 391);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 392);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 393);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 394);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 395);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 396);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 397);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 398);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 399);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 400);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 401);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 402);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 403);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 404);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 405);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 406);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 407);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 408);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 409);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 410);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 411);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 412);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 413);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 414);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 415);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 416);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 417);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 418);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 419);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 420);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 421);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 422);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 423);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 424);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 425);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 426);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 427);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 428);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 429);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 430);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 431);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 432);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 433);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 434);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 435);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 436);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 437);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 438);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 439);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 440);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 441);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 442);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 443);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 444);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 445);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 446);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 447);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 448);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 449);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 450);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 451);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 452);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 453);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 454);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 455);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 456);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 457);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 458);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 459);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 460);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 461);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 462);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 463);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 464);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 465);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 466);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 467);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 468);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 469);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 470);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 471);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 472);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 473);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 474);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 475);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 476);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 477);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 478);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 479);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 480);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 481);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 482);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 483);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 484);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 485);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 486);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 487);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 488);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 489);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 490);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 491);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 492);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 493);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 494);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 495);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 496);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 497);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 498);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 499);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 500);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 501);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 502);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 503);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 504);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 505);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 506);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 507);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 508);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 509);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 510);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 511);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 512);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 513);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 514);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 515);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 516);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 517);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 518);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 519);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 520);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 521);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 522);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 523);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 524);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 525);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 526);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 527);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 528);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 529);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 530);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 531);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 532);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 533);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 534);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 535);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 536);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 537);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 538);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 539);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 540);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 541);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 542);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 543);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 544);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 545);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 546);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 547);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 548);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 549);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 550);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 551);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 552);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 553);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 554);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 555);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 556);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 557);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 558);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 559);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 560);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 561);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 562);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 563);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 564);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 565);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 566);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 567);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 568);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 569);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 570);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 571);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 572);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 573);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 574);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 575);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 576);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 577);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 578);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 579);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 580);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 581);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 582);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 583);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 584);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 585);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 586);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 587);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 588);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 589);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 590);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 591);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 592);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 593);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 594);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 595);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 596);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 597);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 598);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 599);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 600);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 601);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 602);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 603);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 604);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 605);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 606);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 607);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 608);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 609);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 610);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 611);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 612);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 613);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 614);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 615);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 616);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 617);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 618);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 619);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 620);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 621);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 622);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 623);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 624);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 625);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 626);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 627);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 628);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 629);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 630);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 631);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 632);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 633);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 634);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 635);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 636);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 637);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 638);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 639);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 640);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 641);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 642);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 643);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 644);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 645);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 646);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 647);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 648);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 649);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 650);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 651);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 652);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 653);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 654);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 655);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 656);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 657);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 658);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 659);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 660);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 661);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 662);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 663);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 664);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 665);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 666);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 667);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 668);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 669);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 670);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 671);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 672);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 673);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 674);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 675);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 676);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 677);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 678);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 679);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 680);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 681);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 682);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 683);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 684);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 685);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 686);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 687);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 688);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 689);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 690);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 691);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 692);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 693);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 694);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 695);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 696);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 697);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 698);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 699);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 700);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 701);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 702);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 703);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 704);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 705);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 706);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 707);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 708);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 709);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 710);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 711);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 712);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 713);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 714);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 715);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 716);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 717);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 718);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 719);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 720);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 721);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 722);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 723);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 724);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 725);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 726);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 727);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 728);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 729);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 730);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 731);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 732);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 733);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 734);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 735);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 736);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 737);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 738);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 739);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 740);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 741);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 742);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 743);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 744);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 745);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 746);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 747);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 748);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 749);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 750);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 751);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 752);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 753);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 754);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 755);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 756);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 757);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 758);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 759);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 760);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 761);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 762);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 763);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 764);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 765);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 766);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 767);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 768);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 769);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 770);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 771);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 772);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 773);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 774);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 775);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 776);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 777);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 778);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 779);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 780);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 781);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 782);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 783);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 784);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 785);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 786);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 787);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 788);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 789);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 790);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 791);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 792);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 793);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 794);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 795);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 796);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 797);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 798);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 799);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 800);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 801);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 802);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 803);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 804);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 805);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 806);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 807);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 808);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 809);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 810);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 811);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 812);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 813);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 814);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 815);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 816);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 817);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 818);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 819);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 820);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 821);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 822);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 823);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 824);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 825);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 826);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 827);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 828);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 829);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 830);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 831);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 832);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 833);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 834);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 835);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 836);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 837);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 838);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 839);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 840);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 841);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 842);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 843);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 844);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 845);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 846);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 847);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 848);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 849);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 850);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 851);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 852);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 853);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 854);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 855);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 856);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 857);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 858);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 859);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 860);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 861);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 862);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 863);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 864);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 865);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 866);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 867);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 868);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 869);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 870);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 871);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 872);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 873);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 874);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 875);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 876);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 877);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 878);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 879);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 880);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 881);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 882);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 883);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 884);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 885);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 886);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 887);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 888);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 889);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 890);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 891);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 892);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 893);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 894);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 895);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 896);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 897);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 898);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 899);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 900);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 901);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 902);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 903);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 904);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 905);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 906);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 907);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 908);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 909);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 910);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 911);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 912);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 913);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 914);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 915);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 916);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 917);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 918);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 919);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 920);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 921);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 922);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 923);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 924);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 925);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 926);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 927);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 928);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 929);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 930);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 931);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 932);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 933);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 934);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 935);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 936);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 937);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 938);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 939);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 940);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 941);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 942);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 943);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 944);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 945);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 946);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 947);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 948);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 949);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 950);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 951);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 952);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 953);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 954);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 955);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 956);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 957);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 958);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 959);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 960);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 961);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 962);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 963);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 964);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 965);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 966);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 967);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 968);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 969);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 970);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 971);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 972);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 973);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 974);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 975);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 976);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 977);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 978);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 979);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 980);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 981);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 982);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 983);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 984);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 985);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 986);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 987);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 988);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 989);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 990);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 991);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 992);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 993);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 994);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 995);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 996);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 997);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 998);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 999);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1000);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1001);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1002);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1003);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1004);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1005);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1006);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1007);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1008);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1009);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1010);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1011);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1012);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1013);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1014);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1015);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1016);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1017);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1018);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1019);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1020);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1021);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1022);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1023);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1024);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1025);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1026);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1027);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1028);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1029);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1030);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1031);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1032);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1033);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1034);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1035);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1036);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1037);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1038);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1039);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1040);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1041);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1042);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1043);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1044);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1045);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1046);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1047);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1048);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1049);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1050);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1051);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1052);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1053);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1054);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1055);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1056);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1057);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1058);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1059);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1060);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1061);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1062);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1063);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1064);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1065);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1066);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1067);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1068);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1069);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1070);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1071);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1072);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1073);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1074);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1075);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1076);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1077);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1078);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1079);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1080);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1081);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1082);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1083);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1084);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1085);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1086);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1087);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1088);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1089);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1090);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1091);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1092);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1093);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1094);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1095);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1096);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1097);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1098);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1099);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1100);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1101);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1102);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1103);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1104);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1105);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1106);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1107);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1108);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1109);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1110);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1111);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1112);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1113);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1114);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1115);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1116);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1117);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1118);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1119);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1120);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1121);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1122);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1123);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1124);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1125);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1126);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1127);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1128);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1129);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1130);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1131);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1132);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1133);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1134);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1135);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1136);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1137);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1138);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1139);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1140);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1141);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1142);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1143);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1144);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1145);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1146);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1147);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1148);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1149);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1150);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1151);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1152);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1153);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1154);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1155);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1156);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1157);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1158);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1159);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1160);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1161);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1162);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1163);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1164);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1165);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1166);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1167);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1168);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1169);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1170);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1171);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1172);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1173);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1174);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1175);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1176);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1177);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1178);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1179);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1180);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1181);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1182);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1183);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1184);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (1, 1185);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (2, 1186);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (3, 1187);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (4, 1188);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (5, 1189);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (6, 1190);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (7, 1191);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (8, 1192);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (9, 1193);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (10, 1194);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (11, 1195);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (12, 1196);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (13, 1197);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (14, 1198);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (15, 1199);

INSERT INTO PRODUKT_DOSTAWA (id_produktu, id_dostawy) 
VALUES (16, 1200);

CREATE OR REPLACE TRIGGER TR_ZAPAS_NEW_PRODUKT
AFTER INSERT ON PRODUKT
FOR EACH ROW
DECLARE
var_ile_sklepow number;
BEGIN
    select count(*) into var_ile_sklepow from sklep;
    for lcntr in 1..var_ile_sklepow
    loop
    insert into zapas
    (ilosc,id_sklepu,id_produktu)
    values(0,lcntr,:NEW.id_produktu);
    end loop;
END;
/

update dostawa
set cena_dostawy = cena_dostawy/100
where id_dostawy>=1;
CREATE OR REPLACE TRIGGER TR_CHECK_ILOSC
BEFORE INSERT ON ZAMOWIENIE_PRODUKT
FOR EACH ROW
DECLARE
var_ilosc number;
BEGIN
    select ilosc into var_ilosc
    from zapas,zamowienie 
    where zapas.id_produktu = :NEW.id_produktu and zamowienie.id_sklepu = zapas.id_sklepu
    and zamowienie.id_zamowienia = :NEW.id_zamowienia;
    if var_ilosc <= 0 or var_ilosc is null then
        raise_application_error(-20001,'Brak produktu w magazynie');
    end if;
END;
/
create or replace procedure pr_rejestracja
(
    v_imie varchar,
    v_nazwisko varchar,
    v_miejscowosc varchar,
    v_adres varchar,
    v_kod_pocztowy varchar,
    v_telefon varchar,
    v_email varchar
) as
begin
insert into klient
(imie,nazwisko,miejscowosc,adres,kod_pocztowy,telefon,email)
values
(
    v_imie,
    v_nazwisko,
    v_miejscowosc,
    v_adres,
    v_kod_pocztowy,
    v_telefon,
    v_email
);
    dbms_output.put_line('Zarejestrowano uzytkownika: '||v_imie||' '||v_nazwisko);
end;
/

create or replace procedure pr_update_zapas
(v_ilosc number,v_id_sklepu number,v_id_produktu number) as
begin
    if v_ilosc < 0 then raise_application_error(-20002,'Ilosc nie moze byc ujemna');
    else
    update zapas
        set ilosc = v_ilosc
        where id_produktu = v_id_produktu
        and   id_sklepu = v_id_sklepu;
    end if;
    dbms_output.put_line('Zaktualizowano ilosc produktu(ID: '||v_id_produktu||') w sklepie(ID: '||v_id_sklepu||') na '||v_ilosc);
end;
/

create or replace procedure pr_delete_kategoria
(v_id_kategorii number) as v_nazwa_kategorii varchar(100);
begin
    select nazwa_kategorii into v_nazwa_kategorii from kategoria where id_kategorii = v_id_kategorii;
    dbms_output.put_line('Usunieto kategorie: '||v_nazwa_kategorii);
    delete from kategoria where id_kategorii = v_id_kategorii;
end;
/

create or replace function fn_licz_staz(v_id_pracownika number)
return number
as
start_pracy date;
koniec_pracy date;
return_val number;
begin
        select pracowal_do into koniec_pracy from pracownik where id_pracownika = v_id_pracownika;
        select pracowal_od into start_pracy from pracownik where id_pracownika = v_id_pracownika;
        if(koniec_pracy is null) then
            koniec_pracy := sysdate;
        end if;  
            return_val := koniec_pracy - start_pracy; 
return round(return_val,0);
end;
/

create or replace function fn_czy_pracuje(koniec_pracy date)
return number
as
return_val number;
begin
        if(koniec_pracy is null) then
            return_val := 1;
        elsif(koniec_pracy <= sysdate) then
            return_val := 0;
        else
            return_val := 1;
        end if;
return return_val;
end;
/

CREATE OR REPLACE TRIGGER TR_UPDATE_PRACOWNIK
BEFORE UPDATE ON pracownik
FOR EACH ROW
DECLARE
v_status varchar(20);
BEGIN
        if(fn_czy_pracuje(:NEW.pracowal_do)=1) then
            v_status :='Pracujacy';
                if(:OLD.status = 'Nie pracujacy') then dbms_output.put_line('Zmieniono status pracownika na pracujacy');
                else dbms_output.put_line('Status pracownika nie ulegl zmianie');
                end if;
        else
            v_status :='Nie pracujacy';
                if(:OLD.status = 'Pracujacy') then dbms_output.put_line('Zmieniono status pracownika na nie pracujacy');
                else dbms_output.put_line('Status pracownika nie ulegl zmianie');
                end if;
        end if;
        :NEW.status := v_status;
END;
/
create or replace trigger tr_update_zamowienie
before update on zamowienie
for each row
begin
    if(:NEW.data_dostawy is not null) then
        :NEW.status := 'Dostarczono';
    else
        :NEW.status := 'Nie dostarczono';
    end if;
end;
/