set search_path to "OCA";
--definizione ruoli
CREATE ROLE UTENTE;
CREATE ROLE GIOCATORE;
CREATE ROLE ADMIN;
CREATE ROLE GAMECREATOR;

--definizioni gerarchia tra i ruoli
GRANT UTENTE TO 
GIOCATORE, ADMIN, GAMECREATOR

--definizione politica di controllo
--degli accessi

--------------------Utente

-- Update e Delete su Utente così un utente può
-- aggiornare i suoi dati e cancellarsi 
GRANT update, delete ON UTENTE TO Utente;

-- Select e Insert su Squadra così un utente può
-- vedere quali squadre ci sono per poi eventualmente
-- iscriversi ad una o più squadre oppure crearne una 
GRANT select, insert ON SQUADRA TO Utente;

-- Insert su UtentePartecipa così l’utente può
-- partecipare ad una sfida
GRANT insert ON UTENTEPARTECIPA TO Utente;

-- Insert e Delete su UtenteAppartiene così un
-- utente può iscriversi ad una squadra oppure
-- cancellarsi (la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT insert, delete ON UTENTEAPPARTIENE TO Utente;

-- Select su Sfida e SfidaInfo così l’utente può
-- capire quale sfida gli può interessare
GRANT select ON Sfida TO Utente;
GRANT select ON SfidaInfo TO Utente;

-- Select su Gioco e GiocoInfo così l’utente capisce
-- la sfida di quale gioco gli può interessare
GRANT select ON Gioco TO Utente;
GRANT select ON GiocoInfo TO Utente;

-- Select su SetIcone e Icone così l’utente può
-- vedere i set e le relative icone 
GRANT select ON SetIcone TO Utente;
GRANT select ON Icona TO Utente;


------------------------Giocatore

-- Insert su GiocatoreCarica così un giocatore può
-- caricare un file per un task (la relazione non
-- compare nel carico di lavoro, funzioni o trigger)
--GRANT insert ON GiocatoreCarica TO Giocatore;

-- Insert su GiocatoreSceglie così un giocatore può
-- scegliere una risposta per un quiz
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
-- GRANT insert ON GiocatoreSceglie TO Giocatore;

-- Select su Turno così un giocatore sà alcune
-- informazioni sul turno per esempio il punteggio
-- ottenuto dalla squadra 
GRANT select ON Turno TO Giocatore;

-- Select su SegnaPosto così un giocatore sà qual è
-- la casella corrente della squadra
GRANT select ON SegnaPosto TO Giocatore;

-- Select su CasellaNumerica così un giocatore può
-- sapere eventualmente il video da guardare
GRANT select ON CasellaNumerica TO Giocatore;

-- Select su Quiz così il giocatore può visualizzare
-- il quiz (la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT select ON Quiz TO Giocatore;

-- Select su Risposta così il giocatore può vedere
-- le risposte possibili al quiz
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT select ON Risposta TO Giocatore;

-- Select su Task così il giocatore può visualizzare
-- il task
GRANT select ON Task TO Giocatore;

-- Select su CasellaPodio così il giocatore sà come
-- sta andando la sfida
GRANT select ON CasellaPodio TO Giocatore;

-- Select su OttienePunteggio così il giocatore
-- sà il punteggio corrente della squadra
-- e il punteggio finale al termine della partita
GRANT select ON OttienePunteggio TO Giocatore;


----------------------Gamecreator

-- Insert, Update e Delete su GiocoInfo e Gioco
-- così da poter creare giochi, aggiornarli o
-- rimuoverli in caso di sviste o ripensamenti.
GRANT insert, update, delete ON Gioco TO Gamecreator;
GRANT insert, update, delete ON GiocoInfo TO Gamecreator;

-- Insert e Delete su Dado così da creare dadi per
-- il gioco oppure rimuoverli
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT insert, delete ON Dado TO Gamecreator;

-- Select, Insert e Delete su CasellaPodio così da creare
-- caselle podio per il gioco oppure rimuoverle
-- in caso di sviste o ripensamenti
GRANT select, insert, delete ON CasellaPodio TO Gamecreator;


-- Insert, Update e Delete su SetIcone e Icona
-- così da creare i set e le icone per i propri giochi,
-- aggiornare o rimuovere in caso di viste o ripensamenti
GRANT insert, update, delete ON SetIcone TO Gamecreator;
GRANT insert, update, delete ON Icona TO Gamecreator;

-- Select, Insert, Update e Delete su CasellaNumerica così
-- da poter creare caselle numeriche, aggiornarle
-- o rimuoverle in caso di sviste o ripensamenti.
GRANT select, insert, update, delete ON CasellaNumerica
TO Gamecreator;

-- Select, Insert, Update e Delete su Quiz così da creare
-- quiz per le caselle numeriche del gioco,
-- aggiornarli o rimuoverli in caso di sviste
-- o ripensamenti. 
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT select, insert, update, delete ON Quiz
--TO Gamecreator;

-- Insert e Update su Risposta così da creare le
-- risposte per i quiz del gioco, aggiornarle o
-- rimuoverle in caso di sviste o ripensamenti.
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT select, insert, update, delete ON Risposta
--TO Gamecreator;

-- Select, Insert, Update e Delete su Task così da creare i
-- task per le caselle numeriche, aggiornarle o
-- rimuoverle in caso di sviste o ripensamenti.
GRANT select, insert, update, delete ON Task
TO Gamecreator;

-------------------------Admin

-- Insert, Update e Delete su SfidaInfo e Sfida per
-- inserire sfide, aggiornarle o rimuoverle in caso
-- di sviste o ripensamenti
GRANT insert, update, delete ON Sfida TO Admin;
GRANT insert, update, delete ON SfidaInfo TO Admin;

-- Select su task per leggere, per esempio,
-- il testo del task di cui dovrà valutare le risposte
GRANT select ON Task TO Admin;

-- Select e Update su squadraCarica così da vedere
-- il file della squadra e dire mediante
-- l’attributo Corretta se la risposta della
-- squadra è corretta o meno
--(la relazione non compare nel carico
-- di lavoro, funzioni o trigger)
--GRANT select, update ON SquadraCarica TO Admin;



