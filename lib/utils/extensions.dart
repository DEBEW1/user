import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint_model.dart';

extension ComplaintCategoryExtension on ComplaintCategory {
  String get displayName {
    switch (this) {
      case ComplaintCategory.infrastruktur:
        return 'Infrastruktur';
      case ComplaintCategory.kebersihan:
        return 'Kebersihan';
      case ComplaintCategory.keamanan:
        return 'Keamanan';
      case ComplaintCategory.pelayanan:
        return 'Pelayanan';
      case ComplaintCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case ComplaintCategory.infrastruktur:
        return '🏗️';
      case ComplaintCategory.kebersihan:
        return '🧹';
      case ComplaintCategory.keamanan:
        return '🛡️';
      case ComplaintCategory.pelayanan:
        return '👥';
      case ComplaintCategory.lainnya:
        return '❓';
    }
  }
}

extension ComplaintStatusExtension on ComplaintStatus {
  String get displayName {
    switch (this) {
      case ComplaintStatus.menunggu:
        return 'Menunggu';
      case ComplaintStatus.diproses:
        return 'Diproses';
      case ComplaintStatus.selesai:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case ComplaintStatus.menunggu:
        return Colors.orange;
      case ComplaintStatus.diproses:
        return Colors.blue;
      case ComplaintStatus.selesai:
        return Colors.green;
    }
  }
}

extension DateFormatting on DateTime {
  String formatDate() {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(this);
  }
}