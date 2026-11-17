import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';

class UmkmController extends GetxController {
  final UmkmService _service = UmkmService();

  // Reactive state variables
  var umkmList = <Umkm>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var responseMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUmkm();
  }

  void _showNotification(String title, String message, {bool isError = false}) {
    if (Get.testMode || Get.overlayContext == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  // GET: Mengambil daftar UMKM
  Future<void> fetchUmkm() async {
    try {
      isLoading(true);
      final result = await _service.getUmkmList();
      umkmList.assignAll(result);
      responseMessage.value = 'Data UMKM berhasil dimuat';
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      responseMessage.value = 'Error: $msg';
      _showNotification('Gagal Memuat Data', msg, isError: true);
    } finally {
      isLoading(false);
    }
  }

  // POST: Menambahkan UMKM baru
  Future<bool> createUmkm({
    required String nama,
    String? kategori,
    String? pemilik,
    String? alamat,
    String? kontak,
  }) async {
    if (nama.trim().isEmpty) {
      _showNotification('Validasi Gagal', 'Nama UMKM wajib diisi', isError: true);
      return false;
    }

    try {
      isSaving(true);
      responseMessage('');

      final result = await _service.createUmkm({
        'nama_umkm': nama.trim(),
        'kategori': kategori?.trim() ?? '',
        'pemilik': pemilik?.trim() ?? '',
        'alamat': alamat?.trim() ?? '',
        'kontak': kontak?.trim() ?? '',
      });

      responseMessage.value = result['message'] ?? 'Data berhasil ditambahkan';
      _showNotification('Berhasil', responseMessage.value);

      // Refresh data list
      await fetchUmkm();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      responseMessage.value = 'Error: $msg';
      _showNotification('Error', msg, isError: true);
      return false;
    } finally {
      isSaving(false);
    }
  }

  // PUT: Memperbarui UMKM berdasarkan ID
  Future<bool> updateUmkm({
    required int id,
    required String nama,
    String? kategori,
    String? pemilik,
    String? alamat,
    String? kontak,
  }) async {
    if (nama.trim().isEmpty) {
      _showNotification('Validasi Gagal', 'Nama UMKM wajib diisi', isError: true);
      return false;
    }

    try {
      isSaving(true);
      responseMessage('');

      final result = await _service.updateUmkm(id, {
        'nama_umkm': nama.trim(),
        'kategori': kategori?.trim() ?? '',
        'pemilik': pemilik?.trim() ?? '',
        'alamat': alamat?.trim() ?? '',
        'kontak': kontak?.trim() ?? '',
      });

      responseMessage.value = result['message'] ?? 'Data berhasil diperbarui';
      _showNotification('Berhasil', responseMessage.value);

      // Refresh data list
      await fetchUmkm();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      responseMessage.value = 'Error: $msg';
      _showNotification('Error', msg, isError: true);
      return false;
    } finally {
      isSaving(false);
    }
  }

  // DELETE: Menghapus UMKM berdasarkan ID
  Future<void> deleteUmkm(int id, String nama) async {
    try {
      isLoading(true);
      final result = await _service.deleteUmkm(id);
      final msg = result['message'] ?? 'Data $nama berhasil dihapus';

      _showNotification('Dihapus', msg);
      await fetchUmkm();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showNotification('Error', msg, isError: true);
    } finally {
      isLoading(false);
    }
  }
}
