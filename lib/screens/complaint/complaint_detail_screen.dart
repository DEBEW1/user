import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../utils/extensions.dart';
class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _complaintService = ComplaintService();
  final _authService = AuthService();

  late Future<ComplaintModel?> _complaintFuture;
  bool _isAdmin = false;
  bool _hasChanges = false;

  final _responseController = TextEditingController();
  ComplaintStatus? _newStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadComplaint();
  }

  Future<void> _checkUserRole() async {
    final user = await _authService.getCurrentUser();
    if (user != null && user.email.endsWith('@admin.com')) {
      if (mounted) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  void _loadComplaint() {
    setState(() {
      _complaintFuture = _complaintService.getComplaintById(widget.complaintId);
    });
  }
  
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _updateComplaint(ComplaintModel currentComplaint) async {
    if (_newStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih status baru.')));
      return;
    }
    
    setState(() => _isUpdating = true);

    final success = await _complaintService.updateComplaintStatus(
      currentComplaint.id,
      _newStatus!,
      response: _responseController.text.trim().isNotEmpty ? _responseController.text.trim() : currentComplaint.response,
    );
    
    if (mounted) {
      if (success) {
        _hasChanges = true;
        _loadComplaint(); // Muat ulang data
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diperbarui.'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status.'), backgroundColor: Colors.red));
      }
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) return;
        Navigator.of(context).pop(_hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Pengaduan')),
        body: FutureBuilder<ComplaintModel?>(
          future: _complaintFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Gagal memuat detail pengaduan.'));
            }

            final complaint = snapshot.data!;
            _newStatus ??= complaint.status;
            if (_responseController.text.isEmpty) {
              _responseController.text = complaint.response ?? '';
            }

            return _buildScreenContent(complaint);
          },
        ),
      ),
    );
  }

  Widget _buildScreenContent(ComplaintModel complaint) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(complaint, textTheme),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Laporan Pengaduan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(complaint.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Kategori: ${complaint.category.displayName}', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                const Divider(height: 24),
                Text(complaint.description, style: textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (complaint.evidencePath != null && complaint.evidencePath!.isNotEmpty)
            _buildInfoCard(
              title: 'Bukti Foto',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(complaint.evidencePath!), fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('Gagal memuat gambar.'))),
              ),
            ),
          
          if (complaint.response != null && complaint.response!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Tanggapan',
              child: Text(complaint.response!, style: textTheme.bodyMedium?.copyWith(height: 1.5, fontStyle: FontStyle.italic)),
              icon: Icons.reply,
              iconColor: Theme.of(context).primaryColor,
            ),
          ],
          
          if (_isAdmin) ...[
            const Divider(height: 48),
            _buildAdminPanel(complaint, textTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ComplaintModel complaint, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Saat Ini', style: textTheme.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: complaint.status.color, borderRadius: BorderRadius.circular(20)),
                  child: Text(complaint.status.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tanggal Laporan', style: textTheme.bodySmall),
                  Text(complaint.createdAt.formatDate(), style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({required String title, required Widget child, IconData? icon, Color? iconColor}) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if(icon != null) ...[Icon(icon, color: iconColor ?? Colors.grey[700], size: 20), const SizedBox(width: 8)],
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanel(ComplaintModel complaint, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Panel Admin', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<ComplaintStatus>(
          value: _newStatus,
          decoration: const InputDecoration(labelText: 'Ubah Status Menjadi', border: OutlineInputBorder()),
          items: ComplaintStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(status.displayName))).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _newStatus = value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _responseController,
          decoration: const InputDecoration(labelText: 'Tanggapan (opsional)', border: OutlineInputBorder(), hintText: 'Berikan tanggapan untuk pengguna...'),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isUpdating ? null : () => _updateComplaint(complaint),
          icon: _isUpdating ? const SizedBox.shrink() : const Icon(Icons.update),
          label: _isUpdating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Perbarui Status'),
        ),
      ],
    );
  }
}