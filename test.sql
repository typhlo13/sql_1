CREATE TABLE JOUEUR(
NomJoueur VARCHAR(10) PRIMARY KEY,
ArgentJoueur INTEGER DEFAULT 100) ;

CREATE TABLE OBJET(
NomObjet VARCHAR(10) PRIMARY KEY,
TypeObjet VARCHAR(10),
Effet real,
CoutObjet INTEGER) ;

CREATE DOMAIN typeEntite
AS CHAR(1)
CHECK (VALUE IN ('M', 'A'));

CREATE TABLE ENTITE(Nom VARCHAR(10) PRIMARY KEY,
PVmax INTEGER,
Attaque INTEGER,
Defense INTEGER,
LettreType typeEntite);

CREATE TABLE SKILL (NomSkill VARCHAR(10) PRIMARY KEY,
TypeSkill VARCHAR(10),
EffetSkill real);

CREATE TABLE ObjetAchete(NomJoueur VARCHAR(10) REFERENCES JOUEUR,
NomObjet VARCHAR(10) REFERENCES OBJET,
qte INTEGER NOT NULL,
PRIMARY KEY(NomJoueur, NomObjet));

CREATE TABLE MagazinPerso(
Nom VARCHAR(10) REFERENCES ENTITE,
NomJoueur VARCHAR(10) REFERENCES Joueur,
CoutAllie INTEGER,
PRIMARY KEY(Nom, NomJoueur));

CREATE TABLE PersoPossede(
NomJoueur VARCHAR(10) REFERENCES Joueur,
Nom VARCHAR(10) REFERENCES ENTITE,
PRIMARY KEY(NomJoueur,Nom));

CREATE TABLE SkillEntite(Nom VARCHAR(10) REFERENCES ENTITE,
NomSkill VARCHAR(10) REFERENCES SKILL,
PRIMARY KEY (Nom, NomSkill));

CREATE TABLE Monstre(
Nom VARCHAR(10) REFERENCES ENTITE PRIMARY KEY,
ArgentDrop INTEGER);

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
    ("Bertrand", 200, 35, 20, 'A'),
    ("Roseline", 150, 45, 15, 'A'),
    ("Igor", 350, 20, 45, 'A'),
    ("Giselle", 400, 50, 50, 'A'),
    
    ("Loup", 100, 30, 5, 'M'),
    ("Ogre", 200, 40, 15, 'M'),
    ("Gobelin", 70, 55, 3, 'M'),
    ("Blob", 50, 10, 0, 'M'),
    ("Ours", 150, 50, 20, 'M'),
    ("Sirene", 100, 50, 10, 'M'),
    ("Dragon", 400, 250, 90, 'M'),
    ("Cyclope", 250, 100, 70, 'M');

INSERT INTO JOUEUR VALUES
    ("Player", 100);

INSERT INTO PersoPossede
VALUES('Player','Bertrand');

INSERT INTO Monstre
VALUES('Blob',5,1),
('Gobelin',15,2),
('Loup',25,3),
('Sirene',35,4),
('Ours',50,5),
('Ogre',60,6),
('Cyclope',120,7),
('Dragon',250,8);
