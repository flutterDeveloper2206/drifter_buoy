import 'package:drifter_buoy/core/utils/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';

class GeneralUserBuoyOverviewShimmer extends StatelessWidget {
  const GeneralUserBuoyOverviewShimmer({super.key});

  static const _pageBg = Color(0xFFDDE1E4);
  static const _cardBg = Color(0xFFF2F2F2);
  static const _tabTrackBg = Color(0xFFECECEC);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _pageBg,
      child: AppShimmer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _circle(48),
                  Expanded(
                    child: Center(
                      child: _box(height: 20, width: 160, radius: 8),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _tabTrackBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _box(height: 52, radius: 10),
                    ),
                    Expanded(
                      child: _box(height: 52, radius: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buoyOverviewCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _box(height: 20, radius: 8)),
                        const SizedBox(width: 10),
                        _box(height: 20, width: 76, radius: 8),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _circle(20),
                        const SizedBox(width: 6),
                        Expanded(child: _box(height: 18, radius: 6)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buoyOverviewCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 20, width: 72, radius: 8),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buoyOverviewMetricColumn()),
                        Expanded(child: _buoyOverviewMetricColumn()),
                        Expanded(child: _buoyOverviewMetricColumn()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buoyOverviewCard(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _box(height: 22, width: 132, radius: 8),
                        const Spacer(),
                        _box(height: 32, width: 32, radius: 10),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _box(height: 190, radius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buoyOverviewCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 20, width: 120, radius: 8),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _box(height: 24, width: 24, radius: 6),
                        const SizedBox(width: 6),
                        _box(height: 20, width: 96, radius: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buoyOverviewCard({
    required EdgeInsetsGeometry padding,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  static Widget _buoyOverviewMetricColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(height: 18, width: 18, radius: 4),
        const SizedBox(height: 4),
        _box(height: 14, radius: 4),
        const SizedBox(height: 4),
        _box(height: 14, width: double.infinity, radius: 4),
      ],
    );
  }
}

class GeneralUserDashboardShimmer extends StatelessWidget {
  const GeneralUserDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            _box(height: 70),
            const SizedBox(height: 14),
            _box(height: 180),
            const SizedBox(height: 14),
            _box(height: 220),
          ],
        ),
      ),
    );
  }
}

class GeneralUserBuoysShimmer extends StatelessWidget {
  const GeneralUserBuoysShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            _box(height: 52, radius: 26),
            const SizedBox(height: 14),
            _box(height: 88),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => _box(height: 110),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralUserExportSelectionShimmer extends StatelessWidget {
  const GeneralUserExportSelectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            _box(height: 52, radius: 26),
            const SizedBox(height: 14),
            _box(height: 52),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => _box(height: 68),
              ),
            ),
            const SizedBox(height: 10),
            _box(height: 56, radius: 10),
          ],
        ),
      ),
    );
  }
}

class GeneralUserMetricsShimmer extends StatelessWidget {
  const GeneralUserMetricsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Column(
          children: [
            _box(height: 108),
            const SizedBox(height: 16),
            _box(height: 250),
          ],
        ),
      ),
    );
  }
}

class GeneralUserMapShimmer extends StatelessWidget {
  const GeneralUserMapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _circle(44),
                const Spacer(),
                _circle(44),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.paddingOf(context).top + 100,
            child: _box(width: 52, height: 120, radius: 26),
          ),
          Positioned(left: 40, right: 40, bottom: 124, child: _box(height: 40)),
          Positioned(left: 0, right: 0, bottom: 0, child: _box(height: 95)),
        ],
      ),
    );
  }
}

class GeneralUserMapFiltersShimmer extends StatelessWidget {
  const GeneralUserMapFiltersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Center(child: _box(width: 120, height: 26)),
          const SizedBox(height: 16),
          _box(height: 20, width: 140),
          const SizedBox(height: 10),
          _box(height: 48),
          const SizedBox(height: 10),
          _box(height: 48),
          const SizedBox(height: 10),
          _box(height: 48),
          const SizedBox(height: 18),
          _box(height: 20, width: 120),
          const SizedBox(height: 10),
          _box(height: 48),
          const SizedBox(height: 10),
          _box(height: 48),
        ],
      ),
    );
  }
}

Widget _box({
  double? width,
  required double height,
  double radius = 12,
}) {
  return Container(
    width: width ?? double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

Widget _circle(double size) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
  );
}
