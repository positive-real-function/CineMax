<?php
$title = "Vérification du ticket";
include_once "./util/header.inc.php";
require_once "./util/config.inc.php";

$timezone = new DateTimeZone('Europe/Paris');


if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id_ticket'])) {
    $id_ticket = $_POST['id_ticket'];
    $erreur = "";

    try {
        // 检查门票是否已使用
        $stmt_used = $pdo->prepare("SELECT used FROM ticket WHERE id_ticket = :id_ticket");
        $stmt_used->execute(['id_ticket' => $id_ticket]);
        $used = $stmt_used->fetchColumn();

        if (!$used) {
            $erreur = "Ticket non valide.";
        } elseif ($used === 'U') {
            $erreur = "Désolé, votre ticket a déjà été utilisé.";
        } else {
            // 获取电影场次时间段
            $stmt_time = $pdo->prepare("
                SELECT s.h_debut, s.h_fin 
                FROM ticket t
                JOIN seance s ON s.id_seance = t.id_seance
                WHERE t.id_ticket = :id_ticket
            ");
            $stmt_time->execute(['id_ticket' => $id_ticket]);
            $time = $stmt_time->fetch(PDO::FETCH_ASSOC);

            if (!$time) {
                $erreur = "Erreur : Impossible de trouver les informations de la séance.";
            } else {
                $now = new DateTime('now', $timezone);
                $h_debut = new DateTime($time['h_debut'], $timezone); // 明确指定时区
                $h_fin = new DateTime($time['h_fin'], $timezone);
                $h_debut->modify('-15 minutes'); // 检票开始时间

                if ($now < $h_debut) {
                    $erreur = "Désolé, votre film n'a pas encore commencé la vérification. La vérification commencera à : "
                        . $h_debut->format('Y-m-d H:i:s') . ".";
//                    echo $now->format('Y-m-d H:i:s');
//                    echo 'debut'.$h_debut->format('Y-m-d H:i:s');
//                    echo 'fin'.$h_fin->format('Y-m-d H:i:s');
                } elseif ($now > $h_fin) {
                    $erreur = "Désolé, votre film est déjà terminé.";
                } else {
                    // 验票成功，获取详细信息
                    $stmt_details = $pdo->prepare("
                        SELECT f.titre, s.h_debut, s.h_fin, f.duree, sa.nom_s, si.num_range, si.num_place
                        FROM ticket t
                        JOIN public.siege si ON si.id_siege = t.id_siege
                        JOIN public.salle sa ON sa.id_salle = si.id_salle
                        JOIN public.seance s ON s.id_seance = t.id_seance
                        JOIN public.film f ON f.id_film = s.id_film
                        WHERE t.id_ticket = :id_ticket
                    ");
                    $stmt_details->execute(['id_ticket' => $id_ticket]);
                    $details = $stmt_details->fetch(PDO::FETCH_ASSOC);

                    if (!$details) {
                        $erreur = "Erreur : Impossible de récupérer les informations du film.";
                    } else {
                        // 标记门票为已使用
                        $stmt_update = $pdo->prepare("UPDATE ticket SET used = 'U' WHERE id_ticket = :id_ticket");
                        $stmt_update->execute(['id_ticket' => $id_ticket]);

                        echo "<h2>Vérification réussie</h2>";
                        echo "<p>Bienvenue ! Voici les détails de votre film :</p>";
                        echo "<ul>
                                <li>Titre du film : " . htmlspecialchars($details['titre']) . "</li>
                                <li>Début : " . htmlspecialchars($details['h_debut']) . "</li>
                                <li>Fin : " . htmlspecialchars($details['h_fin']) . "</li>
                                <li>Durée : " . htmlspecialchars($details['duree']) . " minutes</li>
                                <li>Salle : " . htmlspecialchars($details['nom_s']) . "</li>
                                <li>Rangée : " . htmlspecialchars($details['num_range']) . ", Place : " . htmlspecialchars($details['num_place']) . "</li>
                              </ul>";
                        echo "<p>Profitez de votre film !</p>";
                        exit;
                    }
                }
            }
        }
    } catch (PDOException $e) {
        $erreur = "Erreur lors de la vérification : " . htmlspecialchars($e->getMessage());
    }
}
?>

    <h1>Vérification du ticket</h1>

<?php if (!empty($erreur)): ?>
    <p style="color: red;"><?= htmlspecialchars($erreur) ?></p>
<?php endif; ?>

    <form method="POST" action="verifier.php">
        <label for="id_ticket">ID du ticket :</label>
        <input type="text" id="id_ticket" name="id_ticket" required>
        <br>
        <button type="submit">Vérifier le ticket</button>
    </form>

    <a href="accueil.php" class="back-link">Retour à l'accueil</a>

<?php include_once "./util/footer.inc.php"; ?>


