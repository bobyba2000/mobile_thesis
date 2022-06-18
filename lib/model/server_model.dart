import 'package:mobile_v2/model/user_model.dart';

class ServerModel {
  final String url;
  final UserModel owner;
  String? description;
  String status;
  String? location;
  String ownerId;

  ServerModel({
    this.description,
    required this.url,
    required this.owner,
    this.location,
    required this.status,
    required this.ownerId,
  });

  factory ServerModel.fromJson(dynamic json) {
    print(json);
    return ServerModel(
      url: json['url'],
      status: json['status'],
      description: json['description'],
      location: json['location'],
      owner: UserModel.fromJson(json['owner']),
      ownerId: json['ownerId'],
    );
  }

  Map toJson() {
    return {
      'url': url,
      'status': status,
      'description': description,
      'location': location,
      'owner': owner.toJson(),
      'ownerId': ownerId,
    };
  }
}
