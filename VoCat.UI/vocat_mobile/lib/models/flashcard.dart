class Flashcard {
  final String id;
  final String front;
  final String back;
  final String? folderId; // null means root level
  final String? pronunciation;
  final DateTime lastReviewed;
  int repetitionLevel;
  bool isMemorized;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.folderId,
    this.pronunciation,
    DateTime? lastReviewed,
    this.repetitionLevel = 0,
    this.isMemorized = false,
  }) : lastReviewed = lastReviewed ?? DateTime.now();

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      front: json['front'],
      back: json['back'],
      folderId: json['folderId'],
      pronunciation: json['pronunciation'],
      lastReviewed: DateTime.parse(json['lastReviewed']),
      repetitionLevel: json['repetitionLevel'],
      isMemorized: json['isMemorized'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'folderId': folderId,
      'pronunciation': pronunciation,
      'lastReviewed': lastReviewed.toIso8601String(),
      'repetitionLevel': repetitionLevel,
      'isMemorized': isMemorized,
    };
  }

  Flashcard copyWith({
    String? front,
    String? back,
    String? folderId,
    String? pronunciation,
    DateTime? lastReviewed,
    int? repetitionLevel,
    bool? isMemorized,
  }) {
    return Flashcard(
      id: id,
      front: front ?? this.front,
      back: back ?? this.back,
      folderId: folderId ?? this.folderId,
      pronunciation: pronunciation ?? this.pronunciation,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      repetitionLevel: repetitionLevel ?? this.repetitionLevel,
      isMemorized: isMemorized ?? this.isMemorized,
    );
  }
}
