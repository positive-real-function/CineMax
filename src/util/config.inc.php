<?php
$host = 'postgresql-cinemaproject.alwaysdata.net';
$dbname = 'cinemaproject_cine';
$username = 'cinemaproject';
$password = 'thecinemaproject2';

//$host = 'localhost';
//$dbname = 'projet_bd_reseau';
//$username = 'bd';
//$password = '123456';


try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
?>



