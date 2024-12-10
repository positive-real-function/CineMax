-- verifiez le ticket
-- selection duree de projection de ticket donnee
--给定ticket查询电影放映时间段
SELECT s.h_debut,s.h_fin
FROM ticket t
         JOIN public.seance s on s.id_seance = t.id_seance
where t.id_ticket=:id_ticket;

--verifier le ticket si deja utilise
--查看电影票是否已经使用 N 表示未使用 U 表示已经使用
SELECT t.used
FROM ticket t
WHERE id_ticket=:id_ticket;

--显示场次座位信息，表示欢迎
SELECT f.titre,s.h_debut,s.h_fin,f.duree,sa.nom_s,si.num_range,si.num_place
FROM ticket t
         JOIN public.siege si on si.id_siege = t.id_siege
         JOIN public.salle sa on sa.id_salle = si.id_salle
         JOIN public.seance s on s.id_seance = t.id_seance
         JOIN public.film f on f.id_film = s.id_film
WHERE t.id_ticket=:id_ticket;



-- Sélection des informations sur les séances d'un film particulier qui ne sont pas en cours.
-- 删选特定电影未放映的场次
-- Remplacez 'F-00000001' par l'ID du film concerné.
SELECT film.titre,
       seance.h_debut,
       seance.h_fin,
       seance.prix,
       seance.langue,
       seance.st   AS sous_titres,
       seance.play AS type_projection
FROM seance
         JOIN film on seance.id_film = film.id_film
WHERE seance.id_film = :id_film
  AND CURRENT_TIMESTAMP < seance.h_debut;



-- Sélection de tous les billets en joignant naturellement les tables Siege, Salle et Cinema,
-- filtrant les résultats pour inclure uniquement les billets avec un statut d'utilisation en 'Utilise'.
-- 筛选已使用的票
SELECT ticket.id_ticket,
       ticket.date_crea,
       ticket.date_expir,
       ticket.used    AS statut_utilisation,
       siege.id_siege,
       siege.num_place,
       siege.num_range,
       salle.id_salle,
       salle.nom_s    AS nom_salle,
       cinema.id_cinema,
       cinema.nom_cin AS nom_cinema
FROM ticket
         NATURAL JOIN siege
         NATURAL JOIN salle
         NATURAL JOIN cinema
WHERE ticket.used = 'N';
-- 'U' est utilisé ici pour représenter le statut 'Utilisé'.


-- Sélection des identifiants des sièges disponibles (statut = 'Libre') pour une séance spécifique.
-- 筛选特定场次中可用座位
-- Remplacez 'SEA0001' par l'ID de la séance concernée.
SELECT sa.nom_s, s.id_siege, s.num_place, s.num_range
FROM siege s
         JOIN salle sa ON sa.id_salle = s.id_salle
         JOIN seance se ON se.id_salle = sa.id_salle
WHERE se.id_seance = :id_seance
  AND s.st = 'T'
  AND s.type_p = : N_OU_V
ORDER BY id_siege;
--F:occupé T:disponible
--N:normale V:VIP

-- Sélection des détails des billets achetés par un client spécifique, incluant l'identifiant du billet, le titre du film, le nom du cinéma, le nom de la salle, l'heure de projection, le numéro du siège et le statut d'utilisation du billet.
-- 获取某客户已购买票的详情
-- Remplacez 'CLI-1001' par l'ID du client concerné.
SELECT t.id_ticket,
       film.titre      AS titre_film,
       cinema.nom_cin  AS nom_cinema,
       salle.nom_s     AS nom_salle,
       seance.h_debut  AS heure_projection,
       siege.num_place AS numero_place,
       siege.num_range AS numero_range,
       t.used          AS statut_utilisation
FROM ticket t
         JOIN
     siege ON t.id_siege = siege.id_siege
         JOIN
     salle ON siege.id_salle = salle.id_salle
         JOIN
     seance ON t.id_seance = seance.id_seance
         JOIN
     film ON seance.id_film = film.id_film
         JOIN
     cinema ON salle.id_cinema = cinema.id_cinema
WHERE t.id_client = :id_client;


-- Sélection du statut d'utilisation et de la date d'expiration d'un ticket spécifique.
-- 查询特定票的状态和到期日期
-- Remplacez 'TIC-1001' par l'ID du ticket concerné.
SELECT used       AS statut_utilisation,
       date_expir AS date_expiration
FROM ticket
WHERE id_ticket = 'TIC-1001';



--Permet de récupérer les séances en cours dans tous les cinémas (Entre maintenant et 2 jours pour faciliter nos chances de trouver un film en cours)
-- 获取未来两天内放映的电影
SELECT seance.id_seance,
       film.titre     AS titre_film,
       cinema.nom_cin AS nom_cinema,
       seance.h_debut AS heure_debut,
       seance.h_fin   AS heure_fin,
       seance.prix,
       seance.langue,
       seance.st      AS sous_titres,
       seance.play    AS type_projection
FROM seance
         INNER JOIN
     film ON seance.id_film = film.id_film
         INNER JOIN
     salle ON seance.id_salle = salle.id_salle
         INNER JOIN
     cinema ON salle.id_cinema = cinema.id_cinema
WHERE seance.h_debut BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '2 days'
  AND seance.h_debut <= seance.h_fin;
-- Assurez-vous que la séance est bien en cours


--Permet de récupérer le chiffre d'affaire total de chaque flim et classé par ordre décroisant
-- 获取每部电影的总收入
SELECT f.id_film,f.titre,SUM(s.prix) AS revenu
FROM ticket t
         JOIN public.seance s on s.id_seance = t.id_seance
         JOIN public.film f on f.id_film = s.id_film
GROUP BY f.id_film,f.titre
ORDER BY revenu DESC ;


--Permet de récupérer les clients les plus fidèles (ceux qui ont dépensé le plus) et trie par
-- ordre décroissant sur notre site nous récupérons seulement le top 5
-- 获取最忠实客户（消费最多的前5名）
SELECT t.id_client, p.nom, p.prenom, SUM(s.prix) as prix_total
FROM ticket t
         JOIN public.seance s on s.id_seance = t.id_seance
         JOIN public.client c on c.id_client = t.id_client
         JOIN public.personne p on p.id_personne = c.id_personne
GROUP BY t.id_client, p.nom, p.prenom
ORDER BY prix_total
LIMIT 5;



-- Trouver l’utilisateur ayant regardé le plus grand nombre de séances de films et afficher ses informations.
-- 找出观看电影场次最多的用户，并查看信息
SELECT c.id_client,
       p.nom            AS nom_client,
       p.prenom         AS prenom_client,
       total.nb_seances AS total_seances
FROM personne p
         JOIN client c ON p.id_personne = c.id_personne
         JOIN (SELECT id_client,
                      COUNT(*) AS nb_seances
               FROM ticket
               GROUP BY id_client) total ON c.id_client = total.id_client
ORDER BY nb_seances DESC
LIMIT 1;


-- Permet de récupérer les tickets dont le statut est "Problème", c'est seulement du côté Réseau que ce statut peut survenir
-- 筛选状态为”问题”的票
SELECT ticket.id_ticket,
       ticket.date_crea,
       ticket.date_expir,
       ticket.used,
       ticket.premium,
       siege.num_place,
       siege.num_range,
       salle.nom_s    AS nom_salle,
       cinema.nom_cin AS nom_cinema
FROM ticket
         INNER JOIN
     siege ON ticket.id_siege = siege.id_siege
         INNER JOIN
     salle ON siege.id_salle = salle.id_salle
         INNER JOIN
     cinema ON salle.id_cinema = cinema.id_cinema
WHERE ticket.used = 'N';
-- Seulement les billets non utilisés

--AND ticket.statut = 'Problème';  -- Filtrer par le statut "Problème"


--Permet de savoir pour un client donné, combien d'argent il a dépensé au total sur notre site internet
-- 统计某客户的总消费金额
SELECT client.id_client,
       personne.nom     AS nom_client,
       personne.prenom  AS prenom_client,
       SUM(seance.prix) AS total_depense
FROM ticket
         JOIN
     client ON ticket.id_client = client.id_client
         JOIN
     personne ON client.id_personne = personne.id_personne
         JOIN
     siege ON ticket.id_siege = siege.id_siege
         JOIN
     salle ON siege.id_salle = salle.id_salle
         JOIN
     seance ON salle.id_salle = seance.id_salle
WHERE client.id_client = 'CLI-1001' -- Remplacez par l'ID du client spécifique
GROUP BY client.id_client, personne.nom, personne.prenom;


--Lister les films d'un certain genre
-- 列出某一类型的电影
SELECT titre, date_sortie, duree, director
FROM film
WHERE genre = 'Action';


--Afficher les informations de tous les cinémas avec leurs salles et capacité
--显示所有电影院的信息，包括名称、地址、电话以及其包含的影厅和每个影厅的座位容量
SELECT c.nom_cin, c.adresse, c.tel, s.nom_s, s.capacite
FROM cinema c
         JOIN salle s ON c.id_cinema = s.id_cinema;

--Lister les clients avec leur niveau (niveau normal ou VIP)
--打印客户列表
SELECT p.nom, p.prenom, c.lvl, c.date_insc
FROM client c
         JOIN personne p ON c.id_personne = p.id_personne;

--Obtenir le nombre de sièges disponibles pour une séance spécifique
SELECT COUNT(s.id_siege) AS nb_sieges_disponibles
FROM siege s
WHERE s.id_salle = :id_salle  --SAL-0001
  AND s.st = 'T';


--Liste des films joués par un acteur spécifique
--演员演的电影列表
SELECT f.titre, f.date_sortie
FROM film f
         JOIN jouer j ON f.id_film = j.id_film
WHERE j.id_acteur = :id_acteur; --'ACT-1001'

--Afficher les machines présentes dans une salle spécifique
SELECT m.id_machine, m.fabricant, m.date_achat, m.stat
FROM machine m
WHERE m.id_salle = 'SAL-0001';


--Récupérer les employés ayant un niveau d'accès "Master" dans un cinéma spécifique
--查询某个特定电影院中具有“Master”级别访问权限的员工及其职位
SELECT p.nom, p.prenom, e.poste
FROM employee e
         JOIN personne p ON e.id_personne = p.id_personne
WHERE e.id_cinema = 'CIN-0002'
  AND e.lvl_acces = 'M';






SELECT t.id_client, p.nom, p.prenom,total.nb_seances, SUM(s.prix) AS prix_total
FROM ticket t
         JOIN public.seance s ON s.id_seance = t.id_seance
         JOIN public.client c ON c.id_client = t.id_client
         JOIN public.personne p ON p.id_personne = c.id_personne
         JOIN (SELECT id_client,
                      COUNT(*) AS nb_seances
               FROM ticket
               GROUP BY id_client) total ON c.id_client = total.id_client
GROUP BY t.id_client, p.nom, p.prenom,total.nb_seances
ORDER BY prix_total DESC
LIMIT 5



