import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../models/bus_model.dart';
import '../../../models/pemesanan_model.dart';
import '../../../controllers/bus_controller.dart';
import '../../../controllers/conversion_controller.dart';
import '../../../models/currency_conversion_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BookingPage extends StatefulWidget {
  final BusModel bus;
  final int userId;
  const BookingPage({super.key, required this.bus, required this.userId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const double radius = 12.0;

  final _controller = BusController();
  final _conversionController = ConversionController();

  final _locationC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int _totalHari = 0;
  double _totalHarga = 0.0;
  bool _isLoading = false;

  CurrencyConversionModel? _conversionRates;
  bool _isConverting = false;
  String? _selectedCurrency;
  double _convertedTotal = 0.0;
  final List<String> _displayCurrencies = const [
    'USD',
    'EUR',
    'MYR',
    'SGD',
    'JPY',
    'GBP',
    'AUD',
    'CAD',
  ];

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );
  }

  Future<void> _scheduleBookingSuccessNotification() async {
    await Future.delayed(const Duration(seconds: 5));

    final busName = widget.bus.namaBus;
    final platNumber = widget.bus.platNomer;
    final totalDays = _totalHari;

    final notificationBody =
        'Berhasil memesan bus $busName ($platNumber) selama $totalDays hari.';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'bus_booking_channel_id',
          'Pemesanan Bus',
          channelDescription: 'Notifikasi untuk status pemesanan bus.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Pemesanan Berhasil! 🎉',
      notificationBody,
      platformChannelSpecifics,
      payload: 'booking_success_payload',
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _locationC.dispose();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    if (_isConverting) return;
    setState(() => _isConverting = true);

    final rates = await _conversionController.fetchExchangeRates();

    setState(() {
      _conversionRates = rates;
      _isConverting = false;
    });
  }

  void _updateConvertedAmount() {
    if (_totalHarga > 0 &&
        _selectedCurrency != null &&
        _conversionRates != null) {
      final rate = _conversionRates!.rates[_selectedCurrency];
      if (rate != null) {
        setState(() {
          _convertedTotal = _totalHarga * rate;
        });
      }
    } else {
      setState(() {
        _convertedTotal = 0.0;
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? DateTime.now().add(const Duration(days: 1))
          : _tanggalMulai?.add(const Duration(days: 1)) ??
                DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: accentGreen,
              onPrimary: Colors.white,
              onSurface: darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkText),
            ),
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (DateTime day) {
        if (!isStart && _tanggalMulai != null) {
          return day.isAfter(_tanggalMulai!) ||
              day.isAtSameMomentAs(_tanggalMulai!);
        }
        return true;
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
          if (_tanggalSelesai != null &&
              _tanggalSelesai!.isBefore(_tanggalMulai!)) {
            _tanggalSelesai = null;
          }
        } else {
          _tanggalSelesai = picked;
        }
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    if (_tanggalMulai != null &&
        _tanggalSelesai != null &&
        (_tanggalSelesai!.isAfter(_tanggalMulai!) ||
            _tanggalSelesai!.isAtSameMomentAs(_tanggalMulai!))) {
      final difference = _tanggalSelesai!.difference(_tanggalMulai!);
      _totalHari = difference.inDays + 1;
      _totalHarga = widget.bus.hargaPerHari != null
          ? _totalHari * widget.bus.hargaPerHari!.toDouble()
          : 0.0;
    } else {
      _totalHari = 0;
      _totalHarga = 0.0;
    }
    _updateConvertedAmount();
    setState(() {});
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _totalHari <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mohon lengkapi tanggal sewa, tujuan, dan durasi yang valid.',
            ),
          ),
        );
      }
      return;
    }

    final int currentUserId = widget.userId;

    if (widget.bus.id == null || currentUserId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: ID Bus atau User tidak valid. Mohon periksa konsistensi ID.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final newBooking = PemesananModel(
      userId: currentUserId,
      busId: widget.bus.id!,
      tanggalMulai: _tanggalMulai!,
      tanggalSelesai: _tanggalSelesai!,
      totalHari: _totalHari,
      totalHarga: _totalHarga,
      tujuanSewa: _locationC.text.trim(),
      statusPemesanan: 'Pending',
      tglPemesanan: DateTime.now(),
    );

    final result = await _controller.createBooking(newBooking);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context);

      await Future.delayed(const Duration(milliseconds: 100));

      await _scheduleBookingSuccessNotification();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: ${result['message']}')));
    }
  }

  Widget _buildBusImage() {
    final imageUrl = widget.bus.fotoUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Image.network(
            '$imageUrl?t=$cacheBuster',
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(color: accentGreen),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: lightGrey,
                child: Center(
                  child: Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 60,
                    color: darkText.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: accentGreen, width: 2.0),
          ),
          prefixIcon: Icon(icon, color: accentGreen),
          enabled: enabled,
          fillColor: enabled ? Colors.white : lightGrey.withOpacity(0.5),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 12.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? darkText : Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCostSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Biaya (IDR):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              'Durasi Sewa:',
              '${_totalHari} hari',
              Colors.grey.shade700,
            ),
            _buildSummaryRow(
              'Harga Harian:',
              _currencyFormatter.format(widget.bus.hargaPerHari),
              Colors.grey.shade700,
            ),
            const Divider(height: 25, thickness: 2),
            _buildSummaryRow(
              'TOTAL BIAYA:',
              _currencyFormatter.format(_totalHarga),
              accentGreen,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: darkText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyConversionWidget() {
    if (_isConverting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 15),
          child: CircularProgressIndicator(strokeWidth: 2, color: accentGreen),
        ),
      );
    }

    if (_conversionRates == null) {
      return Center(
        child: TextButton.icon(
          onPressed: _fetchExchangeRates,
          icon: const Icon(Icons.refresh, color: darkText),
          label: const Text('Gagal memuat nilai tukar. Coba lagi.'),
          style: TextButton.styleFrom(foregroundColor: darkText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Konversi Mata Uang (Opsional):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Pilih Mata Uang Konversi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: accentGreen, width: 2.0),
            ),
            prefixIcon: const Icon(Icons.paid, color: accentGreen),
            fillColor: Colors.white,
            filled: true,
          ),
          isExpanded: true,
          value: _selectedCurrency,
          hint: const Text('Pilih mata uang (Contoh: USD, EUR)'),
          items: _displayCurrencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCurrency = newValue;
              _updateConvertedAmount();
            });
          },
        ),
        const SizedBox(height: 15),
        if (_selectedCurrency != null && _convertedTotal > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total dalam $_selectedCurrency:',
                style: const TextStyle(fontSize: 16, color: darkText),
              ),
              Text(
                NumberFormat.currency(
                  symbol: '$_selectedCurrency ',
                  decimalDigits: 2,
                ).format(_convertedTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 18,
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final autoInputDecoration = InputDecoration(
      labelText: 'Cari Kota/Daerah Tujuan',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: accentGreen, width: 2.0),
      ),
      prefixIcon: const Icon(Icons.location_city, color: accentGreen),
      fillColor: Colors.white,
      filled: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Pemesanan Bus',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusImage(),
              Card(
                color: accentGreen.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                margin: const EdgeInsets.only(bottom: 25),
                child: ListTile(
                  title: Text(
                    '${widget.bus.namaBus} (${widget.bus.platNomer})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  subtitle: Text(
                    'Kapasitas: ${widget.bus.kapasitas} | Kelas: ${widget.bus.tipeBus}',
                    style: TextStyle(color: darkText.withOpacity(0.8)),
                  ),
                  leading: const Icon(Icons.directions_bus, color: accentGreen),
                ),
              ),
              const Text(
                'Tanggal Mulai Sewa:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildDateField(
                onTap: () => _selectDate(true),
                label: _tanggalMulai == null
                    ? 'Pilih Tanggal Mulai'
                    : _dateFormat.format(_tanggalMulai!),
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 20),
              const Text(
                'Tanggal Selesai Sewa:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildDateField(
                onTap: () => _selectDate(false),
                label: _tanggalSelesai == null
                    ? 'Pilih Tanggal Selesai'
                    : _dateFormat.format(_tanggalSelesai!),
                icon: Icons.calendar_month_rounded,
                enabled: _tanggalMulai != null,
              ),
              const SizedBox(height: 30),
              const Text(
                'Lokasi Tujuan Sewa:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  return await ConversionController.getDestinationSuggestions(
                    textEditingValue.text,
                  );
                },
                onSelected: (String selection) {
                  _locationC.text = selection;
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      _locationC.text = textEditingController.text;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: autoInputDecoration,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Tujuan wajib diisi.'
                            : null,
                        onChanged: (text) {
                          textEditingController.text = text;
                        },
                      );
                    },
              ),
              const SizedBox(height: 40),
              _buildCostSummary(),
              _buildCurrencyConversionWidget(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'KIRIM PERMINTAAN SEWA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
