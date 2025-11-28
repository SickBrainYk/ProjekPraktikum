import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/bus_model.dart';

const Color accentGreen = Color(0xFF8BC34A);
const Color darkText = Color(0xFF212121);
const Color lightGrey = Color(0xFFF5F5F5);
const double radius = 12.0;

class ManajemenBusTab extends StatefulWidget {
  const ManajemenBusTab({super.key});

  @override
  State<ManajemenBusTab> createState() => _ManajemenBusTabState();
}

class _ManajemenBusTabState extends State<ManajemenBusTab> {
  final AdminController _controller = AdminController();
  late Future<List<BusModel>> _busesFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  void _loadBuses() {
    setState(() {
      _busesFuture = _controller.fetchAllBuses();
    });
  }

  Future<void> _showBusForm({BusModel? busToEdit}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BusFormDialog(busToEdit: busToEdit),
    );

    if (result == true) {
      _loadBuses();
    }
  }

  Future<void> _deleteBus(int busId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: darkText),
        ),
        content: const Text(
          'Yakin ingin menghapus data bus ini?',
          style: TextStyle(color: darkText),
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
      final success = await _controller.deleteBus(busId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Bus berhasil dihapus.' : 'Gagal menghapus bus.',
            ),
          ),
        );
        if (success) _loadBuses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showBusForm(),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    'Tambah Bus Baru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<BusModel>>(
            future: _busesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(color: accentGreen),
                );
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );

              final buses = snapshot.data ?? [];

              if (buses.isEmpty)
                return const Center(
                  child: Text(
                    'Belum ada data bus.',
                    style: TextStyle(color: darkText),
                  ),
                );

              final cacheBuster = DateTime.now().millisecondsSinceEpoch
                  .toString();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final bus = buses[index];
                  final imageUrl = bus.fotoUrl != null
                      ? '${bus.fotoUrl!}?t=$cacheBuster'
                      : null;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: lightGrey,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: accentGreen,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 60,
                                      height: 60,
                                      color: lightGrey,
                                      child: Icon(
                                        Icons.directions_bus,
                                        size: 40,
                                        color: darkText.withOpacity(0.5),
                                      ),
                                    ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: lightGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.directions_bus,
                                size: 40,
                                color: darkText.withOpacity(0.5),
                              ),
                            ),
                      title: Text(
                        '${bus.namaBus} (${bus.platNomer})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Kelas: ${bus.tipeBus} | Kapasitas: ${bus.kapasitas} kursi\nHarga: ${_currencyFormatter.format(bus.hargaPerHari)}/hari',
                        style: TextStyle(color: darkText.withOpacity(0.7)),
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: accentGreen,
                            ),
                            onPressed: () => _showBusForm(busToEdit: bus),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteBus(bus.id!),
                            tooltip: 'Hapus',
                          ),
                        ],
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

class BusFormDialog extends StatefulWidget {
  final BusModel? busToEdit;
  const BusFormDialog({super.key, this.busToEdit});

  @override
  State<BusFormDialog> createState() => _BusFormDialogState();
}

class _BusFormDialogState extends State<BusFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _platC = TextEditingController();
  final _kapasitasC = TextEditingController();
  final _tipeBusC = TextEditingController();
  final _hargaC = TextEditingController();

  final AdminController _controller = AdminController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.busToEdit != null) {
      _namaC.text = widget.busToEdit!.namaBus;
      _platC.text = widget.busToEdit!.platNomer;
      _kapasitasC.text = widget.busToEdit!.kapasitas.toString();
      _tipeBusC.text = widget.busToEdit!.tipeBus;
      _hargaC.text = widget.busToEdit!.hargaPerHari.toString();
    }
  }

  @override
  void dispose() {
    _namaC.dispose();
    _platC.dispose();
    _kapasitasC.dispose();
    _tipeBusC.dispose();
    _hargaC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? uploadedUrl;
      String? currentUrl = widget.busToEdit?.fotoUrl;

      if (_selectedImage != null) {
        uploadedUrl = await _controller.uploadBusImage(
          _selectedImage!,
          _platC.text.trim(),
        );
        if (uploadedUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Gagal upload gambar. Cek izin Storage Supabase.',
                ),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }
        currentUrl = uploadedUrl;
      }

      final newBus = BusModel(
        id: widget.busToEdit?.id,
        namaBus: _namaC.text.trim(),
        platNomer: _platC.text.trim(),
        kapasitas: int.parse(_kapasitasC.text.trim()),
        tipeBus: _tipeBusC.text.trim(),
        hargaPerHari: int.parse(_hargaC.text.trim()),
        isAvailable: widget.busToEdit?.isAvailable ?? true,
        fotoUrl: currentUrl,
      );

      bool success;
      String message;

      if (widget.busToEdit == null) {
        success = await _controller.createBus(newBus, fotoUrl: currentUrl);
        message = success
            ? 'Bus berhasil ditambahkan!'
            : 'Gagal menambahkan bus.';
      } else {
        success = await _controller.updateBus(newBus, fotoUrl: currentUrl);
        message = success
            ? 'Data bus berhasil diubah!'
            : 'Gagal mengubah data bus.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: darkText.withOpacity(0.8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: lightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: accentGreen, width: 2.0),
      ),
      filled: true,
      fillColor: lightGrey.withOpacity(0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : widget.busToEdit?.fotoUrl != null
        ? Image.network(
            widget.busToEdit!.fotoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (c, o, s) => Center(
              child: Icon(
                Icons.image_not_supported,
                color: darkText.withOpacity(0.5),
              ),
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  color: darkText.withOpacity(0.5),
                  size: 30,
                ),
                Text(
                  widget.busToEdit != null ? 'Ganti Foto' : 'Pilih Foto Bus',
                  style: TextStyle(color: darkText.withOpacity(0.6)),
                ),
              ],
            ),
          );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius * 1.5),
      ),
      title: Text(
        widget.busToEdit == null ? 'Tambah Bus Baru' : 'Edit Data Bus',
        style: const TextStyle(fontWeight: FontWeight.bold, color: darkText),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: darkText.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: displayImage,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaC,
                decoration: _buildInputDecoration('Nama Bus'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _platC,
                decoration: _buildInputDecoration('Plat Nomer'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kapasitasC,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Kapasitas (Penumpang)'),
                validator: (v) {
                  if (v!.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipeBusC,
                decoration: _buildInputDecoration('Tipe Bus / Kelas'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaC,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Harga Per Hari (Rp)'),
                validator: (v) {
                  if (v!.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: darkText)),
        ),
        _isLoading
            ? Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CircularProgressIndicator(color: accentGreen),
              )
            : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  widget.busToEdit == null ? 'Simpan' : 'Update',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ],
    );
  }
}
