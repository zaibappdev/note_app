import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/note.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final Box<Note> notesBox = Hive.box<Note>('notesBox');

  Map<String, int> getCategoryStats() {
    final Map<String, int> categoryCount = {};
    for (final note in notesBox.values) {
      final category = note.category ?? 'Other';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Map<String, int> getMonthlyStats() {
    final Map<String, int> monthlyCount = {};
    for (final note in notesBox.values) {
      final date = note.createdAt ?? DateTime.now();
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }
    return monthlyCount;
  }

  List<Note> getRecentNotes() {
    final notes = notesBox.values.toList();
    notes.sort(
      (a, b) => (b.updatedAt ?? b.createdAt ?? DateTime.now()).compareTo(
        a.updatedAt ?? a.createdAt ?? DateTime.now(),
      ),
    );
    return notes.take(5).toList();
  }

  Color getCategoryColor(String category, int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    switch (category) {
      case 'Personal':
        return Colors.blue;
      case 'Work':
        return Colors.orange;
      case 'Ideas':
        return Colors.purple;
      case 'Tasks':
        return Colors.green;
      default:
        return colors[index % colors.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // body
      body: CustomScrollView(
        slivers: [
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ValueListenableBuilder(
              valueListenable: notesBox.listenable(),
              builder: (context, Box<Note> box, _) {
                final totalNotes = box.length;
                final categoryStats = getCategoryStats();
                final recentNotes = getRecentNotes();
                final totalWords = box.values.fold<int>(
                  0,
                  (sum, note) => sum + note.wordCount,
                );

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Overview Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Notes',
                            totalNotes.toString(),
                            Icons.note,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Categories',
                            categoryStats.length.toString(),
                            Icons.category,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Words',
                            totalWords.toString(),
                            Icons.text_fields,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Avg Words',
                            totalNotes > 0
                                ? (totalWords / totalNotes).round().toString()
                                : '0',
                            Icons.analytics,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Category Distribution
                    if (categoryStats.isNotEmpty) ...[
                      _buildSectionHeader('Category Distribution'),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: PieChart(
                          PieChartData(
                            sections: categoryStats.entries.map((entry) {
                              final index = categoryStats.keys.toList().indexOf(
                                entry.key,
                              );
                              return PieChartSectionData(
                                color: getCategoryColor(entry.key, index),
                                value: entry.value.toDouble(),
                                title: '${entry.value}',
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Legend
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: categoryStats.entries.map((entry) {
                          final index = categoryStats.keys.toList().indexOf(
                            entry.key,
                          );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getCategoryColor(
                                entry.key,
                                index,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: getCategoryColor(
                                  entry.key,
                                  index,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: getCategoryColor(entry.key, index),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${entry.key} (${entry.value})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Recent Activity
                    if (recentNotes.isNotEmpty) ...[
                      _buildSectionHeader('Recent Activity'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: recentNotes.map((note) {
                            final isLast = recentNotes.last == note;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        note.colorValue ?? 0xFFFFD54F,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          note.category ?? 'Other',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    note.isRecentlyUpdated
                                        ? 'Recent'
                                        : note.formattedUpdatedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Quick Stats
                    _buildSectionHeader('Quick Stats'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildQuickStat(
                            'Notes created today',
                            _getNotesCreatedToday().toString(),
                          ),
                          const Divider(height: 24),
                          _buildQuickStat(
                            'Notes updated this week',
                            _getNotesUpdatedThisWeek().toString(),
                          ),
                          const Divider(height: 24),
                          _buildQuickStat(
                            'Longest note',
                            '${_getLongestNote()} words',
                          ),
                          const Divider(height: 24),
                          _buildQuickStat(
                            'Most used category',
                            _getMostUsedCategory(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // Bottom padding
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  int _getNotesCreatedToday() {
    final today = DateTime.now();
    return notesBox.values.where((note) {
      final createdDate = note.createdAt ?? DateTime.now();
      return createdDate.year == today.year &&
          createdDate.month == today.month &&
          createdDate.day == today.day;
    }).length;
  }

  int _getNotesUpdatedThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return notesBox.values.where((note) {
      final updatedDate = note.updatedAt ?? note.createdAt ?? DateTime.now();
      return updatedDate.isAfter(weekStart);
    }).length;
  }

  int _getLongestNote() {
    if (notesBox.isEmpty) return 0;
    return notesBox.values
        .map((note) => note.wordCount)
        .reduce((a, b) => a > b ? a : b);
  }

  String _getMostUsedCategory() {
    final categoryStats = getCategoryStats();
    if (categoryStats.isEmpty) return 'None';

    String mostUsed = categoryStats.keys.first;
    int maxCount = categoryStats.values.first;

    for (final entry in categoryStats.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostUsed = entry.key;
      }
    }

    return mostUsed;
  }
}
