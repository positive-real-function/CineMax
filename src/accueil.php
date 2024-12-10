<?php
$title = "Bienvenue";
include_once "./util/header.inc.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

?>

    <h1>Bienvenue, <?= htmlspecialchars($_SESSION['user_nom']) ?> !</h1>
    <p>Vous êtes connecté.</p>
    <ul>
        <?php if (isset($_SESSION['user_role']) && $_SESSION['user_role'] !== 'M' && $_SESSION['user_role'] !== 'I' && $_SESSION['user_role'] !== 'N') : ?>
            <li><a href="film.php">Nos films</a></li>
            <li><a href="reservation.php">Faire une réservation</a></li>
            <li><a href="seance.php">Voir les séances</a></li>
        <?php endif; ?>
        <?php if (isset($_SESSION['user_role']) && ($_SESSION['user_role'] === 'M' || $_SESSION['user_role'] === 'N' ||  $_SESSION['user_role'] === 'I')) : ?>
            <li><a href="film.php">films</a></li>
            <li><a href="seance.php">séances</a></li>
            <li><a href="addseance.php">Aujouter un seance</a></li>
            <li><a href="supseance.php">Supprimer un seance</a></li>
            <li><a href="addfilm.php">Ajouter un film</a></li>
            <li><a href="delfilm.php">Supprimer un film</a></li>
        <?php if (isset($_SESSION['user_role']) && $_SESSION['user_role'] === 'M') : ?>
            <li><a href="users.php">Gestion des utilisateurs</a></li>
            <li><a href="donnee.php">Données</a></li>
        <?php endif; ?>
        <?php endif; ?>
    </ul>
    <a href="logout.php">Déconnexion</a>
<?php
include_once "./util/footer.inc.php";
?>
