--a) Richiesta:
--   Funzione che realizza l’interrogazione 2c in
--   maniera parametrica rispetto all’ID del gioco
--   (cioè determina le sfide che hanno durata superiore
--   alla durata medie delle sfide di un dato gioco,
--   prendendo come parametro l’ID del gioco);

CREATE OR REPLACE FUNCTION mostraSfideOltreMedia(gioco INT)
RETURNS TABLE(id INT)
AS $$
BEGIN
	RETURN QUERY
		SELECT SfidaId
		FROM SFIDA AS X
		WHERE X.GiocoId = gioco AND
		DurataMassima > 
		(
			SELECT AVG(DurataMassima)
			FROM SFIDA
			WHERE SFIDA.GiocoId = X.GiocoId
		);
END;
$$ LANGUAGE plpgsql

--======[alcuni input:
--select mostraSfideOltreMedia(7);
--select mostraSfideOltreMedia(7);

--b) Richiesta:
--   Funzione di scelta dell’icona da parte di una squadra
--   in una sfida: possono essere scelte solo le 
--   icone corrispondenti al gioco cui si riferisce
--   la sfida che non siano già state scelte da altre squadre.

CREATE OR REPLACE FUNCTION scegliIcona(squadraArg varchar(20), sfidaArg INT,
nomeIconaArg varchar(20), nomeSetArg varchar(15))
RETURNS VOID
language plpgsql
AS 
$$
DECLARE
gioco INT;
BEGIN
--Ricavo il gioco della sfida
gioco := (SELECT GiocoId
            FROM SFIDA
            WHERE SfidaId = sfidaArg);
--Controllo se esiste la sfida
IF count(gioco) = 0 
        THEN RAISE EXCEPTION 'La sfida inserita non esiste';
END IF;

--controllo se il SetIcone specificato appartiene al gioco
--sui cui è basata la sfida
IF count(
	(SELECT NomeSet
	FROM GiocoInfo
	WHERE Id = gioco AND NomeSet = nomeSetArg)
) = 0
	THEN RAISE EXCEPTION 'Il set inserito non appartiene al relativo gioco della sfida';
END IF;
--controllo se l'icona specificata esiste
IF count(
	(SELECT Nome
	FROM Icona
	WHERE Nome = nomeIconaArg AND NomeSet = nomeSetArg) 
) = 0
	THEN RAISE EXCEPTION 'L icona specificata non esiste';
END IF;	
--controllo se l'icona specificata è già stata presa
IF count(
	(SELECT NomeIcona
	FROM SEGNAPOSTO
	WHERE SfidaId = sfidaArg AND
	NomeIcona = nomeIconaArg AND NomeSet = nomeSetArg)
) !=0
	THEN RAISE EXCEPTION 'L icona specificata è già stata presa';
END IF;
--aggiungo la scelta fatta
INSERT INTO SegnaPosto
VALUES(squadraArg, sfidaArg, nomeIconaArg, nomeSetArg, 0, 0);
END
$$ 

--======[alcuni input:
-- usiamo il gioco 5001, la sfida 6003,
-- il set Dinosauri, le squadre Mani, Piedi ed Occhi

-- aggiungiamo, oltre all'icona T-rex, altre icone:
INSERT INTO Icona
VALUES('Apatosauro', 'Dinosauri', 50, 50);
INSERT INTO Icona
VALUES('Iguanodonte', 'Dinosauri', 50, 50);


-- osserviamo che la tabella che tiene traccia
-- di chi ha una certa casella in una certa sfida
-- e' vuota, select * from segnaposto

-- facciamo scegliere alla squadra Mani un'icona
SELECT scegliIcona('Mani', 6003, 'T-Rex', 'Dinosauri');

-- vediamo che la scelta e' stata fatta
-- select * from segnaposto

-- facciamo scegliere alla squadra Piedi la stessa icona
--SELECT scegliIcona('Piedi', 6003, 'T-Rex', 'Dinosauri');

-- creiamo un altro set e delle icone
-- e facciamo scegliere alla squadra Piedi
-- un'icona di un altro gioco

INSERT INTO SetIcone
VALUES('Animali', 50, 50);
INSERT INTO Icona
VALUES('Gatto', 'Animali', 50, 50);
INSERT INTO Icona
VALUES('Cane', 'Animali', 50, 50);
--SELECT scegliIcona('Piedi', 6003, 'Gatto', 'Animali');

-- controllo se mi assegna un'icona che non esiste
--SELECT scegliIcona('Piedi', 6003, 'NonEsisto', 'Dinosauri');

-- verifico se il controllo sull'esistenza della sfida funziona
--SELECT scegliIcona('Piedi', 77777, 'Apatosauro', 'Dinosauri');

-- controllo se posso prendere la stessa icona in due sfide
-- diverse
SELECT scegliIcona('Piedi', 6003, 'Apatosauro', 'Dinosauri');
SELECT scegliIcona('Piedi', 6002, 'Apatosauro', 'Dinosauri');



