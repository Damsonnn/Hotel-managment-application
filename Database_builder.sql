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

create table Rezerwacje(
    id_rezerwacji number(10) 
        default id_rez.nextval primary key,
    oplata number(10,2) not null,
    czy_oplacone varchar(3) not null check 
        (czy_oplacone in ('TAK', 'NIE')),
    data_dokonania_rezerwacji date default 
        current_date not null,
    zadatek number(10,2) not null,
    rodzaj_rezerwacji varchar(1) not null check
        (rodzaj_rezerwacji in ('S','P')),
    od date,
    do date,
    liczba_gosci number(3),
    liczba_pokoi number(3),
    data_wypozyczenia date,
    rezerwujacy not null references Klienci(pesel)
);

create table Uslugi(
    nazwa varchar(64) primary key,
    cena number(10,2) not null,
    rodzaj_uslugi varchar(1) not null check
        (rodzaj_uslugi in ('S','P'))
);
create table Uslugi_Rezerwacje(
    id_rezerwacji references Rezerwacje(id_rezerwacji),
    usluga references Uslugi(nazwa),
    primary key(id_rezerwacji, usluga)
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

create table Rezerwacje(
    id_rezerwacji number(10) 
        default id_rez.nextval primary key,
    oplata number(10,2) not null,
    czy_oplacone varchar(3) not null check 
        (czy_oplacone in ('TAK', 'NIE')),
    data_dokonania_rezerwacji date default 
        current_date not null,
    zadatek number(10,2) not null,
    rodzaj_rezerwacji varchar(1) not null check
        (rodzaj_rezerwacji in ('S','P')),
    od date,
    do date,
    liczba_pokoi number(3),
    liczba_gosci number(3),
    data_wypozyczenia date,
    rezerwujacy not null references Klienci(pesel)
);

create table Uslugi(
    nazwa varchar(64) primary key,
    cena number(10,2) not null,
    rodzaj_uslugi varchar(1) not null check
        (rodzaj_uslugi in ('S','P'))
);
create table Uslugi_Rezerwacje(
    id_rezerwacji references Rezerwacje(id_rezerwacji),
    usluga references Uslugi(nazwa),
    primary key(id_rezerwacji, usluga)
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
    rodzaj not null references Rodzaje_pokojow(nazwa)
);

create table Pokoje_Rezerwacje(
    id_rezerwacji references Rezerwacje(id_rezerwacji),
    nr_pokoju references Pokoje(nr_pokoju),
    primary key(id_rezerwacji, nr_pokoju)
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

create or replace function obliczCenePokoju
    (od in date,
    do in date,
    vNrPokoju in number)
    return number
is
    vCena number;
    vNoce number;
    vCenaPokoju number;
    vLiczbaOsob number;
begin
    select cena into vCenaPokoju
        from rodzaje_pokojow join pokoje on(nazwa = rodzaj)
        where nr_pokoju = vNrPokoju;
    select liczba_osob into vLiczbaOsob
        from pokoje where nr_pokoju = vNrPokoju;
    vNoce := do - od;
    vCena := vNoce * vCenaPokoju * vLiczbaOsob;
    return vCena;
end;
/

create or replace function ustalPlace
    (vStanowisko in varchar,
    vPlaca in number)
    return number
is
    vMin number;
    vMax number;
begin
    select placa_min, placa_max into vMin, vMax  
        from stanowiska_pracy where nazwa = vStanowisko;
    if vPlaca < vMin then
        return vMin;
    elsif vPlaca > vMax then
        return vMax;
    else 
        return vPlaca;
    end if;
end;
/
create or replace procedure dodajUslugeDoRezerwacji
    (vUsluga in varchar,
    vId in number) 
is
    vCena number;
begin
    insert into uslugi_rezerwacje values(vId, vUsluga);
    select cena into vCena from uslugi where nazwa = vUsluga; 
    update rezerwacje set oplata = vCena + oplata;
end;
/ 
    
    
    
    
    
    
    
    
    
    
    
    
    
    