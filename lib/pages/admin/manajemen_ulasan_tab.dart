import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/local_feedback_model.dart';
import '../../../services/local_database_helper.dart';

class ManajemenUlasanTab extends StatefulWidget {
  const ManajemenUlasanTab({super.key});

  @override
  State<ManajemenUlasanTab> createState() => _ManajemenUlasanTabState();
}

class _ManajemenUlasanTabState extends State<ManajemenUlasanTab> {
  late Future<List<LocalFeedbackModel>> _localFeedbackFuture;

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 12.0;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _loadAllLocalFeedback();
  }

  void _loadAllLocalFeedback() {
    setState(() {
      _localFeedbackFuture = LocalDatabaseHelper.instance.readAllFeedback();
    });
  }

  Future<void> _deleteLocalFeedback(int feedbackId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ulasan Lokal?'),
        content: const Text(
          'Yakin ingin menghapus ulasan ini secara permanen dari perangkat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalDatabaseHelper.instance.deleteFeedback(feedbackId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan lokal berhasil dihapus.')),
        );
        _loadAllLocalFeedback();
      }
    }
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
              onPressed: _loadAllLocalFeedback,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Muat Ulang Ulasan Lokal',
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
          child: FutureBuilder<List<LocalFeedbackModel>>(
            future: _localFeedbackFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: accentGreen),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error memuat data lokal: ${snapshot.error.toString()}',
                    textAlign: TextAlign.center,
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
                        Icons.info_outline_rounded,
                        size: 60,
                        color: darkText.withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tidak ada ulasan layanan yang tersimpan di perangkat ini.',
                        textAlign: TextAlign.center,
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
                      leading: Text(
                        '${feedback.rating}/5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      title: Text(
                        'User ID: ${feedback.userId}',
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
                            'Komentar: ${feedback.comment}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: darkText.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Disimpan Lokal: ${_dateFormat.format(feedback.createdAt)}',
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
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deleteLocalFeedback(feedback.id!),
                        tooltip: 'Hapus Ulasan Lokal',
                      ),
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
