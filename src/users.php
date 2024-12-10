<?php
$title = "Gestion des utilisateurs";
include_once "./util/header.inc.php";
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

function generateEmployeeId()
{
    return 'EMP-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_user_id'])) {
    $delete_user_id = $_POST['delete_user_id'];

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("DELETE FROM client WHERE id_personne = :id_personne");
        $stmt->execute([':id_personne' => $delete_user_id]);

        $stmt = $pdo->prepare("DELETE FROM employee WHERE id_personne = :id_personne");
        $stmt->execute([':id_personne' => $delete_user_id]);

        $stmt = $pdo->prepare("DELETE FROM personne WHERE id_personne = :id_personne");
        $stmt->execute([':id_personne' => $delete_user_id]);

        $pdo->commit();

        $delete_message = "L'utilisateur a été supprimé avec succès.";
    } catch (Exception $e) {
        $pdo->rollBack();
        $delete_message = "Erreur lors de la suppression de l'utilisateur : " . $e->getMessage();
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_user_level'])) {
    $user_id = $_POST['user_id'];
    $new_level = $_POST['new_level'];
    $poste = $_POST['poste'] ?? 'Non défini';
    $id_cinema = $_POST['id_cinema'] ?? null;

    try {
        $stmt = $pdo->prepare("SELECT * FROM employee WHERE id_personne = :id_personne");
        $stmt->execute([':id_personne' => $user_id]);
        $employee = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($employee) {
            $stmt = $pdo->prepare("UPDATE employee SET lvl_acces = :lvl_acces, poste = :poste, id_cinema = :id_cinema WHERE id_personne = :id_personne");
            $stmt->execute([
                ':lvl_acces' => $new_level,
                ':poste' => $poste,
                ':id_cinema' => $id_cinema,
                ':id_personne' => $user_id
            ]);
        } else {
            $id_employee = generateEmployeeId();
            $stmt = $pdo->prepare("INSERT INTO employee (id_employee, id_personne, poste, lvl_acces, id_cinema) VALUES (:id_employee, :id_personne, :poste, :lvl_acces, :id_cinema)");
            $stmt->execute([
                ':id_employee' => $id_employee,
                ':id_personne' => $user_id,
                ':poste' => $poste,
                ':lvl_acces' => $new_level,
                ':id_cinema' => $id_cinema
            ]);
        }

        $update_message = "Le niveau d'accès de l'utilisateur a été mis à jour.";
    } catch (Exception $e) {
        $update_message = "Erreur lors de la mise à jour : " . $e->getMessage();
    }
}

$stmt = $pdo->prepare("
    SELECT 
        p.id_personne, 
        p.nom, 
        p.prenom, 
        COALESCE(e.lvl_acces, 'Non défini') AS lvl_acces,
        e.poste, 
        e.id_cinema
    FROM personne p
    LEFT JOIN employee e ON p.id_personne = e.id_personne
    ORDER BY p.nom, p.prenom
");
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

$stmt = $pdo->prepare("SELECT id_cinema, nom_cin FROM cinema");
$stmt->execute();
$cinemas = $stmt->fetchAll(PDO::FETCH_ASSOC);


?>

<h1 class="page-title">Gestion des utilisateurs</h1>

<?php if (isset($delete_message)): ?>
    <p class="message success"><?= htmlspecialchars($delete_message) ?></p>
<?php endif; ?>

<?php if (isset($update_message)): ?>
    <p class="message success"><?= htmlspecialchars($update_message) ?></p>
<?php endif; ?>

<div class="table-container">
    <table class="user-table">
        <thead>
            <tr>
                <th class="table-header">Nom</th>
                <th class="table-header">Prénom</th>
                <th class="table-header">Niveau d'accès</th>
                <th class="table-header">Poste</th>
                <th class="table-header">Cinéma</th>
                <th class="table-header">Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($users as $user): ?>
                <tr class="table-row">
                    <td class="table-data"><?= htmlspecialchars($user['nom']) ?></td>
                    <td class="table-data"><?= htmlspecialchars($user['prenom']) ?></td>
                    <td class="table-data"><?= htmlspecialchars($user['lvl_acces']) ?></td>
                    <td class="table-data"><?= htmlspecialchars($user['poste'] ?? 'Non défini') ?></td>
                    <td class="table-data"><?= htmlspecialchars($user['id_cinema'] ?? 'Non défini') ?></td>
                    <td class="table-data">
                        <form method="POST" action="users.php" class="form-update-level">
                            <select name="new_level" class="select-level">
                                <option value="M" <?= $user['lvl_acces'] == 'M' ? 'selected' : '' ?>>Master</option>
                                <option value="I" <?= $user['lvl_acces'] == 'I' ? 'selected' : '' ?>>Intermediate</option>
                                <option value="N" <?= $user['lvl_acces'] == 'N' ? 'selected' : '' ?>>Normal</option>
                            </select>

                            <input type="text" name="poste" value="<?= htmlspecialchars($user['poste'] ?? '') ?>" placeholder="Poste" class="input-poste">

                            <select name="id_cinema" class="select-cinema">
                                <?php foreach ($cinemas as $cinema): ?>
                                    <option value="<?= htmlspecialchars($cinema['id_cinema']) ?>" <?= $user['id_cinema'] == $cinema['id_cinema'] ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($cinema['nom_cin']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>

                            <input type="hidden" name="user_id" value="<?= htmlspecialchars($user['id_personne']) ?>">
                            <button type="submit" name="update_user_level" class="update-button">Mettre à jour</button>
                        </form>


                        <form method="POST" action="users.php" class="form-delete-user">
                            <input type="hidden" name="delete_user_id" value="<?= htmlspecialchars($user['id_personne']) ?>">
                            <button type="submit" class="delete-button" onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?');">Supprimer</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>