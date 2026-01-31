import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime? createdAt;

  @HiveField(3)
  DateTime? updatedAt;

  @HiveField(4)
  String? category;

  @HiveField(5)
  int? colorValue;

  @HiveField(6)
  bool isPinned;

  @HiveField(7)
  List<String>? tags;

  Note({
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.category = 'Personal',
    this.colorValue,
    this.isPinned = false,
    this.tags,
  }) {
    createdAt ??= DateTime.now();
    updatedAt ??= DateTime.now();
    colorValue ??= 0xFFFFD54F; // Default amber color
  }

  // Helper method to get formatted creation date
  String get formattedCreatedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  // Helper method to get formatted update date
  String get formattedUpdatedDate {
    if (updatedAt == null) return '';
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}';
  }

  // Helper method to check if note was recently updated (within 24 hours)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);
    return difference.inHours < 24;
  }

  // Helper method to get word count
  int get wordCount {
    if (description.isEmpty) return 0;
    return description.trim().split(RegExp(r'\s+')).length;
  }

  // Helper method to get reading time estimate (assuming 200 words per minute)
  String get estimatedReadTime {
    final words = wordCount;
    if (words == 0) return '0 min';
    final minutes = (words / 200).ceil();
    return minutes == 1 ? '1 min' : '$minutes mins';
  }

  @override
  String toString() {
    return 'Note{title: $title, category: $category, createdAt: $createdAt}';
  }
}
