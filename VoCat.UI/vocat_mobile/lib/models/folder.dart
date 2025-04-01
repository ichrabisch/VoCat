class Folder {
  final String folderId;
  final String name;
  final String? parentFolderId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Folder({
    required this.folderId,
    required this.name,
    this.parentFolderId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      folderId: json['folderId'],
      name: json['name'],
      parentFolderId: json['parentFolderId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "folderContract": {
      "folderId": folderId,
      "name": name,
      "parentFolderId": parentFolderId?.toString(),
      "userId": userId,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    },
  };
}
