create sequence id_rez
    minvalue 10
    start with 10
    increment by 10;

create table Klienci(
    pesel number(11) primary key,
    imie varchar(32) not null,
    nazwisko varchar(32) not null,
    nr_telefonu number(9) not null,
    email varchar(64)
);

create table Rodzaje_pokojow(
    nazwa varchar(32) primary key,
    cena number(10) not null
);

create table Pokoje(
    nr_pokoju number(10) primary key,
    liczba_osob number(2) not null,
    pojedyncze_lozka number(2) not null,
    podwojne_lozka number(2) not null,
    rodzaj not null references Rodzaje_pokojow(nazwa),
    cena number(10,2) not null
);

create table Sale (
    nr_sali number(10) not null, 
    liczba_osob number(4) not null,
    cena number(10,2) not null,
    constraint sale_pk primary key (nr_sali)
);

create table typy_rezerwacji(
    nazwa varchar(64) not null,
    cena number(10,2) not null,
    rodzaj_typu varchar(1) not null,
    constraint pk_typy_rezerwacji primary key(nazwa),
    constraint ch_typ check (rodzaj_typu in ('S', 'P'))
);

create table Rezerwacje(
    id_rezerwacji number(10) 
        default id_rez.nextval primary key,
    oplata number(10,2) not null,
    czy_oplacone varchar(3) not null check 
        (czy_oplacone in ('TAK', 'NIE')),
    data_dokonania_rezerwacji date default 
        current_date not null,
    rodzaj_rezerwacji varchar(1) not null check
        (rodzaj_rezerwacji in ('S','P')),
    od date,
    do date,
    data_wypozyczenia date,
    rezerwujacy not null references Klienci(pesel),
    nr_pokoju null references Pokoje(nr_pokoju),
    nr_sali null references Sale(nr_sali),
    typ_rezerwacji not null references typy_rezerwacji(nazwa)
);

create table Zespoly(
    nazwa varchar(32) primary key
);

create table Stanowiska_pracy(
    nazwa varchar(32) primary key,
    placa_min number(10,2) not null,
    placa_max number(10,2) not null,
    zespol not null references Zespoly(nazwa)
);     

create table Pracownicy(
    pesel number(11) primary key,
    imie varchar(32) not null,
    nazwisko varchar(32) not null,
    nr_telefonu number(9) not null,
    email varchar(64) not null,
    data_zatrudnienia date not null,
    placa number(10,2) not null,
    stanowisko not null references Stanowiska_pracy(nazwa)
);

create table Obslugi_pokojow(
    nr_pokoju references Pokoje(nr_pokoju),
    pracownik references Pracownicy(pesel),
    dzien_tygodnia varchar(12),
    godzina_od number(2) not null, 
    godzina_do number(2) not null,
    primary key(nr_pokoju, pracownik, dzien_tygodnia)
);

create or replace view rezerwacje_sali  as
    select id_rezerwacji, nazwisko as Nazwisko, imie as Imię, rezerwujacy as PESEL, data_dokonania_rezerwacji, 
    data_wypozyczenia as "Data Wypożyczenia", nr_sali, oplata as Opłata, czy_oplacone as "Czy Opłacone", typ_rezerwacji
    from klienci join rezerwacje on (pesel = rezerwujacy) 
    where rodzaj_rezerwacji = 'S'
    order by data_dokonania_rezerwacji desc, nazwisko asc;


create or replace view rezerwacje_pokoi as 
    select id_rezerwacji, nazwisko as Nazwisko, imie as Imię, rezerwujacy as PESEL, data_dokonania_rezerwacji, nr_pokoju, typ_rezerwacji,
    od, do, oplata as Opłata, czy_oplacone as "Czy Opłacone" 
    from klienci join rezerwacje on (pesel = rezerwujacy) 
    where rodzaj_rezerwacji = 'P'
    order by data_dokonania_rezerwacji desc, nazwisko asc;
/
create or replace function oblicz_cene_pokoju
    (vLiczba_osob number, vRodzaj varchar)
    return number is
    vCena_rodzaju number(10,2);
    vCena_pokoju number(10,2);
begin
    select cena into vCena_rodzaju from rodzaje_pokojow where nazwa = vRodzaj;
    vCena_pokoju := vCena_rodzaju * vLiczba_osob;
    return vCena_pokoju;
end;
/
create or replace function oblicz_cene_rezerwacji(
    vNr number, vOd date, vDo date, vTyp varchar)
    return number is
    vCena_dodatkowa number(10,2);
    vCena_pokoju number(10,2);
    vCena number(10,2);
    vLiczba_gosci number(4);
begin
    select liczba_osob into vLiczba_gosci from pokoje where nr_pokoju = vNr;
    select cena into vCena_dodatkowa from typy_rezerwacji where nazwa = vTyp;
    select cena into vCena_pokoju from pokoje where nr_pokoju = vNr;
    vCena := (vCena_pokoju + vCena_dodatkowa * vLiczba_gosci) * (vDo - vOd);
    return vCena;
end;
/
create or replace procedure wstaw_pokoj(
    vNr number, vLiczba number, vPoj_lozka number,
    vPod_lozka number, vRodzaj varchar, vCena number) is
begin
    if vCena is null then
        insert into pokoje values (vNr, vLiczba, vPoj_lozka,
        vPod_lozka, vRodzaj, oblicz_cene_pokoju(vLiczba, vRodzaj));
    else
        insert into pokoje values (vNr, vLiczba, vPoj_lozka,
        vPod_lozka, vRodzaj, vCena);
    end if;
end;
/
create or replace procedure wstaw_rezerwacje_pokoju
    (vRezerwujacy number, vOd date, vDo date, 
    vPokoj number, vCzy_oplacone varchar, vCena number, vTyp varchar) is
begin
    if vCena is null then
        insert into rezerwacje(oplata, czy_oplacone,
            rodzaj_rezerwacji, od, do, rezerwujacy, nr_pokoju, typ_rezerwacji) 
            values(oblicz_cene_rezerwacji(vPokoj, vOd, vDo, vTyp), 
            vCzy_oplacone, 'P', vOd, vDo, vRezerwujacy, vPokoj, vTyp);
    else
        insert into rezerwacje(oplata, czy_oplacone,
            rodzaj_rezerwacji, od, do, rezerwujacy, nr_pokoju, typ_rezerwacji) 
            values(vCena, 
            vCzy_oplacone, 'P', vOd, vDo, vRezerwujacy, vPokoj, vTyp); 
    end if;
end;
/
create or replace procedure wstaw_rezerwacje_sali
    (vRezerwujacy number, vData_wypozyczenia date,
    vOplata number, vCzy_oplacone varchar, vSala number, vTyp varchar) is
    vCena number(10,2);
    vCena_dodatkowa number(10,2);
begin
    if vOplata is null then 
        select cena into vCena from sale where nr_sali = vSala;
        select cena into vCena_dodatkowa from typy_rezerwacji where nazwa = vTyp;
        vCena := vCena + vCena_dodatkowa;
        insert into rezerwacje(oplata, czy_oplacone,
            rodzaj_rezerwacji, data_wypozyczenia, rezerwujacy, nr_sali, typ_rezerwacji) 
            values(vCena, vCzy_oplacone, 'S', vData_wypozyczenia, vRezerwujacy, vSala, vTyp); 
    else 
        insert into rezerwacje(oplata, czy_oplacone,
            rodzaj_rezerwacji, data_wypozyczenia, rezerwujacy, nr_sali, typ_rezerwacji) 
            values(vOplata, vCzy_oplacone, 'S', vData_wypozyczenia, vRezerwujacy, vSala, vTyp); 
    end if;
end;