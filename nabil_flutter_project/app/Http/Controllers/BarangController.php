<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;

class BarangController extends Controller
{
    public function index()
    {
        return Barang::all();
    }

    public function show($id)
    {
        return Barang::findOrFail($id);
    }

    public function store(Request $request)
    {
        $data = $request->all();
        return Barang::create($data);
    }

    public function update(Request $request, $id)
    {
        $update = Barang::findOrFail($id);
        $update->update($request->all());
        return $update;
    }

    public function destroy($id)
    {
        Barang::destroy($id);
        return response()->json(['message' => 'Data berhasil dihapus']);
    }
}