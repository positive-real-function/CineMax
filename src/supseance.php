<?php
$title = "Supprimer une séance";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id_seance'])) {
    $id_seance = $_POST['id_seance'];

    try {
        $pdo->beginTransaction();

        // 删除与该场次相关的票务记录
        $stmt = $pdo->prepare("DELETE FROM ticket WHERE id_seance = :id_seance");
        $stmt->execute([':id_seance' => $id_seance]);

        // 删除该场次记录
        $stmt = $pdo->prepare("DELETE FROM seance WHERE id_seance = :id_seance");
        $stmt->execute([':id_seance' => $id_seance]);

        $pdo->commit();

        $success_message = "La séance a été supprimée avec succès.";
    } catch (Exception $e) {
        $pdo->rollBack();
        $error_message = "Erreur lors de la suppression de la séance : " . $e->getMessage();
    }
}

$stmt = $pdo->prepare("SELECT id_seance, f.titre AS film_titre, sa.nom_s AS salle, se.h_debut, se.h_fin
                        FROM seance se
                        JOIN film f ON se.id_film = f.id_film
                        JOIN salle sa ON se.id_salle = sa.id_salle
                        ORDER BY se.h_debut ASC");
$stmt->execute();
$seances = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

    <h1>Supprimer une séance</h1>

<?php if (isset($success_message)): ?>
    <p style="color: green;"><?= htmlspecialchars($success_message) ?></p>
<?php endif; ?>

<?php if (isset($error_message)): ?>
    <p style="color: red;"><?= htmlspecialchars($error_message) ?></p>
<?php endif; ?>

    <form method="POST" action="supseance.php">
        <div>
            <label for="id_seance">Choisir une séance à supprimer :</label>
            <select name="id_seance" id="id_seance" required>
                <option value="">-- Sélectionner une séance --</option>
                <?php foreach ($seances as $seance): ?>
                    <option value="<?= htmlspecialchars($seance['id_seance']) ?>">
                        <?= htmlspecialchars($seance['film_titre']) ?> - <?= htmlspecialchars($seance['salle']) ?>
                        (<?php echo htmlspecialchars(date('d/m/Y H:i', strtotime($seance['h_debut']))); ?>)
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
        <div>
            <button type="submit">Supprimer la séance</button>
        </div>
    </form>

    <a href="seance.php" class="back-link">Retour à la liste des séances</a>

<?php
include_once "./util/footer.inc.php";
?>