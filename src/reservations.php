<?php
$title = "Mes Réservations";
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
$erreur = "";

try {
    $stmt = $pdo->prepare("
        SELECT t.id_ticket, t.date_crea, t.date_expir, f.titre AS film_titre, 
               se.h_debut, se.h_fin, s.num_place, s.num_range, sa.nom_s, c.nom_cin
        FROM ticket t
        JOIN siege s ON t.id_siege = s.id_siege
        JOIN salle sa ON s.id_salle = sa.id_salle
        JOIN seance se ON t.id_seance = se.id_seance
        JOIN film f ON se.id_film = f.id_film
        JOIN cinema c ON sa.id_cinema = c.id_cinema
        JOIN client cl ON t.id_client = cl.id_client
        WHERE cl.id_personne = ?  -- On filtre par id_personne
        ORDER BY t.date_crea DESC
    ");
    $stmt->execute([$user_id]);

    $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $erreur = "Erreur lors de la récupération des réservations : " . htmlspecialchars($e->getMessage());
}

?>

<h1>Mes Réservations</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?php echo $erreur; ?></p>
<?php endif; ?>

<?php if (empty($reservations)): ?>
    <p>Aucune réservation en cours.</p>
<?php else: ?>
    <table border="1">
        <thead>
            <tr>
                <th>ID Ticket</th>
                <th>Film</th>
                <th>Date de Création</th>
                <th>Date d'Expiration</th>
                <th>Séance</th>
                <th>Siège</th>
                <th>Range</th>
                <th>Cinéma</th>
                <th>Salle</th>
                <th>Annuler</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($reservations as $reservation): ?>
                <tr>
                    <td><?php echo htmlspecialchars($reservation['id_ticket']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['film_titre']); ?></td>
                    <td><?php echo htmlspecialchars(date('d/m/Y H:i', strtotime($reservation['date_crea']))); ?></td>
                    <td><?php echo htmlspecialchars(date('d/m/Y H:i', strtotime($reservation['date_expir']))); ?></td>
                    <td><?php echo htmlspecialchars(date('d/m/Y H:i', strtotime($reservation['h_debut']))) . ' - ' . htmlspecialchars(date('d/m/Y H:i', strtotime($reservation['h_fin']))); ?></td>
                    <td><?php echo htmlspecialchars($reservation['num_place']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['num_range']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['nom_cin']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['nom_s']); ?></td>
                    <td>
                        <form method="POST" action="annuler_reservation.php" onsubmit="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?');">
                            <input type="hidden" name="id_ticket" value="<?php echo $reservation['id_ticket']; ?>">
                            <button type="submit">Annuler</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>

<a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>
