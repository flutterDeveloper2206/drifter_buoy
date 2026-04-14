import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/animated_list_entrance.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/general_user_back_navigation_scope.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_main_app_bar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_export_route_extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/general_user_loading_shimmers.dart';

class GeneralUserExportSelectionPage extends StatefulWidget {
  const GeneralUserExportSelectionPage({super.key});

  @override
  State<GeneralUserExportSelectionPage> createState() =>
      _GeneralUserExportSelectionPageState();
}

class _GeneralUserExportSelectionPageState
    extends State<GeneralUserExportSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralUserTabRootPopScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE1E4),
        body: SafeArea(
          child: Column(
            children: [
              const AppGeneralUserMainAppBar(),
              const _Header(),
              Expanded(
                child: BlocListener<GeneralUserExportSelectionBloc, GeneralUserExportSelectionState>(
                  listenWhen: (previous, current) =>
                      previous.query != current.query,
                  listener: (_, state) {
                    if (_searchController.text == state.query) {
                      return;
                    }
                    _searchController.text = state.query;
                    _searchController.selection = TextSelection.collapsed(
                      offset: _searchController.text.length,
                    );
                  },
                  child:
                      BlocBuilder<
                        GeneralUserExportSelectionBloc,
                        GeneralUserExportSelectionState
                      >(
                        builder: (context, state) {
                          if (state.status ==
                                  GeneralUserExportSelectionStatus.loading ||
                              state.status ==
                                  GeneralUserExportSelectionStatus.initial) {
                            return const GeneralUserExportSelectionShimmer();
                          }

                          if (state.status ==
                              GeneralUserExportSelectionStatus.error) {
                            return AppErrorView(
                              message: state.message,
                              onRetry: () {
                                context
                                    .read<GeneralUserExportSelectionBloc>()
                                    .add(
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
                              Expanded(
                                child: RefreshIndicator(
                                  color: const Color(0xFF1F88D1),
                                  onRefresh: () async {
                                    final bloc = context
                                        .read<GeneralUserExportSelectionBloc>();
                                    bloc.add(
                                      const LoadGeneralUserExportSelection(),
                                    );
                                    await bloc.stream.firstWhere(
                                      (s) =>
                                          s.status !=
                                          GeneralUserExportSelectionStatus
                                              .loading,
                                    );
                                  },
                                  child: ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      8,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          10,
                                        ),
                                        child: _SearchBar(
                                          controller: _searchController,
                                          onChanged: (value) {
                                            context
                                                .read<
                                                  GeneralUserExportSelectionBloc
                                                >()
                                                .add(
                                                  UpdateGeneralUserExportSelectionQuery(
                                                    value,
                                                  ),
                                                );
                                          },
                                          onSearchTap: () =>
                                              FocusScope.of(context).unfocus(),
                                          onClearTap: queryTrimmed.isNotEmpty
                                              ? () {
                                                  _searchController.clear();
                                                  context
                                                      .read<
                                                        GeneralUserExportSelectionBloc
                                                      >()
                                                      .add(
                                                        const UpdateGeneralUserExportSelectionQuery(
                                                          '',
                                                        ),
                                                      );
                                                }
                                              : null,
                                        ),
                                      ),
                                      if (showSelectAll)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            10,
                                          ),
                                          child: _SelectAllRow(
                                            selected: state.allFilteredSelected,
                                            onTap: () {
                                              context
                                                  .read<
                                                    GeneralUserExportSelectionBloc
                                                  >()
                                                  .add(
                                                    const ToggleGeneralUserExportSelectionAll(),
                                                  );
                                            },
                                          ),
                                        ),
                                      if (state.filteredItems.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            0,
                                          ),
                                          child: SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.46,
                                            child: _ExportSelectionEmptyView(
                                              isSearching: isSearching,
                                              query: queryTrimmed,
                                            ),
                                          ),
                                        )
                                      else
                                        ...state.filteredItems.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          final selected = state.selectedIds
                                              .contains(item.id);
                                          return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              index ==
                                                      state
                                                              .filteredItems
                                                              .length -
                                                          1
                                                  ? 0
                                                  : 8,
                                            ),
                                            child: AnimatedListEntrance(
                                              index: index,
                                              child: _BuoySelectableCard(
                                                item: item,
                                                selected: selected,
                                                onTap: () {
                                                  context
                                                      .read<
                                                        GeneralUserExportSelectionBloc
                                                      >()
                                                      .add(
                                                        ToggleGeneralUserExportSelectionItem(
                                                          item.id,
                                                        ),
                                                      );
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  10,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: AppElevatedButton(
                                    loading: false,
                                    onPressed: state.selectedCount == 0
                                        ? null
                                        : () => context.push(
                                            AppRoutes.exportPath,
                                            extra:
                                                GeneralUserExportSelectionBuoysExtra(
                                                  buoyIds: state.allItems
                                                      .where(
                                                        (i) => state.selectedIds
                                                            .contains(i.id),
                                                      )
                                                      .map((i) => i.id)
                                                      .toList(),
                                                ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Export',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF242A2F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onClearTap;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    this.onSearchTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF31363A),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search with Buoy ID',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9A9FA4),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: onClearTap == null
                    ? null
                    : IconButton(
                        onPressed: onClearTap,
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF8F9498),
                        ),
                      ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF206BBE),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
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
    final textTheme = Theme.of(context).textTheme;
    final title = isSearching
        ? 'No buoys match "$query".'
        : 'No buoys available to export.';
    final subtitle = isSearching
        ? 'Try a different Buoy ID.'
        : 'Buoys will show here when they are available.';
    final icon = isSearching
        ? Icons.search_off_rounded
        : Icons.file_download_outlined;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: const Color(0xFF5E656C).withValues(alpha: 0.55),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: const Color(0xFF5E656C),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF8A9095),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
    final statusColor = item.isActive
        ? const Color(0xFF22BE61)
        : const Color(0xFFE74C3C);
    final statusIcon = item.isActive ? Icons.wifi : Icons.wifi_off;
    final statusLabel = item.isActive ? 'Active' : 'Offline';

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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF2A2F34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last Update : ${item.lastUpdate}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: statusColor,
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
        border: Border.all(color: selected ? _accent : _ring, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
