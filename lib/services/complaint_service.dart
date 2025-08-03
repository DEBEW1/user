import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint_model.dart';
import 'auth_service.dart';

class ComplaintService {
  static const String _complaintsKey = 'complaints';
  final AuthService _authService = AuthService();

  Future<bool> submitComplaint({
    required String title,
    required String description,
    required ComplaintCategory category,
    String? evidencePath,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      final newComplaint = ComplaintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        status: ComplaintStatus.menunggu,
        evidencePath: evidencePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: currentUser.id,
      );

      final complaints = await getAllComplaints();
      complaints.add(newComplaint);
      await _saveComplaints(complaints);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<int> getComplaintCountByStatus(ComplaintStatus status) async {
    final complaints = await getAllComplaints();
    return complaints.where((c) => c.status == status).length;
  }

  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complaintsJson = prefs.getString(_complaintsKey);
      
      if (complaintsJson != null) {
        final List<dynamic> complaintsList = json.decode(complaintsJson);
        return complaintsList
            .map((complaint) => ComplaintModel.fromJson(complaint))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveComplaints(List<ComplaintModel> complaints) async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = json.encode(
      complaints.map((complaint) => complaint.toJson()).toList(),
    );
    await prefs.setString(_complaintsKey, complaintsJson);
  }

  // ... (sisa method lainnya tetap sama) ...
    Future<List<ComplaintModel>> getComplaintsByUser(String userId) async {
    final allComplaints = await getAllComplaints();
    return allComplaints.where((complaint) => complaint.userId == userId).toList();
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    final complaints = await getAllComplaints();
    try {
      return complaints.firstWhere((complaint) => complaint.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateComplaintStatus(String id, ComplaintStatus status, {String? response}) async {
    try {
      final complaints = await getAllComplaints();
      final index = complaints.indexWhere((complaint) => complaint.id == id);
      
      if (index != -1) {
        complaints[index] = complaints[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          response: response,
        );
        await _saveComplaints(complaints);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<ComplaintModel>> getComplaintsByStatus(ComplaintStatus status) async {
    final complaints = await getAllComplaints();
    return complaints.where((complaint) => complaint.status == status).toList();
  }

  Future<List<ComplaintModel>> getComplaintsByCategory(ComplaintCategory category) async {
    final complaints = await getAllComplaints();
    return complaints.where((complaint) => complaint.category == category).toList();
  }

  Future<bool> deleteComplaint(String id) async {
    try {
      final complaints = await getAllComplaints();
      complaints.removeWhere((complaint) => complaint.id == id);
      await _saveComplaints(complaints);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getComplaintStatistics() async {
    final complaints = await getAllComplaints();
    
    return {
      'total': complaints.length,
      'menunggu': complaints.where((c) => c.status == ComplaintStatus.menunggu).length,
      'diproses': complaints.where((c) => c.status == ComplaintStatus.diproses).length,
      'selesai': complaints.where((c) => c.status == ComplaintStatus.selesai).length,
    };
  }

  Future<void> clearAllComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_complaintsKey);
  }
}