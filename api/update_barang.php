<?php
include "koneksi.php";

$id = $_POST['id'];
$nama = $_POST['nama'];
$harga = $_POST['harga'];

$query = "UPDATE tb_barang SET nama='$nama', harga='$harga', updated_at=NOW() WHERE id='$id'";

if (mysqli_query($koneksi, $query)) {
    echo json_encode(["success" => true, "message" => "Barang berhasil diperbarui"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal memperbarui barang"]);
}
