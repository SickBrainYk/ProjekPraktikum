import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/course_feedback_model.dart';

class FeedbackAdminTab extends StatefulWidget {
  const FeedbackAdminTab({super.key});

  @override
  State<FeedbackAdminTab> createState() => _FeedbackAdminTabState();
}

class _FeedbackAdminTabState extends State<FeedbackAdminTab> {
  final AdminController _controller = AdminController();
  late Future<List<CourseFeedbackModel>> _feedbackFuture;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 12.0;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  void _loadFeedback() {
    setState(() {
      _feedbackFuture = _controller.fetchAllFeedback();
    });
  }

  Future<void> _deleteFeedback(int feedbackId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Yakin ingin menghapus feedback ini secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: darkText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _controller.deleteFeedback(feedbackId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Feedback berhasil dihapus.'
                  : 'Gagal menghapus feedback.',
            ),
          ),
        );
        if (success) _loadFeedback();
      }
    }
  }

  void _showFeedbackDetail(CourseFeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius * 1.5),
        ),
        title: const Text(
          'Detail Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dari: ${feedback.userName ?? 'User ID ${feedback.userId}'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Dikirim: ${_dateFormat.format(feedback.createdAt)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const Divider(height: 20),
              _buildDetailSection('KESAN:', feedback.kesan, accentGreen),
              const SizedBox(height: 15),
              _buildDetailSection('SARAN:', feedback.saran, Colors.redAccent),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: darkText)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _deleteFeedback(feedback.id);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Hapus Feedback'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: accentColor,
            fontSize: 15,
          ),
        ),
        Text(
          content,
          style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.8)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loadFeedback,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Refresh Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                elevation: 4,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CourseFeedbackModel>>(
            future: _feedbackFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: accentGreen),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error.toString()}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 60,
                        color: darkText.withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tidak ada feedback yang masuk.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              final feedbackList = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  final feedback = feedbackList[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Kesan: ${feedback.kesan}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saran: ${feedback.saran}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: darkText.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Dari: ${feedback.userName ?? 'User ID ${feedback.userId}'} - ${_dateFormat.format(feedback.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deleteFeedback(feedback.id),
                        tooltip: 'Hapus Feedback',
                      ),
                      onTap: () => _showFeedbackDetail(feedback),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
