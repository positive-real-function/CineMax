-- Table de base : personne
CREATE TABLE personne(
                         id_personne SERIAL PRIMARY KEY,
                         nom VARCHAR(50) NOT NULL,
                         prenom VARCHAR(50) NOT NULL,
                         sexe CHAR(1) CHECK (sexe = 'H' OR sexe = 'F'), -- H = homme, F = femme
                         p_login VARCHAR(50) NOT NULL,
                         p_mdp VARCHAR(255) NOT NULL,
                         email VARCHAR(100) CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$') -- format de type email
);


-- Table : client
CREATE TABLE client(
                       id_client CHAR(8) PRIMARY KEY CHECK (id_client ~* '^CLI-\d{4}$'),
                       id_personne SERIAL,
                       birth DATE NOT NULL,
                       CONSTRAINT check_birth CHECK (
                           birth BETWEEN '1900-01-01' AND CURRENT_DATE - INTERVAL '13 years'
                           ),
                       lvl CHAR(1) NOT NULL CHECK (lvl = 'V' OR lvl = 'N') DEFAULT 'N',
                       date_insc DATE DEFAULT CURRENT_DATE,
                       CONSTRAINT check_date_insc CHECK (
                           date_insc BETWEEN '1900-01-01' AND CURRENT_DATE
                           ),
                       CONSTRAINT CliFK FOREIGN KEY (id_personne) REFERENCES personne(id_personne)
);

-- Table : cinema
CREATE TABLE cinema(
                       id_cinema VARCHAR(8) PRIMARY KEY CHECK (id_cinema ~* '^CIN-[0-9]{4}$'), -- ex : CIN-7501
                       nom_cin VARCHAR(100) NOT NULL,
                       adresse VARCHAR(255) CHECK (adresse ~ '^[0-9]+[ ]+[A-Za-z ]+(St|Street|Ave|Avenue|Blvd|Boulevard|Rue|rue)?[ ]+[A-Za-z ]+$'), -- ex : 75 rue de la rue
                       tel VARCHAR(15) NOT NULL CHECK (tel ~ '^\+?[0-9\s\-()]+$'), -- ex: 0123456789 ou +33123456789
                       web VARCHAR(40) CHECK (web ~* '^(http|https)://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$') -- ex : http://www.ugc.fr
);

-- Table : salle
CREATE TABLE salle(
                      id_salle CHAR(8) PRIMARY KEY CHECK (id_salle ~* '^SAL-\d{4}$'),
                      nom_s VARCHAR(50) NOT NULL,
                      active BOOLEAN NOT NULL,
                      type_proj VARCHAR(50) NOT NULL,
                      capacite INT NOT NULL CHECK (capacite > 0),
                      id_cinema VARCHAR(8),
                      CONSTRAINT SalFK1 FOREIGN KEY (id_cinema) REFERENCES cinema(id_cinema)
);


-- Table : siege
CREATE TABLE siege(
                      id_siege CHAR(8) PRIMARY KEY CHECK (id_siege ~* '^SIE-\d{4}$'),
                      num_place INT NOT NULL,
                      num_range INT NOT NULL,
                      type_p CHAR(1) NOT NULL CHECK (type_p = 'N' OR type_p = 'V'),
                      st CHAR(1) NOT NULL CHECK (st = 'F' OR st = 'T'),
                      id_salle CHAR(8),
                      CONSTRAINT SieFk FOREIGN KEY (id_salle) REFERENCES salle(id_salle)
);


-- Table : employee
CREATE TABLE employee(
                         id_employee CHAR(8) PRIMARY KEY CHECK (id_employee ~* '^EMP-\d{4}$'), -- ex : EMP-4545
                         id_personne SERIAL,
                         poste VARCHAR(50) NOT NULL,
                         lvl_acces CHAR(1) NOT NULL CHECK (lvl_acces = 'M' OR lvl_acces = 'I' OR lvl_acces = 'N'), -- M = master, I = intermediate, N = normal
                         id_cinema VARCHAR(8),
                         CONSTRAINT EmpFK1 FOREIGN KEY (id_personne) REFERENCES personne(id_personne),
                         CONSTRAINT EmpFK2 FOREIGN KEY (id_cinema) REFERENCES cinema(id_cinema)
);




-- Table : film
CREATE TABLE film(
                     id_film CHAR(10) PRIMARY KEY CHECK (id_film ~* '^F-\d{8}$'), -- ex : F-12345678
                     titre VARCHAR(50) NOT NULL,
                     date_sortie DATE NOT NULL,
                     duree TIME NOT NULL,
                     director VARCHAR(100) NOT NULL,
                     genre VARCHAR(50),
                     nationalite CHAR(2) -- code ISO de la nationalitÃ© 'FR', 'EN', 'SP'
);


-- Table : acteur
CREATE TABLE acteur(
                       id_acteur CHAR(8) PRIMARY KEY CHECK (id_acteur ~* '^ACT-\d{4}$'),
                       nom VARCHAR(50) NOT NULL,
                       prenom VARCHAR(50) NOT NULL
);


-- Table : jouer
CREATE TABLE jouer(
                      id_film CHAR(10),
                      id_acteur CHAR(8),
                      CONSTRAINT jouer_pk PRIMARY KEY (id_film, id_acteur),
                      FOREIGN KEY (id_film) REFERENCES film(id_film),
                      FOREIGN KEY (id_acteur) REFERENCES acteur(id_acteur)
);


-- Table : seance
CREATE TABLE seance(
                       id_seance CHAR(8) PRIMARY KEY CHECK (id_seance ~* '^SEA-\d{4}$'),
                       h_debut TIMESTAMP NOT NULL,
                       h_fin TIMESTAMP NOT NULL,
                       prix FLOAT CHECK (prix > 0),
                       langue CHAR(2) NOT NULL,
                       st BOOLEAN NOT NULL,
                       play CHAR(1) NOT NULL CHECK (play = 'E' OR play = 'S' OR play = 'F'),
                       id_film CHAR(10),
                       id_salle CHAR(8),
                       CONSTRAINT SeaFK1 FOREIGN KEY (id_film) REFERENCES film(id_film),
                       CONSTRAINT SeaFK2 FOREIGN KEY (id_salle) REFERENCES salle(id_salle)
);



-- Table : ticket
CREATE TABLE ticket(
                       id_ticket CHAR(8) PRIMARY KEY CHECK (id_ticket ~* '^TIC-\d{4}$'),
                       date_crea TIMESTAMP NOT NULL,
                       date_expir TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '1 year',
                       used CHAR(1) NOT NULL CHECK (used = 'U' OR used = 'N') DEFAULT 'N',
                       premium CHAR(1) NOT NULL CHECK (premium = 'V' OR premium = 'N') DEFAULT 'N',
                       id_siege CHAR(8),
                       id_client CHAR(8),
                       id_seance CHAR(8),
                       CONSTRAINT TicFK1 FOREIGN KEY (id_siege) REFERENCES siege(id_siege),
                       CONSTRAINT TicFK2 FOREIGN KEY (id_client) REFERENCES client(id_client),
                       CONSTRAINT TicFk3 FOREIGN KEY (id_seance) REFERENCES seance(id_seance)
);


-- Table : machine
CREATE TABLE machine(
                        id_machine CHAR(8) PRIMARY KEY CHECK (id_machine ~* '^MAC-\d{4}$'),
                        fabricant VARCHAR(50) NOT NULL,
                        date_achat DATE DEFAULT CURRENT_DATE,
                        CONSTRAINT check_date_achat CHECK (date_achat BETWEEN '1900-01-01' AND CURRENT_DATE),
                        stat CHAR(1) CHECK (stat = 'W' OR stat = 'N') DEFAULT 'W',
                        id_salle CHAR(8),
                        FOREIGN KEY (id_salle) REFERENCES salle(id_salle)
);



-- Supprimer les tables avec dépendances
-- DROP TABLE jouer CASCADE;
-- DROP TABLE machine CASCADE;
-- DROP TABLE ticket CASCADE;
-- DROP TABLE siege CASCADE;
-- DROP TABLE seance CASCADE;
-- DROP TABLE salle CASCADE;
-- DROP TABLE film CASCADE;
-- DROP TABLE acteur CASCADE;
-- DROP TABLE client CASCADE;
-- DROP TABLE employee CASCADE;
-- DROP TABLE cinema CASCADE;
-- DROP TABLE personne CASCADE;




--personne
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (1, 'Dupont', 'Jean', 'H', 'jdupont', '$2y$10$G5/NkmzcL8mCpZJhhK9LXuFR64yXB/lnICmGt8Jpy.mruDlQ8ES.i', 'jean.dupont@example.com');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (4, 'Durand', 'Pierre', 'H', 'pdurand', '$2y$10$rHPoTTmK1PkcNFuK.pTSU.nSSaWu22SGlyktb1GASntIMXYW/idtK', 'pierre@mail.mail');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (5, 'Moreau', 'Julie', 'F', 'jmoreau', '$2y$10$adPTmascxk/AkooFG.BuMeaK.fdTU5PNVXGN2mGkBt1Yh5MJYtpiy', 'julie.moreau@example.com');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (9, 'Blanc', 'Emma', 'F', 'eblanc', 'emma123', 'emma.blanc@example.org');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (10, 'Girard', 'Nicolas', 'H', 'ngirard', '$2y$10$3BYu2sfGfEh0/RaHbBq0ruA4em7A1UpDIA0JmwRQazzpFtmVVMoB2', 'nicolas.girard@example.net');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (11, 'Fwala', 'Yvon', 'H', 'yveezy', 'yvon-z', 'yvon.fwala@example.com');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (12, 'Hedgehog', 'Shadow', 'H', 'shadow75', 'shadow-z', 'shadow.hedgehog@example.fr');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (13, 'el mafioso', 'el chapo', 'H', 'el chapo.el mafioso', '$2y$10$2R/lNf586YhEtjU9RbI6guzSdrxtx6Z2v84G03uMqzbcESEuW46f2', 'mail@mail.mail');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (14, 'cheballah', 'jawed', 'H', 'jawed.cheballah', '$2y$10$FI6uZqiPkvxbDAX1wkXwdeB6ijUx/Wsib9dEl0uow5NCAk1FtlVUO', 'jawed@gmail.com');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (15, 'kamil', 'ouatati', 'H', 'ouatati.kamil', '$2y$10$wGDgh05DqaSZdm372oj6IeTcx9csJC8sOm5dCkrHhK4O8SP8w8QPK', 'kamil@mail.mail');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (19, 'OUA', 'klz', 'H', 'klz.oua', '$2y$10$td4dnDJppSpH5qTOcYZH.u3ESAN7ZHTCHjLiVE4wwH6yhAA/bIHUC', 'pierre.dura@mail.mal');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (21, 'elfamoso', 'kamil', 'H', 'kamil.elfamoso', '$2y$10$AUjzX4S6Ck26qdGIQcazD.wLGBzA65kLzBaq3c6fE4C2yN5CF5Du6', 'il@mail.mail');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (22, 'JIN', 'Zhuoyuan', 'H', 'zhuoyuan.jin', '$2y$12$dSW4RuONoVhFdCqo/2VFQOycmQY6iLDJHIM79WTRZJOG8D./yMFLi', 'jzy@gmail.com');
INSERT INTO public.personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email) VALUES (23, 'Zhang', 'san', 'H', 'san.zhang', '$2y$12$i0hUa6D/YLS0n.co/NwT1OX9XuZMDG9c10uB/b6H24IyRcEjQa3Yy', 'zhangsan@gmail.com');


--cinema
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0001', 'UGC Cine Cite', '75 rue de Paris', '+33123456789', 'http://www.ugc.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0002', 'Gaumont Wilson', '30 Boulevard de Strasbourg', '+33567891234', 'http://www.gaumont.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0003', 'MK2 Bibliothèque', '162 Rue Tolbiac', '+33678901234', 'http://www.mk2.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0004', 'Cinéma du Panthéon', '13 Rue Victor Cousin', '+33167890123', 'http://www.pantheon.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0005', 'Le Louxor', '170 Boulevard Magenta', '+33234567890', 'http://www.louxor.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0006', 'Cinémathèque Française', '51 Rue de Bercy', '+33378901234', 'http://www.cinematheque.fr');
INSERT INTO public.cinema (id_cinema, nom_cin, adresse, tel, web) VALUES ('CIN-0007', 'Le Balzac', '1 Rue Balzac', '+33123456780', 'http://www.lebalzac.fr');


--employee
INSERT INTO public.employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES ('EMP-0001', 11, 'Caissier', 'M', 'CIN-0002');
INSERT INTO public.employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES ('EMP-0101', 12, 'Caissier', 'I', 'CIN-0001');
INSERT INTO public.employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES ('EMP-3641', 14, 'caissier', 'N', 'CIN-0001');
INSERT INTO public.employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES ('EMP-4671', 9, 'Responsable', 'M', 'CIN-0006');
INSERT INTO public.employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES ('EMP-4901', 1, 'Directeur', 'M', 'CIN-0005');


--client
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1001', 1, '1990-05-15', 'N', '2024-11-29');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1002', 11, '2002-03-11', 'V', '2024-11-29');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1005', 5, '1992-12-12', 'N', '2024-11-29');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1009', 9, '1993-11-03', 'N', '2024-11-29');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1010', 10, '1991-02-17', 'N', '2024-11-29');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1012', 21, '2000-03-21', 'N', '2024-12-09');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1013', 22, '2001-02-05', 'V', '2024-12-09');
INSERT INTO public.client (id_client, id_personne, birth, lvl, date_insc) VALUES ('CLI-1014', 23, '2005-06-07', 'N', '2024-12-10');


--acteur
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1001', 'DiCaprio', 'Leonardo');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1002', 'Page', 'Elliot');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1003', 'Smith', 'Will');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1004', 'Hanks', 'Tom');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1005', 'Pitt', 'Brad');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1006', 'Johansson', 'Scarlett');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1007', 'Bale', 'Christian');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1008', 'Damon', 'Matt');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1009', 'Gosling', 'Ryan');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1010', 'Streep', 'Meryl');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1011', 'Lawrence', 'Jennifer');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1012', 'Cruz', 'Penélope');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1013', 'Theron', 'Charlize');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1014', 'McConaughey', 'Matthew');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1015', 'Paltrow', 'Gwyneth');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1016', 'Gyllenhaal', 'Jake');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1017', 'Portman', 'Natalie');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1018', 'Chalamet', 'Timothée');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1019', 'Kidman', 'Nicole');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1020', 'Cumberbatch', 'Benedict');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1021', 'Watts', 'Naomi');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1022', 'Crowe', 'Russell');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1023', 'Depp', 'Johnny');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1024', 'Watson', 'Emma');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1025', 'Saldana', 'Zoe');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1026', 'Ramirez', 'Diego');
INSERT INTO public.acteur (id_acteur, nom, prenom) VALUES ('ACT-1027', 'Wahlberg', 'Mark');


--film
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000001', 'Inception', '2010-07-16', '02:28:00', 'Christopher Nolan', 'Science-fiction', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000002', 'Parasite', '2019-05-30', '02:12:00', 'Bong Joon-ho', 'Thriller', 'KR');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000003', 'Avatar', '2009-12-18', '02:42:00', 'James Cameron', 'Action', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000004', 'Le Roi Lion', '1994-06-15', '01:28:00', 'Roger Allers', 'Animation', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000005', 'Titanic', '1997-12-19', '03:14:00', 'James Cameron', 'Romance', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000006', 'Amélie', '2001-04-25', '02:02:00', 'Jean-Pierre Jeunet', 'Comédie', 'FR');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000007', 'Interstellar', '2014-11-07', '02:49:00', 'Christopher Nolan', 'Science-fiction', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000009', 'Joker', '2019-10-04', '02:02:00', 'Todd Phillips', 'Drame', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000010', 'The Dark Knight', '2008-07-18', '02:32:00', 'Christopher Nolan', 'Action', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000011', 'Sonic 3', '2024-02-01', '01:49:00', 'Jeff Fowler', 'Aventure', 'US');
INSERT INTO public.film (id_film, titre, date_sortie, duree, director, genre, nationalite) VALUES ('F-00000012', 'Juré 2', '2000-01-21', '03:02:00', 'elGrandeToto', 'Action', 'AM');


--salle
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0001', 'Salle 1', true, 'IMAX', 200, 'CIN-0005');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0002', 'Salle 2', true, 'Standard', 150, 'CIN-0003');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0003', 'Salle principale', true, 'Standard', 150, 'CIN-0001');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0004', 'Salle principale', true, 'Standard', 150, 'CIN-0002');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0005', 'Salle principale', true, 'Standard', 150, 'CIN-0004');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0006', 'Salle principale', true, 'Standard', 150, 'CIN-0006');
INSERT INTO public.salle (id_salle, nom_s, active, type_proj, capacite, id_cinema) VALUES ('SAL-0007', 'Salle principale', true, 'Standard', 150, 'CIN-0007');


--seance
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0001', '2024-12-11 15:00:00.000000', '2024-12-11 17:28:00.000000', 12.5, 'EN', true, 'F', 'F-00000001', 'SAL-0001');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0002', '2028-11-26 18:00:00.000000', '2028-11-26 20:12:00.000000', 10, 'KR', true, 'S', 'F-00000002', 'SAL-0002');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0003', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 13.811911013448725, 'FR', true, 'S', 'F-00000001', 'SAL-0003');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0004', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 12.807633211756999, 'FR', true, 'S', 'F-00000002', 'SAL-0004');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0005', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 14.845214265923, 'FR', true, 'S', 'F-00000003', 'SAL-0005');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0006', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 12.611335996901987, 'FR', true, 'S', 'F-00000004', 'SAL-0006');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0007', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 16.675325474783786, 'FR', true, 'S', 'F-00000005', 'SAL-0007');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0008', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 14.504212489381407, 'FR', true, 'S', 'F-00000006', 'SAL-0001');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0009', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 15.806977224697423, 'FR', true, 'S', 'F-00000007', 'SAL-0002');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0011', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 14.87594612906639, 'FR', true, 'S', 'F-00000009', 'SAL-0003');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0012', '2028-11-28 00:04:00.609525', '2028-11-28 01:04:00.609525', 15.48118630493896, 'FR', true, 'S', 'F-00000010', 'SAL-0004');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0013', '2024-12-11 20:00:00.000000', '2024-12-11 20:42:00.000000', 12.8, 'EN', true, 'S', 'F-00000003', 'SAL-0001');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0014', '2024-12-10 10:10:00.000000', '2024-12-10 12:52:00.000000', 12.8, 'EN', true, 'E', 'F-00000003', 'SAL-0002');
INSERT INTO public.seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle) VALUES ('SEA-0015', '2024-12-10 10:10:00.000000', '2024-12-10 12:52:00.000000', 12.8, 'EN', true, 'E', 'F-00000003', 'SAL-0002');


--machine
INSERT INTO public.machine (id_machine, fabricant, date_achat, stat, id_salle) VALUES ('MAC-1001', 'Sony', '2023-06-15', 'W', 'SAL-0001');
INSERT INTO public.machine (id_machine, fabricant, date_achat, stat, id_salle) VALUES ('MAC-1002', 'Parasonic', '2024-11-30', 'W', 'SAL-0001');


--jour
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1001');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1002');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1003');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1004');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1005');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1006');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1007');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1008');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1009');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1010');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1011');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1012');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1013');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1014');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1015');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1016');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1017');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1018');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1019');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1020');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1021');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1022');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1023');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1024');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1025');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1026');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000001', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000002', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000003', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000004', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000005', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000006', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000007', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000009', 'ACT-1027');
INSERT INTO public.jouer (id_film, id_acteur) VALUES ('F-00000010', 'ACT-1027');


--siege
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0001', 1, 1, 'V', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0002', 2, 1, 'V', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0003', 1, 2, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0004', 1, 1, 'V', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0005', 1, 2, 'V', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0006', 1, 3, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0007', 1, 4, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0008', 1, 5, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0009', 2, 1, 'N', 'F', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0010', 2, 2, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0011', 2, 3, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0012', 2, 4, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0013', 2, 5, 'N', 'F', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0014', 3, 1, 'N', 'F', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0015', 3, 2, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0016', 3, 3, 'N', 'F', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0017', 3, 4, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0018', 3, 5, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0019', 4, 1, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0020', 4, 2, 'N', 'F', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0021', 4, 3, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0022', 4, 4, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0023', 4, 5, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0024', 5, 1, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0025', 5, 2, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0026', 5, 3, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0027', 5, 4, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0028', 5, 5, 'N', 'T', 'SAL-0001');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0029', 1, 1, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0030', 1, 2, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0031', 1, 3, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0032', 1, 4, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0033', 1, 5, 'V', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0034', 2, 1, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0035', 2, 2, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0036', 2, 3, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0037', 2, 4, 'N', 'F', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0038', 2, 5, 'N', 'F', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0039', 3, 1, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0040', 3, 2, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0041', 3, 3, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0042', 3, 4, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0043', 3, 5, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0044', 4, 1, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0045', 4, 2, 'N', 'F', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0046', 4, 3, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0047', 4, 4, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0048', 4, 5, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0049', 5, 1, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0050', 5, 2, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0051', 5, 3, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0052', 5, 4, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0053', 5, 5, 'N', 'T', 'SAL-0002');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0054', 1, 1, 'V', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0055', 1, 2, 'V', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0056', 1, 3, 'V', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0057', 1, 4, 'V', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0058', 1, 5, 'V', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0059', 2, 1, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0060', 2, 2, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0061', 2, 3, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0062', 2, 4, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0063', 2, 5, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0064', 3, 1, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0065', 3, 2, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0066', 3, 3, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0067', 3, 4, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0068', 3, 5, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0069', 4, 1, 'N', 'T', 'SAL-0003');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0070', 4, 2, 'V', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0071', 4, 3, 'V', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0072', 4, 4, 'V', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0073', 4, 5, 'V', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0074', 5, 1, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0075', 5, 2, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0076', 5, 3, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0077', 5, 4, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0078', 5, 5, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0079', 1, 1, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0080', 1, 2, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0081', 1, 3, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0082', 1, 4, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0083', 1, 5, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0084', 2, 1, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0085', 2, 2, 'N', 'T', 'SAL-0004');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0086', 2, 3, 'V', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0087', 2, 4, 'V', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0088', 2, 5, 'V', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0089', 3, 1, 'V', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0090', 3, 2, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0091', 3, 3, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0092', 3, 4, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0093', 3, 5, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0094', 4, 1, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0095', 4, 2, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0096', 4, 3, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0097', 4, 4, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0098', 4, 5, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0099', 5, 1, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0100', 5, 2, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0101', 5, 3, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0102', 5, 4, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0103', 5, 5, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0104', 1, 1, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0105', 1, 2, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0106', 1, 3, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0107', 1, 4, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0108', 1, 5, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0109', 2, 1, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0110', 2, 2, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0111', 2, 3, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0112', 2, 4, 'N', 'T', 'SAL-0005');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0113', 2, 5, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0114', 3, 1, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0115', 3, 2, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0116', 3, 3, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0117', 3, 4, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0118', 3, 5, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0119', 4, 1, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0120', 4, 2, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0121', 4, 3, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0122', 4, 4, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0123', 4, 5, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0124', 5, 1, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0125', 5, 2, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0126', 5, 3, 'V', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0127', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0128', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0129', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0130', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0131', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0132', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0133', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0134', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0135', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0136', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0137', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0138', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0139', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0140', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0141', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0142', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0143', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0144', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0145', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0146', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0147', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0148', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0149', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0150', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0151', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0152', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0153', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0154', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0155', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0156', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0157', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0158', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0159', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0160', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0161', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0162', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0163', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0164', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0165', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0166', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0167', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0168', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0169', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0170', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0171', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0172', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0173', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0174', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0175', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0176', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0177', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0178', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0179', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0180', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0181', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0182', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0183', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0184', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0185', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0186', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0187', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0188', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0189', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0190', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0191', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0192', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0193', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0194', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0195', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0196', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0197', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0198', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0199', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0200', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0201', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0202', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0203', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0204', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0205', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0206', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0207', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0208', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0209', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0210', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0211', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0212', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0213', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0214', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0215', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0216', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0217', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0218', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0219', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0220', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0221', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0222', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0223', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0224', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0225', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0226', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0227', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0228', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0229', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0230', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0231', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0232', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0233', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0234', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0235', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0236', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0237', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0238', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0239', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0240', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0241', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0242', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0243', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0244', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0245', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0246', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0247', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0248', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0249', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0250', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0251', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0252', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0253', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0254', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0255', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0256', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0257', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0258', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0259', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0260', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0261', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0262', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0263', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0264', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0265', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0266', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0267', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0268', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0269', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0270', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0271', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0272', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0273', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0274', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0275', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0276', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0277', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0278', 5, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0279', 1, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0280', 1, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0281', 1, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0282', 1, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0283', 1, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0284', 2, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0285', 2, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0286', 2, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0287', 2, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0288', 2, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0289', 3, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0290', 3, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0291', 3, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0292', 3, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0293', 3, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0294', 4, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0295', 4, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0296', 4, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0297', 4, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0298', 4, 5, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0299', 5, 1, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0300', 5, 2, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0301', 5, 3, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0302', 5, 4, 'N', 'T', 'SAL-0006');
INSERT INTO public.siege (id_siege, num_place, num_range, type_p, st, id_salle) VALUES ('SIE-0303', 5, 5, 'N', 'T', 'SAL-0006');


INSERT INTO public.ticket (id_ticket, date_crea, date_expir, used, premium, id_siege, id_client, id_seance) VALUES ('TIC-0001', '2024-12-10 01:58:59.000000', '2025-12-10 01:58:59.000000', 'N', 'N', 'SIE-0009', 'CLI-1013', 'SEA-0013');
INSERT INTO public.ticket (id_ticket, date_crea, date_expir, used, premium, id_siege, id_client, id_seance) VALUES ('TIC-0002', '2024-12-10 01:59:24.000000', '2025-12-10 01:59:24.000000', 'N', 'N', 'SIE-0016', 'CLI-1013', 'SEA-0001');
INSERT INTO public.ticket (id_ticket, date_crea, date_expir, used, premium, id_siege, id_client, id_seance) VALUES ('TIC-0003', '2024-12-10 09:02:34.000000', '2025-12-10 09:02:34.000000', 'U', 'N', 'SIE-0037', 'CLI-1009', 'SEA-0014');
