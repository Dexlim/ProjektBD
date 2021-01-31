select * from dane_kontaktowe;
select * from dostawa;
select * from kategoria;
select * from klient order by id_klienta desc;
select * from pracownik;
select * from producent;
select * from produkt;
select * from produkt_dostawa;
select * from sklep;
select * from zamowienie order by id_zamowienia desc;
select * from zamowienie_produkt;
select * from zapas;

select * from bilans;
select * from ilosc_dostarczona;
select * from ilosc_produktow;
select * from ilosc_sprzedanych_sztuk;
select * from ilosc_wyprzedana;
select * from place_dla_pracownikow;
select * from porownanie_klientow;
select * from porownanie_regionow;
select * from porownanie_sprzedazy_w_sklepach;

select imie,nazwisko,status,wynagrodzenie||'zl',nazwa_sklepu from pracownik p,sklep s
where s.id_sklepu = p.id_sklepu
order by nazwa_sklepu;

select nazwa_kategorii,nazwa_producenta,nazwa_produktu,cena||('zl') as "Cena"
from produkt p,producent pr, kategoria k
where p.id_producenta = pr.id_producenta
and p.id_kategorii = k.id_kategorii;

select data_zamowienia,data_dostawy,k.imie||' '||k.nazwisko as "Klient",nazwa_sklepu,nazwa_produktu,pr.imie||' '||pr.nazwisko as "Sprzedawca",p.id_produktu,z.id_zamowienia,cena||'zl' as "Cena"
from zamowienie z,zamowienie_produkt zp, produkt p, klient k, sklep s,pracownik pr
where z.id_klienta = k.id_klienta
and z.id_pracownika = pr.id_pracownika
and z.id_sklepu = s.id_sklepu
and z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
order by data_zamowienia;

select extract(year from data_zamowienia) as "Rok",nazwa_kategorii,nazwa_producenta,nazwa_produktu,sum(cena)||'zl' as "Przychod ze sprzedazy"
from zamowienie z, kategoria k, producent pr, produkt p, zamowienie_produkt zp
where z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
and p.id_kategorii = k.id_kategorii
and p.id_producenta = pr.id_producenta
group by extract(year from data_zamowienia),nazwa_kategorii,nazwa_producenta,nazwa_produktu
order by "Rok" desc,sum(cena) desc;

select nazwa_sklepu,nazwa_produktu,ilosc
from sklep s,produkt p,zapas z
where s.id_sklepu = z.id_sklepu
and p.id_produktu = z.id_produktu;

select data_dostawy,cena_dostawy,ilosc_produktow,id_sklepu,nazwa_produktu from produkt_dostawa pd,dostawa d,produkt p
where p.id_produktu = pd.id_produktu
and d.id_dostawy = pd.id_dostawy
order by data_dostawy desc;


select * from Bilans;

select * from ilosc_sprzedanych_sztuk;

select * from porownanie_sprzedazy_w_sklepach;

select * from porownanie_klientow;

select * from porownanie_regionow;

select * from produkt;

begin
pr_rejestracja('Zbigniew','Waliwoda','Siemiatycze','ul. Husarzy 23','15-021',null,'zbysio_waliw@gmail.com');
end;
/

select * from zapas;
begin
pr_update_zapas(145,1,3);
end;
/
select * from produkt;
begin
pr_delete_kategoria(2);
end;
/

select imie,nazwisko,status,fn_licz_staz(id_pracownika) as "Przepracowane dni" from pracownik;

select * from pracownik;

update pracownik
set pracowal_do = '19/05/04' where id_pracownika = 11;

select id_pracownika,fn_czy_pracuje(id_pracownika) from pracownik;

-- Demonstracja limitowania wierszy
select * from bilans
where rownum between 1 and 12;

--Demonstracja funkcji agregujacych
select round(avg("Ilosc"),0) as "Srednia ilosc produktow" from ilosc_produktow;

--Demonstracja zdan podrzednych we frazie from
select data_zamowienia,imie,nazwisko,nazwa_produktu
from klient k,(select data_zamowienia,nazwa_produktu,id_klienta from produkt p,zamowienie_produkt zp,zamowienie z where p.id_produktu = zp.id_produktu and zp.id_zamowienia = z.id_zamowienia) sel
where k.id_klienta = sel.id_klienta;

--Demonstracja zdan podrzednych we frazie where , pokazuje producenta ktory sprzedal najwiecej produktow
select nazwa_producenta from producent
where id_producenta = (
                        select * from(select pr.id_producenta
                        from producent pr, produkt p, zamowienie_produkt zp,zamowienie z
                        where pr.id_producenta = p.id_producenta
                        and zp.id_produktu = p.id_produktu
                        and z.id_zamowienia = zp.id_zamowienia
                        group by pr.id_producenta
                        order by count(zp.id_produktu) desc) where rownum =1
                      );
--Demonstracja zdan podrzednych we frazie having, pokazuje klientow ktorzy maja ilosc zamowien wieksza od sredniej
select imie,nazwisko,count(*) as "Ilosc zamowien"
from klient k, zamowienie z, zamowienie_produkt zp,produkt p
where k.id_klienta = z.id_klienta
and z.id_zamowienia = zp.id_zamowienia
and zp.id_produktu = p.id_produktu
group by imie,nazwisko
having count(*) > (
                        select round(avg(count(*)),0) from klient kl,zamowienie z
                        where kl.id_klienta = z.id_klienta
                        group by imie,nazwisko 
                    )
order by "Ilosc zamowien" desc;

         
commit;