import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/umkm_controller.dart';
import 'umkm_form_page.dart';

class UmkmView extends StatelessWidget {
  const UmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller GetX
    final controller = Get.put(UmkmController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar UMKM'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () => controller.fetchUmkm(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.umkmList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.umkmList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined, size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada data UMKM',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchUmkm(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUmkm,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: controller.umkmList.length,
            itemBuilder: (context, index) {
              final item = controller.umkmList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          item.id != null ? '${item.id}' : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaUmkm,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.kategori != null && item.kategori!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  item.kategori!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            if (item.pemilik != null && item.pemilik!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Pemilik: ${item.pemilik}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (item.alamat != null && item.alamat!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.alamat!,
                                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (item.kontak != null && item.kontak!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.kontak!,
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit UMKM',
                            onPressed: () {
                              Get.to(() => UmkmFormPage(umkm: item));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Hapus UMKM',
                            onPressed: () {
                              _confirmDelete(context, controller, item.id!, item.namaUmkm);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah UMKM Baru',
        onPressed: () {
          Get.to(() => const UmkmFormPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UmkmController controller, int id, String nama) {
    Get.defaultDialog(
      title: 'Hapus UMKM',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Apakah Anda yakin ingin menghapus data "$nama"?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Tutup dialog
        controller.deleteUmkm(id, nama);
      },
    );
  }
}
