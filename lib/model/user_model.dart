class UserModel {
  String name;
  String phoneNumber;
  String? imageUrl;
  // String id;

  UserModel({
    required this.imageUrl,
    required this.name,
    required this.phoneNumber,
    // required this.id,
  });

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
      imageUrl: json['imageUrl'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      // id: json['id'],
    );
  }

  Map toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'phoneNumber': phoneNumber,
      // 'id': id,
    };
  }
}
