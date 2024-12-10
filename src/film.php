<?php
$title = "Nos films";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

$stmt = $pdo->prepare("SELECT id_film, titre FROM film");
$stmt->execute();
$films = $stmt->fetchAll(PDO::FETCH_ASSOC);

?>


    <h1>Nos Films</h1>
    <h2>Reservez rapidement une seance grace a notre site</h2>
    <?php if ($films): ?>
        <ul>
            <?php foreach ($films as $film): ?>
                <li>
                    <a href="film_details.php?id_film=<?= htmlspecialchars($film['id_film']) ?>">
                        <?= htmlspecialchars($film['titre']) ?>
                    </a>
                </li>
            <?php endforeach; ?>
        </ul>
    <?php else: ?>
        <p>Aucun film disponible.</p>
    <?php endif; ?>

    <a href="accueil.php" class="back-link">Retour à l'accueil</a>
<?php
include_once "./util/footer.inc.php";
?>
