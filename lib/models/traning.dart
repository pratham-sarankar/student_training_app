class Training {
  final String id;
  final String title;
  final String description;
  final double price;
  final DateTime createdAt;

  Training({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  Training copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    DateTime? createdAt,
  }) {
    return Training(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return DateTime.now();

      if (createdAt is String) {
        return DateTime.parse(createdAt);
      } else if (createdAt is DateTime) {
        return createdAt;
      } else if (createdAt.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        try {
          // Access the seconds and nanoseconds properties
          final seconds = createdAt.seconds as int? ?? 0;
          final nanoseconds = createdAt.nanoseconds as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds / 1000000).round(),
          );
        } catch (e) {
          print('Error parsing Firestore Timestamp: $e');
          return DateTime.now();
        }
      }

      return DateTime.now();
    }

    // Handle different field names from Firestore
    final price = json['price'] ?? json['cost'] ?? 0.0;

    return Training(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (price is num) ? price.toDouble() : 0.0,
      createdAt: parseCreatedAt(json['createdAt']),
    );
  }
}
