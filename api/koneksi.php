<?php
$host = "localhost";     // Ganti sesuai server kamu
$user = "root";          // User database
$pass = "";              // Password database
$db   = "nabil_pos";   // Nama database

$koneksi = mysqli_connect($host, $user, $pass, $db);

if (!$koneksi) {
    die(json_encode(["success" => false, "message" => "Koneksi database gagal: " . mysqli_connect_error()]));
}
