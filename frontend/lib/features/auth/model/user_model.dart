class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool hasResume;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.hasResume = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      hasResume: map['hasResume'] ?? false,
    );
  }
}
