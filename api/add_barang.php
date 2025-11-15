<?php
include "koneksi.php";

$nama = $_POST['nama'];
$harga = $_POST['harga'];

$query = "INSERT INTO tb_barang (nama, harga, created_at, updated_at) VALUES ('$nama', '$harga', NOW(), NOW())";

if (mysqli_query($koneksi, $query)) {
    echo json_encode(["success" => true, "message" => "Barang berhasil ditambahkan"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menambah barang"]);
}
