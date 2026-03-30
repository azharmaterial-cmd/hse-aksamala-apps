import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockUser {
  final String id;
  final String username;
  final String password;
  final String role; 
  final List<String> areaAccess;

  MockUser({
    required this.id, 
    required this.username, 
    required this.password, 
    required this.role,
    this.areaAccess = const [],
  });
}

class MockDatabase {
  final List<MockUser> users = [
    MockUser(id: '1', username: 'petugas', password: '123', role: 'petugas'),
    MockUser(id: '2', username: 'pic', password: '123', role: 'pic', areaAccess: ['Area Produksi 1 - Mesin Bubut', 'Koridor Evakuasi Barat']),
  ];

  final List<Map<String, dynamic>> reports = [
    {
      'id': 'rpt_001',
      'buildingType': 'Fasilitas Produksi',
      'area': 'Area Produksi 1 - Mesin Bubut',
      'riskLevel': 'Berat',
      'notes': 'Mesin mendadak mati dan stop darurat.',
      'rootCause': 'Belum ada analisa lanjutan.',
      'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'status': 'Pending',
    },
    {
      'id': 'rpt_002',
      'buildingType': 'Fasilitas Non-Produksi',
      'area': 'Koridor Evakuasi Barat',
      'riskLevel': 'Ringan',
      'notes': 'Lampu neon koridor putus.',
      'rootCause': 'Usia pakai lampu habis.',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'status': 'Approved',
    }, 
    {
      'id': 'rpt_002',
      'buildingType': 'Fasilitas Non-Produksi',
      'area': 'Koridor Evakuasi Barat',
      'riskLevel': 'Kritis',
      'notes': 'Lampu neon kedap kedip.',
      'rootCause': 'udah lama.',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'status': 'Approved',
    }
  ];

  void addReport(Map<String, dynamic> report) {
    reports.insert(0, report);
  }

  void updateReportStatus(String id, String newStatus, {String? picNotes, List<String>? picPhotos, String? rejectedReason}) {
    final index = reports.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      final updatedReport = Map<String, dynamic>.from(reports[index]);
      updatedReport['status'] = newStatus;
      
      List<dynamic> followUps = updatedReport['followUps'] != null 
          ? List<dynamic>.from(updatedReport['followUps']) 
          : [];
          
      if (newStatus == 'Follow Up Done') {
         followUps.add({
           'type': 'PIC_FOLLOW_UP',
           'notes': picNotes,
           'photos': picPhotos ?? [],
           'date': DateTime.now().toIso8601String(),
         });
      } else if (newStatus == 'Rejected' || newStatus == 'Approved') {
         followUps.add({
           'type': 'PETUGAS_REVIEW',
           'action': newStatus,
           'notes': rejectedReason,
           'date': DateTime.now().toIso8601String(),
         });
      }
      
      updatedReport['followUps'] = followUps;
      
      // Karena kita mutate isi list, paksa Riverpod recognize (asumsi immutable structure, tapi karena mock list biasa, kita assign ulang saja)
      reports[index] = updatedReport;
    }
  }
}

final mockDatabaseProvider = Provider<MockDatabase>((ref) {
  return MockDatabase();
});

final currentUserProvider = StateProvider<MockUser?>((ref) => null);
