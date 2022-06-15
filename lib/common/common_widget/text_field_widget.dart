import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool readOnly;
  final bool isPassword;
  final String label;
  const TextFieldWidget({
    Key? key,
    required this.controller,
    this.hintText,
    this.readOnly = false,
    this.isPassword = false,
    required this.label,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  InputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      );
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        FormBuilderTextField(
          name: '',
          controller: widget.controller,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Color.fromRGBO(41, 35, 63, 1.0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          readOnly: widget.readOnly,
          maxLength: 500,
          obscureText: widget.isPassword && !_passwordVisible,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            border: _inputBorder(Colors.transparent),
            enabledBorder: _inputBorder(Colors.transparent),
            focusedBorder: _inputBorder(Theme.of(context).primaryColor),
            errorBorder: _inputBorder(Colors.red),
            focusedErrorBorder: _inputBorder(Colors.transparent),
            disabledBorder: _inputBorder(Colors.transparent),
            counterText: '',
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color.fromRGBO(41, 35, 63, 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
