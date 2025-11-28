import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user_model.dart';
import 'location_picker_page.dart'; // Pastikan path ini benar

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const double radius = 12.0;

  final UserController _controller = UserController();
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  UserModel? _currentProfileData;
  bool _isLoading = false;

  late TextEditingController _nameC;
  late TextEditingController _emailC;
  late TextEditingController _phoneC;
  late TextEditingController _addressC;

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final int userIdToFetch = widget.user.id;
    final user = await _controller.fetchUserById(userIdToFetch);

    if (user != null) {
      _currentProfileData = user;
      _nameC.text = user.namaLengkap;
      _emailC.text = user.email;
      _phoneC.text = user.noHp ?? '';
      _addressC.text = user.alamat ?? '';
    } else {
      // Fallback jika fetchUserById gagal, gunakan data dari widget
      _currentProfileData = widget.user;
      _nameC.text = widget.user.namaLengkap;
      _emailC.text = widget.user.email;
      _phoneC.text = widget.user.noHp ?? '';
      _addressC.text = widget.user.alamat ?? '';
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _emailC = TextEditingController();
    _phoneC = TextEditingController();
    _addressC = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  // <<< MODIFIKASI: Menambahkan opsi pilihan sumber gambar >>>
  Future<void> _pickImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final user = _currentProfileData!;
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _isLoading = true);
    final newPhotoUrl = await _controller.uploadProfilePhoto(image, user.id);

    if (newPhotoUrl != null) {
      final updatedUser = await _controller.updateProfileData(user.id, {
        'photo_url': newPhotoUrl,
      });

      if (updatedUser != null) {
        setState(() => _currentProfileData = updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
          );
        }
      }
    }
    setState(() => _isLoading = false);
  }
  // <<< AKHIR MODIFIKASI >>>

  Future<void> _updateProfileData() async {
    final user = _currentProfileData!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final dataToUpdate = {
      'nama_lengkap': _nameC.text,
      'no_hp': _phoneC.text,
      'alamat': _addressC.text,
    };
    final updatedUser = await _controller.updateProfileData(
      user.id,
      dataToUpdate,
    );

    if (updatedUser != null) {
      setState(() => _currentProfileData = updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data profil berhasil diperbarui!')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null && result is String) {
      setState(() {
        _addressC.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProfileData == null && _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentProfileData == null) {
      return const Scaffold(
        body: Center(
          child: Text("Gagal memuat profil. ID pengguna tidak valid."),
        ),
      );
    }

    final user = _currentProfileData!;

    final inputDecorationTheme = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: accentGreen, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: lightGrey,
                      backgroundImage:
                          user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!) as ImageProvider
                          : null,
                      child: user.photoUrl == null || user.photoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 60, color: darkText)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: accentGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: darkText.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            // <<< MODIFIKASI: Memanggil _pickImageSource() >>>
                            : IconButton(
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed:
                                    _pickImageSource, // Panggil metode baru
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Data Profil:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameC,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person, color: accentGreen),
                ),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailC,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Email (Tidak Dapat Diubah)',
                  prefixIcon: const Icon(Icons.email, color: darkText),
                ),
                readOnly: true,
                style: TextStyle(color: darkText.withOpacity(0.6)),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneC,
                keyboardType: TextInputType.phone,
                decoration: inputDecorationTheme.copyWith(
                  labelText: 'Nomor Telepon',
                  prefixIcon: const Icon(Icons.phone, color: accentGreen),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickLocation,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _addressC,
                    maxLines: 3,
                    decoration: inputDecorationTheme.copyWith(
                      labelText: 'Alamat (Pilih dari Peta)',
                      prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: accentGreen,
                      ),
                      suffixIcon: const Icon(
                        Icons.map_rounded,
                        color: accentGreen,
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  elevation: 6,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('SIMPAN PERUBAHAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
