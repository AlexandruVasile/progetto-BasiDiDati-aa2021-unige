CREATE INDEX idxNrDadiMaxSquadre
ON Gioco(NrDadi, MaxSquadre);

CREATE INDEX idxGiocoIdSfida
ON Sfida(GiocoId);

CLUSTER Gioco USING idxNrDadiMaxSquadre;
CLUSTER Sfida USING idxGiocoIdSfida;
