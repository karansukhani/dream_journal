class UserData {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserData({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: DateTime.parse(json['last_login'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }

  UserData copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
