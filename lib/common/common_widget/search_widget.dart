import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iconsax/iconsax.dart';

class SearchWidget extends StatefulWidget {
  final bool isExpanded;
  final String? hintTextSearch;
  final Function(String?)? onSearch;
  const SearchWidget({
    Key? key,
    this.isExpanded = false,
    this.onSearch,
    this.hintTextSearch,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  InputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      );
  late bool _isSearching;
  String? _value;

  @override
  void initState() {
    super.initState();
    _isSearching = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return _isSearching
        ? Expanded(
            child: FormBuilderTextField(
              name: '',
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color.fromRGBO(41, 35, 63, 1.0),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              maxLength: 500,
              initialValue: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                EasyDebounce.debounce(
                    'debounceTagSearch',
                    const Duration(milliseconds: 700),
                    () => widget.onSearch?.call(value));
              },
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                border: _inputBorder(Colors.transparent),
                enabledBorder: _inputBorder(Colors.transparent),
                focusedBorder: _inputBorder(Colors.blue),
                errorBorder: _inputBorder(Colors.red),
                focusedErrorBorder: _inputBorder(Colors.transparent),
                disabledBorder: _inputBorder(Colors.transparent),
                counterText: '',
                hintText: widget.hintTextSearch,
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(41, 35, 63, 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(
                      () {
                        _isSearching = false;
                        if (_value != null && _value != '') {
                          EasyDebounce.debounce(
                              'debounceTagSearch',
                              const Duration(milliseconds: 700),
                              () => widget.onSearch?.call(null));
                        }
                        _value = null;
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Iconsax.close_circle,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () {
              setState(() {
                _isSearching = true;
              });
            },
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Iconsax.search_normal,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
            ),
          );
  }
}
