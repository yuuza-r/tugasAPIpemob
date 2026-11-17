<?php

namespace App\Controllers\Api;

use App\Models\UmkmModel;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\RESTful\ResourceController;

class UmkmController extends ResourceController
{
    protected $modelName = 'App\Models\UmkmModel';
    protected $format    = 'json';

    /**
     * GET /api/umkm
     * Mengambil semua daftar UMKM
     */
    public function index(): ResponseInterface
    {
        $umkmModel = new UmkmModel();
        $umkm = $umkmModel->orderBy('id', 'DESC')->findAll();

        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil diambil',
            'data'    => $umkm,
        ], 200);
    }

    /**
     * GET /api/umkm/{id}
     * Mengambil detail satu UMKM
     */
    public function show($id = null): ResponseInterface
    {
        $umkmModel = new UmkmModel();
        $data = $umkmModel->find($id);

        if (!$data) {
            return $this->respond([
                'success' => false,
                'message' => 'Data UMKM tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        return $this->respond([
            'success' => true,
            'message' => 'Detail data UMKM berhasil diambil',
            'data'    => $data,
        ], 200);
    }

    /**
     * POST /api/umkm
     * Menambahkan data UMKM baru
     */
    public function create(): ResponseInterface
    {
        $validation = \Config\Services::validation();

        $rules = [
            'nama_umkm' => 'required|min_length[3]|is_unique[umkm.nama_umkm]',
            'kategori'  => 'permit_empty|string',
            'pemilik'   => 'permit_empty|string',
            'alamat'    => 'permit_empty|string',
            'kontak'    => 'permit_empty|string',
        ];

        // Mendukung request via JSON body maupun Form Data secara aman
        $data = null;
        try {
            $data = $this->request->getJSON(true);
        } catch (\Throwable $e) {
            $data = null;
        }

        if (empty($data)) {
            $data = $this->request->getPost();
        }

        if (empty($data)) {
            $data = $this->request->getRawInput();
        }

        if (!$validation->setRules($rules)->run($data ?? [])) {
            return $this->respond([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validation->getErrors(),
            ], 400);
        }

        $umkmModel = new UmkmModel();
        $insertedId = $umkmModel->insert($data);

        if ($insertedId === false) {
            return $this->respond([
                'success' => false,
                'message' => 'Gagal menambahkan data UMKM',
                'errors'  => $umkmModel->errors(),
            ], 500);
        }

        $newData = $umkmModel->find($insertedId);

        return $this->respondCreated([
            'success' => true,
            'message' => 'Data UMKM berhasil ditambahkan',
            'data'    => $newData,
        ]);
    }

    /**
     * PUT /api/umkm/{id}
     * Memperbarui data UMKM yang ada
     */
    public function update($id = null): ResponseInterface
    {
        $umkmModel = new UmkmModel();
        $existing = $umkmModel->find($id);

        if (!$existing) {
            return $this->respond([
                'success' => false,
                'message' => 'Data UMKM tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        // Mendukung update via JSON body maupun x-www-form-urlencoded secara aman
        $data = null;
        try {
            $data = $this->request->getJSON(true);
        } catch (\Throwable $e) {
            $data = null;
        }

        if (empty($data)) {
            $data = $this->request->getRawInput();
        }

        if (empty($data)) {
            $data = $this->request->getPost();
        }

        $validation = \Config\Services::validation();
        $rules = [
            'nama_umkm' => "required|min_length[3]|is_unique[umkm.nama_umkm,id,{$id}]",
            'kategori'  => 'permit_empty|string',
            'pemilik'   => 'permit_empty|string',
            'alamat'    => 'permit_empty|string',
            'kontak'    => 'permit_empty|string',
        ];

        if (!$validation->setRules($rules)->run($data ?? [])) {
            return $this->respond([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validation->getErrors(),
            ], 400);
        }

        $umkmModel->update($id, $data);
        $updatedData = $umkmModel->find($id);

        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil diperbarui',
            'data'    => $updatedData,
        ], 200);
    }

    /**
     * DELETE /api/umkm/{id}
     * Menghapus data UMKM
     */
    public function delete($id = null): ResponseInterface
    {
        $umkmModel = new UmkmModel();
        $data = $umkmModel->find($id);

        if (!$data) {
            return $this->respond([
                'success' => false,
                'message' => 'Data UMKM tidak ditemukan',
            ], 404);
        }

        $umkmModel->delete($id);

        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil dihapus',
            'data'    => $data,
        ], 200);
    }
}
