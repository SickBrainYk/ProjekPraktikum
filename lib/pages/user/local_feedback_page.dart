import 'package:flutter/material.dart';
import '../../../models/local_feedback_model.dart';
import '../../../services/local_database_helper.dart';

class LocalFeedbackPage extends StatefulWidget {
  final String userId;
  const LocalFeedbackPage({super.key, required this.userId});

  @override
  State<LocalFeedbackPage> createState() => _LocalFeedbackPageState();
}

class _LocalFeedbackPageState extends State<LocalFeedbackPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 15.0;

  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<LocalFeedbackModel> _localFeedbackList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalFeedback();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalFeedback() async {
    setState(() => _isLoading = true);
    final feedback = await LocalDatabaseHelper.instance.readAllFeedbackByUserId(
      widget.userId,
    );
    setState(() {
      _localFeedbackList = feedback;
      _isLoading = false;
    });
  }

  Future<void> _saveFeedbackLocally() async {
    if (_currentRating == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon berikan rating (bintang) terlebih dahulu.'),
          ),
        );
      }
      return;
    }

    final newFeedback = LocalFeedbackModel(
      userId: widget.userId,
      rating: _currentRating,
      comment: _commentController.text.trim().isEmpty
          ? '(Tanpa komentar)'
          : _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await LocalDatabaseHelper.instance.createFeedback(newFeedback);

    _commentController.clear();
    setState(() {
      _currentRating = 0;
    });

    _loadLocalFeedback();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Umpan balik berhasil disimpan secara lokal!'),
        ),
      );
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= _currentRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: starIndex <= _currentRating
                ? Colors.amber
                : Colors.grey[400],
            size: 36,
          ),
          onPressed: () {
            setState(() {
              _currentRating = starIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Umpan Balik Layanan Lokal',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: darkText),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bagaimana pengalaman Anda?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildStarRating(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Tulis Komentar Anda (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius),
                          borderSide: const BorderSide(
                            color: accentGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saveFeedbackLocally,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan Umpan Balik Lokal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Riwayat Umpan Balik Lokal Anda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const Divider(color: accentGreen),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: accentGreen),
                  )
                : _localFeedbackList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Belum ada umpan balik yang disimpan secara lokal.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _localFeedbackList.length,
                    itemBuilder: (context, index) {
                      final feedback = _localFeedbackList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        child: ListTile(
                          leading: Text(
                            '${feedback.rating}/5',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  feedback.comment,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Disimpan: ${feedback.createdAt.day}/${feedback.createdAt.month}/${feedback.createdAt.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: darkText.withOpacity(0.6),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
