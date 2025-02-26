import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormFieldComponent extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validation;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  final double? padding;
  final Function()? onTap;
  final bool readOnly;
  final int? maxlines;
  final Widget? prefixIcon;
  final bool isRequired;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final int? maxLength;
  final int? minLines;
  final double height;
  final FloatingLabelBehavior? floatingLabelBehavior;
  const TextFormFieldComponent(
      {super.key,
      required this.controller,
      required this.validation,
      this.keyboardType,
      this.hintText,
      this.labelText,
      this.padding,
      this.onTap,
      this.readOnly = false,
      this.maxlines,
      this.prefixIcon,
      this.isRequired = false,
      this.prefix,
      this.suffix,
      this.suffixIcon,
      this.maxLength,
      this.minLines,
      this.height = 56,
      this.floatingLabelBehavior,
      this.onChanged});

  @override
  State<TextFormFieldComponent> createState() => _TextFormFieldComponentState();
}

class _TextFormFieldComponentState extends State<TextFormFieldComponent> {
  bool _isValidated = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
  
    return Padding(
      padding: EdgeInsets.all(widget.padding ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: widget.height,
            child: TextFormField(
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              controller: widget.controller,
              validator: (value) {
                setState(() {
                  _isValidated = true;
                  _errorText = widget.validation(value);
                });
                return _errorText;
              },
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    if (_isValidated) {
                      _errorText = widget.validation(value);
                    }
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                }
              },
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              maxLines: widget.maxlines,
              style: GoogleFonts.firaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              decoration: InputDecoration(
                prefix: widget.prefix,
                suffix: widget.suffix,
                suffixIcon: widget.suffixIcon,
                isDense: true,
                prefixIcon: widget.prefixIcon,
                hintText: widget.hintText ?? "",
                hintStyle: GoogleFonts.firaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelBehavior: widget.floatingLabelBehavior,
                labelText:
                    "${widget.labelText ?? ""} ${widget.isRequired ? "*" : ""}",
                labelStyle: GoogleFonts.firaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isRequired ? Colors.red : Colors.black),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(),
                  borderRadius: BorderRadius.circular(15),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(15),
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ),
          if (_isValidated && _errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Text(
                _errorText!,
                style: GoogleFonts.firaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
