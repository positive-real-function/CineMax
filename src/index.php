<?php
$title = "CineMax";
$filename = "index.php";
include_once("./util/header.inc.php");
?>
<h1 class='alignement 1'>CineMax</h1>
<section>
    <h2 class="alignement2">Votre site de gestion de cinemas et de films prefere!</h2>
    <p class="homep">Creez un compte ou connectez vous pour acceder aux fonctionnalites de notre site</p>
    <span class="homecon">
        <ul>
            <li><a href="connect.php" class="homeconn">Se connecter</a></li>
            <li><a href="createAccount.php" class="homeconn">Creer un compte</a></li>
        </ul>
    </span>
</section>
<?php

include_once("./util/footer.inc.php");
?>