<?php
$title = "Ajouter une séance";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

// Générer un nouvel id_seance en fonction de la base de données
function genererIdSeance($pdo) {
    $stmt = $pdo->query("SELECT MAX(id_seance) AS max_id FROM seance");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result && $result['max_id']) {
        $max_id = $result['max_id'];
        $num_part = intval(substr($max_id, 4));
        $new_num = $num_part + 1;
        return 'SEA-' . str_pad($new_num, 4, '0', STR_PAD_LEFT);
    } else {
        return 'SEA-0001';
    }
}



// Récupérer les films pour la liste déroulante
$stmt_films = $pdo->query("SELECT id_film, titre FROM film");
$films = $stmt_films->fetchAll(PDO::FETCH_ASSOC);

// Récupérer les salles pour la liste déroulante
$stmt_salles = $pdo->query("SELECT id_salle, nom_s FROM salle");
$salles = $stmt_salles->fetchAll(PDO::FETCH_ASSOC);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $h_debut = $_POST['h_debut'];
    $h_fin = $_POST['h_fin'];
    $prix = $_POST['prix'];
    $langue = $_POST['langue'];
    $st = $_POST['st'];
    $play = $_POST['play'];
    $id_film = $_POST['id_film'];
    $id_salle = $_POST['id_salle'];

    $id_seance = genererIdSeance($pdo);

    if (empty($h_debut) || empty($h_fin) || empty($prix) || empty($langue) || empty($play) || empty($id_film) || empty($id_salle)) {
        $error_message = "Tous les champs sont obligatoires.";
    } elseif (!in_array($play, ['E', 'S', 'F'])) {
        $error_message = "Le champ 'Version de lecture' doit être 'E', 'S' ou 'F'.";
    } elseif ($prix <= 0) {
        $error_message = "Le prix doit être supérieur à 0.";
    } else {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO seance (id_seance, h_debut, h_fin, prix, langue, st, play, id_film, id_salle)
                VALUES (:id_seance, :h_debut, :h_fin, :prix, :langue, :st, :play, :id_film, :id_salle)
            ");
            $stmt->execute([
                ':id_seance' => $id_seance,
                ':h_debut' => $h_debut,
                ':h_fin' => $h_fin,
                ':prix' => $prix,
                ':langue' => $langue,
                ':st' => $st,
                ':play' => $play,
                ':id_film' => $id_film,
                ':id_salle' => $id_salle
            ]);
            $success_message = "La séance a été ajoutée avec succès.";
        } catch (Exception $e) {
            $error_message = "Erreur lors de l'ajout de la séance : " . $e->getMessage();
        }
    }
}
?>

    <h1>Ajouter une séance</h1>

<?php if (isset($error_message)): ?>
    <p style="color: red;"><?= htmlspecialchars($error_message) ?></p>
<?php elseif (isset($success_message)): ?>
    <p style="color: green;"><?= htmlspecialchars($success_message) ?></p>
<?php endif; ?>

    <form method="POST" action="addseance.php">
        <div>
            <label for="h_debut">Heure de début :</label>
            <input type="datetime-local" id="h_debut" name="h_debut" required>
        </div>
        <div>
            <label for="h_fin">Heure de fin :</label>
            <input type="datetime-local" id="h_fin" name="h_fin" required>
        </div>
        <div>
            <label for="prix">Prix (€) :</label>
            <input type="number" step="0.01" id="prix" name="prix" required>
        </div>
        <div>
            <label for="langue">Langue :</label>
            <input type="text" id="langue" name="langue" maxlength="2" required>
        </div>
        <div>
            <label for="st">Présence des sous-titres :</label>
            <select id="st" name="st" required>
                <option value="true" selected>Oui</option>
                <option value="false">Non</option>
            </select>
        </div>
        <div>
            <label for="play">Version de lecture :</label>
            <select id="play" name="play" required>
                <option value="E">Version originale</option>
                <option value="S">Sous-titres</option>
                <option value="F">Doublage</option>
            </select>
        </div>
        <div>
            <label for="id_film">Film :</label>
            <select id="id_film" name="id_film" required>
                <option value="">Sélectionner un film</option>
                <?php foreach ($films as $film): ?>
                    <option value="<?= htmlspecialchars($film['id_film']) ?>"><?= htmlspecialchars($film['titre']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div>
            <label for="id_salle">Salle :</label>
            <select id="id_salle" name="id_salle" required>
                <option value="">Sélectionner une salle</option>
                <?php foreach ($salles as $salle): ?>
                    <option value="<?= htmlspecialchars($salle['id_salle']) ?>"><?= htmlspecialchars($salle['nom_s']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div>
            <button type="submit">Ajouter la séance</button>
        </div>
    </form>

    <a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>