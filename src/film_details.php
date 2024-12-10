<?php
$title = $_GET['id_film'] ?? 'Détails du film';
include_once('./util/header.inc.php');
require_once('./util/config.inc.php');

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

if (!isset($_GET['id_film'])) {
    header('Location: film.php');
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM film WHERE id_film = :id_film");
$stmt->bindParam(':id_film', $_GET['id_film'], PDO::PARAM_STR);
$stmt->execute();

$film_detail = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$film_detail) {
    echo "<p>Film introuvable.</p>";
    exit;
}
?>

<h1>Détails sur le film sélectionné</h1>

<table border="1">
    <tr>
        <th>Titre</th>
        <td><?= htmlspecialchars($film_detail['titre']) ?></td>
    </tr>
    <tr>
        <th>Réalisateur</th>
        <td><?= htmlspecialchars($film_detail['director']) ?></td>
    </tr>
    <tr>
        <th>Date de sortie</th>
        <td><?= htmlspecialchars($film_detail['date_sortie']) ?></td>
    </tr>
    <tr>
        <th>Durée</th>
        <td><?= htmlspecialchars($film_detail['duree']) ?></td>
    </tr>
    <tr>
        <th>Genre</th>
        <td><?= htmlspecialchars($film_detail['genre']) ?></td>
    </tr>
</table>

<form action="reservation.php" method="get">
    <input type="hidden" name="id_film" value="<?= htmlspecialchars($film_detail['id_film']) ?>">
    <button type="submit">Réserver</button>
</form>

<?php include_once("./util/footer.inc.php"); ?>
