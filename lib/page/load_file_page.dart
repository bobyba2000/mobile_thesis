import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_v2/bloc/load_file/load_file_bloc.dart';
import 'package:mobile_v2/bloc/load_file/load_file_state.dart';
import 'package:mobile_v2/common/common_widget/file_widget.dart';
import 'package:mobile_v2/common/common_widget/folder_widget.dart';
import 'package:mobile_v2/common/common_widget/load_more_widget.dart';
import 'package:mobile_v2/model/file_model.dart';
import 'package:mobile_v2/model/server_model.dart';
import 'package:mobile_v2/utils/toast_utils.dart';

import '../common/common_widget/search_widget.dart';

class LoadFilePage extends StatefulWidget {
  const LoadFilePage({Key? key}) : super(key: key);

  @override
  _LoadFilePageState createState() => _LoadFilePageState();
}

class _LoadFilePageState extends State<LoadFilePage> {
  late LoadFileBloc bloc;
  late PagewiseLoadController<FileModel> _filePagewiseLoadController;
  late PagewiseLoadController<ServerModel> _serverPagewiseLoadController;

  @override
  void initState() {
    super.initState();
    bloc = LoadFileBloc();
    _filePagewiseLoadController = PagewiseLoadController<FileModel>(
      pageFuture: (pageIndex) => bloc.loadListFile((pageIndex ?? 0), 6),
      pageSize: 6,
    );
    _serverPagewiseLoadController = PagewiseLoadController<ServerModel>(
      pageFuture: (pageIndex) => bloc.loadListServer((pageIndex ?? 0)),
      pageSize: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocListener<LoadFileBloc, LoadFileState>(
        listener: (context, state) {
          if ((state.listStatus?.isNotEmpty ?? false) &&
              state.isRequestDone()) {
            if (state.isDownloadSuccess == true ||
                state.isUploadSuccess == true) {
              if (state.isDownloadSuccess == true) {
                ToastUtilities.show(
                  message: 'Download file success',
                );
              }
              if (state.isUploadSuccess == true) {
                ToastUtilities.show(
                  message: 'Upload file success',
                );
              }
            } else {
              ToastUtilities.show(
                message: 'Request failed.',
              );
            }
            _filePagewiseLoadController.reset();
            bloc.closeRequest();
          }
        },
        child: BlocBuilder<LoadFileBloc, LoadFileState>(
          builder: (context, state) {
            return _buildScreen(state);
          },
        ),
      ),
    );
  }

  Widget _buildScreen(LoadFileState state) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'List Files',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Iconsax.logout,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    SearchWidget(
                      onSearch: (value) {
                        bloc.onSearch(value ?? '');
                        _filePagewiseLoadController.reset();
                      },
                      hintTextSearch: 'Search by File Name',
                    ),
                  ],
                ),
                const Text(
                  'All Servers',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 54, 54, 54),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: LoadMoreWidget<ServerModel>.buildList(
                    pullToRefresh: () => _serverPagewiseLoadController.reset(),
                    pageLoadController: _serverPagewiseLoadController,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.3,
                    shrinkWrap: true,
                    itemBuilder: (context, value, index) {
                      return FolderWidget(
                        name: value.name,
                        time: value.timeCreate.toString(),
                        note: '${value.numberOfFile ?? 0} mục',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'All Files',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 54, 54, 54),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: LoadMoreWidget<FileModel>.buildList(
                    pullToRefresh: () => _filePagewiseLoadController.reset(),
                    pageLoadController: _filePagewiseLoadController,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.3,
                    shrinkWrap: true,
                    itemBuilder: (context, value, index) {
                      return FileWidget(
                        name: value.name,
                        time: value.timeCreate,
                        size: value.size ?? '0 kb',
                        onDownload: () async {
                          bloc.downloadFile(value);
                          // final isSuccess = await bloc.download(value.id);
                          // if (isSuccess) {
                          //   ToastUtilities.show(
                          //       message: 'Download file success');
                          //   _filePagewiseLoadController.reset();
                          // } else {
                          //   ToastUtilities.show(
                          //       message: 'Download file failed', isError: true);
                          // }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              await bloc.uploadFile(result.files.first);
              // if (isSuccess) {
              //   ToastUtilities.show(message: 'Add file success');
              //   _filePagewiseLoadController.reset();
              // } else {
              //   ToastUtilities.show(message: 'Add file failed', isError: true);
              // }
            } else {
              ToastUtilities.show(message: 'Add file failed', isError: true);
            }
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
            ),
            child: const Center(
                child: Icon(
              Iconsax.add,
              color: Colors.white,
              size: 24,
            )),
          ),
        ),
      ),
    );
  }
}
