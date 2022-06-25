import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mobile_v2/common/common_widget/dropdown_widget.dart';
import 'package:mobile_v2/common/common_widget/text_field_widget.dart';
import 'package:mobile_v2/model/location_model.dart';
import 'package:mobile_v2/utils/toast_utils.dart';

class SignupOptionWidget extends StatefulWidget {
  const SignupOptionWidget({Key? key}) : super(key: key);

  @override
  _SignupOptionWidgetState createState() => _SignupOptionWidgetState();
}

class _SignupOptionWidgetState extends State<SignupOptionWidget> {
  double _height = 175;
  int optionSelected = -1;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? location;
  List<String> listLocation = [];
  List<LocationModel> listLocationModel = [];
  @override
  void initState() {
    super.initState();
    getListLocation();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 500,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      curve: Curves.bounceOut,
      width: kIsWeb ? 400 : 250,
      height: _height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose your service',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            OptionWidget(
              listOptions: const ['Server', 'Client'],
              onSelect: (value) {
                setState(
                  () {
                    optionSelected = value;
                    if (optionSelected == -1) {
                      _height = 175;
                    } else {
                      if (optionSelected == 0) {
                        _height = 500;
                      } else {
                        _height = 175;
                      }
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Visibility(
              visible: optionSelected == 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          controller: _nameController,
                          label: 'Your Name',
                          hintText: 'Enter your name.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          controller: _phoneController,
                          label: 'Your Phone Number',
                          hintText: 'Enter your phone number.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          controller: _urlController,
                          label: 'Your Server',
                          hintText: 'Enter your server.',
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          controller: _descController,
                          label: 'Server Description',
                          hintText: 'Enter some description about your server.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () {
                    if (optionSelected == 1) {
                      var locationModel = listLocationModel.reduce(
                          (value, element) =>
                              value.numberOfUser < element.numberOfUser
                                  ? value
                                  : element);
                      location = locationModel.name;
                    }
                    if ((optionSelected == 1 && location != null) ||
                        (optionSelected == 0 &&
                            _urlController.text != '' &&
                            _descController.text != '' &&
                            _phoneController.text != '' &&
                            _nameController.text != '')) {
                      Navigator.pop(
                        context,
                        SignupModel(
                          option: optionSelected == 0 ? 'Server' : 'Client',
                          optionDetail: optionSelected == 0
                              ? _urlController.text
                              : location ?? '',
                          name:
                              optionSelected == 0 ? _nameController.text : null,
                          phone: optionSelected == 0
                              ? _phoneController.text
                              : null,
                          description:
                              optionSelected == 0 ? _descController.text : null,
                        ),
                      );
                    } else {
                      ToastUtilities.show(
                        message: 'Please fulfill the form.',
                        isError: true,
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> getListLocation() async {
    DataSnapshot response =
        await FirebaseDatabase.instance.ref('locations').get();
    List<LocationModel> listLocation =
        response.children.map((e) => LocationModel.fromJson(e.value)).toList();
    setState(() {
      this.listLocation = listLocation
          .where((element) => element.status == 'Active')
          .map((e) => e.name)
          .toList();
    });
  }
}

class OptionWidget extends StatefulWidget {
  final List<String> listOptions;
  final Function(int) onSelect;
  const OptionWidget({
    Key? key,
    required this.listOptions,
    required this.onSelect,
  }) : super(key: key);

  @override
  _OptionWidgetState createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  int selectedValue = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.listOptions
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedValue = e.key;
                    widget.onSelect.call(selectedValue);
                  });
                },
                child: Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: selectedValue == e.key
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      e.value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class SignupModel {
  String option;
  String optionDetail;
  String? name;
  String? phone;
  String? description;
  SignupModel(
      {required this.option,
      required this.optionDetail,
      this.description,
      this.phone,
      this.name});
}
