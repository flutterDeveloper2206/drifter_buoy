import 'package:flutter/material.dart';

class AppCommonDropdown<T> extends StatelessWidget {
  const AppCommonDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.placeholder = 'Select',
  });

  final T? value;
  final List<T> items;
  final String Function(T value) itemLabelBuilder;
  final ValueChanged<T?>? onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A86CE), width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled
              ? () async {
                  final selected = await showModalBottomSheet<T>(
                    context: context,
                    backgroundColor: Colors.white,
                    showDragHandle: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (sheetContext) {
                      return SafeArea(
                        top: false,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFFE5E7EB),
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isCurrent = item == value;
                            return ListTile(
                              title: Text(
                                itemLabelBuilder(item),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF353A3F),
                                      fontWeight: isCurrent
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                              trailing: isCurrent
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF206BBE),
                                    )
                                  : null,
                              onTap: () => Navigator.of(sheetContext).pop(item),
                            );
                          },
                        ),
                      );
                    },
                  );
                  if (selected != null) {
                    onChanged!(selected);
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? itemLabelBuilder(value as T) : placeholder,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? (value == null
                                ? const Color(0xFF8A8F94)
                                : const Color(0xFF353A3F))
                          : const Color(0xFF8A8F94),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? const Color(0xFF272C31)
                      : const Color(0xFF8A8F94),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
