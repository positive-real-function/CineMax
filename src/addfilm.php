<?php
$title = "Ajouter un film";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}


function genererIdFilm($pdo) {
    // 获取最大 id_film
    $stmt = $pdo->query("SELECT MAX(id_film) AS max_id FROM film");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    // 如果找到了最大值
    if ($result && $result['max_id']) {
        // 提取数字部分并加 1
        $max_id = $result['max_id'];
        $num_part = intval(substr($max_id, 2));  // 获取数字部分
        $new_num = $num_part + 1;
        // 生成新的 id_film，确保是八位数
        return 'F-' . str_pad($new_num, 8, '0', STR_PAD_LEFT);
    } else {
        // 如果没有记录，则返回 F-00000001
        return 'F-00000001';
    }
}


function chargerPaysDepuisCSV($fichier) {
    $pays = [];
    if (($handle = fopen($fichier, 'r')) !== FALSE) {
        fgetcsv($handle, 0, ',', '"', '\\'); // Ignorer l'en-tête

        while (($data = fgetcsv($handle, 0, ',', '"', '\\')) !== FALSE) {
            // Vérifier que la ligne contient au moins deux colonnes
            if (count($data) < 2 || empty($data[0]) || empty($data[1])) {
                continue; // Passer à la ligne suivante
            }
            $pays[$data[1]] = $data[0];
        }
        fclose($handle);
    }
    return $pays;
}

$pays = chargerPaysDepuisCSV('./doc/pays.csv');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $titre = $_POST['titre'];
    $date_sortie = $_POST['date_sortie'];
    $duree = $_POST['duree'];
    $director = $_POST['director'];
    $genre = $_POST['genre'];
    $nationalite = $_POST['nationalite'];

//    $id_film = 'F-' . str_pad(rand(0, 99999999), 8, '0', STR_PAD_LEFT); // Génère un ID unique
    // 调用生成 id_film
    $id_film = genererIdFilm($pdo);

    if (empty($titre) || empty($date_sortie) || empty($duree) || empty($director)) {
        $error_message = "Tous les champs sont obligatoires.";
    } else {
        $stmt = $pdo->prepare("
            INSERT INTO film (id_film, titre, date_sortie, duree, director, genre, nationalite)
            VALUES (:id_film, :titre, :date_sortie, :duree, :director, :genre, :nationalite)
        ");
        $stmt->execute([
            ':id_film' => $id_film,
            ':titre' => $titre,
            ':date_sortie' => $date_sortie,
            ':duree' => $duree,
            ':director' => $director,
            ':genre' => $genre,
            ':nationalite' => $nationalite
        ]);

        $success_message = "Le film a été ajouté avec succès.";
    }
}

?>

<h1>Ajouter un film</h1>

<?php if (isset($error_message)): ?>
    <p style="color: red;"><?= htmlspecialchars($error_message) ?></p>
<?php elseif (isset($success_message)): ?>
    <p style="color: green;"><?= htmlspecialchars($success_message) ?></p>
<?php endif; ?>

<form method="POST" action="addfilm.php">
    <div>
        <label for="titre">Titre :</label>
        <input type="text" id="titre" name="titre" required>
    </div>
    <div>
        <label for="date_sortie">Date de sortie :</label>
        <input type="date" id="date_sortie" name="date_sortie" required>
    </div>
    <div>
        <label for="duree">Durée :</label>
        <input type="time" id="duree" name="duree" required>
    </div>
    <div>
        <label for="director">Réalisateur :</label>
        <input type="text" id="director" name="director" required>
    </div>
    <div>
        <label for="genre">Genre :</label>
        <input type="text" id="genre" name="genre">
    </div>
    <div>
        <label for="nationalite">Nationalité :</label>
        <select id="nationalite" name="nationalite" required>
            <option value="">Sélectionner un pays</option>
            <?php foreach ($pays as $code => $nom): ?>
                <option value="<?= htmlspecialchars($code) ?>"><?= htmlspecialchars($nom) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div>
        <button type="submit">Ajouter le film</button>
    </div>
</form>

<a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php
include_once "./util/footer.inc.php";
?>
