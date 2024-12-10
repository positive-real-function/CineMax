--php文件名：accueil.php
--作用 : Accueil de l'application (应用首页)
--此文件中没有SQL语句

--php文件名：addfilm.php
--作用 : Ajouter un film (添加电影)
INSERT INTO film (id_film, titre, date_sortie, duree, director, genre, nationalite)
VALUES (:id_film, :titre, :date_sortie, :duree, :director, :genre, :nationalite);

--php文件名：addseance.php
--作用 : Ajouter une séance (添加场次)
SELECT MAX(id_seance) AS max_id FROM seance;
INSERT INTO seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle)
VALUES (:id_seance, :h_debut, :h_fin, :prix, :langue, true, :play, :id_film, :id_salle);

--php文件名：annuler_reservation.php
--作用 : Annuler une Réservation (取消预订)
SELECT t.id_ticket
FROM ticket t
         JOIN client c ON t.id_client = c.id_client
         JOIN personne p ON c.id_personne = p.id_personne
WHERE t.id_ticket = ? AND p.id_personne = ?;
DELETE FROM ticket WHERE id_ticket = ?;

--php文件名：confirmation.php
--作用 : Confirmation de la réservation (预订确认)
SELECT t.id_ticket, t.date_crea, s.num_range, s.num_place, se.h_debut, se.h_fin, f.titre
FROM ticket t
         JOIN siege s ON t.id_siege = s.id_siege
         JOIN seance se ON t.id_seance = se.id_seance
         JOIN film f ON se.id_film = f.id_film
WHERE t.id_client = (
    SELECT id_client FROM client WHERE id_personne = ?
)
ORDER BY t.date_crea DESC
LIMIT 1;

--php文件名：connect.php
--作用 : Connexion à l'application (应用连接)
SELECT * FROM personne WHERE email = ?;

--php文件名：createAccount.php
--作用 : Créer un compte (创建账户)
SELECT COUNT(*) FROM personne WHERE email = :email;
SELECT COALESCE(MAX(id_personne), 0) + 1 AS next_id FROM personne;
INSERT INTO personne (id_personne, nom, prenom, sexe, p_login, p_mdp, email)
VALUES (:id_personne, :nom, :prenom, :sexe, :p_login, :p_mdp, :email);

--php文件名：createClient.php
--作用 : Créer un client (创建客户)
SELECT COALESCE(MAX(CAST(SUBSTRING(id_client FROM 5) AS INTEGER)), 0) + 1 AS next_id
FROM client;
INSERT INTO client (id_client, id_personne, birth, lvl)
VALUES (:id_client, :id_personne, :birth, :lvl);

--php文件名：delfilm.php
--作用 : Supprimer un film (删除电影)
DELETE FROM jouer WHERE id_film = :id_film;
DELETE FROM seance WHERE id_film = :id_film;
DELETE FROM film WHERE id_film = :id_film;

--php文件名：film_details.php
--作用 : Détails du film (电影详情)
SELECT * FROM film WHERE id_film = :id_film;

--php文件名：film.php
--作用 : Liste des films (电影列表)
SELECT id_film, titre FROM film;

--php文件名：goodbye.php
--作用 : Au revoir (再见)
--此文件中没有SQL语句

--php文件名：index.php
--作用 : Page d'accueil (首页)
--此文件中没有SQL语句

--php文件名：logout.php
--作用 : Déconnexion de l'application (应用注销)
--此文件中没有SQL语句

--php文件名：phpinfo.php
--作用 : Informations PHP (PHP信息)
--此文件中没有SQL语句

--php文件名：profile.php
--作用 : Profil utilisateur (用户资料)
SELECT p.nom, p.prenom, p.sexe, p.email, c.birth, c.date_insc
FROM personne p
         JOIN client c ON p.id_personne = c.id_personne
WHERE p.id_personne = :user_id;
UPDATE personne SET email = :email
WHERE id_personne = :user_id;
UPDATE personne SET email = :email, p_mdp = :p_mdp
WHERE id_personne = :user_id;
DELETE FROM ticket WHERE id_client IN (SELECT id_client FROM client WHERE id_personne = :user_id);
DELETE FROM client WHERE id_personne = :user_id;
DELETE FROM personne WHERE id_personne = :user_id;

--php文件名：reservation.php
--作用 : Réservation de place (座位预订)
SELECT s.id_siege, s.num_place, s.num_range
FROM siege s
         JOIN salle sa ON sa.id_salle = s.id_salle
         JOIN seance se ON se.id_salle = sa.id_salle
WHERE se.id_seance = ? AND s.st = 'F' AND s.type_p = ?;
SELECT id_client FROM client WHERE id_personne = ?;
INSERT INTO ticket (id_ticket, date_crea, date_expir, used, premium, id_siege, id_client, id_seance)
VALUES (?, ?, ?, ?, ?, ?, ?, ?);
UPDATE siege SET st = 'T' WHERE id_siege = ?;

--php文件名：reservations.php
--作用 : Mes Réservations (我的预订)
SELECT t.id_ticket, t.date_crea, t.date_expir, f.titre AS film_titre,
       se.h_debut, se.h_fin, s.num_place, s.num_range, sa.nom_s, c.nom_cin
FROM ticket t
         JOIN siege s ON t.id_siege = s.id_siege
         JOIN salle sa ON s.id_salle = sa.id_salle
         JOIN seance se ON t.id_seance = se.id_seance
         JOIN film f ON se.id_film = f.id_film
         JOIN cinema c ON sa.id_cinema = c.id_cinema
         JOIN client cl ON t.id_client = cl.id_client
WHERE cl.id_personne = ?
ORDER BY t.date_crea DESC;

--php文件名：seance.php
--作用 : Séances à venir (即将到来的场次)
SELECT seance.id_seance, seance.h_debut, seance.h_fin, seance.prix, seance.langue, seance.st,
       film.titre, film.genre, cinema.nom_cin, cinema.adresse,
       COUNT(siege.id_siege) AS total_sieges,
       COUNT(CASE WHEN siege.st = 'F' THEN 1 END) AS sieges_restants
FROM seance
         INNER JOIN film ON seance.id_film = film.id_film
         INNER JOIN salle ON seance.id_salle = salle.id_salle
         INNER JOIN cinema ON salle.id_cinema = cinema.id_cinema
         LEFT JOIN siege ON salle.id_salle = siege.id_salle
GROUP BY seance.id_seance, film.titre, film.genre, cinema.nom_cin, cinema.adresse, seance.h_debut, seance.h_fin, seance.prix, seance.langue
ORDER BY seance.h_debut ASC;

--php文件名：supseance.php
--作用 : Supprimer une séance (删除场次)
DELETE FROM ticket WHERE id_seance = :id_seance;
DELETE FROM seance WHERE id_seance = :id_seance;

--php文件名：users.php
--作用 : Gestion des utilisateurs (用户管理)
DELETE FROM client WHERE id_personne = :id_personne;
DELETE FROM employee WHERE id_personne = :id_personne;
DELETE FROM personne WHERE id_personne = :id_personne;
SELECT * FROM employee WHERE id_personne = :id_personne;
UPDATE employee SET lvl_acces = :lvl_acces, poste = :poste, id_cinema = :id_cinema WHERE id_personne = :id_personne;
INSERT INTO employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES (:id_employee, :id_personne, :poste, :lvl_acces, :id_cinema);
SELECT
    p.id_personne,
    p.nom,
    p.prenom,
    COALESCE(e.lvl_acces, 'Non défini') AS lvl_acces,
    e.poste,
    e.id_cinema
FROM personne p
         LEFT JOIN employee e ON p.id_personne = e.id_personne
ORDER BY p.nom, p.prenom;
SELECT id_cinema, nom_cin FROM cinema;