import 'package:flutter/material.dart';

class AppExportFormatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileSize;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const AppExportFormatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileSize,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF2C7ECC) : const Color(0xFFE2E2E2);
    final backgroundColor = selected ? const Color(0xFFE8EEF5) : const Color(0xFFF1F1F1);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: _SelectionDot(selected: selected),
              ),
              Icon(icon, size: 54, color: iconColor),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2A2F34),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF707070),
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                fileSize,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF363636),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final bool selected;

  const _SelectionDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF2A76C8) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFF2A76C8) : const Color(0xFFD1D1D1),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            )
          : null,
    );
  }
}
