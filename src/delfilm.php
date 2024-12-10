<?php
$title = "Supprimer un film";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id_film'])) {
    $id_film = $_POST['id_film'];

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("DELETE FROM jouer WHERE id_film = :id_film");
        $stmt->execute([':id_film' => $id_film]);

        $stmt = $pdo->prepare("DELETE FROM seance WHERE id_film = :id_film");
        $stmt->execute([':id_film' => $id_film]);

        $stmt = $pdo->prepare("DELETE FROM film WHERE id_film = :id_film");
        $stmt->execute([':id_film' => $id_film]);

        $pdo->commit();

        $success_message = "Le film a été supprimé avec succès.";
    } catch (Exception $e) {
        $pdo->rollBack();
        $error_message = "Erreur lors de la suppression du film : " . $e->getMessage();
    }
}

$stmt = $pdo->prepare("SELECT id_film, titre FROM film ORDER BY titre ASC");
$stmt->execute();
$films = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<h1>Supprimer un film</h1>

<?php if (isset($success_message)): ?>
    <p style="color: green;"><?= htmlspecialchars($success_message) ?></p>
<?php endif; ?>

<?php if (isset($error_message)): ?>
    <p style="color: red;"><?= htmlspecialchars($error_message) ?></p>
<?php endif; ?>

<form method="POST" action="delfilm.php">
    <div>
        <label for="id_film">Choisir un film à supprimer :</label>
        <select name="id_film" id="id_film" required>
            <option value="">-- Sélectionner un film --</option>
            <?php foreach ($films as $film): ?>
                <option value="<?= htmlspecialchars($film['id_film']) ?>">
                    <?= htmlspecialchars($film['titre']) ?>
                </option>
            <?php endforeach; ?>
        </select>
    </div>
    <div>
        <button type="submit">Supprimer le film</button>
    </div>
</form>

<a href="film.php" class="back-link">Retour à la liste des films</a>

<?php
include_once "./util/footer.inc.php";
?>
