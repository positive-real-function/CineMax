<?php
include_once "include/header.inc.php";

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
session_destroy();
header('Location: index.php');
include_once "include/footer.inc.php";
exit;
?>
