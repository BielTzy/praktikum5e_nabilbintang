<?php
include "koneksi.php";

$id = $_POST['id'];

$query = "DELETE FROM tb_barang WHERE id='$id'";

if (mysqli_query($koneksi, $query)) {
    echo json_encode(["success" => true, "message" => "Barang berhasil dihapus"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus barang"]);
}
