import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../screens/complaint/complaint_detail_screen.dart';
import '../utils/extensions.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      // PERBAIKAN: InkWell dipindahkan ke luar Card agar efek sentuhan lebih baik
      // dan tidak mengganggu event navigasi.
      child: InkWell(
        onTap: () {
          // PERBAIKAN UTAMA: Mengirim `complaint.id` ke parameter `complaintId`
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ComplaintDetailScreen(complaintId: complaint.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, textTheme),
              const SizedBox(height: 12),
              _buildContent(textTheme),
              const SizedBox(height: 12),
              _buildFooter(context, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        Text(
          complaint.category.icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Text(
          complaint.category.displayName,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _buildStatusChip(textTheme),
      ],
    );
  }

  Widget _buildStatusChip(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: complaint.status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        complaint.status.displayName,
        style: textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          complaint.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          complaint.description,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    final hasEvidence = complaint.evidencePath != null && complaint.evidencePath!.isNotEmpty;

    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          complaint.createdAt.formatDate(),
          style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const Spacer(),
        if (hasEvidence) ...[
          Icon(Icons.camera_alt, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'Foto',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
        ],
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }
}