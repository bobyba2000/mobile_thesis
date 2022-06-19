class UserModel {
  String name;
  String phoneNumber;
  String? imageUrl;
  String email;
  // String id;

  UserModel({
    required this.imageUrl,
    required this.name,
    required this.phoneNumber,
    required this.email,
    // required this.id,
  });

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
      imageUrl: json['imageUrl'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      // id: json['id'],
    );
  }

  Map toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      // 'id': id,
    };
  }
}
