import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../widgets/complaint_card.dart';
import 'complaint_detail_screen.dart'; 

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  final ComplaintService _complaintService = ComplaintService();
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  void _loadComplaints() {
    setState(() {
      _complaintsFuture = _complaintService.getAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengaduan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadComplaints();
        },
        child: FutureBuilder<List<ComplaintModel>>(
          future: _complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada pengaduan.'));
            }

            final complaints = snapshot.data!;
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return InkWell(
                  onTap: () async {
                    // PERBAIKAN: Kirim ID-nya, bukan objek
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailScreen(complaintId: complaint.id),
                      ),
                    );
                    // Jika ada perubahan dari halaman detail, muat ulang daftar
                    if (result == true) {
                      _loadComplaints();
                    }
                  },
                  child: ComplaintCard(complaint: complaint),
                );
              },
            );
          },
        ),
      ),
    );
  }
}