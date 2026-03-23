import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_shimmer.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_bloc.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_event.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_state.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/widgets/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ItemsBloc, ItemsState>(
        builder: (context, state) {
          if (state is ItemsInitial || state is ItemsLoading) {
            return const AppListShimmer();
          }

          if (state is ItemsError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                context.read<ItemsBloc>().add(const FetchItems());
              },
            );
          }

          if (state is ItemsLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items available.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ItemsBloc>().add(const FetchItems());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ItemTile(
                    item: item,
                    onDelete: item.id == null
                        ? null
                        : () {
                            context.read<ItemsBloc>().add(
                              DeleteItemEvent(item.id!),
                            );
                          },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      final title = titleController.text.trim();
      final body = bodyController.text.trim();

      if (title.isNotEmpty && body.isNotEmpty && context.mounted) {
        context.read<ItemsBloc>().add(AddItemEvent(title: title, body: body));
      }
    }

    titleController.dispose();
    bodyController.dispose();
  }
}
