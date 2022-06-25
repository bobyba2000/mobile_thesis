import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_v2/common/common_widget/folder_widget.dart';

class FileWidget extends StatelessWidget {
  final String name;
  final String time;
  final String size;
  final Function onDownload;
  final Function onDelete;
  const FileWidget({
    Key? key,
    required this.name,
    required this.time,
    required this.size,
    required this.onDownload,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FolderWidget(
      name: name,
      time: time,
      note: size,
      isShowMoreAction: true,
      onDownload: onDownload,
      onDelete: onDelete,
      icon: const Icon(
        Iconsax.note,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
