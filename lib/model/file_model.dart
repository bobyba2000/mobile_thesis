import 'dart:convert';

import 'package:crypto/crypto.dart';

class FileModel {
  String name;
  String? size;
  String timeCreate;

  FileModel({
    required this.name,
    this.size,
    required this.timeCreate,
  });

  factory FileModel.fromJson(dynamic json) {
    final name = json['name'] as String;
    final timeCreate = json['timeCreate'] as String;
    final size = json['size'] as String?;
    return FileModel(
      name: name,
      timeCreate: timeCreate,
      size: size,
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
      };
}
