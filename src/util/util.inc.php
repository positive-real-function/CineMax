<?php
declare(strict_types=1);

/**
 * @file
 */

function linkStyle(string $style): string{
    $currentURL = 'http';
    if (isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] === "on") {
        $currentURL .= "s";
    }
    $currentURL .= "://";
    if ($_SERVER["SERVER_PORT"] != "80") {
        $currentURL .= $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"] . $_SERVER["REQUEST_URI"];
    } else {
        $currentURL .= $_SERVER["SERVER_NAME"] . $_SERVER["REQUEST_URI"];
    }

    if (strpos($currentURL, 'style=') !== false) {
        $currentURL = preg_replace('/style=([^&]+)/', 'style=' . $style, $currentURL);
    } else if (strpos($currentURL, '?') !== false) {
        $currentURL .= '&style=' . $style;
    } else {
        $currentURL .= '?style=' . $style;
    }
    return $currentURL;

}
?>