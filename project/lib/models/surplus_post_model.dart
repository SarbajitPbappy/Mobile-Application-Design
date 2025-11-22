class SurplusPostModel {
  final String id;
  final String cafeteriaId;
  final String title;
  final String? description;
  final FoodCategory category;
  final int totalPortions;
  final int availablePortions;
  final String pickupLocation;
  final DateTime startTime;
  final DateTime endTime;
  final bool forNgo;
  final PostStatus status;
  final DateTime createdAt;
  final String? imageUrl;

  SurplusPostModel({
    required this.id,
    required this.cafeteriaId,
    required this.title,
    this.description,
    required this.category,
    required this.totalPortions,
    required this.availablePortions,
    required this.pickupLocation,
    required this.startTime,
    required this.endTime,
    this.forNgo = false,
    this.status = PostStatus.active,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cafeteriaId': cafeteriaId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'totalPortions': totalPortions,
      'availablePortions': availablePortions,
      'pickupLocation': pickupLocation,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'forNgo': forNgo,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory SurplusPostModel.fromMap(Map<String, dynamic> map) {
    return SurplusPostModel(
      id: map['id'] ?? '',
      cafeteriaId: map['cafeteriaId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: FoodCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => FoodCategory.veg,
      ),
      totalPortions: map['totalPortions'] ?? 0,
      availablePortions: map['availablePortions'] ?? 0,
      pickupLocation: map['pickupLocation'] ?? '',
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['endTime'] ?? DateTime.now().toIso8601String()),
      forNgo: map['forNgo'] ?? false,
      status: PostStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PostStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      imageUrl: map['imageUrl'],
    );
  }

  SurplusPostModel copyWith({
    String? id,
    String? cafeteriaId,
    String? title,
    String? description,
    FoodCategory? category,
    int? totalPortions,
    int? availablePortions,
    String? pickupLocation,
    DateTime? startTime,
    DateTime? endTime,
    bool? forNgo,
    PostStatus? status,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return SurplusPostModel(
      id: id ?? this.id,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      totalPortions: totalPortions ?? this.totalPortions,
      availablePortions: availablePortions ?? this.availablePortions,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      forNgo: forNgo ?? this.forNgo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get isFullReserved => availablePortions == 0;
}

enum FoodCategory {
  veg,
  nonVeg,
}

enum PostStatus {
  active,
  partiallyReserved,
  fullReserved,
  expired,
}

