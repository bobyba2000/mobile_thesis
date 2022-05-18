import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile_v2/bloc/load_file/load_file_state.dart';
import 'package:mobile_v2/constants.dart';
import 'package:mobile_v2/model/file_model.dart';
import 'package:mobile_v2/model/server_model.dart';

class LoadFileBloc extends Cubit<LoadFileState> {
  LoadFileBloc() : super(const LoadFileState());

  void onSearch(String textSearch) {
    emit(
      state.copyWith(
        textSearch: textSearch,
      ),
    );
  }

  Future<void> getListFile() async {
    EasyLoading.show();
    DataSnapshot response = await FirebaseDatabase.instance
        .ref('files')
        .orderByChild('ownerId')
        .equalTo(FirebaseAuth.instance.currentUser?.uid)
        .get();
    List<FileModel> listItem =
        response.children.map((e) => FileModel.fromJson(e.value)).toList();
    EasyLoading.dismiss();
    emit(state.copyWith(listFiles: listItem));
  }

  Future<List<FileModel>> loadListFile(int pageIndex, int pageSize) async {
    List<FileModel> listItem = [];
    if (state.listFiles == null) {
      await getListFile();
    }
    listItem = state.listFiles ?? [];

    return listItem
        .where((element) => element.name.contains(state.textSearch ?? ''))
        .toList()
        .sublist(
            pageIndex * pageSize,
            (pageIndex * pageSize + pageSize) > listItem.length
                ? listItem.length
                : pageIndex * pageSize + pageSize);
  }

  Future<List<ServerModel>> loadListServer(int pageIndex) async {
    final List<ServerModel> result = [
      ServerModel(
          name: 'Server 1', numberOfFile: 10, timeCreate: DateTime.now()),
      ServerModel(
          name: 'Server 2', numberOfFile: 10, timeCreate: DateTime.now()),
      ServerModel(
          name: 'Server 3', numberOfFile: 10, timeCreate: DateTime.now()),
      ServerModel(
          name: 'Server 4', numberOfFile: 10, timeCreate: DateTime.now()),
    ];
    return result;
  }

  Future<void> uploadFile(
    PlatformFile file,
  ) async {
    EasyLoading.show();
    emit(
      state.copyWith(
        isUploadSuccess: false,
        listStatus: AppConstants.listUrl.map((e) => false).toList(),
      ),
    );
    Uint8List bytes = kIsWeb
        ? (file.bytes ?? Uint8List.fromList([]))
        : await (File(file.path ?? '').readAsBytes());

    FileModel fileModel = FileModel(
      name: file.name,
      timeCreate: DateFormat('dd/MM/y hh:mm').format(DateTime.now()),
      size: '${((bytes.length) / 1024).round()} kb',
      ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    for (var i = 0; i < AppConstants.listUrl.length; i++) {
      _sendRequestUpload(i, file, fileModel);
    }
  }

  Future<void> _sendRequestUpload(
      int urlIndex, PlatformFile file, FileModel fileModel) async {
    final String url = AppConstants.listUrl[urlIndex];
    Uint8List bytes = kIsWeb
        ? (file.bytes ?? Uint8List.fromList([]))
        : await (File(file.path ?? '').readAsBytes());
    final request = MultipartRequest(
      "POST",
      Uri.parse('${url}upload'),
    )
      ..fields['hash'] = fileModel.getHash()
      ..files.add(
        MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );
    final response = await request.send();

    if (response.statusCode == 200 && state.isUploadSuccess != true) {
      DatabaseReference ref = FirebaseDatabase.instance.ref('files');
      ref.push().set(fileModel.toJson());
      EasyLoading.dismiss();
      emit(
        state.copyWith(
          isUploadSuccess: true,
          listStatus: AppConstants.listUrl
              .asMap()
              .entries
              .map((e) =>
                  e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
              .toList(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          listStatus: AppConstants.listUrl
              .asMap()
              .entries
              .map((e) =>
                  e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
              .toList(),
        ),
      );
    }
  }

  Future<void> downloadFile(FileModel fileModel) async {
    EasyLoading.show();
    emit(
      state.copyWith(
        isDownloadSuccess: false,
        listStatus: AppConstants.listUrl.map((e) => false).toList(),
      ),
    );
    for (var i = 0; i < AppConstants.listUrl.length; i++) {
      _sendRequestDownload(i, fileModel);
    }
  }

  Future<void> _sendRequestDownload(int urlIndex, FileModel fileModel) async {
    final String url = AppConstants.listUrl[urlIndex];
    if (state.isDownloadSuccess == true) {
      return;
    }
    final request = MultipartRequest(
      "GET",
      Uri.parse(
          '${url}download?hash=${fileModel.getHash()}&fileName=${fileModel.getSavedName()}'),
    );
    final response = await request.send();
    if (response.statusCode == 200 && state.isDownloadSuccess != true) {
      emit(
        state.copyWith(
          isDownloadSuccess: true,
          listStatus: AppConstants.listUrl
              .asMap()
              .entries
              .map((e) =>
                  e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
              .toList(),
        ),
      );
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          fileModel.name,
          await response.stream.toBytes(),
          fileModel.getFileExt(),
        );
      } else {
        await FileSaver.instance.saveAs(
            fileModel.getFileNameOnly(),
            await response.stream.toBytes(),
            fileModel.getFileExt(),
            MimeType.OTHER);
      }
      EasyLoading.dismiss();
    } else {
      emit(
        state.copyWith(
          listStatus: AppConstants.listUrl
              .asMap()
              .entries
              .map((e) =>
                  e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
              .toList(),
        ),
      );
    }
  }

  Future<void> closeRequest() async {
    EasyLoading.dismiss();
    emit(
      state.copyWith(
        listStatus: [],
        isUploadSuccess: false,
        isDownloadSuccess: false,
      ),
    );
    await getListFile();
  }
}
