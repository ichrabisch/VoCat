class Word {
  final String wordId;
  final String wordText;
  final String translation;
  final String? definition;
  final String? exampleSentence;
  final String folderId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int masteryLevel;
  final DateTime lastReviewed;
  final bool isFromRecognition;
  final String? base64Image;
  final String? imageUrl;

  Word({
    required this.wordId,
    required this.wordText,
    required this.translation,
    this.definition,
    this.exampleSentence,
    required this.folderId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.masteryLevel = 1,
    required this.lastReviewed,
    this.isFromRecognition = false,
    this.base64Image,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    "wordContract": {
      "wordId": wordId,
      "wordText": wordText,
      "translation": translation,
      "definition": definition,
      "exampleSentence": exampleSentence,
      "folderId": folderId,
      "userId": userId,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "masteryLevel": masteryLevel,
      "lastReviewed": lastReviewed.toIso8601String(),
      "isFromRecognition": isFromRecognition,
    },
    "imageContract": base64Image != null ? {"base64Image": base64Image} : null,
  };

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      wordId: json['wordId'],
      wordText: json['wordText'],
      translation: json['translation'],
      definition: json['definition'],
      exampleSentence: json['exampleSentence'],
      folderId: json['folderId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      masteryLevel: json['masteryLevel'],
      lastReviewed:
          json['lastReviewed'] != null
              ? DateTime.parse(json['lastReviewed'])
              : DateTime.now(),
      isFromRecognition: json['isFromRecognition'],
      imageUrl: json['imageUrl'],
    );
  }

  Word copyWith({
    String? wordId,
    String? wordText,
    String? translation,
    String? definition,
    String? exampleSentence,
    String? folderId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? masteryLevel,
    DateTime? lastReviewed,
    bool? isFromRecognition,
    String? imageUrl,
  }) {
    return Word(
      wordId: wordId ?? this.wordId,
      wordText: wordText ?? this.wordText,
      translation: translation ?? this.translation,
      definition: definition ?? this.definition,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      folderId: folderId ?? this.folderId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      isFromRecognition: isFromRecognition ?? this.isFromRecognition,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
