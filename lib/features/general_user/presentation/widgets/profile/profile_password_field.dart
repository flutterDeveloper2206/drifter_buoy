import 'package:flutter/material.dart';

class GeneralUserProfilePasswordField extends StatelessWidget {
  const GeneralUserProfilePasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.obscureText,
    required this.onToggleVisibility,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3F4750),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: false,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF23282D),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC2C7CC)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8DCE0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3A86D1),
                width: 1.1,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: enabled ? onToggleVisibility : null,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF3A4046),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
