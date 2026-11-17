class Umkm {
  final int? id;
  final String namaUmkm;
  final String? kategori;
  final String? pemilik;
  final String? alamat;
  final String? kontak;
  final String? createdAt;
  final String? updatedAt;

  Umkm({
    this.id,
    required this.namaUmkm,
    this.kategori,
    this.pemilik,
    this.alamat,
    this.kontak,
    this.createdAt,
    this.updatedAt,
  });

  factory Umkm.fromJson(Map<String, dynamic> json) {
    return Umkm(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      namaUmkm: json['nama_umkm']?.toString() ?? '',
      kategori: json['kategori']?.toString(),
      pemilik: json['pemilik']?.toString(),
      alamat: json['alamat']?.toString(),
      kontak: json['kontak']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama_umkm': namaUmkm,
      'kategori': kategori ?? '',
      'pemilik': pemilik ?? '',
      'alamat': alamat ?? '',
      'kontak': kontak ?? '',
    };
  }
}
