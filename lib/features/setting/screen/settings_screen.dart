import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/note.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box<Note> notesBox = Hive.box<Note>('notesBox');

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete All Notes'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted)
                return; // Prevent using context after widget disposed
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notesBox.clear();
              if (!mounted) return;
              Navigator.of(context).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notes deleted!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('About Smart Notes'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A beautiful and feature-rich note-taking app built with Flutter.',
            ),
            SizedBox(height: 16),
            Text('Features:'),
            SizedBox(height: 8),
            Text('• Create and organize notes'),
            Text('• Color-coded categories'),
            Text('• Search functionality'),
            Text('• Statistics and analytics'),
            Text('• Beautiful UI design'),
            SizedBox(height: 16),
            Text('Built with ❤️ using Flutter & Hive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // body
      body: CustomScrollView(
        slivers: [
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // App Info Section
                _buildSectionHeader('App Information'),
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
                    children: [
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Learn more about Smart Notes',
                        onTap: _showAboutDialog,
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.star_outline,
                        title: 'Rate App',
                        subtitle: 'Help us improve by rating the app',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you for your support!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.share_outlined,
                        title: 'Share App',
                        subtitle: 'Share with friends and family',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Share functionality would open here',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Storage Section
                _buildSectionHeader('Storage'),
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
                  child: ValueListenableBuilder(
                    valueListenable: notesBox.listenable(),
                    builder: (context, Box<Note> box, _) {
                      final totalNotes = box.length;
                      final totalWords = box.values.fold<int>(
                        0,
                        (sum, note) => sum + note.wordCount,
                      );

                      return Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.note,
                            title: 'Total Notes',
                            value: totalNotes.toString(),
                          ),
                          const Divider(height: 1),
                          _buildInfoTile(
                            icon: Icons.text_fields,
                            title: 'Total Words',
                            value: totalWords.toString(),
                          ),
                          const Divider(height: 1),
                          _buildInfoTile(
                            icon: Icons.storage,
                            title: 'Database Size',
                            value:
                                '${(totalWords * 6 / 1024).toStringAsFixed(1)} KB', // Rough estimate
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Actions Section
                _buildSectionHeader('Actions'),
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
                    children: [
                      _buildSettingTile(
                        icon: Icons.backup_outlined,
                        title: 'Export Notes',
                        subtitle: 'Save your notes to a file',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Export functionality would be implemented here',
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.cloud_upload_outlined,
                        title: 'Import Notes',
                        subtitle: 'Import notes from a file',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Import functionality would be implemented here',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.delete_sweep_outlined,
                        title: 'Delete All Notes',
                        subtitle: 'Permanently delete all notes',
                        onTap: _showDeleteAllDialog,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Developer Section
                _buildSectionHeader('Developer'),
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
                    children: [
                      _buildSettingTile(
                        icon: Icons.code,
                        title: 'View Source Code',
                        subtitle: 'Check out the code on GitHub',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'GitHub repository would open here',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.bug_report_outlined,
                        title: 'Report Bug',
                        subtitle: 'Help us improve the app',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bug report form would open here'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.lightbulb_outline,
                        title: 'Suggest Feature',
                        subtitle: 'Share your ideas with us',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Feature request form would open here',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
