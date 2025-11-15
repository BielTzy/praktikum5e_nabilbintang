<?php
include "koneksi.php";

$user = $_POST['user'];
$password = $_POST['password'];

$query = "SELECT * FROM tb_pengguna WHERE user='$user' AND password='$password'";
$result = mysqli_query($koneksi, $query);

if (mysqli_num_rows($result) > 0) {
    $data = mysqli_fetch_assoc($result);
    echo json_encode([
        "success" => true,
        "message" => "Login berhasil",
        "data" => $data
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Username atau password salah"
    ]);
}
