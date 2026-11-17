import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:umkm_api/app/controllers/umkm_controller.dart';
import 'package:umkm_api/app/models/umkm_model.dart';
import 'package:umkm_api/app/views/umkm_form_page.dart';

void main() {
  testWidgets('UmkmFormPage renders all required input fields', (WidgetTester tester) async {
    // Register controller for GetX
    Get.put(UmkmController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: UmkmFormPage(),
      ),
    );

    expect(find.text('Tambah UMKM'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('Nama UMKM *'), findsOneWidget);
    expect(find.text('Nama Pemilik'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Kontak / No. HP'), findsOneWidget);
    expect(find.text('Simpan Data'), findsOneWidget);
  });

  testWidgets('UmkmFormPage in edit mode populates fields with existing data', (WidgetTester tester) async {
    final existingUmkm = Umkm(
      id: 99,
      namaUmkm: 'Bakso Barokah',
      pemilik: 'Pak Joko',
      alamat: 'Jl. Melati No. 5',
      kategori: 'Kuliner',
      kontak: '0812345678',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: UmkmFormPage(umkm: existingUmkm),
      ),
    );

    expect(find.text('Edit Data UMKM'), findsOneWidget);
    expect(find.text('Bakso Barokah'), findsOneWidget);
    expect(find.text('Pak Joko'), findsOneWidget);
    expect(find.text('Kuliner'), findsOneWidget);
    expect(find.text('Jl. Melati No. 5'), findsOneWidget);
    expect(find.text('0812345678'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
