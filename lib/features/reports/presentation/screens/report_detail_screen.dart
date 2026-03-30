import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../app/router/route_names.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  // Modal Penolakan Modern
  void _handlePetugasReview(MockDatabase db, String newStatus) async {
    String? reason;

    if (newStatus == 'Rejected') {
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface, // Dark mode surface
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Text('Tolak Perbaikan', style: AppTypography.h3),
          content: TextField(
            controller: controller,
            style: AppTypography.body1,
            decoration: InputDecoration(
              hintText: 'Misal: Pagar pembatas tidak dilas permanen...',
              hintStyle: AppTypography.caption,
              filled: true,
              fillColor: AppColors.background, // Hitam pekat
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Alasan wajib diisi!')));
                    return;
                  }
                  Navigator.pop(ctx, controller.text.trim());
                },
                child: Text('Tolak', style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      );

      if (reason == null) return; // Batal
    }

    db.updateReportStatus(widget.reportId, newStatus, rejectedReason: reason);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan di-$newStatus!')));
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mockDatabaseProvider);
    final user = ref.watch(currentUserProvider);

    // =========================================================================
    // DEBUG: Print untuk tracking
    // =========================================================================
    debugPrint('ReportDetailScreen: reportId = ${widget.reportId}');
    debugPrint('ReportDetailScreen: total reports = ${db.reports.length}');

    // =========================================================================
    // BUG FIX LAYAR HITAM: Menggunakan .toString() agar aman dari tipe data int/String
    // =========================================================================
    final rptIndex = db.reports.indexWhere((r) => r['id'].toString() == widget.reportId.toString());

    debugPrint('ReportDetailScreen: rptIndex = $rptIndex');

    // BUG FIX LAYAR HITAM: Styling text putih pada state error agar terlihat
    if (rptIndex == -1) {
      debugPrint('ReportDetailScreen: Report not found!');
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text('Detail', style: AppTypography.h3.copyWith(color: Colors.white)),
        ),
        body: Center(
          child: Text(
            'Laporan tidak ditemukan.',
            style: AppTypography.body1.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    final rpt = db.reports[rptIndex];
    debugPrint('ReportDetailScreen: rpt = $rpt');
    debugPrint('ReportDetailScreen: area = ${rpt['area']}');
    debugPrint('ReportDetailScreen: status = ${rpt['status']}');
    final isPic = user?.role == 'pic';
    final isPetugas = user?.role == 'petugas';
    final status = rpt['status']?.toString() ?? 'Pending';

    debugPrint('ReportDetailScreen: Building UI with $isPic, $isPetugas, $status');

    return Scaffold(
      backgroundColor: AppColors.background, // Hitam Pekat
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Task Detail', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. KONTEN UTAMA (Scrollable)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HERO SECTION (Card Berwarna) ---
                  _buildHeroCard(rpt, status),
                  const SizedBox(height: 24),

                  // --- QUICK INFO GRID ---
                  Text("Informasi Laporan", style: AppTypography.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                            PhosphorIcons.mapPin(), 'Lokasi', rpt['area']?.toString() ?? '-'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                            PhosphorIcons.warningCircle(), 'Risiko', rpt['riskLevel']?.toString() ?? '-',
                            iconColor: rpt['riskLevel']?.toString() == 'Kritis' ? Colors.redAccent : AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(PhosphorIcons.clock(), 'Waktu Dilaporkan',
                    _formatDate(rpt['date']?.toString())),
                  const SizedBox(height: 24),

                  // --- DESKRIPSI MASALAH ---
                  _buildSectionBox('Catatan Temuan', rpt['notes']?.toString() ?? '-', PhosphorIcons.notePencil()),
                  const SizedBox(height: 16),
                  _buildSectionBox('Akar Masalah (Root Cause)', rpt['rootCause']?.toString() ?? '-', PhosphorIcons.treeStructure()),
                  const SizedBox(height: 24),

                  // --- LAMPIRAN FOTO ---
                  if (rpt['photos'] != null && (rpt['photos'] as List).isNotEmpty) ...[
                    Text("Lampiran Bukti", style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildPhotoGrid(List<String>.from(rpt['photos'])),
                    const SizedBox(height: 32),
                  ],

                  // --- TIMELINE RIWAYAT ---
                  Builder(builder: (context) {
                    final followUps = rpt['followUps'] as List<dynamic>? ?? [];
                    if (followUps.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Riwayat Tindak Lanjut", style: AppTypography.h3),
                        const SizedBox(height: 16),
                        ...followUps.asMap().entries.map((entry) {
                          final isLast = entry.key == followUps.length - 1;
                          return _buildTimelineItem(entry.value as Map<String, dynamic>, isLast);
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // 2. FLOATING ACTION BOTTOM AREA
            _buildFloatingActionArea(isPic, isPetugas, status, db),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS (DESIGN SYSTEM)
  // ===========================================================================

  Widget _buildHeroCard(Map<String, dynamic> rpt, String status) {
    // Tentukan warna berdasarkan status untuk memberikan nuansa "Colorful"
    Color bgColor = AppColors.secondary; // Default Ungu Pastel
    Color textColor = AppColors.textInverted;

    if (status == 'Approved') bgColor = AppColors.primary; // Kuning Neon
    if (status == 'Rejected') bgColor = Colors.redAccent.withValues(alpha: 0.9); // Merah

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.2), // Tembus pandang
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                color: textColor,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            rpt['rootCause']?.toString() ?? 'Inspeksi Area',
            style: AppTypography.h1.copyWith(color: textColor, height: 1.1),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Card kecil bergaya modern untuk Lokasi, Waktu, Risiko
  Widget _buildInfoCard(PhosphorIconData icon, String title, String value, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Abu-abu gelap flat
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PhosphorIcon(icon, color: iconColor ?? AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Box surface untuk membungkus catatan panjang
  Widget _buildSectionBox(String title, String content, PhosphorIconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.body1.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTypography.body1.copyWith(height: 1.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Modern Timeline Item
  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    final isPicLog = log['type']?.toString() == 'PIC_FOLLOW_UP';
    final action = log['action']?.toString();

    // Warnai titik timeline berdasarkan aksi
    Color dotColor = AppColors.secondary;
    if (action == 'Rejected') dotColor = Colors.redAccent;
    if (action == 'Approved') dotColor = AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis Vertikal & Titik
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.surfaceLight,
                    ),
                  )
              ],
            ),
          ),
          // Konten Timeline
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPicLog ? 'Tindak Lanjut PIC' : 'Review Petugas (${action ?? "Unknown"})',
                      style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold, color: dotColor),
                    ),
                    if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(log['notes'].toString(), style: AppTypography.caption),
                    ],
                    if (isPicLog && log['photos'] != null && (log['photos'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPhotoGrid(List<String>.from(log['photos'] as List), height: 60),
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths, {double height = 80}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: paths.map((p) {
          final isNetwork = p.toString().startsWith('http');
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Rounded lebih mulus
              child: isNetwork
                  ? Image.network(p.toString(), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, error, stack) {
                      return Container(
                        width: height,
                        height: height,
                        color: AppColors.surface,
                        child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                      );
                    })
                  : Image.file(File(p.toString()), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, error, stack) {
                      return Container(
                        width: height,
                        height: height,
                        color: AppColors.surface,
                        child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                      );
                    }),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Helper untuk format tanggal dengan aman
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      final date = DateTime.parse(dateString);
      // Format: "2025-03-25 14:30"
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return dateString;
    }
  }

  // Floating Action Area agar tombol selalu nempel di bawah layar
  Widget _buildFloatingActionArea(bool isPic, bool isPetugas, String status, MockDatabase db) {
    Widget? actionWidget;

    if (isPic && (status == 'Pending' || status == 'Rejected')) {
      bool isRejected = status == 'Rejected';
      actionWidget = AppButton(
        text: isRejected ? 'Ulangi Tindak Lanjut' : 'Mulai Tindak Lanjut',
        onPressed: () {
          ref.read(picFollowUpFormProvider.notifier).setReportId(widget.reportId);
          context.pushNamed(RouteNames.picFollowUpPhotos);
        },
      );
    } else if (isPetugas && status == 'Follow Up Done') {
      actionWidget = Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Tolak',
              type: AppButtonType.outlined,
              onPressed: () => _handlePetugasReview(db, 'Rejected'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Selesai',
              onPressed: () => _handlePetugasReview(db, 'Approved'),
            ),
          ),
        ],
      );
    }

    if (actionWidget == null) return const SizedBox.shrink(); // Hide jika tidak ada aksi

    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.8), // Glassmorphism tipis
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: actionWidget,
      ),
    );
  }
}