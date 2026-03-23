import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapSearchPage extends StatefulWidget {
  const GeneralUserMapSearchPage({super.key});

  @override
  State<GeneralUserMapSearchPage> createState() =>
      _GeneralUserMapSearchPageState();
}

class _GeneralUserMapSearchPageState extends State<GeneralUserMapSearchPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.text = 'DB-01';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<GeneralUserMapSearchBloc, GeneralUserMapSearchState>(
        listenWhen: (previous, current) =>
            previous.zoom != current.zoom ||
            previous.selectedBuoy != current.selectedBuoy ||
            previous.query != current.query,
        listener: (_, state) {
          if (_searchController.text != state.query) {
            _searchController.text = state.query;
            _searchController.selection = TextSelection.collapsed(
              offset: _searchController.text.length,
            );
          }

          final center = state.selectedBuoy?.position ?? _safeMapCenter();
          _mapController.move(center, state.zoom);
        },
        child: BlocBuilder<GeneralUserMapSearchBloc, GeneralUserMapSearchState>(
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(child: _buildMapLayer(context, state)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        AppIconCircleButton(
                          onTap: () {
                            if (GoRouter.of(context).canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.mapPath);
                            }
                          },
                          icon: Icons.close,
                          iconSize: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SearchInputCard(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              context.read<GeneralUserMapSearchBloc>().add(
                                UpdateGeneralUserMapSearchQuery(value),
                              );
                            },
                            onSearchTap: () {
                              context.read<GeneralUserMapSearchBloc>().add(
                                UpdateGeneralUserMapSearchQuery(
                                  _searchController.text,
                                ),
                              );

                              if (_searchController.text.trim().isNotEmpty) {
                                context.push(
                                  AppRoutes.buoyOverviewPath,
                                  extra: _searchController.text
                                      .trim()
                                      .toUpperCase(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 95,
                  right: 16,
                  child: _MapZoomControl(
                    onZoomIn: state.canZoomIn
                        ? () => context.read<GeneralUserMapSearchBloc>().add(
                            const ZoomInGeneralUserMapSearch(),
                          )
                        : null,
                    onZoomOut: state.canZoomOut
                        ? () => context.read<GeneralUserMapSearchBloc>().add(
                            const ZoomOutGeneralUserMapSearch(),
                          )
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapLayer(BuildContext context, GeneralUserMapSearchState state) {
    if (state.status == GeneralUserMapSearchStatus.loading ||
        state.status == GeneralUserMapSearchStatus.initial) {
      return const AppLoader();
    }

    if (state.status == GeneralUserMapSearchStatus.error) {
      return AppErrorView(
        message: state.message,
        onRetry: () {
          context.read<GeneralUserMapSearchBloc>().add(
            const LoadGeneralUserMapSearch(),
          );
        },
      );
    }

    return DummyBuoyMapView(
      mapController: _mapController,
      interactive: true,
      showLabels: true,
      initialZoom: state.zoom,
      buoys: state.allBuoys,
      selectedBuoy: state.selectedBuoy,
      onBuoyTap: (buoy) {
        context.read<GeneralUserMapSearchBloc>().add(
          UpdateGeneralUserMapSearchQuery(buoy.id),
        );
      },
    );
  }

  LatLng _safeMapCenter() {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return const LatLng(37.7749, -122.4194);
    }
  }
}

class _SearchInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;

  const _SearchInputCard({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF31363A),
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF007BC2),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapZoomControl extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const _MapZoomControl({this.onZoomIn, this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: onZoomIn,
            icon: const Icon(Icons.add, size: 30, color: Color(0xFF2A2F34)),
          ),
          Container(
            width: 28,
            height: 1,
            color: const Color(0xFFD7DBDF),
            margin: const EdgeInsets.symmetric(vertical: 2),
          ),
          IconButton(
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove, size: 30, color: Color(0xFF2A2F34)),
          ),
        ],
      ),
    );
  }
}
