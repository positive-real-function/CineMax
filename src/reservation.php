<?php
$title = "Réservation";
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
$sieges = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['type_siege'], $_POST['id_seance'])) {
    $id_seance = $_POST['id_seance'];
    $type_siege = $_POST['type_siege'];

    if (!empty($id_seance) && !empty($type_siege)) {
        $stmt_sieges = $pdo->prepare("
            SELECT s.id_siege, s.num_place, s.num_range
            FROM siege s
            JOIN salle sa ON sa.id_salle = s.id_salle
            JOIN seance se ON se.id_salle = sa.id_salle
            WHERE se.id_seance = ? AND s.st = 'T' AND s.type_p = ? 
        ");
        $stmt_sieges->execute([$id_seance, $type_siege]);
        $sieges = $stmt_sieges->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $erreur = "Veuillez sélectionner une séance et un type de siège.";
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id_siege'])) {
    $id_siege = $_POST['id_siege'];

    if (!empty($id_siege) && !empty($id_seance)) {
        try {
            $stmt_client = $pdo->prepare("SELECT id_client FROM client WHERE id_personne = ?");
            $stmt_client->execute([$user_id]);
            $id_client = $stmt_client->fetchColumn();

            if (!$id_client) {
                $erreur = "Erreur : Aucune entrée client trouvée pour cet utilisateur.";
                throw new Exception($erreur);
            }

//            $id_ticket = 'TIC-' . str_pad(mt_rand(0, 9999), 4, '0', STR_PAD_LEFT);
            try {
                $stmt_max_ticket = $pdo->query("SELECT MAX(CAST(SUBSTRING(id_ticket FROM 5) AS INTEGER)) AS max_id FROM ticket");
                $max_id = $stmt_max_ticket->fetchColumn();
                $new_id = $max_id ? $max_id + 1 : 1; // 如果数据库为空，则从 1 开始
                $id_ticket = 'TIC-' . str_pad($new_id, 4, '0', STR_PAD_LEFT);
            } catch (PDOException $e) {
                $erreur = "Erreur lors de la génération de l'ID du ticket : " . htmlspecialchars($e->getMessage());
                throw new Exception($erreur);
            }

            $date_crea = date('Y-m-d H:i:s');
            $date_expir = date('Y-m-d H:i:s', strtotime('+1 year'));

            $stmt = $pdo->prepare("
                INSERT INTO ticket (id_ticket, date_crea, date_expir, used, premium, id_siege, id_client, id_seance) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$id_ticket, $date_crea, $date_expir, 'N', 'N', $id_siege, $id_client, $id_seance]);

            $update_siege = $pdo->prepare("UPDATE siege SET st = 'F' WHERE id_siege = ?");
            $update_siege->execute([$id_siege]);

            header('Location: confirmation.php');
            exit;
        } catch (PDOException $e) {
            $erreur = "Erreur lors de la réservation : " . htmlspecialchars($e->getMessage());
        }
    } else {
        $erreur = "Veuillez sélectionner un siège.";
    }
}
?>

<h1>Réserver une place</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?= htmlspecialchars($erreur) ?></p>
<?php endif; ?>

<form method="POST" action="reservation.php">
    <label for="id_seance">Séance :</label>
    <select name="id_seance" id="id_seance" required>
        <option value="">-- Choisir une séance --</option>
        <?php
        $stmt = $pdo->query("SELECT se.id_seance, se.h_debut, se.h_fin, f.titre 
                             FROM seance se
                             JOIN film f ON se.id_film = f.id_film 
                             WHERE se.h_debut > CURRENT_TIMESTAMP 
                             ORDER BY se.h_debut");
        while ($seance = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $selected = (isset($_POST['id_seance']) && $_POST['id_seance'] == $seance['id_seance']) ? 'selected' : '';
            echo "<option value='{$seance['id_seance']}' $selected>" 
                . htmlspecialchars($seance['titre']) 
                . " - " . htmlspecialchars($seance['h_debut']) 
                . " à " . htmlspecialchars($seance['h_fin']) 
                . "</option>";
        }
        ?>
    </select>
    <br>

    <label for="type_siege">Type de siège :</label>
    <select name="type_siege" id="type_siege" required>
        <option value="">-- Choisir un type de siège --</option>
        <option value="N" <?= (isset($_POST['type_siege']) && $_POST['type_siege'] == 'N') ? 'selected' : '' ?>>Normal</option>
        <option value="V" <?= (isset($_POST['type_siege']) && $_POST['type_siege'] == 'V') ? 'selected' : '' ?>>VIP</option>
    </select>
    <br>

    <button type="submit">Voir les sièges disponibles</button>
</form>

<?php if (!empty($sieges)): ?>
    <h2>Sièges disponibles</h2>
    <form method="POST" action="reservation.php">
        <input type="hidden" name="id_seance" value="<?= htmlspecialchars($_POST['id_seance']) ?>">
        <input type="hidden" name="type_siege" value="<?= htmlspecialchars($_POST['type_siege']) ?>">
        <label for="id_siege">Siège :</label>
        <select name="id_siege" id="id_siege" required>
            <option value="">-- Choisir un siège --</option>
            <?php foreach ($sieges as $siege): ?>
                <option value="<?= htmlspecialchars($siege['id_siege']) ?>">
                    Rangée <?= htmlspecialchars($siege['num_range']) ?>, Place <?= htmlspecialchars($siege['num_place']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <br>
        <button type="submit">Réserver</button>
    </form>
<?php elseif (isset($_POST['type_siege'])): ?>
    <p>Aucun siège disponible pour ce type et cette séance.</p>
<?php endif; ?>

<a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>
