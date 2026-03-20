import 'package:drifter_buoy/core/utils/widgets/app_image.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onDelete;

  const ItemTile({super.key, required this.item, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final imageSeed = item.id ?? item.title.hashCode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage.cachedNetwork(
                  'https://picsum.photos/seed/$imageSeed/80/80',
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (item.id != null)
                  IconButton(
                    tooltip: 'Delete item',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.body),
            const SizedBox(height: 8),
            Text(
              'ID: ${item.id ?? 'N/A'} | User: ${item.userId}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
