import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  void _handlePetugasReview(MockDatabase db, String newStatus) async {
    String? reason;
    
    if (newStatus == 'Rejected') {
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tolak Perbaikan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Misal: Pagar pembatas tidak dilas secara permanen...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Batal')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRejected, foregroundColor: Colors.white),
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Alasan wajib diisi!')));
                  return;
                }
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text('Tolak')
            ),
          ],
        ),
      );
      
      if (reason == null) return; // Batal tekan tolak
    }

    db.updateReportStatus(widget.reportId, newStatus, rejectedReason: reason);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan di-$newStatus!')));
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mockDatabaseProvider);
    final user = ref.watch(currentUserProvider);
    
    final rptIndex = db.reports.indexWhere((r) => r['id'] == widget.reportId);
    if (rptIndex == -1) {
      return Scaffold(appBar: AppBar(title: const Text('Detail')), body: const Center(child: Text('Laporan tidak ditemukan.')));
    }
    
    final rpt = db.reports[rptIndex];
    final isPic = user?.role == 'pic';
    final isPetugas = user?.role == 'petugas';
    final status = rpt['status'] ?? 'Pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Laporan', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                StatusBadge(
                  text: status,
                  backgroundColor: _getStatusColor(status),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            
            // Detail Informasi Petugas
            _buildDetailRow('Lokasi / Area', rpt['area']),
            _buildDetailRow('Tingkat Risiko', rpt['riskLevel']),
            _buildDetailRow('Waktu Lapor', rpt['date'] != null ? rpt['date'].toString().substring(0, 16) : '-'),
            _buildDetailRow('Catatan Temuan', rpt['notes']),
            _buildDetailRow('Identifikasi Akar Masalah', rpt['rootCause']),
            
            if (rpt['photos'] != null && (rpt['photos'] as List).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Text('Foto Bukti Temuan (Petugas)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildPhotoGrid(List<String>.from(rpt['photos'])),
            ],
            
            const SizedBox(height: AppSpacing.xl),
            
            // Historical Updates (Tanggapan beruntun dari PIC dan Petugas)
            Builder(
              builder: (context) {
                final followUps = rpt['followUps'] as List<dynamic>? ?? [];
                if (followUps.isEmpty) return const SizedBox();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Riwayat Tindak Lanjut & Review', 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...followUps.map((log) {
                      final isPicLog = log['type'] == 'PIC_FOLLOW_UP';
                      final actionStatus = log['action'];
                      
                      Color boxColor = AppColors.primaryLight.withValues(alpha: 0.1);
                      Color borderColor = AppColors.primary;
                      
                      if (!isPicLog) {
                         if (actionStatus == 'Rejected') {
                           boxColor = AppColors.statusRejected.withValues(alpha: 0.1);
                           borderColor = AppColors.statusRejected;
                         } else {
                           boxColor = AppColors.statusApproved.withValues(alpha: 0.1);
                           borderColor = AppColors.statusApproved;
                         }
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: boxColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPicLog ? 'Tindak Lanjut PIC' : 'Review Petugas (${log['action']})',
                              style: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                            ),
                            const SizedBox(height: 8),
                            if (log['notes'] != null && log['notes'].toString().isNotEmpty)
                               Text(log['notes'].toString()),
                            if (isPicLog && log['photos'] != null && (log['photos'] as List).isNotEmpty) ...[
                               const SizedBox(height: AppSpacing.md),
                               _buildPhotoGrid(List<String>.from(log['photos'])),
                            ]
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }
            ),
            
            // ---------------- ACTIONS BLOCK ----------------
            if (isPic && (status == 'Pending' || status == 'Rejected')) ...[
              Text(
                status == 'Rejected' ? 'Laporan Ditolak Petugas!' : 'Aksi Dibutuhkan', 
                style: TextStyle(fontWeight: FontWeight.bold, color: status == 'Rejected' ? AppColors.statusRejected : AppColors.textPrimary)
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                status == 'Rejected' 
                  ? 'Silakan baca alasan penolakan pada riwayat di atas, lalu ulangi perbaikan dan lampirkan bukti baru.' 
                  : 'Silakan berikan respons dengan melampirkan foto hasil perbaikan di lapangan.', 
                style: Theme.of(context).textTheme.bodyMedium
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: status == 'Rejected' ? 'Ulangi Tindak Lanjut' : 'Mulai Tindak Lanjut',
                onPressed: () {
                   ref.read(picFollowUpFormProvider.notifier).setReportId(widget.reportId);
                   context.pushNamed(RouteNames.picFollowUpPhotos);
                },
              )
            ]  
            else if (isPic && status == 'Follow Up Done') ...[
              const Center(child: Text('Menunggu persetujuan (Approve/Reject) dari Petugas.', style: TextStyle(fontStyle: FontStyle.italic))),
            ]
            else if (isPetugas && (status == 'Pending' || status == 'Rejected')) ...[
              const Center(child: Text('Menunggu tindak lanjut dari PIC yang bertanggung jawab.', style: TextStyle(fontStyle: FontStyle.italic))),
            ]
            else if (isPetugas && status == 'Follow Up Done') ...[
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Tolak Perbaikan',
                      type: AppButtonType.outlined,
                      onPressed: () => _handlePetugasReview(db, 'Rejected'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      text: 'Approve (Selesai)',
                      onPressed: () => _handlePetugasReview(db, 'Approved'),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: paths.map((p) {
          final isNetwork = p.startsWith('http');
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetwork 
                ? Image.network(p, width: 80, height: 80, fit: BoxFit.cover)
                : Image.file(File(p), width: 80, height: 80, fit: BoxFit.cover),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return AppColors.statusApproved;
      case 'rejected': return AppColors.statusRejected;
      case 'follow up done': return AppColors.primary;
      case 'pending':
      default: return AppColors.statusPending;
    }
  }
}
