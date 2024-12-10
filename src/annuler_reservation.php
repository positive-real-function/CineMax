<?php
$title = "Annuler une Réservation";
include_once "./util/header.inc.php";
require_once "./util/config.inc.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: connect.php');
    exit;
}

$user_id = $_SESSION['user_id'];

if (!isset($_POST['id_ticket'])) {
    die("Erreur : Aucun ticket sélectionné pour annulation.");
}

$id_ticket = $_POST['id_ticket'];
$erreur = "";

try {
    $stmt_check = $pdo->prepare("
        SELECT t.id_ticket
        FROM ticket t
        JOIN client c ON t.id_client = c.id_client
        JOIN personne p ON c.id_personne = p.id_personne
        WHERE t.id_ticket = ? AND p.id_personne = ?
    ");
    $stmt_check->execute([$id_ticket, $user_id]);
    
    if ($stmt_check->rowCount() == 0) {
        die("Erreur : Vous n'êtes pas le propriétaire de ce ticket ou ce ticket n'existe pas.");
    }

    $stmt_delete = $pdo->prepare("DELETE FROM ticket WHERE id_ticket = ?");
    $stmt_delete->execute([$id_ticket]);

    if ($stmt_delete->rowCount() > 0) {
        echo "<p>Votre réservation a bien été annulée.</p>";
        header("Location: reservations.php");
        exit;
    } else {
        $erreur = "La réservation n'a pas pu être annulée. Veuillez réessayer.";
    }
} catch (PDOException $e) {
    $erreur = "Erreur lors de l'annulation de la réservation : " . htmlspecialchars($e->getMessage());
}

?>

<h1>Annulation de Réservation</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?php echo $erreur; ?></p>
<?php endif; ?>

<a href="reservations.php" class="back-link">Retour aux réservations</a>

<?php include_once "./util/footer.inc.php"; ?>
