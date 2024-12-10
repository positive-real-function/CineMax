<?php
$title = "Données d'exploitation";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

// 获取每部电影的总收入
$query_revenu_films = "
    SELECT f.id_film, f.titre, SUM(s.prix) AS revenu
    FROM ticket t
             JOIN public.seance s ON s.id_seance = t.id_seance
             JOIN public.film f ON f.id_film = s.id_film
    GROUP BY f.id_film, f.titre
    ORDER BY revenu DESC
";
$revenu_films = $pdo->query($query_revenu_films)->fetchAll(PDO::FETCH_ASSOC);

// 获取最忠实客户（消费最多的前5名）
$query_meilleurs_clients = "
    SELECT t.id_client, p.nom, p.prenom,total.nb_seances AS nb, SUM(s.prix) AS prix_total
    FROM ticket t
             JOIN public.seance s ON s.id_seance = t.id_seance
             JOIN public.client c ON c.id_client = t.id_client
             JOIN public.personne p ON p.id_personne = c.id_personne
             JOIN (SELECT id_client,
                      COUNT(*) AS nb_seances
               FROM ticket
               GROUP BY id_client) total ON c.id_client = total.id_client
    GROUP BY t.id_client, p.nom, p.prenom, total.nb_seances
    ORDER BY prix_total DESC
    LIMIT 5
";
$meilleurs_clients = $pdo->query($query_meilleurs_clients)->fetchAll(PDO::FETCH_ASSOC);
?>

    <h1>Données d'exploitation</h1>

    <h2>Revenu par film</h2>
    <table border="1">
        <thead>
        <tr>
            <th>ID Film</th>
            <th>Titre</th>
            <th>Revenu (€)</th>
        </tr>
        </thead>
        <tbody>
        <?php foreach ($revenu_films as $film): ?>
            <tr>
                <td><?= htmlspecialchars($film['id_film']) ?></td>
                <td><?= htmlspecialchars($film['titre']) ?></td>
                <td><?= number_format($film['revenu'], 2, ',', ' ') ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

    <h2>Top 5 des clients les plus fidèles</h2>
    <table border="1">
        <thead>
        <tr>
            <th>ID Client</th>
            <th>Nom</th>
            <th>Prénom</th>
            <th>Nombres de seances</th>
            <th>Total Dépensé (€)</th>
        </tr>
        </thead>
        <tbody>
        <?php foreach ($meilleurs_clients as $client): ?>
            <tr>
                <td><?= htmlspecialchars($client['id_client']) ?></td>
                <td><?= htmlspecialchars($client['nom']) ?></td>
                <td><?= htmlspecialchars($client['prenom']) ?></td>
                <td><?= htmlspecialchars($client['nb']) ?></td>
                <td><?= number_format($client['prix_total'], 2, ',', ' ') ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

    <a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>