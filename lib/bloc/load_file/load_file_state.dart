import 'package:equatable/equatable.dart';
import 'package:mobile_v2/model/file_model.dart';

class LoadFileState extends Equatable {
  final bool? isUploadSuccess;
  final List<bool>? listStatus;
  final List<FileModel>? listFiles;
  final String? textSearch;
  final bool? isDownloadSuccess;
  final String? userName;
  final String? phoneNumber;
  final String? location;
  final bool? isServer;
  final bool isLocationActive;
  final String? errorMessage;

  const LoadFileState({
    this.isUploadSuccess,
    this.listStatus,
    this.listFiles,
    this.textSearch,
    this.isDownloadSuccess,
    this.userName,
    this.phoneNumber,
    this.location,
    this.isServer,
    this.isLocationActive = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        listStatus,
        isUploadSuccess,
        listFiles,
        textSearch,
        isDownloadSuccess,
        userName,
        phoneNumber,
        location,
        isLocationActive,
      ];

  bool isRequestDone() =>
      !(listStatus?.any((element) => element == false) ?? true);

  LoadFileState copyWith({
    bool? isUploadSuccess,
    List<FileModel>? listFiles,
    List<bool>? listStatus,
    bool? isDownloadSuccess,
    String? textSearch,
    String? userName,
    String? phoneNumber,
    String? location,
    bool? isServer,
    bool? isLocationActive,
    String? errorMessage,
  }) {
    return LoadFileState(
      isUploadSuccess: isUploadSuccess ?? this.isUploadSuccess,
      listFiles: listFiles ?? this.listFiles,
      textSearch: textSearch ?? textSearch,
      listStatus: listStatus ?? this.listStatus,
      isDownloadSuccess: isDownloadSuccess ?? this.isDownloadSuccess,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      isServer: isServer ?? this.isServer,
      isLocationActive: isLocationActive ?? this.isLocationActive,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
