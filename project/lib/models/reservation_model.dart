class ReservationModel {
  final String id;
  final String postId;
  final String studentId;
  final int quantity;
  final ReservationStatus status;
  final String qrCodeData;
  final DateTime createdAt;
  final DateTime? completedAt;

  ReservationModel({
    required this.id,
    required this.postId,
    required this.studentId,
    required this.quantity,
    this.status = ReservationStatus.reserved,
    required this.qrCodeData,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'studentId': studentId,
      'quantity': quantity,
      'status': status.toString().split('.').last,
      'qrCodeData': qrCodeData,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      studentId: map['studentId'] ?? '',
      quantity: map['quantity'] ?? 1,
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ReservationStatus.reserved,
      ),
      qrCodeData: map['qrCodeData'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  ReservationModel copyWith({
    String? id,
    String? postId,
    String? studentId,
    int? quantity,
    ReservationStatus? status,
    String? qrCodeData,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      studentId: studentId ?? this.studentId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum ReservationStatus {
  reserved,
  completed,
  cancelled,
  expired,
}

