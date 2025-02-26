import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Allow onPressed to be null
  final Color? backgroundColor;
  final Color? textColor;
  final double? widthFactor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isEnabled; // New parameter to enable/disable the button

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.widthFactor = 1,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.textStyle,
    this.isEnabled = true, // Default to true (enabled)
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null, // Disable button if not enabled
        style: TextButton.styleFrom(
          padding: padding,
          textStyle: textStyle ??
              GoogleFonts.firaSans(fontSize: 18, fontWeight: FontWeight.w800),
          shape: const StadiumBorder(),
          backgroundColor: isEnabled
              ? backgroundColor ?? Theme.of(context).primaryColor
              : Colors.grey, // Change background color when disabled
        ),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.firaSans(
            color: isEnabled ? (textColor ?? Colors.white) : Colors.grey[300], // Change text color when disabled
          ),
        ),
      ),
    );
  }
}
