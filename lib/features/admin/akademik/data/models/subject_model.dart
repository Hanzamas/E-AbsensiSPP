class SubjectModel {
  final int? id;
  final String nama;
  final String deskripsi;

  SubjectModel({
    this.id,
    required this.nama,
    required this.deskripsi,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
    };
  }

  // Add method for create request
  Map<String, dynamic> toCreateJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
    };
  }

  // Add method for update request
  Map<String, dynamic> toUpdateJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
    };
  }

  SubjectModel copyWith({
    int? id,
    String? nama,
    String? deskripsi,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
    );
  }
}
