import 'package:equatable/equatable.dart';
import 'package:mobile_v2/model/file_model.dart';

class LoadFileState extends Equatable {
  final bool? isUploadSuccess;
  final List<bool>? listStatus;
  final List<FileModel>? listFiles;
  final String? textSearch;
  final bool? isDownloadSuccess;

  const LoadFileState({
    this.isUploadSuccess,
    this.listStatus,
    this.listFiles,
    this.textSearch,
    this.isDownloadSuccess,
  });

  @override
  List<Object?> get props => [
        listStatus,
        isUploadSuccess,
        listFiles,
        textSearch,
        isDownloadSuccess,
      ];

  bool isRequestDone() =>
      !(listStatus?.any((element) => element == false) ?? true);

  LoadFileState copyWith({
    bool? isUploadSuccess,
    List<FileModel>? listFiles,
    List<bool>? listStatus,
    bool? isDownloadSuccess,
    String? textSearch,
  }) {
    return LoadFileState(
      isUploadSuccess: isUploadSuccess ?? this.isUploadSuccess,
      listFiles: listFiles ?? this.listFiles,
      textSearch: textSearch ?? textSearch,
      listStatus: listStatus ?? this.listStatus,
      isDownloadSuccess: isDownloadSuccess ?? this.isDownloadSuccess,
    );
  }
}
