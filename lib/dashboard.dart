import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

// Tema warna
const Color backgroundColor = Color(0xFFEEDCC5);
const Color cardColor = Color(0xFFE5D1B8);
const Color textColor = Color(0xFF5B4633);
const Color iconColor = Color(0xFF5B4633);
const Color fabColor = Color(0xFF7B6047);
const Color dangerColor = Color(0xFFB64330);

// Model
class Item {
  int? id;
  String nama;
  int harga;
  int stock;

  Item({this.id, required this.nama, required this.harga, required this.stock});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'harga': harga, 'stock': stock};
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Item> items = [];
  List<Item> filteredItems = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchItems();
    _searchController.addListener(_filterItems);
  }

  Future<void> fetchItems() async {
    const String url = "http://127.0.0.1:8000/api/barang";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          items = data.map((e) => Item.fromJson(e)).toList();
          filteredItems = items;
        });
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  void _filterItems() {
    String q = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = q.isEmpty
          ? items
          : items.where((e) => e.nama.toLowerCase().contains(q)).toList();
    });
  }

  int get totalJenisBarang => items.length;
  int get totalStock => items.fold(0, (a, b) => a + b.stock);

  // ---------------------------------------------------
  // ============ POPUP SNACKBAR =======================
  void _showSnackbar(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? dangerColor : fabColor,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ---------------------------------------------------
  // ============ DIALOG HAPUS =========================
  Future<bool> _showDeleteConfirm() async {
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: dangerColor, size: 48),
              const SizedBox(height: 12),
              Text(
                "Hapus Data?",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Apakah Anda yakin ingin menghapus barang ini?",
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("Batal", style: TextStyle(color: textColor)),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dangerColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Hapus"),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // ============ CRUD =================================
  Future<void> _createItem(Item item) async {
    try {
      await http.post(
        Uri.parse("http://127.0.0.1:8000/api/barang"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(item.toJson()),
      );
      _showSnackbar("Barang berhasil ditambahkan!");
    } catch (e) {
      _showSnackbar("Gagal menambah barang!", error: true);
    }
  }

  Future<void> _updateItem(Item item) async {
    try {
      await http.put(
        Uri.parse("http://127.0.0.1:8000/api/barang/${item.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(item.toJson()),
      );
      _showSnackbar("Barang berhasil diperbarui!");
    } catch (e) {
      _showSnackbar("Gagal update barang!", error: true);
    }
  }

  Future<void> _deleteItem(int id) async {
    bool confirmed = await _showDeleteConfirm();
    if (!confirmed) return;

    try {
      await http.delete(Uri.parse("http://127.0.0.1:8000/api/barang/$id"));
      fetchItems();
      _showSnackbar("Barang berhasil dihapus!");
    } catch (e) {
      _showSnackbar("Gagal menghapus barang!", error: true);
    }
  }

  // ---------------------------------------------------
  // ============ ADD / EDIT POPUP =====================
  Future<void> _addOrEditItem({Item? item}) async {
    final namaC = TextEditingController(text: item?.nama ?? "");
    final hargaC = TextEditingController(text: item?.harga.toString() ?? "");
    final stockC = TextEditingController(text: item?.stock.toString() ?? "");

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? "Tambah Barang" : "Edit Barang",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildInput("Nama", namaC),
              const SizedBox(height: 12),
              _buildInput("Harga", hargaC, isNumber: true),
              const SizedBox(height: 12),
              _buildInput("Stock", stockC, isNumber: true),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("Batal", style: TextStyle(color: textColor)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fabColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final newItem = Item(
                        id: item?.id,
                        nama: namaC.text,
                        harga: int.tryParse(hargaC.text) ?? 0,
                        stock: int.tryParse(stockC.text) ?? 0,
                      );

                      if (item == null) {
                        await _createItem(newItem);
                      } else {
                        await _updateItem(newItem);
                      }

                      Navigator.pop(context);
                      fetchItems();
                    },
                    child: Text(item == null ? "Tambah" : "Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 70,
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.logout, color: iconColor),
              const SizedBox(width: 6),
              Text("Logout", style: TextStyle(color: iconColor)),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          backgroundColor: fabColor,
          shape: const CircleBorder(),
          onPressed: () => _addOrEditItem(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildSummary(
                  "Total Jenis Barang",
                  totalJenisBarang.toString(),
                ),
                const SizedBox(width: 12),
                _buildSummary("Total Stock", totalStock.toString()),
              ],
            ),

            const SizedBox(height: 16),

            _buildSearchBar(),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, i) {
                  final item = filteredItems[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nama,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Harga: Rp ${item.harga} | Stock: ${item.stock}",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: iconColor),
                          onPressed: () => _addOrEditItem(item: item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: dangerColor),
                          onPressed: () => _deleteItem(item.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // WIDGETS
  Widget _buildInput(
    String label,
    TextEditingController c, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSummary(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: textColor)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Cari Barang...",
                hintStyle: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
