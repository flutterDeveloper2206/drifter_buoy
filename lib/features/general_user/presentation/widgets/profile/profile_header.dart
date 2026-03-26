import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserProfileHeader extends StatelessWidget {
  const GeneralUserProfileHeader({super.key});

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
                'Profile',
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

