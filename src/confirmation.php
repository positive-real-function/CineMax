<?php
$title = "Confirmation";
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

try {
    $stmt = $pdo->prepare("
        SELECT t.id_ticket, t.date_crea, s.num_range, s.num_place, se.h_debut, se.h_fin, f.titre
        FROM ticket t
        JOIN siege s ON t.id_siege = s.id_siege
        JOIN seance se ON t.id_seance = se.id_seance
        JOIN film f ON se.id_film = f.id_film
        WHERE t.id_client = (
            SELECT id_client FROM client WHERE id_personne = ?
        )
        ORDER BY t.date_crea DESC
        LIMIT 1
    ");
    $stmt->execute([$user_id]);
    $ticket = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$ticket) {
        throw new Exception("Aucun ticket trouvé pour cet utilisateur.");
    }
} catch (Exception $e) {
    $erreur = "Erreur : " . htmlspecialchars($e->getMessage());
}
?>

<h1>Confirmation de votre réservation</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?php echo $erreur; ?></p>
<?php else: ?>
    <p>Merci pour votre réservation ! Voici les détails de votre ticket :</p>
    <ul>
        <li><strong>Numéro de ticket :</strong> <?php echo htmlspecialchars($ticket['id_ticket']); ?></li>
        <li><strong>Film :</strong> <?php echo htmlspecialchars($ticket['titre']); ?></li>
        <li><strong>Heure de la séance :</strong> <?php echo htmlspecialchars($ticket['h_debut']); ?> - <?php echo htmlspecialchars($ticket['h_fin']); ?></li>
        <li><strong>Siège :</strong> Rangée <?php echo htmlspecialchars($ticket['num_range']); ?>, Place <?php echo htmlspecialchars($ticket['num_place']); ?></li>
    </ul>

    <p><a href="accueil.php" class="back-link">Retour à l'accueil</a></p>
<?php endif; ?>

<?php
include_once "./util/footer.inc.php";
?>

