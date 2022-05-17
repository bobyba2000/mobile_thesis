import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FolderWidget extends StatelessWidget {
  final String name;
  final Icon? icon;
  final String time;
  final String note;
  final bool isShowMoreAction;
  final Function? onDownload;
  const FolderWidget({
    Key? key,
    required this.name,
    this.icon,
    required this.time,
    required this.note,
    this.isShowMoreAction = false,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromRGBO(245, 179, 66, 1),
          ),
          padding: const EdgeInsets.all(3),
          child: icon ??
              const Icon(
                Iconsax.folder_2,
                color: Colors.white,
                size: 30,
              ),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              time,
                              style: const TextStyle(
                                color: Color.fromRGBO(184, 183, 182, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note,
                              style: const TextStyle(
                                color: Color.fromRGBO(184, 183, 182, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isShowMoreAction,
                    child: PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              onDownload?.call();
                            },
                            child: const Text(
                              'Download',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {},
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color.fromARGB(255, 148, 147, 146)),
            ],
          ),
        ),
      ],
    );
  }
}
