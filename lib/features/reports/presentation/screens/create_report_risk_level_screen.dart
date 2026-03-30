import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportRiskLevelScreen extends ConsumerWidget {
  const CreateReportRiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void selectRisk(String riskName) {
      ref.read(createReportFormProvider.notifier).setRiskLevel(riskName);
      context.pushNamed(RouteNames.petugasCreateReportPhotos);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tingkat Risiko')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 3 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Pilih Tingkat Risiko',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Seberapa bahaya temuan ini terhadap keselamatan kerja?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  _buildRiskCard(context, 'Kritis (1)', AppColors.riskCritical, () => selectRisk('Kritis')),
                  _buildRiskCard(context, 'Berat (2)', AppColors.riskHigh, () => selectRisk('Berat')),
                  _buildRiskCard(context, 'Sedang (3)', AppColors.riskMedium, () => selectRisk('Sedang')),
                  _buildRiskCard(context, 'Ringan (4)', AppColors.riskLow, () => selectRisk('Ringan')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context, String title, Color color, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
