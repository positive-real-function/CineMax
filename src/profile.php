<?php
$title = "Mon Profil";
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
    $stmt_personne = $pdo->prepare("
    SELECT p.nom, p.prenom, p.sexe, p.email, c.birth, c.date_insc
    FROM personne p
    JOIN client c ON p.id_personne = c.id_personne
    WHERE p.id_personne = :user_id
    ");

    $stmt_personne->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt_personne->execute();

    $personne = $stmt_personne->fetch(PDO::FETCH_ASSOC);

    if (!$personne) {
        throw new Exception('Aucune information personnelle trouvée. Vérifiez si l\'utilisateur existe.');
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (isset($_POST['update'])) {
            $new_email = trim($_POST['email']);
            $new_password = trim($_POST['password']);
            $new_password_confirm = trim($_POST['password_confirm']);

            if (!empty($new_email) && !filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
                throw new Exception("L'adresse email n'est pas valide.");
            }

            if (!empty($new_email)) {
                $stmt_check_email = $pdo->prepare("SELECT COUNT(*) FROM personne WHERE email = :email AND id_personne != :user_id");
                $stmt_check_email->execute([':email' => $new_email, ':user_id' => $user_id]);
                $email_exists = $stmt_check_email->fetchColumn();

                if ($email_exists) {
                    throw new Exception("Cet email est déjà utilisé.");
                }
            }

            if (!empty($new_password) && $new_password !== $new_password_confirm) {
                throw new Exception("Les mots de passe ne correspondent pas.");
            }

            $email_to_update = !empty($new_email) ? $new_email : $personne['email'];

            $sql = "UPDATE personne SET email = :email";
            if (!empty($new_password)) {
                $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
                $sql .= ", p_mdp = :p_mdp";
            }
            $sql .= " WHERE id_personne = :user_id";

            $stmt_update = $pdo->prepare($sql);
            $stmt_update->bindParam(':email', $email_to_update, PDO::PARAM_STR);
            if (!empty($new_password)) {
                $stmt_update->bindParam(':p_mdp', $hashed_password, PDO::PARAM_STR);
            }
            $stmt_update->bindParam(':user_id', $user_id, PDO::PARAM_INT);
            $stmt_update->execute();

            $message = "Vos informations ont été mises à jour avec succès.";
        } elseif (isset($_POST['delete_account'])) {
            $stmt_delete_tickets = $pdo->prepare("DELETE FROM ticket WHERE id_client IN (SELECT id_client FROM client WHERE id_personne = :user_id)");
            $stmt_delete_tickets->execute([':user_id' => $user_id]);

            $stmt_delete_client = $pdo->prepare("DELETE FROM client WHERE id_personne = :user_id");
            $stmt_delete_client->execute([':user_id' => $user_id]);

            $stmt_delete_personne = $pdo->prepare("DELETE FROM personne WHERE id_personne = :user_id");
            $stmt_delete_personne->execute([':user_id' => $user_id]);

            session_destroy();
            header('Location: goodbye.php');
            exit;
        }
    }

    $stmt_reservations = $pdo->prepare("
        SELECT t.id_ticket,
               f.titre  AS film_titre,
               se.h_debut,
               se.h_fin,
               s.num_place,
               s.num_range,
               sa.nom_s AS salle,
               c.nom_cin,
               se.prix
        FROM ticket t
                 JOIN public.seance se on se.id_seance = t.id_seance
                 JOIN public.film f on f.id_film = se.id_film
                 JOIN public.siege s on s.id_siege = t.id_siege
                 JOIN public.salle sa on sa.id_salle = se.id_salle
                 JOIN public.cinema c on c.id_cinema = sa.id_cinema
                 JOIN public.client cl on cl.id_client = t.id_client
        
        WHERE cl.id_personne = :user_id
        ORDER BY t.date_crea DESC;
");
    $stmt_reservations->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt_reservations->execute();
    $reservations = $stmt_reservations->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $erreur = "Erreur : " . htmlspecialchars($e->getMessage());
}
?>

<h1>Mon Profil</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?php echo $erreur; ?></p>
<?php elseif (!empty($message)): ?>
    <p style="color: green;"><?php echo $message; ?></p>
<?php endif; ?>

<h2>Informations Personnelles</h2>
<?php if ($personne): ?>
    <ul>
        <li><strong>Nom :</strong> <?php echo htmlspecialchars($personne['nom']); ?></li>
        <li><strong>Prénom :</strong> <?php echo htmlspecialchars($personne['prenom']); ?></li>
        <li><strong>Sexe :</strong> <?php echo htmlspecialchars($personne['sexe']) === 'H' ? 'Homme' : 'Femme'; ?></li>
        <li><strong>Email :</strong> <?php echo htmlspecialchars($personne['email']); ?></li>
        <li><strong>Date de naissance :</strong> <?php echo date('d/m/Y', strtotime($personne['birth'])); ?></li>
        <li><strong>Date d'inscription :</strong> <?php echo date('d/m/Y', strtotime($personne['date_insc'])); ?></li>
    </ul>
<?php else: ?>
    <p>Les informations personnelles n'ont pas pu être récupérées.</p>
<?php endif; ?>

<h2>Modifier mes Informations</h2>
<form method="POST" action="">
    <label for="email">Nouvel Email :</label>
    <input type="email" name="email" id="email" value="<?php echo htmlspecialchars($personne['email']); ?>">

    <label for="password">Nouveau Mot de Passe :</label>
    <input type="password" name="password" id="password">

    <label for="password_confirm">Confirmer le Mot de Passe :</label>
    <input type="password" name="password_confirm" id="password_confirm">

    <button type="submit" name="update">Mettre à jour</button>
</form>

<h2>Supprimer mon compte</h2>
<p style="color: red;">Attention : cette action est irréversible.</p>
<form method="POST" action="">
    <button type="submit" name="delete_account" style="background-color: red; color: white;">Supprimer mon compte</button>
</form>

<h2>Mes Réservations</h2>
<?php if (empty($reservations)): ?>
    <p>Aucune réservation trouvée.</p>
<?php else: ?>
    <table border="1">
        <thead>
            <tr>
                <th>ID</th>
                <th>Film</th>
                <th>Heure de Séance</th>
                <th>Prix</th>
                <th>Siège</th>
                <th>Salle</th>
                <th>Cinéma</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($reservations as $reservation): ?>
                <tr>
                    <td><?php echo htmlspecialchars($reservation['id_ticket']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['film_titre']); ?></td>
                    <td><?php echo htmlspecialchars(date('d/m/Y H:i', strtotime($reservation['h_debut']))); ?></td>
                    <td><?php echo htmlspecialchars($reservation['prix']); ?> €</td>
                    <td><?php echo "Place " . htmlspecialchars($reservation['num_place']) . ", Rangée " . htmlspecialchars($reservation['num_range']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['salle']); ?></td>
                    <td><?php echo htmlspecialchars($reservation['nom_cin']); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>

<a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>