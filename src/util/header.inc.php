<?php
//if (isset($_GET['style'])) {
//    setcookie('daylight', $_GET['style'], time() + 60 * 60 * 24 * 30, './', $_SERVER['SERVER_NAME'], false, true);
//}
require_once("util.inc.php");
session_start();
?>
<!DOCTYPE html>
<html lang='fr'>

<head>
    <meta charset='utf-8' />
    <meta http-equiv='X-UA-Compatible' content='IE=edge' />
    <title>
        <?= htmlspecialchars('Bienvenu') ?>
    </title>
    <meta name="author" content="JIN Zhuoyuan FWALA YENGA MUBY WENU Yvon OUATATI Kamil" />
    <meta name="description" content="Site web réalisé dans le cadre du projet de base de données et réseau" />
    <meta name='viewport' content='width=device-width, initial-scale=1' />
    <meta name='keywords' content='Cinema, Cine, cine, cinema, film, acteur, reserver, tickets, ticket' />
    <?php
    $style = isset($_GET['style']) ? $_GET['style'] : (isset($_COOKIE['daylight']) ? $_COOKIE['daylight'] : 'day');
    $stylesheet = ($style == 'night') ? './CSS/night.css' : './CSS/style.css';
    $favicon = ($style == 'night') ? './doc/faviconB.ico' : './doc/favicon.ico';
    ?>
    <link rel="stylesheet" type="text/css" media="screen" href="<?= $stylesheet ?>" />
    <link rel="icon" href='<?= $favicon ?>' />
</head>

<body>
    <header>
        <nav class="navbar">
            <ul>

                <?php if (isset($_SESSION['user_id'])): ?>
                    <li>
                        <a href="accueil.php?style=<?= $style ?>"><img src="<?= $favicon ?>" alt="Logo du site" title="Homepage" /></a>
                    </li>
                    <li><a href="profile.php?style=<?= $style ?>">Mon profil</a></li>
                    <li><a href="reservations.php?style=<?= $style ?>">Mes réservations</a></li>
                    <li><a href="logout.php?style=<?= $style ?>">Se déconnecter</a></li>
                    <li><a href="verifier.php?style=<?= $style ?>">Verifier le ticket</a></li>
                <?php else: ?>
                    <li>
                        <a href="index.php?style=<?= $style ?>"><img src="<?= $favicon ?>" alt="Logo du site" title="Homepage" /></a>
                    </li>
                    <li><a href="connect.php?style=<?= $style ?>">Se connecter</a></li>
                    <li><a href="createAccount.php?style=<?= $style ?>">Créer un compte</a></li>
                    <li><a href="verifier.php?style=<?= $style ?>">Verifier le ticket</a></li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>
    <main>