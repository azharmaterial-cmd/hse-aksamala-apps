import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';

class PetugasHomeScreen extends ConsumerWidget {
  const PetugasHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final db = ref.watch(mockDatabaseProvider);

    final reports = [...db.reports]
      ..sort((a, b) => DateTime.parse(b['date'] as String)
          .compareTo(DateTime.parse(a['date'] as String)));
    final latestReports = reports.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 84,
            floating: true,
            pinned: false,
            elevation: 0,
            leading: null,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              centerTitle: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Good Morning,',
                        style: AppTypography.h2,
                      ),
                      Text(
                        '${user?.username ?? 'Tisha'}!',
                        style: AppTypography.h1,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed(RouteNames.petugasProfile),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Icon(
                        PhosphorIcons.user(),
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION: TEAM PRODUCTIVITY CARD
                  _buildTeamProductivityCard(),
                  const SizedBox(height: 32),
                  // TYPOGRAPHY TASKS HEADER MIRIP GAMBAR
                  Text(
                    '${latestReports.length} More Tasks',
                    style: AppTypography.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'that have already been patrolled',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // SECTION: OVERLAPPING TASKS LIST
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rpt = latestReports[index];
                  // Kita menggunakan Align dengan heightFactor < 1.0 untuk membuat
                  // kartu di bawahnya naik dan menutupi (overlap) kartu sebelumnya
                  final isLast = index == latestReports.length - 1;

                  return Align(
                    heightFactor: isLast ? 1.0 : 0.75, // Mengatur tingkat overlap
                    alignment: Alignment.topCenter,
                    child: _buildExactTaskCard(
                      context,
                      index: index,
                      title: _getMockTitle(rpt),
                      timeRange: _getMockTime(rpt['date']?.toString()),
                      tag: _getStatusTag(rpt['status']?.toString()),
                      reportId: rpt['id'].toString(),
                      isLast: isLast,
                    ),
                  );
                },
                childCount: latestReports.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: EXACT TASK CARD (Clone Layout & Style Gambar)
  // ===========================================================================
  Widget _buildExactTaskCard(
    BuildContext context, {
    required int index,
    required String title,
    required String timeRange,
    String? tag,
    required String reportId,
    required bool isLast,
  }) {
    // Definisi palet warna berdasarkan urutan index kartu seperti di gambar
    final List<Color> cardColors = [
      const Color(0xFFD4D8FF), // Light Purple
      const Color(0xFFFFFFFF), // White
      const Color(0xFFFAFF9F), // Light Yellow
    ];
    final color = cardColors[index % cardColors.length];

    return InkWell(
      onTap: () => context.pushNamed(
        RouteNames.reportDetail,
        pathParameters: {'id': reportId},
      ),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          // Border solid warna gelap (hitam keabuan) untuk mempertegas overlap
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
        ),
        // Padding bottom ekstra jika bukan kartu terakhir supaya kontennya
        // tidak terlalu tertutup oleh kartu yang overlap di bawahnya
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: isLast ? 24 : 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      color: const Color(0xFF1E1E1E),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF6B6E94),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ]
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  timeRange,
                  style: AppTypography.body1.copyWith(
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildOverlappingAvatars(index),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Membuat tumpukan avatar mock (profil) di pojok kanan bawah
  Widget _buildOverlappingAvatars(int index) {
    // Variasi jumlah avatar berdasarkan index supaya mirip gambar
    int count = index == 0 ? 4 : (index == 1 ? 2 : 0);
    if (count == 0) return const SizedBox(); // Card ke-3 di gambar tidak ada avatar

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count + (index == 0 ? 1 : 0), (i) {
        final isMoreBubble = index == 0 && i == count; // Bubble "+4" untuk kartu pertama
        return Align(
          widthFactor: 0.7, // Membuat avatar saling tumpang tindih
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isMoreBubble ? const Color(0xFF1E1E1E) : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              image: !isMoreBubble
                  ? DecorationImage(
                      image: NetworkImage(
                          'https://i.pravatar.cc/100?img=${(index * 10) + i + 1}'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: isMoreBubble
                ? Text('+4',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))
                : null,
          ),
        );
      }),
    );
  }

  // --- Helper Data dari Mock Database ---
  String _getMockTitle(Map<String, dynamic> report) {
    // Tampilkan rootCause sebagai judul utama, fallback ke area atau notes
    return report['rootCause']?.toString() ??
           report['area']?.toString() ??
           report['notes']?.toString() ??
           'Task';
  }

  String _getMockTime(String? dateString) {
    if (dateString == null) return 'Just now';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      // Format berdasarkan waktu relatif
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        // Format tanggal lengkap: "Mar 25, 2:30 PM"
        return '${DateFormat.MMMd().format(date)}, ${DateFormat.jm().format(date)}';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  String? _getStatusTag(String? status) {
    if (status == null) return null;

    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'follow up done':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return null;
    }
  }

  // ===========================================================================
  // WIDGET: TEAM PRODUCTIVITY CARD (TIDAK ADA PERUBAHAN)
  // ===========================================================================
  Widget _buildTeamProductivityCard() {
    final List<List<int>> gridPattern = [
      [1, 1, 1, 1, 2, 3, 3],
      [1, 1, 1, 2, 2, 3, 3],
      [1, 1, 2, 2, 3, 3, 1],
      [1, 1, 2, 3, 3, 3, 1],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team\nProductivity',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textInverted,
                  height: 1.15,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textInverted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    PhosphorIcons.caretDown(),
                    size: 16,
                    color: AppColors.textInverted,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Column(
            children: gridPattern.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: row.asMap().entries.map((entry) {
                    final isLast = entry.key == row.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 6.0),
                        child: _buildGridPill(entry.value),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPill(int type) {
    if (type == 1) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.textInverted,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    } else {
      final isBold = type == 2;
      return Container(
        height: 12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _StripedPainter(
            color: isBold
                ? AppColors.textInverted.withValues(alpha: 0.3)
                : AppColors.textInverted.withValues(alpha: 0.1),
          ),
        ),
      );
    }
  }
}

class _StripedPainter extends CustomPainter {
  final Color color;
  _StripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const double space = 5.0;
    for (double i = -size.height; i < size.width; i += space) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}