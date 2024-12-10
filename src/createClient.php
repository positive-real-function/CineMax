<?php
$title = "Créer un client";
include_once "./util/header.inc.php";
require_once "./util/config.inc.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $id_personne = $_POST['id_personne'];
        $birth = $_POST['birth'];
        $lvl = $_POST['lvl'];

        if (empty($birth) || empty($lvl)) {
            throw new Exception("Tous les champs obligatoires doivent être remplis.");
        }

        $stmt = $pdo->query("SELECT COALESCE(MAX(CAST(SUBSTRING(id_client FROM 5) AS INTEGER)), 0) + 1 AS next_id
FROM client");
        $next_id_number = $stmt->fetch(PDO::FETCH_ASSOC)['next_id'];
        $next_id = sprintf("CLI-%04d", $next_id_number);

        $stmt_insert = $pdo->prepare("
            INSERT INTO client (id_client, id_personne, birth, lvl)
            VALUES (:id_client, :id_personne, :birth, :lvl)
        ");
        $stmt_insert->execute([
            ':id_client' => $next_id,
            ':id_personne' => $id_personne,
            ':birth' => $birth,
            ':lvl' => $lvl
        ]);

        $success_message = "Le client a été créé avec succès.";
    } catch (Exception $e) {
        $error_message = $e->getMessage();
    }
} else {
    $id_personne = $_GET['id_personne'] ?? null;
    if (!$id_personne) {
        die("ID personne manquant.");
    }
}
?>

    <h1>Créer un client</h1>

<?php if (!empty($error_message)): ?>
    <p style="color: red;"><?php echo htmlspecialchars($error_message); ?></p>
<?php elseif (!empty($success_message)): ?>
    <p style="color: green;"><?php echo $success_message; ?></p>
<?php endif; ?>

    <form method="POST" action="createClient.php">
        <input type="hidden" name="id_personne" value="<?php echo htmlspecialchars($id_personne); ?>">

        <label for="birth">Date de naissance : *</label>
        <input type="date" name="birth" id="birth" required>

        <label for="lvl">Niveau : *</label>
        <select name="lvl" id="lvl" required>
            <option value="N">Normal</option>
            <option value="V">VIP</option>
        </select>

        <button type="submit">Créer un client</button>
    </form>

    <a href="index.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>