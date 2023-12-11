DROP TABLE IF EXISTS JOUEUR;
CREATE TABLE JOUEUR(
NomJoueur VARCHAR(10) PRIMARY KEY,
ArgentJoueur INTEGER DEFAULT 100) ;

DROP TABLE IF EXISTS OBJET;
CREATE TABLE OBJET(
NomObjet VARCHAR(10) PRIMARY KEY,
TypeObjet VARCHAR(10),
Effet real,
CoutObjet INTEGER) ;

DROP TABLE IF EXISTS ENTITE;
CREATE TABLE ENTITE(
Nom VARCHAR(10) PRIMARY KEY,
PVmax INTEGER,
PVactuels INTEGER,
Attaque INTEGER,
Defense INTEGER,
LettreType CHAR(1) CHECK (LettreType IN ('M', 'A')));

DROP TABLE IF EXISTS SKILL;
CREATE TABLE SKILL (
NomSkill VARCHAR(10) PRIMARY KEY,
TypeSkill VARCHAR(10),
EffetSkill real);

DROP TABLE IF EXISTS ObjetAchete;
CREATE TABLE ObjetAchete(
NomJoueur VARCHAR(10) REFERENCES JOUEUR,
NomObjet VARCHAR(10) REFERENCES OBJET,
qte INTEGER NOT NULL,
PRIMARY KEY(NomJoueur, NomObjet),
FOREIGN KEY (NomJoueur) REFERENCES JOUEUR(NomJoueur),
FOREIGN KEY (NomObjet) REFERENCES OBJET(NomObjet));

DROP TABLE IF EXISTS MagazinPerso;
CREATE TABLE MagazinPerso(
Nom VARCHAR(10) REFERENCES ENTITE,
NomJoueur VARCHAR(10) REFERENCES Joueur,
CoutAllie INTEGER,
PRIMARY KEY(Nom, NomJoueur),
FOREIGN KEY (Nom) REFERENCES ENTITE(Nom),
FOREIGN KEY (NomJoueur) REFERENCES JOUEUR(NomJoueur));

DROP TABLE IF EXISTS PersoPossede;
CREATE TABLE PersoPossede(
NomJoueur VARCHAR(10) REFERENCES Joueur,
Nom VARCHAR(10) REFERENCES ENTITE,
PRIMARY KEY(NomJoueur,Nom),
FOREIGN KEY (NomJoueur) REFERENCES JOUEUR(NomJoueur),
FOREIGN KEY (Nom) REFERENCES ENTITE(Nom));

DROP TABLE IF EXISTS SkillEntite;
CREATE TABLE SkillEntite(
Nom VARCHAR(10) REFERENCES ENTITE,
NomSkill VARCHAR(10) REFERENCES SKILL,
PRIMARY KEY (Nom, NomSkill),
FOREIGN KEY (Nom) REFERENCES ENTITE(Nom),
FOREIGN KEY (NomSkill) REFERENCES SKILL(NomSkill));

DROP TABLE IF EXISTS Monstre;
CREATE TABLE Monstre(
Nom VARCHAR(10) REFERENCES ENTITE PRIMARY KEY,
ArgentDrop INTEGER,
IdMontre INTEGER,
FOREIGN KEY (Nom) REFERENCES ENTITE(Nom));

/* ========================= DEBUT TRIGGERS ========================= */

DROP TRIGGER if EXISTS AchatObjet;
CREATE TRIGGER AchatObjet
BEFORE UPDATE ON ObjetAchete
WHEN (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) >= ((SELECT CoutObjet FROM OBJET WHERE NomObjet = NEW.NomObjet) * (NEW.qte - OLD.qte))
BEGIN
   UPDATE ObjetAchete
   SET qte = qte + NEW.qte
   WHERE NomObjet = NEW.NomObjet;
   UPDATE JOUEUR
   SET ArgentJoueur = (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) - ((SELECT CoutObjet FROM OBJET WHERE NomObjet = NEW.NomObjet) * (NEW.qte - OLD.qte));
END;

DROP TRIGGER IF EXISTS AchatObjetRefuse;
CREATE TRIGGER AchatObjetRefuse
BEFORE UPDATE ON ObjetAchete
WHEN (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) < ((SELECT CoutObjet FROM OBJET WHERE NomObjet = NEW.NomObjet) * (NEW.qte - OLD.qte))
BEGIN
	SELECT CASE
		WHEN NEW.qte <> OLD.qte THEN
			RAISE (ABORT,"Vous n'avez pas assez d'argent.")
	END;
END;

DROP TRIGGER IF EXISTS AchatPersoRefuse;
CREATE TRIGGER AchatPersoRefuse
BEFORE INSERT ON PersoPossede
WHEN (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) < (SELECT CoutAllie FROM MagazinPerso WHERE NomJoueur = NEW.NomJoueur AND Nom = NEW.Nom)
BEGIN
	SELECT RAISE(ABORT,"Vous n'avez pas assez d'argent.");
END;

DROP TRIGGER IF EXISTS AchatPerso;
CREATE TRIGGER AchatPerso
BEFORE INSERT ON PersoPossede
WHEN (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) >= 
    (SELECT CoutAllie FROM MagazinPerso WHERE NomJoueur = NEW.NomJoueur AND Nom = NEW.Nom)
BEGIN
  UPDATE JOUEUR
  SET ArgentJoueur = (SELECT ArgentJoueur FROM JOUEUR WHERE NomJoueur = NEW.NomJoueur) - 
                    (SELECT CoutAllie FROM MagazinPerso WHERE NomJoueur = NEW.NomJoueur AND Nom = NEW.Nom);
END;

DROP TRIGGER IF EXISTS DebutCombat;
CREATE TRIGGER DebutCombat
AFTER UPDATE ON ENTITE
WHEN (SELECT COUNT(*) FROM ENTITE WHERE LettreType = 'M' AND PVMax = PVactuels) > 0
BEGIN
 UPDATE ENTITE
 SET PVactuels = PVMax
 WHERE Nom IN (
   SELECT Nom
   FROM PersoPossede
 );
END;
/* Le trigger en haut permet de débuter un combat, en assignant les PV Max en valeur de PV actuels pour chaque allié que le joueur possède, dès que un monstre a PV Max = PV actuels. (tout en bas)
Je sais pas si ça peut créer des problèmes ensuite, je suppose que oui mais on verra ça plus tard avec les combats. Normalement si le joueur attaque directement y a pas de problème.*/


/* ========================= FIN TRIGGERS  ========================= */

INSERT INTO SKILL
VALUES('Attaque Basique','Offensif',1),
('Boule Magique', 'Offensif', 1.2),
('Morsure', 'Offensif', 1.1),
('Soin', 'Soin', 20),
('Grand Soin', 'Soin', 50),
('Tres Grand Soin', 'Soin', 100);

INSERT INTO OBJET VALUES
('Talisman', 'Augmente_Vie', 0.1, 200), 
('Amulette', 'Augmente_Def', 0.2, 250), 
('Baton', 'Augmente_Atk', 0.2, 350);

INSERT INTO ENTITE VALUES
    ("Bertrand", 200,0, 35, 20, 'A'),
    ("Roseline", 150, 0, 45, 15, 'A'),
    ("Igor", 350, 0, 20, 45, 'A'),
    ("Giselle", 400, 0, 50, 50, 'A'),
    
    ("Loup", 100, 0, 30, 5, 'M'),
    ("Ogre", 200, 0, 40, 15, 'M'),
    ("Gobelin", 70, 0, 55, 3, 'M'),
    ("Blob", 50, 0, 10, 0, 'M'),
    ("Ours", 150, 0, 50, 20, 'M'),
    ("Sirene", 100, 0, 50, 10, 'M'),
    ("Dragon", 400, 0, 250, 90, 'M'),
    ("Cyclope", 250, 0, 100, 70, 'M');

INSERT INTO JOUEUR VALUES
    ("Player", 100);

INSERT INTO Monstre
VALUES('Blob',5,1),
('Gobelin',15,2),
('Loup',25,3),
('Sirene',35,4),
('Ours',50,5),
('Ogre',60,6),
('Cyclope',120,7),
('Dragon',250,8);

INSERT INTO SkillEntite
VALUES("Bertrand","Attaque Basique"),
("Roseline","Attaque Basique"),
("Igor","Attaque Basique"),
("Giselle","Attaque Basique"),
("Loup","Attaque Basique"),
("Ogre","Attaque Basique"),
("Gobelin","Attaque Basique"),
("Blob","Attaque Basique"),
("Ours","Attaque Basique"),
("Sirene","Attaque Basique"),
("Dragon","Attaque Basique"),
("Cyclope","Attaque Basique"),
("Bertrand","Soin"),
("Roseline","Soin"),
("Igor","Soin"),
("Giselle","Soin"),
("Bertrand","Grand Soin"),
("Roseline","Grand Soin"),
("Igor","Grand Soin"),
("Giselle","Grand Soin"),
("Igor","Tres Grand Soin"),
("Giselle","Tres Grand Soin"),
("Roseline","Boule Magique"),
("Giselle","Boule Magique"),
("Loup","Morsure"),
("Gobelin","Morsure"),
("Ours","Morsure"),
("Dragon","Morsure");

INSERT INTO ObjetAchete
VALUES("Player","Talisman",0),
("Player","Amulette",0),
("Player","Baton",0);

INSERT INTO MagazinPerso VALUES
	("Bertrand","Player",0),
	("Roseline","Player",1250),
	("Igor","Player",1500),
	("Giselle","Player",3000);
	
INSERT INTO PersoPossede VALUES
	("Player","Bertrand");
	
/* ===================== COMMANDES A RENTRER POUR JOUER : =====================

=== Début de combat ===
UPDATE ENTITE
SET PVactuels = PVMax
WHERE Nom IN (
  SELECT Nom
  FROM ENTITE
  WHERE LettreType = 'M'
  ORDER BY RANDOM()
  LIMIT 1
); 

Prend un monstre aléatoire et lui assigne la valeur de PVMax dans PVactuels, ce qui commence le combat. Le combat sera gérée par une vue qui n'affiche que les monstres et alliés ayant
des pv actuels supérieurs à 0, j'ai toujours pas fait ça.



=== Achat de perso ===
INSERT INTO PersoPossede VALUES
	("Player","[Nom du perso voulu]");

*/
