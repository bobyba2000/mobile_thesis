import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DropDownWidget extends StatelessWidget {
  final String? hintText;
  final bool readOnly;
  final List<String> items;
  final String label;
  final String? initialValue;
  final Function(String?) onSelect;
  InputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      );
  const DropDownWidget({
    Key? key,
    this.readOnly = false,
    this.hintText,
    required this.label,
    this.initialValue,
    required this.items,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        FormBuilderDropdown<String>(
          name: '',
          style: const TextStyle(
            color: Color.fromRGBO(41, 35, 63, 1.0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            onSelect.call(value);
          },
          initialValue: items.contains(initialValue) ? initialValue : null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            border: _inputBorder(Colors.transparent),
            enabledBorder: _inputBorder(Colors.transparent),
            focusedBorder: _inputBorder(Colors.black),
            errorBorder: _inputBorder(Colors.red),
            focusedErrorBorder: _inputBorder(Colors.transparent),
            disabledBorder: _inputBorder(Colors.transparent),
            counterText: '',
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color.fromRGBO(41, 35, 63, 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      color: Color.fromRGBO(41, 35, 63, 1.0),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Barlow',
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
