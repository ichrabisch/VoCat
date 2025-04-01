class ParagraphResult {
  final String id;
  final List<String> words;
  final String promptType;
  final String targetAudience;
  final String? paragraph;
  final DateTime createdAt;
  final bool isPending;

  ParagraphResult({
    required this.id,
    required this.words,
    required this.promptType,
    required this.targetAudience,
    this.paragraph,
    required this.createdAt,
    this.isPending = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'words': words,
    'promptType': promptType,
    'targetAudience': targetAudience,
    'paragraph': paragraph,
    'createdAt': createdAt.toIso8601String(),
    'isPending': isPending,
  };

  factory ParagraphResult.fromJson(Map<String, dynamic> json) =>
      ParagraphResult(
        id: json['id'],
        words: List<String>.from(json['words']),
        promptType: json['promptType'],
        targetAudience: json['targetAudience'],
        paragraph: json['paragraph'],
        createdAt: DateTime.parse(json['createdAt']),
        isPending: json['isPending'],
      );

  ParagraphResult copyWith({
    String? id,
    List<String>? words,
    String? promptType,
    String? targetAudience,
    String? paragraph,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return ParagraphResult(
      id: id ?? this.id,
      words: words ?? this.words,
      promptType: promptType ?? this.promptType,
      targetAudience: targetAudience ?? this.targetAudience,
      paragraph: paragraph ?? this.paragraph,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }
}
