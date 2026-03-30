import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportBuildingTypeScreen extends ConsumerWidget {
  const CreateReportBuildingTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Inspeksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 1 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Pilih Jenis Fasilitas/Bangunan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AppCard(
                onTap: () {
                  ref.read(createReportFormProvider.notifier).setBuildingType('Fasilitas Produksi');
                  context.pushNamed(RouteNames.petugasCreateReportLocation);
                },
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.factory_outlined, size: 64, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Fasilitas Produksi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Area pabrik, gudang bahan baku, dll',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AppCard(
                onTap: () {
                  ref.read(createReportFormProvider.notifier).setBuildingType('Fasilitas Non-Produksi');
                  context.pushNamed(RouteNames.petugasCreateReportLocation);
                },
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.park_outlined, size: 64, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Fasilitas Non-Produksi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Kantor umum, area parkir, kantin, dll',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
