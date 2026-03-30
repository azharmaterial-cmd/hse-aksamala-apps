import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

class PetugasShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PetugasShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0), // Full extend ke bawah
              child: navigationShell,
            ),
          ),

          Positioned(
            bottom: 24,
            left: 102,
            right: 102,
            child: Material(
              elevation: 8, // Elevation tinggi untuk memastikan di atas konten home screen
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparan agar homepage screen di belakang terlihat
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(
                    iconPath: 'lib/assets/tasks.svg',
                    index: 1,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.petugasCreateReport),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.textInverted.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'lib/assets/add_bold.svg',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textInverse,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildNavItem(
                    iconPath: 'lib/assets/calendar.svg',
                    index: 0,
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return InkWell(
      onTap: () => _goBranch(index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        width: 50,
        height: 54,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: isActive ? 32 : 32,
            height: isActive ? 32 : 32,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.textPrimary : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
