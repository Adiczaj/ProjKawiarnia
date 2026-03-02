-- 1. Tabela Firmy (Dla klientów B2B) - Tworzymy jako pierwszą, bo nikogo nie potrzebuje
CREATE TABLE Firmy (
    id SERIAL PRIMARY KEY,
    nazwa_firmy VARCHAR(150) NOT NULL,
    nip VARCHAR(15) UNIQUE,
    adres_biura VARCHAR(255)
);

-- 2. Tabela Produkty (Menu kawiarni) - Niezależny słownik
CREATE TABLE Produkty (
    id SERIAL PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL,
    cena DECIMAL(10, 2) NOT NULL
);

-- 3. Tabela Uzytkownicy (Wszyscy w systemie) - Teraz może podpiąć się pod Firmę
CREATE TABLE Uzytkownicy (
    id SERIAL PRIMARY KEY,
    id_firmy INT NULL, -- Puste (NULL) dla zwykłych klientów, wypełnione dla B2B
    imie VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rola VARCHAR(50) NOT NULL, -- np. 'KLIENT', 'KOORDYNATOR', 'BARISTA'
    FOREIGN KEY (id_firmy) REFERENCES Firmy(id)
);

-- 4. Tabela Koszyki_Grupowe (Nasz "brudnopis" dla B2B)
CREATE TABLE Koszyki_Grupowe (
    id SERIAL PRIMARY KEY,
    id_koordynatora INT NOT NULL,
    kod_zaproszenia VARCHAR(50) UNIQUE NOT NULL,
    status_koszyka VARCHAR(50) DEFAULT 'OTWARTY',
    czas_zamkniecia TIMESTAMP NOT NULL,
    FOREIGN KEY (id_koordynatora) REFERENCES Uzytkownicy(id)
);

-- 5. Tabela Zamowienia (Oficjalny paragon - B2B i B2C)
CREATE TABLE Zamowienia (
    id SERIAL PRIMARY KEY,
    id_klienta INT NOT NULL, -- Kto płaci
    status VARCHAR(50) DEFAULT 'NOWE',
    data_planowanej_dostawy TIMESTAMP NOT NULL,
    id_koszyka_grupowego INT NULL, -- NULL dla zwykłych klientów
    adres_dostawy VARCHAR(255) NOT NULL, -- Gdzie wiezie kurier
    FOREIGN KEY (id_klienta) REFERENCES Uzytkownicy(id),
    FOREIGN KEY (id_koszyka_grupowego) REFERENCES Koszyki_Grupowe(id)
);

-- 6. Tabela Pozycje_Koszyka_Grupowego (Karteczki z kawami na tacy w B2B)
CREATE TABLE Pozycje_Koszyka_Grupowego (
    id SERIAL PRIMARY KEY,
    id_koszyka INT NOT NULL,
    id_pracownika INT NOT NULL,
    id_produktu INT NOT NULL,
    personalizacja VARCHAR(255), -- np. 'Owsiane, bez cukru'
    FOREIGN KEY (id_koszyka) REFERENCES Koszyki_Grupowe(id),
    FOREIGN KEY (id_pracownika) REFERENCES Uzytkownicy(id),
    FOREIGN KEY (id_produktu) REFERENCES Produkty(id)
);

-- 7. Tabela Pozycje_Zamowienia (Linijki na oficjalnym paragonie)
CREATE TABLE Pozycje_Zamowienia (
    id SERIAL PRIMARY KEY,
    id_zamowienia INT NOT NULL,
    id_produktu INT NOT NULL,
    ilosc INT DEFAULT 1,
    cena_zakupu DECIMAL(10, 2) NOT NULL, -- Zamrożona cena z dnia zakupu
    notatki VARCHAR(255), -- np. 'Dla: Marek, Owsiane'
    FOREIGN KEY (id_zamowienia) REFERENCES Zamowienia(id),
    FOREIGN KEY (id_produktu) REFERENCES Produkty(id)
);