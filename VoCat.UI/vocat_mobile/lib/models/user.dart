class User {
  final String email;
  final String passwordHash;
  final String preferredLanguage;
  final String userName;

  User({
    required this.email,
    required this.passwordHash,
    required this.preferredLanguage,
    required this.userName,
  });

  Map<String, dynamic> toJson() => {
    "userContract": {
      "email": email,
      "passwordHash": passwordHash,
      "preferredLanguage": preferredLanguage,
      "userName": userName,
    },
  };
}
