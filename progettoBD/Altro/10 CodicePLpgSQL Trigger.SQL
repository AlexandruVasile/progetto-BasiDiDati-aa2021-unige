--a) Richiesta:
--   Verifica del vincolo che nessun utente possa
--   partecipare a sfide contemporanee;

CREATE OR REPLACE FUNCTION utenteInPiuSfide() RETURNS trigger AS 
$utenteInPiuSfide$
BEGIN
	IF
	(-- se esiste un'altra sfida non ancora
	 -- terminata in cui l'utente considerato
	 -- partecipa
		EXISTS
		(
			SELECT *
			FROM UTENTEPARTECIPA JOIN SFIDAINFO ON SfidaId = Id
			WHERE Nickname = NEW.Nickname AND
			SFIDAINFO.Id != NEW.SfidaId AND
			DurataEffettiva IS NULL
		)
	)
	THEN 
		RAISE EXCEPTION '% sei già in una sfida', NEW.Nickname;
	ELSE
		RETURN NEW;
	END IF;
END;
$utenteInPiuSfide$ LANGUAGE plpgsql;

CREATE TRIGGER utenteInPiuSfideTrigger
BEFORE INSERT ON UTENTEPARTECIPA
FOR EACH ROW
EXECUTE PROCEDURE utenteInPiuSfide();

--======[Alcuni input:
-- Ale non sta attualmente partecipando
-- a nessuna sfida non finita.
/*
SELECT Nickname, SfidaId, DurataEffettiva
FROM UtentePartecipa JOIN SfidaInfo
ON SfidaId = Id
WHERE Nickname='Ale'
*/
-- faccio partecipare l'utente Ale
-- alla sfida che deve ancora iniziare numero 21
INSERT INTO UtentePartecipa
VALUES('Ale', 'Mani', 21, 'giocatore');

/*
SELECT Nickname, SfidaId, DurataEffettiva
FROM UtentePartecipa JOIN SfidaInfo
ON SfidaId = Id
WHERE Nickname='Ale' AND
DurataEffettiva IS NULL
*/

-- il prossimo inserimento fallira' dato che partecipa
-- ad una sfida non finita

--INSERT INTO UtentePartecipa
--VALUES('Ale', 'Mani', 23, 'giocatore');


--b) Richiesta:
--   Mantenimento del punteggio corrente di ciascuna
--   squadra in ogni sfida e inserimento delle 
--   icone opportune nella casella podio.
CREATE OR REPLACE FUNCTION aggiornaPodioProcedure() RETURNS trigger AS 
$aggiornaPodioProcedure$
DECLARE
	giocoSfida INT;
	squadra1 varchar(20);
	squadra2 varchar(20);
	squadra3 varchar(20);
	punteggioCorrenteSquadra INT;
	cur CURSOR FOR 
	( 
		-- prendo le squadre della sfida
		-- in ordine decrescente di punteggio
		SELECT Squadra
		FROM OTTIENEPUNTEGGIO
		WHERE SfidaId = NEW.SfidaId
		ORDER BY PunteggioCorrente DESC
	);	
BEGIN
-- estrai punteggio corrente della squadra
-- che ha appena terminato il turno
punteggioCorrenteSquadra:=
				  (
					  SELECT SUM(TURNO.PunteggioOttenuto)
					  FROM TURNO
					  WHERE TURNO.SfidaId = NEW.SfidaId AND
					  TURNO.Squadra = NEW.Squadra
				  );
				  
-- se la squadra non ha mai effettuato un turno allora
-- il suo punteggio e' quello del turni appena terminato		  
IF count(punteggioCorrenteSquadra) = 0 
	THEN punteggioCorrenteSquadra:= NEW.PunteggioOttenuto;
ELSE --altrimenti quello dei turni precedenti + quello del turno corrente
	punteggioCorrenteSquadra:= punteggioCorrenteSquadra +  NEW.PunteggioOttenuto;
END IF; 
-- aggiorno il punteggio corrente della squadra
UPDATE OTTIENEPUNTEGGIO
SET PunteggioCorrente = punteggioCorrenteSquadra
WHERE Squadra = NEW.Squadra;

OPEN cur;
	FETCH cur INTO squadra1;
	FETCH cur INTO squadra2;
	FETCH cur INTO squadra3;
	CLOSE cur;
	-- ricavo il gioco della sfida
	giocoSfida := (
		SELECT GiocoId
		FROM SFIDA NATURAL JOIN GIOCO
		WHERE SfidaId = NEW.SfidaId
	);
	
	-- aggiorno le caselle podio

    -- aggiorno prima casella	
	UPDATE CASELLAPODIO
	SET VisualizzaIcona = 
	(
		SELECT NomeIcona
		FROM Segnaposto
		WHERE Squadra = squadra1 AND
		SfidaId = NEW.SfidaId
	)
	WHERE GiocoId = giocoSfida AND Numero = -1;
	
	-- aggiorno seconda casella
	UPDATE CASELLAPODIO
	SET VisualizzaIcona = 
	(
		SELECT NomeIcona
		FROM Segnaposto
		WHERE Squadra = squadra2 AND
		SfidaId = NEW.SfidaId
	)
	WHERE GiocoId = giocoSfida AND Numero = -2;
	
	-- aggiorno terza casella
	UPDATE CASELLAPODIO
	SET VisualizzaIcona = 
	(
		SELECT NomeIcona
		FROM Segnaposto
		WHERE Squadra = squadra3 AND
		SfidaId = NEW.SfidaId
	)
	WHERE GiocoId = giocoSfida AND Numero = -3;
	RETURN NEW;
END;
$aggiornaPodioProcedure$ LANGUAGE plpgsql;

CREATE TRIGGER aggiornaPodio
BEFORE INSERT ON TURNO
FOR EACH ROW
EXECUTE PROCEDURE aggiornaPodioProcedure();

-- esempio di input usato per verificare
-- che il trigger funzioni correttamente

/*
set search_path to "OCA";
-- creo un set e 3 icone
INSERT INTO SetIcone
VALUES('Mila&Shiro', 50, 50);

INSERT INTO Icona
VALUES('Mila', 'Mila&Shiro', 1280, 720);

INSERT INTO Icona
VALUES('Shiro', 'Mila&Shiro', 1280, 720);

INSERT INTO Icona
VALUES('Allenatore', 'Mila&Shiro', 1280, 720);

-- creo un gioco
INSERT INTO GameCreator
VALUES (5002);

INSERT INTO GiocoInfo
VALUES(5002, 'Sfondo', '00:00:30', 'Mila&Shiro', 5002);

INSERT INTO Gioco
VALUES(5002, 3, 3);

-- creo 3 caselle podio
INSERT INTO CasellaPodio
VALUES (-1, 5002, 0, 1, NULL, 'Mila&Shiro');

INSERT INTO CasellaPodio
VALUES (-2, 5002, 0, 1, NULL, 'Mila&Shiro');

INSERT INTO CasellaPodio
VALUES (-3, 5002, 0, 1, NULL, 'Mila&Shiro');

-- creo 3 squadre
INSERT INTO Squadra
VALUES('Rossi');

INSERT INTO Squadra
VALUES('Bianchi');

INSERT INTO Squadra
VALUES('Verdi');

-- creo una sfida
INSERT INTO Admin
VALUES (5002);

INSERT INTO SfidaInfo
VALUES(5002, '04:00:00', NULL, 2, 2, false, 5002, 5002);

INSERT INTO Sfida
VALUES(5002, 5002, '2021-02-02', '00:02:00');

-- creo tre caselle numeriche per il gioco
INSERT INTO CasellaNumerica
VALUES (0, 5002, 5, 5, 'normale', NULL, NULL, NULL, NULL);

INSERT INTO CasellaNumerica
VALUES (1, 5002, 5, 5, 'normale', NULL, NULL, NULL, NULL);

INSERT INTO CasellaNumerica
VALUES (2, 5002, 5, 5, 'normale', NULL, NULL, NULL, NULL);

-- assegno le icone
INSERT INTO Segnaposto
VALUES('Rossi', 5002, 'Mila', 'Mila&Shiro', 0, 0);

INSERT INTO Segnaposto
VALUES('Bianchi', 5002, 'Shiro', 'Mila&Shiro', 0, 0);

INSERT INTO Segnaposto
VALUES('Verdi', 5002, 'Allenatore', 'Mila&Shiro', 0, 0);

-- inizializzo il punteggio delle squadre nella sfida
INSERT INTO OttienePunteggio
VALUES ('Rossi', 5002, 0, NULL);

INSERT INTO OttienePunteggio
VALUES ('Bianchi', 5002, 0, NULL);

INSERT INTO OttienePunteggio
VALUES ('Verdi', 5002, 0, NULL);


-- aggiungo l'esito delle squadre nel primo turno

INSERT INTO TURNO
VALUES(0, 'Rossi', 5002, 0, 5002, 10, NULL, 3, '00:00:30' );

INSERT INTO TURNO
VALUES(0, 'Bianchi', 5002, 0, 5002, 11, NULL, 3, '00:00:30' );

INSERT INTO TURNO
VALUES(0, 'Verdi', 5002, 0, 5002, 12, NULL, 3, '00:00:30' );
*/
-- decommentare per controllare se i punteggi
-- sono stati aggiornati correttamente

--SELECT *FROM OTTIENEPUNTEGGIO WHERE SfidaId=5002

-- decommentare per controllare se le caselle podio sono state
-- aggiornate correttamente

--SELECT * FROM CASELLAPODIO WHERE GiocoId=5002

-- aggiungo l'esito delle squadre nel secondo turno

--INSERT INTO TURNO
--VALUES(1, 'Rossi', 5002, 0, 5002, 10, NULL, 3, '00:00:30' );

--INSERT INTO TURNO
--VALUES(1, 'Bianchi', 5002, 0, 5002, 11, NULL, 3, '00:00:30' );

--INSERT INTO TURNO
--VALUES(1, 'Verdi', 5002, 0, 5002, 12, NULL, 3, '00:00:30' );

