<?php
$title = "Connexion";
include_once("./util/header.inc.php");
require("./util/config.inc.php");

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $mot_de_passe = $_POST['mot_de_passe'] ?? '';

    if (!empty($email) && !empty($mot_de_passe)) {
        $stmt = $pdo->prepare("SELECT * FROM personne WHERE email = ?");
        $stmt->execute([$email]);
        $personne = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($personne) {
            if (password_get_info($personne['p_mdp'])['algo'] !== null) {
                if (password_verify($mot_de_passe, $personne['p_mdp'])) {
                    $_SESSION['user_id'] = $personne['id_personne'];
                    $_SESSION['user_nom'] = $personne['nom'];

                    $stmt_role = $pdo->prepare("SELECT lvl_acces FROM employee WHERE id_personne = ?");
                    $stmt_role->execute([$personne['id_personne']]);
                    $role = $stmt_role->fetchColumn();

                    $_SESSION['user_role'] = $role;

                    header('Location: accueil.php');
                    exit;
                } else {
                    $erreur = "Email ou mot de passe incorrect.";
                }
            } else {
                if ($mot_de_passe === $personne['p_mdp']) {
                    $_SESSION['user_id'] = $personne['id_personne'];
                    $_SESSION['user_nom'] = $personne['nom'];

                    $stmt_role = $pdo->prepare("SELECT lvl_acces FROM employee WHERE id_personne = ?");
                    $stmt_role->execute([$personne['id_personne']]);
                    $role = $stmt_role->fetchColumn();

                    $_SESSION['user_role'] = $role;

                    header('Location: accueil.php');
                    exit;
                } else {
                    $erreur = "Email ou mot de passe incorrect.";
                }
            }
        } else {
            $erreur = "Email ou mot de passe incorrect.";
        }
    } else {
        $erreur = "Tous les champs doivent être remplis.";
    }
}
?>

<h1>Page de connexion au service de CineMax</h1>
<h2>Connexion</h2>

<?php if (isset($erreur)): ?>
    <p style="color: red;"><?php echo htmlspecialchars($erreur); ?></p>
<?php endif; ?>

<form method="POST" action="">
    <label for="email">Email :</label>
    <input type="email" id="email" name="email" required>
    <br>
    <label for="mot_de_passe">Mot de passe :</label>
    <input type="password" id="mot_de_passe" name="mot_de_passe" required>
    <br>
    <button type="submit">Se connecter</button>
</form>

<?php
include_once("./util/footer.inc.php");
?>
