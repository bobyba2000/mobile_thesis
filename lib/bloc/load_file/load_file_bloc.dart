import 'dart:async';
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
import 'package:mobile_v2/model/file_model.dart';
import 'package:mobile_v2/model/location_model.dart';
import 'package:mobile_v2/model/server_model.dart';
import 'package:mobile_v2/preference/user_prefrence.dart';

class LoadFileBloc extends Cubit<LoadFileState> {
  LoadFileBloc() : super(const LoadFileState());

  void onSearch(String textSearch) {
    emit(
      state.copyWith(
        textSearch: textSearch,
      ),
    );
  }

  Future<void> setInfo({
    required bool isServer,
    required String location,
    String? url,
    String? phoneNumber,
  }) async {
    await UserPrefrence.setIsServer(isServer);
    await UserPrefrence.setLocation(location);
    await UserPrefrence.setUrl(url ?? '');
    UserPrefrence.setPhoneNumber(phoneNumber ?? '');
  }

  Future<void> loadInfo() async {
    final server = await FirebaseDatabase.instance
        .ref('servers')
        .orderByChild('ownerId')
        .equalTo(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (server.exists) {
      final model = ServerModel.fromJson(
          (server.value as Map<String, dynamic>).values.first);
      setInfo(
        isServer: true,
        location: model.location ?? '',
        url: model.url,
        phoneNumber: model.owner.phoneNumber,
      );
    } else {
      DataSnapshot client = await FirebaseDatabase.instance
          .ref('client')
          .orderByChild('clientId')
          .equalTo(FirebaseAuth.instance.currentUser?.uid)
          .get();
      await setInfo(
          isServer: false,
          location:
              (client.value as Map<String, dynamic>).values.first['location'] ??
                  '');
    }
  }

  Future<void> getListFile() async {
    EasyLoading.show();
    await loadInfo();
    String? location = await UserPrefrence.location;

    bool isActive = false;

    String? errorMessage;
    if (location != null && location != '') {
      DataSnapshot locationResponse = await FirebaseDatabase.instance
          .ref('locations')
          .orderByChild('name')
          .equalTo(location)
          .get();
      LocationModel locationModel = LocationModel.fromJson(
          (locationResponse.value as Map<String, dynamic>).values.first);
      isActive = locationModel.status == 'Active';
      if (locationModel.status == 'Inactive') {
        errorMessage = 'Your location is inactive now';
      } else if (locationModel.status == 'Pending') {
        errorMessage = 'Your location is pending now';
      }
    } else {
      errorMessage = 'Your server is still Pending. Please wait.';
    }
    DataSnapshot response = await FirebaseDatabase.instance
        .ref('files')
        .orderByChild('ownerId')
        .equalTo(FirebaseAuth.instance.currentUser?.uid)
        .get();
    List<FileModel> listItem =
        response.children.map((e) => FileModel.fromJson(e.value)).toList();
    EasyLoading.dismiss();
    emit(
      state.copyWith(
        listFiles: listItem,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        isServer: await UserPrefrence.isServer,
        isLocationActive: isActive,
        errorMessage: errorMessage,
      ),
    );
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

  Future<List<String>> loadListServers() async {
    DataSnapshot response = await FirebaseDatabase.instance
        .ref('servers')
        .orderByChild('location')
        .equalTo(await UserPrefrence.location)
        .get();
    List<ServerModel> listServer =
        response.children.map((e) => ServerModel.fromJson(e.value)).toList();
    return listServer.map((e) => e.url).toList();
  }

  Future<void> uploadFile(
    PlatformFile file,
  ) async {
    List<String> listServers = await loadListServers();
    EasyLoading.show();
    emit(
      state.copyWith(
        isUploadSuccess: false,
        listStatus: listServers.map((e) => false).toList(),
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
      location: (await UserPrefrence.location) ?? '',
    );
    for (var i = 0; i < listServers.length; i++) {
      _sendRequestUpload(i, file, fileModel, listServers);
    }
  }

  Future<void> _sendRequestUpload(int urlIndex, PlatformFile file,
      FileModel fileModel, List<String> urls) async {
    final String url = urls[urlIndex];
    Uint8List bytes = kIsWeb
        ? (file.bytes ?? Uint8List.fromList([]))
        : await (File(file.path ?? '').readAsBytes());
    final request = MultipartRequest(
      "POST",
      Uri.parse('$url/upload'),
    )
      ..fields['hash'] = fileModel.getHash()
      ..files.add(
        MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );
    DateTime start = DateTime.now();
    final response = await request
        .send()
        .timeout(const Duration(milliseconds: 5000), onTimeout: () {
      return StreamedResponse(Stream.value([]), 408);
    }).onError((error, stackTrace) => StreamedResponse(Stream.value([]), 500));
    DateTime end = DateTime.now();
    int timeResponse =
        end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    updateServerInfo(response.statusCode, timeResponse, url, false);

    if (response.statusCode == 200 && state.isUploadSuccess != true) {
      DatabaseReference ref = FirebaseDatabase.instance.ref('files');
      ref.push().set(fileModel.toJson());
      EasyLoading.dismiss();
      emit(
        state.copyWith(
          isUploadSuccess: true,
          listStatus: urls
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
          listStatus: urls
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
    List<String> urls = await loadListServers();
    EasyLoading.show();
    emit(
      state.copyWith(
        isDownloadSuccess: false,
        listStatus: urls.map((e) => false).toList(),
      ),
    );
    for (var i = 0; i < urls.length; i++) {
      _sendRequestDownload(i, fileModel, urls);
    }
  }

  Future<void> _sendRequestDownload(
      int urlIndex, FileModel fileModel, List<String> urls) async {
    final String url = urls[urlIndex];
    if (state.isDownloadSuccess == true) {
      return;
    }
    final request = MultipartRequest(
      "GET",
      Uri.parse(
          "$url/download?hash=${fileModel.getHash()}&fileName=${fileModel.getSavedName()}"),
    );
    DateTime start = DateTime.now();
    final response = await request
        .send()
        .timeout(const Duration(milliseconds: 5000), onTimeout: () {
      return StreamedResponse(Stream.value([]), 408);
    }).onError((error, stackTrace) => StreamedResponse(Stream.value([]), 500));
    DateTime end = DateTime.now();
    int timeResponse =
        end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    updateServerInfo(response.statusCode, timeResponse, url, true);
    if (response.statusCode == 200 && state.isDownloadSuccess != true) {
      emit(
        state.copyWith(
          isDownloadSuccess: true,
          listStatus: urls
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
          listStatus: urls
              .asMap()
              .entries
              .map((e) =>
                  e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
              .toList(),
        ),
      );
    }
  }

  Future<void> deleteFile(FileModel fileModel) async {
    List<String> urls = await loadListServers();
    EasyLoading.show();
    emit(
      state.copyWith(
        isDeleteSuccess: false,
        listStatus: urls.map((e) => false).toList(),
      ),
    );
    for (var i = 0; i < urls.length; i++) {
      _sendRequestDelete(i, fileModel, urls);
    }
    deleteFileOnFirebase(fileModel);
  }

  Future<void> deleteFileOnFirebase(FileModel fileModel) async {
    DataSnapshot response = await FirebaseDatabase.instance
        .ref('files')
        .orderByChild('ownerId')
        .get();
    for (DataSnapshot res in response.children) {
      var file = FileModel.fromJson(res.value);
      if (file.name == fileModel.name &&
          file.timeCreate == fileModel.timeCreate) {
        res.ref.remove();
      }
    }
  }

  Future<void> _sendRequestDelete(
      int urlIndex, FileModel fileModel, List<String> urls) async {
    final String url = urls[urlIndex];
    final request = MultipartRequest(
      "DELETE",
      Uri.parse(
          "$url/delete?hash=${fileModel.getHash()}&fileName=${fileModel.getSavedName()}"),
    );
    await request.send().timeout(const Duration(milliseconds: 5000),
        onTimeout: () {
      return StreamedResponse(Stream.value([]), 408);
    }).onError((error, stackTrace) => StreamedResponse(Stream.value([]), 500));
    emit(
      state.copyWith(
        isDeleteSuccess: true,
        listStatus: urls
            .asMap()
            .entries
            .map((e) =>
                e.key == urlIndex ? true : state.listStatus?[e.key] ?? false)
            .toList(),
      ),
    );
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

  Future<void> updateServerInfo(
      int statusCode, int time, String url, bool isDownload) async {
    final server = await FirebaseDatabase.instance
        .ref('servers')
        .orderByChild('url')
        .equalTo(url)
        .get();
    if (server.exists) {
      final model = ServerModel.fromJson(
          (server.value as Map<String, dynamic>).values.first);
      if (statusCode == 408) {
        model.unresponse++;
      } else {
        model.requestNumber++;
        model.responseTime =
            (model.responseTime * (model.requestNumber - 1) + time) /
                model.requestNumber;

        if (isDownload) {
          model.requestDownload++;
          model.responseDownloadTime =
              (model.responseDownloadTime * (model.requestDownload - 1) +
                      time) /
                  model.requestDownload;
        } else {
          model.requestUpload++;
          model.responseUploadTime =
              (model.responseUploadTime * (model.requestUpload - 1) + time) /
                  model.requestUpload;
        }
      }
      server.children.first.ref.update(model.toJson());
    }
  }
}
