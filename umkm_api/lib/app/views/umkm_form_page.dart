import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/umkm_controller.dart';
import '../models/umkm_model.dart';

class UmkmFormPage extends StatefulWidget {
  final Umkm? umkm;

  const UmkmFormPage({super.key, this.umkm});

  @override
  State<UmkmFormPage> createState() => _UmkmFormPageState();
}

class _UmkmFormPageState extends State<UmkmFormPage> {
  final UmkmController controller = Get.find<UmkmController>();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController namaC;
  late final TextEditingController pemilikC;
  late final TextEditingController alamatC;
  late final TextEditingController kategoriC;
  late final TextEditingController kontakC;

  bool get isEdit => widget.umkm != null;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.umkm?.namaUmkm ?? '');
    pemilikC = TextEditingController(text: widget.umkm?.pemilik ?? '');
    alamatC = TextEditingController(text: widget.umkm?.alamat ?? '');
    kategoriC = TextEditingController(text: widget.umkm?.kategori ?? '');
    kontakC = TextEditingController(text: widget.umkm?.kontak ?? '');
  }

  @override
  void dispose() {
    namaC.dispose();
    pemilikC.dispose();
    alamatC.dispose();
    kategoriC.dispose();
    kontakC.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (isEdit) {
      success = await controller.updateUmkm(
        id: widget.umkm!.id!,
        nama: namaC.text,
        pemilik: pemilikC.text,
        alamat: alamatC.text,
        kategori: kategoriC.text,
        kontak: kontakC.text,
      );
    } else {
      success = await controller.createUmkm(
        nama: namaC.text,
        pemilik: pemilikC.text,
        alamat: alamatC.text,
        kategori: kategoriC.text,
        kontak: kontakC.text,
      );
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Data UMKM' : 'Tambah UMKM'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: namaC,
                decoration: const InputDecoration(
                  labelText: 'Nama UMKM *',
                  hintText: 'Contoh: Kopi Nusantara',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama UMKM wajib diisi';
                  }
                  if (val.trim().length < 3) {
                    return 'Nama UMKM minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: pemilikC,
                decoration: const InputDecoration(
                  labelText: 'Nama Pemilik',
                  hintText: 'Contoh: Rafi A',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: kategoriC,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Contoh: Kuliner, Fashion, Kerajinan',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: alamatC,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  hintText: 'Contoh: Jl. A. Yani No. 10',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: kontakC,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Kontak / No. HP',
                  hintText: 'Contoh: 08123456789',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isSaving.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(
                    isEdit ? 'Simpan Perubahan' : 'Simpan Data',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.responseMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                final isErr = controller.responseMessage.value.startsWith('Error');
                return Center(
                  child: Text(
                    controller.responseMessage.value,
                    style: TextStyle(
                      color: isErr ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
