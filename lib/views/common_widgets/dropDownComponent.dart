import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownFieldComponent extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String? hintText;
  final String? labelText;
  final double? padding;
  final Function(String?)? onChanged;
  final Widget? prefixIcon;
  final String? Function(String?)? validation;
  final bool needOptionInModal;
  final bool needCustomItemsOption;
  final bool disableDropdown;

  const DropdownFieldComponent(
      {super.key,
      required this.items,
      this.value,
      this.hintText,
      this.labelText,
      this.padding,
      this.onChanged,
      this.prefixIcon,
      this.validation,
      this.needOptionInModal = false,
      this.needCustomItemsOption = false,
      this.disableDropdown = false});

  @override
  State<DropdownFieldComponent> createState() => _DropdownFieldComponentState();
}

class _DropdownFieldComponentState extends State<DropdownFieldComponent> {
  String? selectedValue;
  String? errorText;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.items.contains(widget.value) ? widget.value : null;
  }

  @override
  void didUpdateWidget(covariant DropdownFieldComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selectedValue if the widget's value has changed
    if (widget.value != oldWidget.value && widget.value != selectedValue) {
      setState(() {
        selectedValue =
            widget.items.contains(widget.value) ? widget.value : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.needOptionInModal)
            SizedBox(
              height: 56, // Fixed height for the dropdown field
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                items: widget.items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue;
                    errorText = widget.validation?.call(newValue);
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  }
                },
                validator: (value) {
                  final error = widget.validation?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      errorText = error;
                    });
                  });
                  return error;
                },
                decoration: InputDecoration(
                  prefixIcon: widget.prefixIcon,
                  hintText: widget.hintText ?? "",
                  hintStyle: GoogleFonts.firaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  labelText: widget.labelText ?? "",
                  labelStyle: GoogleFonts.firaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: const TextStyle(
                      height: 0, fontSize: 0), // Hide default error
                ),
                dropdownColor: Colors.white,
                isExpanded: true,
              ),
            )
          else
            GestureDetector(
              onTap: widget.disableDropdown ? () {} : () => _showModal(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.labelText != null && widget.needOptionInModal)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.labelText!,
                        style: GoogleFonts.firaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                      color: widget.disableDropdown
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedValue ?? widget.hintText ?? "",
                            style: GoogleFonts.firaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color: widget.disableDropdown
                                  ? Colors.grey.withOpacity(0.4)
                                  : Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Text(
                errorText!,
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

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Border color
                      borderRadius: BorderRadius.circular(8.0), // Border radius
                    ),
                    child: ListTile(
                      title: Text(
                        item.capitalize!,
                        style: GoogleFonts.firaSans(),
                      ),
                      onTap: () {
                        setState(() {
                          selectedValue = item;
                          errorText = widget.validation?.call(item);
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(item);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
