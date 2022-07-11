--------------Operazioni del Carico di Lavoro----------
--1)Richiesta:
--Determinare l’identificatore dei giochi che coinvolgono al
--più quattro squadre e richiedono l’uso di due 
--dadi.
set search_path to "OCA";
SELECT GiocoId
FROM GIOCO
WHERE NrDadi = 2 AND MaxSquadre < 5 

-- Riscrittura:
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: NO
-- Sottointerrogazioni: NO
-- Allora non è necessaria nessuna riscrittura

--2)Richiesta:
--Determinare l’identificatore delle sfide relative a un
-- gioco A di vostra scelta (specificare direttamente 
--l’identificatore nella richiesta) che, in alternativa:
-- - hanno avuto luogo a gennaio 2021 e durata massima
--   superiore a 2 ore, o 
-- - hanno avuto luogo a marzo 2021 e durata massima pari
--   a 30 minuti.
set search_path to "OCA";
SELECT SfidaId 
FROM SFIDA
WHERE GiocoId = 28 AND 
(
    (Data BETWEEN '2021-01-01' AND '2021-01-31'  
     AND  DurataMassima > '02:00:00')
     OR
    (Data BETWEEN '2021-03-01' AND '2021-03-31'
     AND  DurataMassima = '00:30:00')
)
-- Riscrittura:
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: NO
-- Sottointerrogazioni: NO
-- Allora non è necessaria nessuna riscrittura


--3)Richiesta:
--Determinare le sfide, di durata massima superiore a 2 ore,
--dei giochi che richiedono almeno due dadi.
--Restituire sia l’identificatore della sfida sia
--l’identificatore del gioco

set search_path to "OCA";
SELECT Sfida.SfidaId, Gioco.GiocoId
FROM SFIDA JOIN GIOCO ON SFIDA.GiocoId = GIOCO.GiocoId
WHERE SFIDA.DurataMassima > '02:00:00' AND GIOCO.NrDadi > 1 
-- Riscrittura:
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: NO
-- Sottointerrogazioni: NO
-- Allora non è necessaria nessuna riscrittura

-------------------Vista--------------------
--Richiesta:
--La definizione di una vista che fornisca alcune
--informazioni riassuntive per ogni gioco: il numero
--di sfide relative a quel gioco disputate,
--la durata media di tali sfide, il numero di
--squadre e di giocatori partecipanti a tali 
--sfide, i punteggi minimo, medio e massimo ottenuti
-- dalle squadre partecipanti a tali sfide;

set search_path to "OCA";
CREATE VIEW InfoRiassuntive
AS(
SELECT *
FROM
(
	SELECT GiocoId, COUNT(DISTINCT Squadra) AS NrSquadre,
	COUNT(DISTINCT sfidaid) AS NrSfide,
	MAX(PunteggioFinale) AS PunteggioMassimo,
	AVG(PunteggioFinale) as PunteggioMedio,
	MIN(PunteggioFinale) as PunteggioMinimo
	FROM OttienePunteggio NATURAL JOIN Sfida
	WHERE PunteggioFinale IS NOT NULL
	GROUP BY GiocoId
)AS X NATURAL JOIN (
	SELECT 
	GiocoId, COUNT(DISTINCT Nickname) AS NrPartecipanti
	FROM UtentePartecipa JOIN SfidaInfo ON SfidaId=Id
	NATURAL JOIN Sfida
	WHERE DurataEffettiva IS NOT NULL
	GROUP BY GiocoId
)AS Y NATURAL JOIN (
	SELECT 
	GiocoId, AVG(DurataEffettiva)
	FROM SfidaInfo JOIN Sfida ON SfidaId=Id
	WHERE DurataEffettiva IS NOT NULL
    GROUP BY GiocoId
) AS Z);

--Riscrittura:
-- Condizioni su espressioni: NO
-- Uso di viste: Si
-- Clausola DISTINCT: Si, ma sono necessarie 
-- Sottointerrogazioni: NO
-- Materializzo la vista cosi' non ho espansioni e ho i
-- join gia' fatti che fanno perdere tempo se faccio
-- le query su di essa senza materializzazione.
-- Sarebbe stato comodo l'enable query rewrite 
-- nel caso l'utente non fosse a conoscenza della vista
-- cosi' da permettere al sistema di fare delle riscritture
-- su delle query simili alla vista
set search_path to "OCA";
CREATE MATERIALIZED VIEW InfoRiassuntive
AS(
SELECT *
FROM
(
	SELECT GiocoId, COUNT(DISTINCT Squadra) AS NrSquadre,
	COUNT(DISTINCT sfidaid) AS NrSfide,
	MAX(PunteggioFinale) AS PunteggioMassimo,
	AVG(PunteggioFinale) as PunteggioMedio,
	MIN(PunteggioFinale) as PunteggioMinimo
	FROM OttienePunteggio NATURAL JOIN Sfida
	WHERE PunteggioFinale IS NOT NULL
	GROUP BY GiocoId
)AS X NATURAL JOIN (
	SELECT 
	GiocoId, COUNT(DISTINCT Nickname) AS NrPartecipanti
	FROM UtentePartecipa JOIN SfidaInfo ON SfidaId=Id
	NATURAL JOIN Sfida
	WHERE DurataEffettiva IS NOT NULL
	GROUP BY GiocoId
)AS Y NATURAL JOIN (
	SELECT 
	GiocoId, AVG(DurataEffettiva)
	FROM SfidaInfo JOIN Sfida ON SfidaId=Id
	WHERE DurataEffettiva IS NOT NULL
    GROUP BY GiocoId
) AS Z);


--======[alcuni input (alcuni inserimenti sono gia' stati
--fatti durante il controllo dei vincoli check):
INSERT INTO Utente
VALUES('Yulia', 'y@gmail.com', 'Y', 'S', NULL);
INSERT INTO Squadra
VALUES('Piedi');
INSERT INTO SfidaInfo
VALUES(6001, '14:00:00', '02:10:00', 10, 10, true, 5000, 5000);
INSERT INTO Sfida
VALUES(6001, 5000, '2021-01-02', '03:00:00');
-- faccio partecipare gli utenti alla sfida 6000 del gioco 5000,
-- notare che Ale sta gia' partecipando
INSERT INTO UtentePartecipa
VALUES('Hasnaa', 'Mani', 6000, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Ilaria', 'Piedi', 6000, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Yulia', 'Piedi', 6000, 'giocatore');
INSERT INTO OttienePunteggio
VALUES('Mani', 6000, 2, 2);
INSERT INTO OttienePunteggio
VALUES('Piedi', 6000, 4, 4);

-- faccio partecipare gli utenti alla sfida 6001 del gioco 5000
INSERT INTO UtentePartecipa
VALUES('Ale', 'Mani', 6001, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Yulia', 'Mani', 6001, 'giocatore');
INSERT INTO UtentePartecipa
VALUES('Ilaria', 'Piedi', 6001, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Hasnaa', 'Piedi', 6001, 'giocatore');
INSERT INTO OttienePunteggio
VALUES('Mani', 6001, 8, 8);
INSERT INTO OttienePunteggio
VALUES('Piedi', 6001, 10, 10);
-- Quindi mi aspetto per il gioco 5000:
-- 2 sfide, 4 giocatori, 2 squadre, PunteggioMedio 6,
-- PunteggioMassimo 10 e PunteggioMinimo 2, DurataMedia 02:05:00


-- Creo due sfide per il gioco 5001
INSERT INTO SfidaInfo
VALUES(6002, '14:00:00', '03:00:00', 10, 10, true, 5000, 5000);
INSERT INTO Sfida
VALUES(6002, 5001, '2021-01-03', '04:00:00');
INSERT INTO SfidaInfo
VALUES(6003, '14:00:00', '03:10:00', 10, 10, true, 5000, 5000);
INSERT INTO Sfida
VALUES(6003, 5001, '2021-01-04', '04:00:00');
-- faccio partecipare i soliti giocatori alla sfida 6002
INSERT INTO UtentePartecipa
VALUES('Ale', 'Mani', 6002, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Yulia', 'Mani', 6002, 'giocatore');
INSERT INTO UtentePartecipa
VALUES('Ilaria', 'Piedi', 6002, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Hasnaa', 'Piedi', 6002, 'giocatore');
-- aggiungo i punteggi
INSERT INTO OttienePunteggio
VALUES('Mani', 6002, 1, 1);
INSERT INTO OttienePunteggio
VALUES('Piedi', 6002, 2, 2);

-- aggiungo una nuova squadra e 2 nuovi utenti
INSERT INTO Squadra
VALUES('Occhi');
INSERT INTO Utente
VALUES('Lorenzo', 'l@gmail.com', 'L', 'P', NULL);
INSERT INTO Utente
VALUES('Pietro', 'p@gmail.com', 'P', 'M', NULL);
-- faccio partecipare gli utenti alla sfida 6003
INSERT INTO UtentePartecipa
VALUES('Ale', 'Mani', 6003, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Yulia', 'Mani', 6003, 'giocatore');
INSERT INTO UtentePartecipa
VALUES('Ilaria', 'Piedi', 6003, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Hasnaa', 'Piedi', 6003, 'giocatore');
INSERT INTO UtentePartecipa
VALUES('Lorenzo', 'Occhi', 6003, 'caposquadra');
INSERT INTO UtentePartecipa
VALUES('Pietro', 'Occhi', 6003, 'giocatore');
-- aggiungo i punteggi
INSERT INTO OttienePunteggio
VALUES('Mani', 6003, 3, 3);
INSERT INTO OttienePunteggio
VALUES('Piedi', 6003, 4, 4);
INSERT INTO OttienePunteggio
VALUES('Occhi', 6003, 5, 5);

-- aggiunga la sfida non terminata 6004 del gioco 5001
INSERT INTO SfidaInfo
VALUES(6004, '14:00:00', NULL, 10, 10, false, 5000, 5000);
INSERT INTO Sfida
VALUES(6004, 5001, '2021-01-05', '04:00:00');
-- creo due nuove squadre e due nuovi utenti
INSERT INTO Squadra
VALUES('Capelli');
INSERT INTO Squadra
VALUES('Baffi');
INSERT INTO Utente
VALUES('Madre', 'm@gmail.com', 'E', 'V', NULL);
INSERT INTO Utente
VALUES('Padre', 'pp@gmail.com', 'I', 'V', NULL);
-- gli faccio partecipare alla sfida 6004
INSERT INTO UtentePartecipa
VALUES('Madre', 'Capelli', 6004, 'giocatore');
INSERT INTO UtentePartecipa
VALUES('Padre', 'Baffi', 6004, 'giocatore');
-- aggiungo i punteggi, ma non c'e' ancora quello finale
INSERT INTO OttienePunteggio
VALUES('Capelli', 6004, 5, NULL);
INSERT INTO OttienePunteggio
VALUES('Baffi', 6004, 6, NULL);

-- Quindi mi aspetto per il gioco 5001:
-- 2 sfide(terminate), 6 giocatori, 3 squadre, PunteggioMedio 2.5,
-- PunteggioMassimo 5 e PunteggioMinimo 1, DurataMedia 03:05:00




-------Interrogazioni non incluse nel carico di lavoro----------------
--a)Richiesta: Determinare i giochi che contengono
--  caselle a cui sono associati task;
-- 
SELECT DISTINCT GiocoCasella
FROM TASK
-- Riscrittura: 
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: Si
-- Sottointerrogazioni: NO
-- Il distinct è necessario dato che ci può essere 
-- più di un task associato ad un certo gioco
-- Non è necessaria nessuna riscrittura


--======[ alcuni input

-- associamo al gioco 1 e 2 delle caselle numeriche
INSERT INTO CasellaNumerica
VALUES(0, 1, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
INSERT INTO CasellaNumerica
VALUES(1, 1, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
INSERT INTO CasellaNumerica
VALUES(2, 1, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
INSERT INTO CasellaNumerica
VALUES(0, 2, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
INSERT INTO CasellaNumerica
VALUES(1, 2, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
INSERT INTO CasellaNumerica
VALUES(2, 2, 0, 0, 'normale', NULL, NULL, 'Video', '00:01:30');
-- associamo alla casella 0 di entrambi i giochi un task
INSERT INTO TASK
VALUES(99, 'Sono un task', 10, 0, 1);
INSERT INTO TASK
VALUES(100, 'Sono un task', 10, 0, 2);
-- Ora possiamo eseguire la query a) per trovare i due giochi

--b)Richiesta: Determinare i giochi che non contengono
--  caselle a cui sono associati task;
SELECT GiocoId
FROM GIOCO
EXCEPT SELECT GiocoCasella AS GiocoId
FROM TASK 
-- Riscrittura:
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: NO
-- Sottointerrogazioni: Sì
-- Contiene una query non correlata non scalare 
-- sarebbe meglio toglierla perché è possibile che il 
-- sistema non consideri degli indici relativi alla
-- query. La riscriviamo in termini di join così possiamo
-- tenere in considerazione anche gli indici per ulteriore
-- velocizzazione. La riscrittura risulta essere:
SELECT GiocoId
FROM Gioco LEFT JOIN Task ON Gioco.GiocoId = TASK.GiocoCasella
WHERE TASK.GiocoCasella IS NULL

--c)Richiesta: Determinare le sfide che hanno durata
--  superiore alla durata media delle sfide relative 
--  allo stesso gioco
set search_path to "OCA";
SELECT SfidaId
FROM SFIDA AS X
WHERE DurataMassima > 
(
    SELECT AVG(DurataMassima)
    FROM SFIDA
    WHERE SFIDA.GiocoId = X.GiocoId
)
-- Condizioni su espressioni: NO
-- Uso di viste: NO
-- Clausola DISTINCT: NO
-- Sottointerrogazioni: Sì
-- Non si può riscrivere dato che postgresql
-- non permette di mettere in join la stessa tabella

/*
eseguendo la query
set search_path to "OCA";
SELECT * FROM SFIDA
notiamo per esempio che il gioco 4 ha due sfide, cioe' 
la sfida 3 e 4. La media della DurataMassima e' 00:45:00
Quindi ci aspettiamo di trovare nel risultato della query
c) la sfida 4 dato che e' maggiore della media 00:45:00
*/ 


