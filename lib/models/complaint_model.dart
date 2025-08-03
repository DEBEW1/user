
enum ComplaintCategory {
  infrastruktur,
  kebersihan,
  keamanan,
  pelayanan,
  lainnya,
}

enum ComplaintStatus {
  menunggu,
  diproses,
  selesai,
}

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final ComplaintCategory category;
  final ComplaintStatus status;
  final String? evidencePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? response;
  final String userId;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.evidencePath,
    required this.createdAt,
    required this.updatedAt,
    this.response,
    required this.userId,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'status': status.index,
      'evidencePath': evidencePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'response': response,
      'userId': userId,
    };
  }

  // Create from JSON
  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ComplaintCategory.values[json['category']],
      status: ComplaintStatus.values[json['status']],
      evidencePath: json['evidencePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      response: json['response'],
      userId: json['userId'],
    );
  }

  // Create a copy with updated fields
  ComplaintModel copyWith({
    String? id,
    String? title,
    String? description,
    ComplaintCategory? category,
    ComplaintStatus? status,
    String? evidencePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? response,
    String? userId,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      evidencePath: evidencePath ?? this.evidencePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      response: response ?? this.response,
      userId: userId ?? this.userId,
    );
  }
}