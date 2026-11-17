import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_api/app/models/umkm_model.dart';
import 'package:umkm_api/app/services/umkm_service.dart';

void main() {
  group('UMKM Model Unit Tests', () {
    test('fromJson and toJson should correctly parse UMKM data', () {
      final jsonMap = {
        'id': 10,
        'nama_umkm': 'Warung Soto Banjar',
        'kategori': 'Kuliner',
        'pemilik': 'Haji Ijai',
        'alamat': 'Jl. Martapura Lama',
        'kontak': '081122334455',
        'created_at': '2026-11-17 10:00:00',
        'updated_at': '2026-11-17 10:00:00',
      };

      final umkm = Umkm.fromJson(jsonMap);

      expect(umkm.id, 10);
      expect(umkm.namaUmkm, 'Warung Soto Banjar');
      expect(umkm.kategori, 'Kuliner');
      expect(umkm.pemilik, 'Haji Ijai');
      expect(umkm.alamat, 'Jl. Martapura Lama');
      expect(umkm.kontak, '081122334455');

      final serialized = umkm.toJson();
      expect(serialized['id'], 10);
      expect(serialized['nama_umkm'], 'Warung Soto Banjar');
      expect(serialized['kategori'], 'Kuliner');
    });
  });

  group('UMKM REST API Live End-to-End Tests', () {
    final service = UmkmService(baseUrl: 'http://127.0.0.1:8080/api/');
    int? createdId;

    test('1. GET /api/umkm should return list', () async {
      final list = await service.getUmkmList();
      expect(list, isA<List<Umkm>>());
    });

    test('2. POST /api/umkm should create a new UMKM', () async {
      final newUmkmData = {
        'nama_umkm': 'Amuntai Itik Panggang ${DateTime.now().millisecondsSinceEpoch}',
        'kategori': 'Kuliner',
        'pemilik': 'Paman Birin',
        'alamat': 'Jl. Amuntai Raya No. 12',
        'kontak': '082155667788',
      };

      final response = await service.createUmkm(newUmkmData);
      expect(response['success'], true);
      expect(response['data'], isNotNull);

      createdId = int.tryParse(response['data']['id'].toString());
      expect(createdId, isNotNull);
    });

    test('3. PUT /api/umkm/{id} should update the created UMKM', () async {
      expect(createdId, isNotNull);

      final updateData = {
        'nama_umkm': 'Amuntai Itik Panggang Spesial ${DateTime.now().millisecondsSinceEpoch}',
        'kategori': 'Kuliner Tradisional',
        'pemilik': 'Paman Birin & Keluarga',
        'alamat': 'Jl. Amuntai Raya No. 12 Pusat',
        'kontak': '082155667799',
      };

      final response = await service.updateUmkm(createdId!, updateData);
      expect(response['success'], true);
      expect(response['data']['kategori'], 'Kuliner Tradisional');
    });

    test('4. DELETE /api/umkm/{id} should delete the UMKM', () async {
      expect(createdId, isNotNull);

      final response = await service.deleteUmkm(createdId!);
      expect(response['success'], true);
    });
  });
}
