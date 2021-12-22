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
commit;

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
);
commit;
create table Rodzaje_pokojow(
    nazwa varchar(32) primary key,
    cena number(10) not null
);

create table Pokoje(
    nr_pokoju number(10) primary key,
    limit_osob number(2) not null,
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    