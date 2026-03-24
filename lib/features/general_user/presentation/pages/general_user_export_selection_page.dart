import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserExportSelectionPage extends StatelessWidget {
  const GeneralUserExportSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<
                GeneralUserExportSelectionBloc,
                GeneralUserExportSelectionState
              >(
                builder: (context, state) {
                  if (state.status == GeneralUserExportSelectionStatus.loading ||
                      state.status == GeneralUserExportSelectionStatus.initial) {
                    return const AppLoader();
                  }

                  if (state.status == GeneralUserExportSelectionStatus.error) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GeneralUserExportSelectionBloc>().add(
                          const LoadGeneralUserExportSelection(),
                        );
                      },
                    );
                  }

                  final queryTrimmed = state.query.trim();
                  final isSearching = queryTrimmed.isNotEmpty;
                  final showSelectAll =
                      !isSearching && state.filteredItems.isNotEmpty;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: _SearchBar(
                          onChanged: (value) {
                            context.read<GeneralUserExportSelectionBloc>().add(
                              UpdateGeneralUserExportSelectionQuery(value),
                            );
                          },
                        ),
                      ),
                      if (showSelectAll)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _SelectAllRow(
                            selected: state.allFilteredSelected,
                            onTap: () {
                              context.read<GeneralUserExportSelectionBloc>().add(
                                const ToggleGeneralUserExportSelectionAll(),
                              );
                            },
                          ),
                        ),
                      Expanded(
                        child: state.filteredItems.isEmpty
                            ? _ExportSelectionEmptyView(
                                isSearching: isSearching,
                                query: queryTrimmed,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  8,
                                ),
                                itemCount: state.filteredItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = state.filteredItems[index];
                                  final selected = state.selectedIds.contains(
                                    item.id,
                                  );
                                  return _BuoySelectableCard(
                                    item: item,
                                    selected: selected,
                                    onTap: () {
                                      context
                                          .read<GeneralUserExportSelectionBloc>()
                                          .add(
                                            ToggleGeneralUserExportSelectionItem(
                                              item.id,
                                            ),
                                          );
                                    },
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.selectedCount == 0
                                ? null
                                : () => context.push(
                                    AppRoutes.exportPath,
                                    extra: state.selectedCount,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF206BBE),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF206BBE,
                              ).withValues(alpha: 0.55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Continue to Export',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      AppGeneralUserBottomNav(
                        selectedTab: GeneralUserBottomNavTab.export,
                        onTap: (tab) {
                          switch (tab) {
                            case GeneralUserBottomNavTab.home:
                              context.go(AppRoutes.dashboardPath);
                            case GeneralUserBottomNavTab.buoys:
                              context.go(AppRoutes.buoysPath);
                            case GeneralUserBottomNavTab.map:
                              context.go(AppRoutes.mapPath);
                            case GeneralUserBottomNavTab.export:
                              break;
                            case GeneralUserBottomNavTab.setup:
                              context.go(AppRoutes.setupPath);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          AppIconCircleButton(
            onTap: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboardPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Export',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF262C31),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF8A9095)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search with Buoy ID',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportSelectionEmptyView extends StatelessWidget {
  final bool isSearching;
  final String query;

  const _ExportSelectionEmptyView({
    required this.isSearching,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final message = isSearching
        ? 'No buoys match "$query".'
        : 'No buoys available to export.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF5E656C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SelectAllRow extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SelectAllRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _ExportCircularCheckbox(selected: selected),
            const SizedBox(width: 10),
            Text(
              'Select All',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF353B41),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuoySelectableCard extends StatelessWidget {
  final GeneralUserExportSelectionItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BuoySelectableCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2A76C8) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            _ExportCircularCheckbox(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.id,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2A2F34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last Update : ${item.lastUpdate}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF70757A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                const Icon(Icons.wifi, color: Color(0xFF22BE61), size: 18),
                const SizedBox(width: 4),
                Text(
                  item.isActive ? 'Active' : 'Offline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: item.isActive
                        ? const Color(0xFF22BE61)
                        : const Color(0xFFE74C3C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular checkbox used on export selection (list + select all).
class _ExportCircularCheckbox extends StatelessWidget {
  final bool selected;

  const _ExportCircularCheckbox({required this.selected});

  static const Color _accent = Color(0xFF216CC0);
  static const Color _ring = Color(0xFFB1B6BB);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _accent : Colors.transparent,
        border: Border.all(
          color: selected ? _accent : _ring,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
