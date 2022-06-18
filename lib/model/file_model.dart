import 'dart:convert';

import 'package:crypto/crypto.dart';

class FileModel {
  String name;
  String? size;
  String timeCreate;
  String location;
  String ownerId;

  FileModel({
    required this.name,
    this.size,
    required this.timeCreate,
    required this.location,
    required this.ownerId,
  });

  factory FileModel.fromJson(dynamic json) {
    final name = json['name'] as String;
    final timeCreate = json['timeCreate'] as String;
    final size = json['size'] as String?;
    final ownerId = json['ownerId'] as String;
    final location = json['location'] as String;
    return FileModel(
      name: name,
      timeCreate: timeCreate,
      size: size,
      location: location,
      ownerId: ownerId,
    );
  }

  String getSavedName() => '${getHash()}.${getFileExt()}';

  String getFileExt() => name.split(".").last;

  String getFileNameOnly() => name.split(".").first;

  String getHash() => sha1
      .convert(
        utf8.encode(name + timeCreate),
      )
      .toString();

  static List<FileModel> listFromJson(List<Map<String, dynamic>> data) {
    return data.map((e) => FileModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'timeCreate': timeCreate,
        'size': size,
        'location': location,
        'ownerId': ownerId,
      };
}
