import 'package:mobile_v2/model/server_model.dart';

class LocationModel {
  String name;
  List<ServerModel>? listServers;
  String status;
  String description;
  LocationModel? parent;

  LocationModel({
    required this.name,
    required this.listServers,
    required this.status,
    required this.description,
    required this.parent,
  });

  factory LocationModel.fromJson(dynamic json) {
    return LocationModel(
      name: json['name'] as String,
      listServers: (json['listServers'] as List?)
          ?.map((e) => ServerModel.fromJson(e))
          .toList(),
      status: json['status'] as String,
      description: json['description'] as String,
      parent: json['parent'] != null
          ? LocationModel.fromJson(
              json['parent'],
            )
          : null,
    );
  }

  Map toJson() {
    return {
      'name': name,
      'listServer': listServers?.map((e) => e.toJson()).toList(),
      'status': status,
      'description': description,
      'parent': parent?.toJson(),
    };
  }
}
