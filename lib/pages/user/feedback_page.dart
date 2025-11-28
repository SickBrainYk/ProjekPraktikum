import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/course_feedback_model.dart';

class FeedbackPage extends StatefulWidget {
  final int userId;
  const FeedbackPage({super.key, required this.userId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 12.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kesan & Saran',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentGreen,
          unselectedLabelColor: darkText.withOpacity(0.6),
          indicatorColor: accentGreen,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Kirim Feedback'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Riwayat Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedbackForm(userId: widget.userId, tabController: _tabController),
          _FeedbackHistory(userId: widget.userId),
        ],
      ),
    );
  }
}

class _FeedbackForm extends StatefulWidget {
  final int userId;
  final TabController tabController;
  const _FeedbackForm({
    super.key,
    required this.userId,
    required this.tabController,
  });

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final UserController _controller = UserController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kesanC = TextEditingController();
  final TextEditingController _saranC = TextEditingController();

  bool _isSending = false;

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 12.0;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final success = await _controller.sendCourseFeedback(
      widget.userId,
      _kesanC.text,
      _saranC.text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih! Feedback Anda berhasil dikirim.'),
          ),
        );
        _kesanC.clear();
        _saranC.clear();
        widget.tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim feedback. Coba lagi.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _kesanC.dispose();
    _saranC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = (String label, String hint) => InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: darkText.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: accentGreen, width: 2.0),
      ),
      alignLabelWithHint: true,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mohon berikan kesan dan saran Anda terkait Mata Kuliah Pemograman Mobile.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const Divider(height: 30),
            TextFormField(
              controller: _kesanC,
              maxLines: 5,
              decoration: inputDecoration(
                'Kesan Anda tentang Matkul',
                'Tulis pengalaman positif atau masukan Anda...',
              ),
              validator: (v) => v!.isEmpty ? 'Kesan wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _saranC,
              maxLines: 5,
              decoration: inputDecoration(
                'Saran untuk Peningkatan Matkul',
                'Berikan saran konstruktif untuk perbaikan...',
              ),
              validator: (v) => v!.isEmpty ? 'Saran wajib diisi' : null,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  elevation: 5,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Kirim Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackHistory extends StatefulWidget {
  final int userId;
  const _FeedbackHistory({super.key, required this.userId});

  @override
  State<_FeedbackHistory> createState() => _FeedbackHistoryState();
}

class _FeedbackHistoryState extends State<_FeedbackHistory> {
  final UserController _controller = UserController();
  late Future<List<CourseFeedbackModel>> _historyFuture;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 12.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _controller.fetchUserFeedback(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CourseFeedbackModel>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: accentGreen));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 60,
                  color: darkText.withOpacity(0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  'Anda belum mengirimkan feedback apa pun.',
                  style: TextStyle(color: darkText.withOpacity(0.7)),
                ),
                TextButton.icon(
                  onPressed: _loadHistory,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(foregroundColor: accentGreen),
                ),
              ],
            ),
          );
        }

        final history = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final feedback = history[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: darkText,
                          ),
                        ),
                        Text(
                          _dateFormat.format(feedback.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildFeedbackSection(
                      'Kesan Anda:',
                      feedback.kesan,
                      accentGreen,
                    ),
                    const SizedBox(height: 15),
                    _buildFeedbackSection(
                      'Saran Anda:',
                      feedback.saran,
                      darkText,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackSection(
    String title,
    String content,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: accentColor,
            fontSize: 14,
          ),
        ),
        Text(
          content,
          style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.8)),
        ),
      ],
    );
  }
}
