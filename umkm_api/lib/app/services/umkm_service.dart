import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/umkm_model.dart';

class UmkmService {
  // Base URL otomatis mendeteksi platform (Web/Desktop -> localhost, Android -> 10.0.2.2)
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/';
      }
    } catch (_) {}
    return 'http://localhost:8080/api/';
  }

  final String baseUrl;

  UmkmService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  // METHOD GET: Mengambil daftar seluruh UMKM
  Future<List<Umkm>> getUmkmList() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}umkm'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => Umkm.fromJson(e)).toList();
      } else {
        final err = _extractErrorMessage(response.body);
        throw Exception(err.isNotEmpty ? err : 'Gagal mengambil data UMKM (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // METHOD POST: Menambahkan UMKM baru
  Future<Map<String, dynamic>> createUmkm(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}umkm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final err = _extractErrorMessage(response.body);
        throw Exception(err.isNotEmpty ? err : 'Gagal menambah data UMKM (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // METHOD PUT: Memperbarui data UMKM berdasarkan ID
  Future<Map<String, dynamic>> updateUmkm(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}umkm/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final err = _extractErrorMessage(response.body);
        throw Exception(err.isNotEmpty ? err : 'Gagal memperbarui data UMKM (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // METHOD DELETE: Menghapus data UMKM berdasarkan ID
  Future<Map<String, dynamic>> deleteUmkm(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}umkm/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final err = _extractErrorMessage(response.body);
        throw Exception(err.isNotEmpty ? err : 'Gagal menghapus data UMKM (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper untuk mengekstrak pesan error validasi/server dari response body
  String _extractErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map) {
        if (parsed['errors'] is Map) {
          final errMap = parsed['errors'] as Map;
          return errMap.values.join('\n');
        }
        if (parsed['message'] != null) {
          return parsed['message'].toString();
        }
      }
    } catch (_) {}
    return '';
  }
}
