import 'package:mobile_v2/model/user_model.dart';

class ServerModel {
  final String url;
  final UserModel owner;
  String? description;
  String status;
  String? location;
  String ownerId;
  int requestNumber;
  int requestDownload;
  int requestUpload;
  double responseTime;
  double responseDownloadTime;
  double responseUploadTime;
  int unresponse;

  ServerModel({
    this.description,
    required this.url,
    required this.owner,
    this.location,
    required this.status,
    required this.ownerId,
    required this.requestDownload,
    required this.requestNumber,
    required this.requestUpload,
    required this.responseDownloadTime,
    required this.responseTime,
    required this.responseUploadTime,
    required this.unresponse,
  });

  factory ServerModel.fromJson(dynamic json) {
    return ServerModel(
      url: json['url'],
      status: json['status'],
      description: json['description'],
      location: json['location'],
      owner: UserModel.fromJson(json['owner']),
      ownerId: json['ownerId'],
      requestDownload: int.tryParse(json['requestDownload'].toString()) ?? 0,
      requestNumber: int.tryParse(json['requestNumber'].toString()) ?? 0,
      requestUpload: int.tryParse(json['requestUpload'].toString()) ?? 0,
      responseDownloadTime:
          double.tryParse(json['responseDownloadTime'].toString()) ?? 0,
      responseTime: double.tryParse(json['responseTime'].toString()) ?? 0,
      responseUploadTime:
          double.tryParse(json['responseUploadTime'].toString()) ?? 0,
      unresponse: int.tryParse(json['unresponse'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'status': status,
      'description': description,
      'location': location,
      'owner': owner.toJson(),
      'ownerId': ownerId,
      'requestDownload': requestDownload,
      'requestNumber': requestNumber,
      'requestUpload': requestUpload,
      'responseDownloadTime': responseDownloadTime,
      'responseTime': responseTime,
      'responseUploadTime': responseUploadTime,
      'unresponse': unresponse,
    };
  }
}
