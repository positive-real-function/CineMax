<?php
$title = "Au revoir";
include_once "./util/header.inc.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

session_destroy();

?>

<h1>Votre compte a été supprimé</h1>

<p>Nous sommes désolés de vous voir partir. Votre compte a été supprimé avec succès. Si vous avez changé d'avis, vous devrez créer un nouveau compte pour accéder à nos services.</p>

<p><a href="connect.php">Cliquez ici pour vous reconnecter</a> ou <a href="accueil.php">retourner à l'accueil</a>.</p>

<?php
include_once "./util/footer.inc.php";
?>
