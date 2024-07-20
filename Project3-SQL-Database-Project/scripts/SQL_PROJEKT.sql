-- Sprawdzenie, czy baza danych istnieje i jej usuniêcie, jeœli istnieje
IF DB_ID('FirmaNieruchomosci') IS NOT NULL
BEGIN
    DROP DATABASE FirmaNieruchomosci;
END
GO

-- Utworzenie bazy danych
CREATE DATABASE FirmaNieruchomosci;
GO

USE FirmaNieruchomosci;
GO

-- Tabela Miasta
CREATE TABLE Miasta (
    ID_Miasta INT PRIMARY KEY IDENTITY(1,1),
    NazwaMiasta NVARCHAR(100) NOT NULL,
    Kraj NVARCHAR(50) NOT NULL,
    LiczbaMieszkancow INT CHECK (LiczbaMieszkancow > 0)
);
CREATE INDEX idx_NazwaMiasta ON Miasta(NazwaMiasta);
GO

-- Tabela TypyNieruchomosci
CREATE TABLE TypyNieruchomosci (
    ID_Typu INT PRIMARY KEY IDENTITY(1,1),
    NazwaTypu NVARCHAR(50) NOT NULL,
    Opis NVARCHAR(255),
    Aktywny BIT DEFAULT 1
);
GO

-- Tabela StatusyTransakcji
CREATE TABLE StatusyTransakcji (
    ID_Statusu INT PRIMARY KEY IDENTITY(1,1),
    NazwaStatusu NVARCHAR(50) NOT NULL,
    Opis NVARCHAR(255),
    DataDodania DATE DEFAULT GETDATE()
);
GO

-- Tabela Nieruchomosci
CREATE TABLE Nieruchomosci (
    ID_Nieruchomosci INT PRIMARY KEY IDENTITY(1,1),
    Adres NVARCHAR(255) NOT NULL,
    MiastoID INT NOT NULL,
    Cena DECIMAL(18,2) CHECK (Cena > 0),
    TypID INT NOT NULL,
    Powierzchnia INT CHECK (Powierzchnia > 0),
    DataDodania DATE,
    StatusID INT NOT NULL,
    FOREIGN KEY (MiastoID) REFERENCES Miasta(ID_Miasta),
    FOREIGN KEY (TypID) REFERENCES TypyNieruchomosci(ID_Typu),
    FOREIGN KEY (StatusID) REFERENCES StatusyTransakcji(ID_Statusu)
);
CREATE INDEX idx_ID_Nieruchomosci ON Nieruchomosci(ID_Nieruchomosci);
CREATE INDEX idx_Nieruchomosci_MiastoID ON Nieruchomosci(MiastoID);
CREATE INDEX idx_Nieruchomosci_TypID ON Nieruchomosci(TypID);
CREATE INDEX idx_Nieruchomosci_StatusID ON Nieruchomosci(StatusID);
GO

-- Tabela Klienci
CREATE TABLE Klienci (
    ID_Klienta INT PRIMARY KEY IDENTITY(1,1),
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) CHECK (Email LIKE '%@%'),
    Telefon NVARCHAR(20),
    MiastoID INT NOT NULL,
    FOREIGN KEY (MiastoID) REFERENCES Miasta(ID_Miasta)
);
CREATE INDEX idx_Klienci_MiastoID ON Klienci(MiastoID);
GO

-- Tabela Agenci
CREATE TABLE Agenci (
    ID_Agenta INT PRIMARY KEY IDENTITY(1,1),
    Imie NVARCHAR(50) NOT NULL,
    Nazwisko NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Telefon NVARCHAR(20),
    MiastoID INT NOT NULL,
    FOREIGN KEY (MiastoID) REFERENCES Miasta(ID_Miasta)
);
CREATE INDEX idx_Agenci_MiastoID ON Agenci(MiastoID);
GO

-- Tabela Transakcje
CREATE TABLE Transakcje (
    ID_Transakcji INT PRIMARY KEY IDENTITY(1,1),
    ID_Nieruchomosci INT NOT NULL,
    ID_Klienta INT NOT NULL,
    ID_Agenta INT NOT NULL,
    DataTransakcji DATE,
    Kwota DECIMAL(18,2) CHECK (Kwota > 0),
    StatusID INT NOT NULL,
    FOREIGN KEY (ID_Nieruchomosci) REFERENCES Nieruchomosci(ID_Nieruchomosci),
    FOREIGN KEY (ID_Klienta) REFERENCES Klienci(ID_Klienta),
    FOREIGN KEY (ID_Agenta) REFERENCES Agenci(ID_Agenta),
    FOREIGN KEY (StatusID) REFERENCES StatusyTransakcji(ID_Statusu)
);
CREATE INDEX idx_ID_Transakcji ON Transakcje(ID_Transakcji);
CREATE INDEX idx_Transakcje_ID_Nieruchomosci ON Transakcje(ID_Nieruchomosci);
CREATE INDEX idx_Transakcje_ID_Klienta ON Transakcje(ID_Klienta);
CREATE INDEX idx_Transakcje_ID_Agenta ON Transakcje(ID_Agenta);
CREATE INDEX idx_Transakcje_StatusID ON Transakcje(StatusID);
GO

-- Tabela ProwizjeAgentow
CREATE TABLE ProwizjeAgentow (
    ID_Prowizji INT PRIMARY KEY IDENTITY(1,1),
    ID_Agenta INT NOT NULL,
    ID_Transakcji INT NOT NULL,
    Prowizja DECIMAL(18,2) CHECK (Prowizja >= 0),
    DataWyplaty DATE,
    FOREIGN KEY (ID_Agenta) REFERENCES Agenci(ID_Agenta),
    FOREIGN KEY (ID_Transakcji) REFERENCES Transakcje(ID_Transakcji)
);
GO

-- Tabela Deweloperzy
CREATE TABLE Deweloperzy (
    ID_Dewelopera INT PRIMARY KEY IDENTITY(1,1),
    Nazwa NVARCHAR(100) NOT NULL,
    Adres NVARCHAR(255),
    Email NVARCHAR(100) CHECK (Email LIKE '%@%'),
    Telefon NVARCHAR(20) CHECK (Telefon LIKE '[0-9]%'),
    MiastoID INT NOT NULL,
    FOREIGN KEY (MiastoID) REFERENCES Miasta(ID_Miasta)
);
GO

-- Tabela UmowyNajmu
CREATE TABLE UmowyNajmu (
    ID_Umowy INT PRIMARY KEY IDENTITY(1,1),
    ID_Nieruchomosci INT NOT NULL,
    ID_Klienta INT NOT NULL,
    DataRozpoczecia DATE NOT NULL,
    DataZakonczenia DATE NOT NULL,
    MiesiecznyCzynsz DECIMAL(18,2) CHECK (MiesiecznyCzynsz > 0),
    FOREIGN KEY (ID_Nieruchomosci) REFERENCES Nieruchomosci(ID_Nieruchomosci),
    FOREIGN KEY (ID_Klienta) REFERENCES Klienci(ID_Klienta)
);
GO
-- Wstawienie przyk³adowych danych

-- Miasta
INSERT INTO Miasta (NazwaMiasta, Kraj, LiczbaMieszkancow) VALUES ('Warszawa', 'Polska', 1790658);
INSERT INTO Miasta (NazwaMiasta, Kraj, LiczbaMieszkancow) VALUES ('Kraków', 'Polska', 779115);
INSERT INTO Miasta (NazwaMiasta, Kraj, LiczbaMieszkancow) VALUES ('Wroc³aw', 'Polska', 643782);

-- TypyNieruchomosci
INSERT INTO TypyNieruchomosci (NazwaTypu, Opis) VALUES ('Mieszkanie', 'Lokal mieszkalny w bloku lub kamienicy');
INSERT INTO TypyNieruchomosci (NazwaTypu, Opis) VALUES ('Dom', 'Wolnostoj¹cy budynek mieszkalny');
INSERT INTO TypyNieruchomosci (NazwaTypu, Opis) VALUES ('Dzia³ka', 'Grunt pod zabudowê');
INSERT INTO TypyNieruchomosci (NazwaTypu, Opis) VALUES ('Biuro', 'Lokal przeznaczony do pracy biurowej');

-- StatusyTransakcji
INSERT INTO StatusyTransakcji (NazwaStatusu, Opis) VALUES ('W trakcie', 'Transakcja jest w trakcie realizacji');
INSERT INTO StatusyTransakcji (NazwaStatusu, Opis) VALUES ('Zakoñczona', 'Transakcja zosta³a zakoñczona pomyœlnie');
INSERT INTO StatusyTransakcji (NazwaStatusu, Opis) VALUES ('Anulowana', 'Transakcja zosta³a anulowana');

-- Nieruchomosci
INSERT INTO Nieruchomosci (Adres, MiastoID, Cena, TypID, Powierzchnia, DataDodania, StatusID) VALUES ('ul. Marsza³kowska 1', 1, 850000.00, 1, 60, '2023-01-15', 1);
INSERT INTO Nieruchomosci (Adres, MiastoID, Cena, TypID, Powierzchnia, DataDodania, StatusID) VALUES ('ul. Floriañska 10', 2, 1250000.00, 2, 120, '2023-02-20', 2);
INSERT INTO Nieruchomosci (Adres, MiastoID, Cena, TypID, Powierzchnia, DataDodania, StatusID) VALUES ('ul. Rynek 5', 3, 400000.00, 3, 300, '2023-03-10', 3);

-- Klienci
INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Jan', 'Kowalski', 'jan.kowalski@example.com', '123456789', 1);
INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Anna', 'Nowak', 'anna.nowak@example.com', '987654321', 2);
INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Piotr', 'Wiœniewski', 'piotr.wisniewski@example.com', '567890123', 3);

-- Agenci
INSERT INTO Agenci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Katarzyna', 'Mazur', 'katarzyna.mazur@example.com', '111222333', 1);
INSERT INTO Agenci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Micha³', 'D¹browski', 'michal.dabrowski@example.com', '444555666', 2);
INSERT INTO Agenci (Imie, Nazwisko, Email, Telefon, MiastoID) VALUES ('Monika', 'Zieliñska', 'monika.zielinska@example.com', '777888999', 3);

-- Transakcje
INSERT INTO Transakcje (ID_Nieruchomosci, ID_Klienta, ID_Agenta, DataTransakcji, Kwota, StatusID) VALUES (1, 1, 1, '2023-05-01', 850000.00, 2);
INSERT INTO Transakcje (ID_Nieruchomosci, ID_Klienta, ID_Agenta, DataTransakcji, Kwota, StatusID) VALUES (2, 2, 2, '2023-06-15', 1250000.00, 2);
INSERT INTO Transakcje (ID_Nieruchomosci, ID_Klienta, ID_Agenta, DataTransakcji, Kwota, StatusID) VALUES (3, 3, 3, '2023-07-20', 400000.00, 2);

-- ProwizjeAgentow
INSERT INTO ProwizjeAgentow (ID_Agenta, ID_Transakcji, Prowizja, DataWyplaty) VALUES (1, 1, 8500.00, '2023-05-10');
INSERT INTO ProwizjeAgentow (ID_Agenta, ID_Transakcji, Prowizja, DataWyplaty) VALUES (2, 2, 12500.00, '2023-06-20');
INSERT INTO ProwizjeAgentow (ID_Agenta, ID_Transakcji, Prowizja, DataWyplaty) VALUES (3, 3, 4000.00, '2023-07-25');

-- Deweloperzy
INSERT INTO Deweloperzy (Nazwa, Adres, Email, Telefon, MiastoID) VALUES ('Budimex', 'ul. Przyk³adowa 1, Warszawa', 'kontakt@budimex.com', '222333444', 1);
INSERT INTO Deweloperzy (Nazwa, Adres, Email, Telefon, MiastoID) VALUES ('Echo Investment', 'ul. Przyk³adowa 2, Kraków', 'kontakt@echo.com', '555666777', 2);
INSERT INTO Deweloperzy (Nazwa, Adres, Email, Telefon, MiastoID) VALUES ('Skanska', 'ul. Przyk³adowa 3, Wroc³aw', 'kontakt@skanska.com', '888999000', 3);

-- UmowyNajmu
INSERT INTO UmowyNajmu (ID_Nieruchomosci, ID_Klienta, DataRozpoczecia, DataZakonczenia, MiesiecznyCzynsz) VALUES (1, 1, '2023-08-01', '2024-08-01', 2500.00);
INSERT INTO UmowyNajmu (ID_Nieruchomosci, ID_Klienta, DataRozpoczecia, DataZakonczenia, MiesiecznyCzynsz) VALUES (2, 2, '2023-09-01', '2024-09-01', 3500.00);
INSERT INTO UmowyNajmu (ID_Nieruchomosci, ID_Klienta, DataRozpoczecia, DataZakonczenia, MiesiecznyCzynsz) VALUES (3, 3, '2023-10-01', '2024-10-01', 1500.00);
GO

-- Tworzenie widoków

-- Widok 1: Przegl¹d transakcji z prowizjami dla aktywnych transakcji
IF OBJECT_ID('dbo.PrzegladTransakcjiAktywne', 'V') IS NOT NULL
    DROP VIEW dbo.PrzegladTransakcjiAktywne;
GO

CREATE VIEW PrzegladTransakcjiAktywne
AS
SELECT
    T.ID_Transakcji,
    N.Adres AS AdresNieruchomosci,
    K.Imie + ' ' + K.Nazwisko AS Klient,
    A.Imie + ' ' + A.Nazwisko AS Agent,
    T.DataTransakcji,
    T.Kwota,
    PT.Prowizja
FROM Transakcje T
INNER JOIN Nieruchomosci N ON T.ID_Nieruchomosci = N.ID_Nieruchomosci
INNER JOIN Klienci K ON T.ID_Klienta = K.ID_Klienta
INNER JOIN Agenci A ON T.ID_Agenta = A.ID_Agenta
LEFT JOIN ProwizjeAgentow PT ON T.ID_Transakcji = PT.ID_Transakcji
WHERE T.StatusID = 2; -- Aktywne transakcje
GO

-- Widok 2: Liczba klientów w poszczególnych miastach dla aktywnych klientów
IF OBJECT_ID('dbo.AktywniKlienciWMiastach', 'V') IS NOT NULL
    DROP VIEW dbo.AktywniKlienciWMiastach;
GO

CREATE VIEW AktywniKlienciWMiastach
AS
SELECT
    M.NazwaMiasta,
    COUNT(K.ID_Klienta) AS LiczbaKlientow
FROM Klienci K
INNER JOIN Miasta M ON K.MiastoID = M.ID_Miasta
GROUP BY M.NazwaMiasta;
GO

-- Widok 3: Statystyki transakcji miesiêczne
IF OBJECT_ID('dbo.StatystykiTransakcjiMiesieczne', 'V') IS NOT NULL
    DROP VIEW dbo.StatystykiTransakcjiMiesieczne;
GO

CREATE VIEW StatystykiTransakcjiMiesieczne
AS
SELECT
    YEAR(T.DataTransakcji) AS Rok,
    MONTH(T.DataTransakcji) AS Miesiac,
    COUNT(T.ID_Transakcji) AS LiczbaTransakcji,
    SUM(T.Kwota) AS SumaKwot,
    AVG(T.Kwota) AS SredniaKwota
FROM Transakcje T
GROUP BY YEAR(T.DataTransakcji), MONTH(T.DataTransakcji);
GO

-- Widok 4: Œrednia cena nieruchomoœci w ró¿nych miastach dla nieruchomoœci powy¿ej okreœlonej wartoœci
IF OBJECT_ID('dbo.SredniaCenaNieruchomosciDrogichWMiastach', 'V') IS NOT NULL
    DROP VIEW dbo.SredniaCenaNieruchomosciDrogichWMiastach;
GO

CREATE VIEW SredniaCenaNieruchomosciDrogichWMiastach
AS
SELECT
    M.NazwaMiasta,
    AVG(N.Cena) AS SredniaCena
FROM Nieruchomosci N
INNER JOIN Miasta M ON N.MiastoID = M.ID_Miasta
WHERE N.Cena > 500000 -- Cena nieruchomoœci powy¿ej 500,000
GROUP BY M.NazwaMiasta;
GO

-- Widok 5: Aktywnoœæ agentów w sprzeda¿y nieruchomoœci
IF OBJECT_ID('dbo.AktywnoscAgentow', 'V') IS NOT NULL
    DROP VIEW dbo.AktywnoscAgentow;
GO

CREATE VIEW AktywnoscAgentow
AS
SELECT
    A.ID_Agenta,
    A.Imie + ' ' + A.Nazwisko AS Agent,
    COUNT(T.ID_Transakcji) AS LiczbaTransakcji,
    SUM(T.Kwota) AS SumaKwot,
    SUM(PT.Prowizja) AS SumaProwizji
FROM Agenci A
LEFT JOIN Transakcje T ON A.ID_Agenta = T.ID_Agenta
LEFT JOIN ProwizjeAgentow PT ON T.ID_Transakcji = PT.ID_Transakcji
GROUP BY A.ID_Agenta, A.Imie, A.Nazwisko;
GO

-- Widok 6: Œrednia cena nieruchomoœci w ró¿nych miastach
IF OBJECT_ID('dbo.SredniaCenaNieruchomosciWMiastach', 'V') IS NOT NULL
    DROP VIEW dbo.SredniaCenaNieruchomosciWMiastach;
GO

CREATE VIEW SredniaCenaNieruchomosciWMiastach
AS
SELECT
    M.NazwaMiasta,
    AVG(N.Cena) AS SredniaCena
FROM Nieruchomosci N
INNER JOIN Miasta M ON N.MiastoID = M.ID_Miasta
GROUP BY M.NazwaMiasta;
GO

-- Widok 7: Liczba klientów w poszczególnych miastach
IF OBJECT_ID('dbo.LiczbaKlientowWMiastach', 'V') IS NOT NULL
    DROP VIEW dbo.LiczbaKlientowWMiastach;
GO

CREATE VIEW LiczbaKlientowWMiastach
AS
SELECT
    M.NazwaMiasta,
    COUNT(K.ID_Klienta) AS LiczbaKlientow
FROM Klienci K
INNER JOIN Miasta M ON K.MiastoID = M.ID_Miasta
GROUP BY M.NazwaMiasta;
GO

-- Wywo³anie widoku PrzegladTransakcjiAktywne
SELECT * FROM PrzegladTransakcjiAktywne;

-- Wywo³anie widoku AktywniKlienciWMiastach
SELECT * FROM AktywniKlienciWMiastach;

-- Wywo³anie widoku StatystykiTransakcjiMiesieczne
SELECT * FROM StatystykiTransakcjiMiesieczne;

-- Wywo³anie widoku SredniaCenaNieruchomosciDrogichWMiastach
SELECT * FROM SredniaCenaNieruchomosciDrogichWMiastach;

-- Wywo³anie widoku AktywnoscAgentow
SELECT * FROM AktywnoscAgentow;

-- Wywo³anie widoku SredniaCenaNieruchomosciWMiastach
SELECT * FROM SredniaCenaNieruchomosciWMiastach;

-- Wywo³anie widoku LiczbaKlientowWMiastach
SELECT * FROM LiczbaKlientowWMiastach;

-- Tworzenie funkcji

-- Funkcja 1: ZnajdŸ transakcje klienta
IF OBJECT_ID('dbo.ZnajdzTransakcjeKlienta', 'TF') IS NOT NULL
    DROP FUNCTION dbo.ZnajdzTransakcjeKlienta;
GO

CREATE FUNCTION ZnajdzTransakcjeKlienta
(
    @ID_Klienta INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        T.ID_Transakcji,
        N.Adres AS AdresNieruchomosci,
        T.DataTransakcji,
        T.Kwota,
        PT.Prowizja
    FROM Transakcje T
    INNER JOIN Nieruchomosci N ON T.ID_Nieruchomosci = N.ID_Nieruchomosci
    LEFT JOIN ProwizjeAgentow PT ON T.ID_Transakcji = PT.ID_Transakcji
    WHERE T.ID_Klienta = @ID_Klienta
);
GO

-- Funkcja 2: ZnajdŸ umowy najmu agenta
IF OBJECT_ID('dbo.ZnajdzUmowyNajmuAgenta', 'TF') IS NOT NULL
    DROP FUNCTION dbo.ZnajdzUmowyNajmuAgenta;
GO

CREATE FUNCTION ZnajdzUmowyNajmuAgenta
(
    @ID_Agenta INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        UN.ID_Umowy,
        N.Adres AS AdresNieruchomosci,
        UN.DataRozpoczecia,
        UN.DataZakonczenia,
        UN.MiesiecznyCzynsz
    FROM UmowyNajmu UN
    INNER JOIN Transakcje T ON UN.ID_Nieruchomosci = T.ID_Nieruchomosci
    INNER JOIN Agenci A ON T.ID_Agenta = A.ID_Agenta
    INNER JOIN Nieruchomosci N ON UN.ID_Nieruchomosci = N.ID_Nieruchomosci
    WHERE A.ID_Agenta = @ID_Agenta
);
GO

-- Funkcja 3: ZnajdŸ ostatnie transakcje
IF OBJECT_ID('dbo.ZnajdzOstatnieTransakcje', 'TF') IS NOT NULL
    DROP FUNCTION dbo.ZnajdzOstatnieTransakcje;
GO

CREATE FUNCTION ZnajdzOstatnieTransakcje
()
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT
        K.ID_Klienta,
        MAX(T.DataTransakcji) AS OstatniaTransakcja
    FROM Klienci K
    INNER JOIN Transakcje T ON K.ID_Klienta = T.ID_Klienta
    GROUP BY K.ID_Klienta
);
GO

-- Funkcja 4: ZnajdŸ klientów z najwiêksz¹ liczb¹ transakcji
IF OBJECT_ID('dbo.ZnajdzKlientowNajwiecejTransakcji', 'TF') IS NOT NULL
    DROP FUNCTION dbo.ZnajdzKlientowNajwiecejTransakcji;
GO

CREATE FUNCTION ZnajdzKlientowNajwiecejTransakcji
()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 10
        K.ID_Klienta,
        K.Imie,
        K.Nazwisko,
        COUNT(T.ID_Transakcji) AS LiczbaTransakcji
    FROM Klienci K
    LEFT JOIN Transakcje T ON K.ID_Klienta = T.ID_Klienta
    GROUP BY K.ID_Klienta, K.Imie, K.Nazwisko
    ORDER BY LiczbaTransakcji DESC
);
GO

-- Wywo³anie funkcji w celu sprawdzenia dzia³ania

-- 1. ZnajdŸ transakcje klienta (przyk³adowo dla klienta o ID_Klienta = 1)
SELECT *
FROM dbo.ZnajdzTransakcjeKlienta(1);

-- 2. ZnajdŸ umowy najmu agenta (przyk³adowo dla agenta o ID_Agenta = 2)
SELECT *
FROM dbo.ZnajdzUmowyNajmuAgenta(2);

-- 3. ZnajdŸ ostatnie transakcje
SELECT *
FROM dbo.ZnajdzOstatnieTransakcje();

-- 4. ZnajdŸ klientów z najwiêksz¹ liczb¹ transakcji
SELECT *
FROM dbo.ZnajdzKlientowNajwiecejTransakcji();

-- Tworzenie procedur sk³adowanych

-- Procedura 1: Zaktualizuj datê rozpoczêcia umowy najmu tylko jeœli umowa istnieje
IF OBJECT_ID('dbo.ZaktualizujDateRozpoczeciaUmowyNajmu', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ZaktualizujDateRozpoczeciaUmowyNajmu;
GO

CREATE PROCEDURE ZaktualizujDateRozpoczeciaUmowyNajmu
    @ID_Umowy INT,
    @NowaDataRozpoczecia DATE
AS
BEGIN
    DECLARE @LiczbaUmow INT;

    SELECT @LiczbaUmow = COUNT(*)
    FROM UmowyNajmu
    WHERE ID_Umowy = @ID_Umowy;

    IF @LiczbaUmow > 0
    BEGIN
        UPDATE UmowyNajmu
        SET DataRozpoczecia = @NowaDataRozpoczecia
        WHERE ID_Umowy = @ID_Umowy;

        PRINT 'Data rozpoczêcia umowy najmu zosta³a zaktualizowana.';
    END
    ELSE
    BEGIN
        PRINT 'Umowa o podanym ID nie istnieje.';
    END
END;
GO
-- Procedura 2: Dodaj nowego klienta

IF OBJECT_ID('dbo.DodajNowegoKlienta', 'P') IS NOT NULL
    DROP PROCEDURE dbo.DodajNowegoKlienta;
GO

CREATE PROCEDURE DodajNowegoKlienta
    @Imie NVARCHAR(50),
    @Nazwisko NVARCHAR(50),
    @Email NVARCHAR(100),
    @Telefon NVARCHAR(20),
    @MiastoID INT
AS
BEGIN
    IF LEN(@Imie) > 0 AND LEN(@Nazwisko) > 0 AND LEN(@Email) > 0 AND LEN(@Telefon) > 0
    BEGIN
        -- SprawdŸ, czy klient o podanym adresie email ju¿ istnieje
        IF NOT EXISTS (SELECT 1 FROM Klienci WHERE Email = @Email)
        BEGIN
            -- Dodaj nowego klienta, jeœli nie istnieje klient o tym adresie email
            INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID)
            VALUES (@Imie, @Nazwisko, @Email, @Telefon, @MiastoID);

            PRINT 'Nowy klient zosta³ dodany.';
        END
        ELSE
        BEGIN
            PRINT 'Nie uda³o siê dodaæ nowego klienta. Klient o podanym adresie email ju¿ istnieje.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Nie uda³o siê dodaæ nowego klienta. Wymagane s¹ wszystkie dane: Imiê, Nazwisko, Email, Telefon.';
    END
END;
GO



-- Procedura 3: Aktualizacja ceny nieruchomoœci
IF OBJECT_ID('dbo.AktualizujCeneNieruchomosci', 'P') IS NOT NULL
    DROP PROCEDURE dbo.AktualizujCeneNieruchomosci;
GO

CREATE PROCEDURE AktualizujCeneNieruchomosci
    @ID_Nieruchomosci INT,
    @NowaCena MONEY
AS
BEGIN
    DECLARE @StatusAktualny INT;

    -- SprawdŸ status aktualny nieruchomoœci
    SELECT @StatusAktualny = StatusID
    FROM Nieruchomosci
    WHERE ID_Nieruchomosci = @ID_Nieruchomosci;

    -- Jeœli nieruchomoœæ ma status "Aktywna" (przyk³adowo, status 1 oznacza "Aktywna")
    IF @StatusAktualny = 1
    BEGIN
        -- Zaktualizuj cenê nieruchomoœci
        UPDATE Nieruchomosci
        SET Cena = @NowaCena
        WHERE ID_Nieruchomosci = @ID_Nieruchomosci;

        PRINT 'Cena nieruchomoœci zosta³a zaktualizowana.';
    END
    ELSE
    BEGIN
        PRINT 'Nie mo¿na zaktualizowaæ ceny nieruchomoœci. Nieruchomoœæ nie jest w aktywnym stanie.';
    END
END;
GO
-- Procedura 4: ZnajdŸ klientów z najwiêksz¹ liczb¹ transakcji
IF OBJECT_ID('dbo.Znajdz_KlientowNajwiecejTransakcji', 'P') IS NOT NULL
    DROP PROCEDURE dbo.Znajdz_KlientowNajwiecejTransakcji;
GO

CREATE PROCEDURE Znajdz_KlientowNajwiecejTransakcji
AS
BEGIN
    SELECT TOP 10
        K.ID_Klienta,
        K.Imie,
        K.Nazwisko,
        COUNT(T.ID_Transakcji) AS LiczbaTransakcji
    FROM Klienci K
    LEFT JOIN Transakcje T ON K.ID_Klienta = T.ID_Klienta
    GROUP BY K.ID_Klienta, K.Imie, K.Nazwisko
    ORDER BY LiczbaTransakcji DESC;
END;
GO

-- Przyk³ady wywo³ania procedur sk³adowanych:

-- Wywo³anie procedury 1: Zaktualizuj datê rozpoczêcia umowy najmu
EXEC ZaktualizujDateRozpoczeciaUmowyNajmu @ID_Umowy = 1, @NowaDataRozpoczecia = '2024-06-30';

-- Wywo³anie procedury 2: Dodaj nowego klienta
EXEC DodajNowegoKlienta @Imie = 'Jan', @Nazwisko = 'Kowalski', @Email = 'jan.kowalski@example.com', @Telefon = '123456789', @MiastoID = 3;

-- Wywo³anie procedury 3: Aktualizacja ceny nieruchomoœci
EXEC AktualizujCeneNieruchomosci @ID_Nieruchomosci = 2, @NowaCena = 350000;

-- Wywo³anie procedury 4: ZnajdŸ klientów z najwiêksz¹ liczb¹ transakcji
EXEC Znajdz_KlientowNajwiecejTransakcji;

-- Tworzenie wyzwalaczy

-- Wyzwalacz 1: Wyzwalacz do sprawdzania poprawnoœci danych w tabeli Klienci
IF OBJECT_ID('SprawdzPoprawnoscDanychKlientow', 'TR') IS NOT NULL
    DROP TRIGGER SprawdzPoprawnoscDanychKlientow;
GO
CREATE TRIGGER SprawdzPoprawnoscDanychKlientow
ON Klienci
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Email NOT LIKE '%@%')
    BEGIN
        RAISERROR ('Niepoprawny format adresu email.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM inserted WHERE NOT Telefon LIKE '[0-9]%')
    BEGIN
        RAISERROR ('Niepoprawny format numeru telefonu.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Wyzwalacz 2: Wyzwalacz przed wstawieniem nowego agenta
IF OBJECT_ID('WstawianieNowegoAgenta', 'TR') IS NOT NULL
    DROP TRIGGER WstawianieNowegoAgenta;
GO

CREATE TRIGGER WstawianieNowegoAgenta
ON Agenci
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Imie NVARCHAR(50), @Nazwisko NVARCHAR(50), @MiastoID INT;
    
    SELECT @Imie = Imie, @Nazwisko = Nazwisko, @MiastoID = MiastoID FROM inserted;
    
    IF LEN(@Imie) > 1 AND LEN(@Nazwisko) > 1
    BEGIN
        INSERT INTO Agenci (Imie, Nazwisko, MiastoID)
        VALUES (@Imie, @Nazwisko, @MiastoID);
        
        PRINT 'Nowy agent zosta³ dodany.';
    END
    ELSE
    BEGIN
        PRINT 'Nie uda³o siê dodaæ nowego agenta. Imiê i nazwisko musz¹ mieæ co najmniej 2 znaki.';
    END
END;
GO

-- Testowanie wyzwalaczy

-- Test SprawdzPoprawnoscDanychKlientow
PRINT 'Testowanie wyzwalacza SprawdzPoprawnoscDanychKlientow';
BEGIN TRY
    INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID) 
    VALUES ('Jan', 'Kowalski', 'jan.kowalski@example.com', '123456789', 1); -- Zak³adaj¹c, ¿e MiastoID = 1 jest poprawne
    PRINT 'Poprawne dane dodane.';
END TRY
BEGIN CATCH
    PRINT 'B³¹d: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, MiastoID) 
    VALUES ('Piotr', 'Zieliñski', 'piotr.zielinski@example.com', 'ABC123', 1);
    PRINT 'B³¹d: dane nie powinny zostaæ dodane z niepoprawnym numerem telefonu.';
END TRY
BEGIN CATCH
    PRINT 'B³¹d: ' + ERROR_MESSAGE();
END CATCH

-- Test WstawianieNowegoAgenta
PRINT 'Testowanie wyzwalacza WstawianieNowegoAgenta';
BEGIN TRY
    INSERT INTO Agenci (Imie, Nazwisko, MiastoID) 
    VALUES ('Jan', 'Kowalski',1); 
    PRINT 'Nowy agent zosta³ dodany.';
END TRY
BEGIN CATCH
    PRINT 'B³¹d: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    INSERT INTO Agenci (Imie, Nazwisko) VALUES ('A', 'B');
    PRINT 'B³¹d: dane nie powinny zostaæ dodane z imieniem i nazwiskiem krótszym ni¿ 2 znaki.';
END TRY
BEGIN CATCH
    PRINT 'B³¹d: ' + ERROR_MESSAGE();
END CATCH