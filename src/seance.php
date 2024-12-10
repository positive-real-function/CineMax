<?php
$title = "Séances à venir";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

$stmt = $pdo->prepare("
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
    ORDER BY seance.h_debut ASC
");

$stmt->execute();
$seances = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<h1 class="page-title">Les prochaines séances</h1>

<?php if (count($seances) > 0): ?>
    <div class="seances-container">
        <?php foreach ($seances as $seance): ?>
            <div class="seance-card">
                <h2 class="film-title"><?= htmlspecialchars($seance['titre']) ?> <span class="film-genre">(<?= htmlspecialchars($seance['genre']) ?>)</span></h2>
                <div class="cinema-info">
                    <p><strong>Cinéma :</strong> <?= htmlspecialchars($seance['nom_cin']) ?></p>
                    <p><strong>Adresse :</strong> <?= htmlspecialchars($seance['adresse']) ?></p>
                </div>
                <div class="seance-details">
                    <p><strong>Début :</strong> <?= date('d/m/Y H:i', strtotime($seance['h_debut'])) ?> </p>
                    <p><strong>Fin :</strong> <?= date('d/m/Y H:i', strtotime($seance['h_fin'])) ?> </p>
                    <p><strong>Langue :</strong> <?= htmlspecialchars($seance['langue']) ?> </p>
                    <p><strong>Prix :</strong> <?= number_format($seance['prix'], 2, ',', ' ') ?> EUR</p>
                </div>
                <div class="seats-info">
                    <p><strong>Sièges restants :</strong> <?= $seance['sieges_restants'] ?> / <?= $seance['total_sieges'] ?></p>
                </div>
                <a class="reserve-button" href="reservation.php?id_seance=<?= htmlspecialchars($seance['id_seance']) ?>">Réserver une place</a>
            </div>
        <?php endforeach; ?>
    </div>
<?php else: ?>
    <p>Aucune séance à venir pour le moment.</p>
<?php endif; ?>

<a class="back-link" href="accueil.php">Retour à l'accueil</a>

<?php
include_once "./util/footer.inc.php";
?>
