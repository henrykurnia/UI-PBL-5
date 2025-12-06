import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

// widgets
import 'package:hydrosee/widgets/button/action_button.dart';
import 'package:hydrosee/widgets/button/button_primary.dart';
import 'package:hydrosee/widgets/card/iot_device_card.dart';
import 'package:hydrosee/widgets/popup/wifiInputDialog.dart';

// services
import 'package:hydrosee/services/api_service.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// package
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

const String _serverUuid = '4fafc201-1fb5-459e-8fcc-c9c9c331914b';
const String _charUuid   = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

final Guid targetServiceGuid = Guid(_serverUuid);
final Guid targetCharGuid    = Guid(_charUuid);

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  bool isScanning = false;
  bool isConnecting = false;
  bool bluetoothOn = false;

  List<ScanResult> scanResults = [];

  StreamSubscription? _scanSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _connSub;

  @override
  void initState() {
    super.initState();
    _listenBluetoothState();
    _initAdapter();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _stateSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _initAdapter() async {
    final state = await FlutterBluePlus.adapterState.first;
    setState(() => bluetoothOn = state == BluetoothAdapterState.on);
  }

  Future<bool> requestBlePermissions() async {
    if (await Permission.bluetoothScan.request().isDenied) return false;
    if (await Permission.bluetoothConnect.request().isDenied) return false;

    return true;
  }


  void _listenBluetoothState() {
    _stateSub = FlutterBluePlus.adapterState.listen((s) {
      setState(() => bluetoothOn = s == BluetoothAdapterState.on);
      if (s == BluetoothAdapterState.on) _startScan();
      if (s == BluetoothAdapterState.off) _stopScan();
    });
  }

  Future<bool> _checkPermissions() async {
    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();
    final loc = await Permission.location.request();

    if (!loc.isGranted) {
      CustomQuickAlert.error(
        title: "Izin Lokasi Dibutuhkan",
        message: "Aktifkan izin lokasi agar BLE bisa discan."
      );
      await Future.delayed(const Duration(milliseconds: 400));
      AppSettings.openAppSettings(type: AppSettingsType.location);
      return false;
    }
    return scan.isGranted && connect.isGranted;
  }

  Future<void> _startScan() async {
    if (isScanning) return;

    final ok2 = await requestBlePermissions();
    if (!ok2) {
      print("BLE permission denied");
      return;
    }

    final ok = await _checkPermissions();
    if (!ok) return;

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 12),
      androidUsesFineLocation: true,
    );

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results.where((r) {
          final n = r.device.platformName.toUpperCase();
          final a = r.advertisementData.advName.toUpperCase();
          return n.contains("HYDROSEE") || a.contains("HYDROSEE");
        }).toList();
      });
    });

    Future.delayed(const Duration(seconds: 12), () => _stopScan());
  }

  Future<void> _stopScan() async {
    if (!isScanning) return;
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanSub = null;
    if (mounted) setState(() => isScanning = false);
  }

  Future<void> _connectDevice(ScanResult r) async {
    if (isConnecting) return;

    await _stopScan();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login."))
      );
      return;
    }

    final device = r.device;
    final deviceName = (device.platformName.isNotEmpty)
        ? device.platformName
        : (r.advertisementData.advName.isNotEmpty
            ? r.advertisementData.advName
            : "ESP32-Hydrosee");

    setState(() => isConnecting = true);

    final wifi = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => WifiInputDialog(initialSsid: deviceName),
    );

    if (wifi == null) {
      setState(() => isConnecting = false);
      return;
    }

    final ssid = wifi['ssid']!;
    final pass = wifi['password']!;

    CustomQuickAlert.loading(
      title: "Menghubungkan",
      message: "Menyiapkan perangkat...",
      backgroundColor: AppColor.primary_05,
      borderRadius: 20,
    );

    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        license: License.free,
      );

      _connSub = device.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected && isConnecting) {
          CustomQuickAlert.dismiss();
        }
      });

      final services = await device.discoverServices();

      await ApiService.registerDevice(
        deviceId: device.remoteId.str,
        deviceName: deviceName,
      );

      BluetoothCharacteristic? char;

      for (var s in services) {
        if (s.uuid == targetServiceGuid) {
          for (var c in s.characteristics) {
            if (c.uuid == targetCharGuid) char = c;
          }
        }
      }

      if (char == null) throw Exception("Characteristic tidak ditemukan.");

      final payload = "$ssid|$pass|${device.remoteId.str}";
      await char.write(payload.codeUnits, withoutResponse: false);

      await Future.delayed(const Duration(milliseconds: 500));

      await device.disconnect();

      CustomQuickAlert.dismiss();
      await CustomQuickAlert.success(
        title: "Berhasil",
        message: "Perangkat berhasil dikonfigurasi.",
        autoCloseDuration: const Duration(seconds: 2),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/device');
      }

    } catch (e) {
      CustomQuickAlert.dismiss();
      await CustomQuickAlert.error(
        title: "Gagal",
        message: e.toString(),
        backgroundColor: AppColor.primary_0,
        titleColor: AppColor.danger,
      );
      try {
        await device.disconnect();
      } catch (_) {}
    } finally {
      _connSub?.cancel();
      if (mounted) setState(() => isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary_0,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            bluetoothOn ? _buildScanSection() : _buildBluetoothOffView()
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.pushReplacementNamed(context, '/device'),
          ),
          Text(
            'Tambah Perangkat IoT',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.primary_5,
            ),
          ),
          bluetoothOn && !isScanning
              ? ActionButton(icon: Icons.refresh, onPressed: _startScan)
              : const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildScanSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (isScanning)
          Column(
            children: [
              LoadingAnimationWidget.inkDrop(
                color: AppColor.primary_5,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text("Memindai perangkat...",
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColor.primary_3)),
            ],
          ),
        ...scanResults.map(
          (r) => IotDeviceCard(
            deviceName: r.device.platformName.isEmpty &&
                    r.advertisementData.advName.isEmpty
                ? "Perangkat Tidak Dikenal"
                : (r.device.platformName.isNotEmpty
                    ? r.device.platformName
                    : r.advertisementData.advName),
            onPressed: isConnecting ? null : () => _connectDevice(r),
          ),
        ),
        if (!isScanning && scanResults.isEmpty) _noDevice(),
      ],
    );
  }

  Widget _noDevice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Image.asset('assets/ilustrations/iot_not_found.png',
              height: 200, width: 260),
          const SizedBox(height: 20),
          Text("Perangkat Tidak Ditemukan",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.danger,
              )),
          const SizedBox(height: 10),
          Text(
            "Pastikan perangkat Hydrosee menyala.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColor.primary_3,
            ),
          ),
          const SizedBox(height: 16),
          if (!isScanning)
            SizedBox(
              width: 180,
              child: ButtonPrimary(
                text: "Coba Lagi",
                onPressed: _startScan,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildBluetoothOffView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Image.asset('assets/ilustrations/iot_not_found.png',
              height: 200, width: 260),
          const SizedBox(height: 30),
          Text(
            "Bluetooth Mati",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.danger,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Aktifkan Bluetooth untuk mendeteksi perangkat IoT.",
            textAlign: TextAlign.center,
            style:
                GoogleFonts.inter(fontSize: 14, color: AppColor.primary_3),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ButtonPrimary(
              text: "Nyalakan Bluetooth",
              onPressed: () async {
                try {
                  await FlutterBluePlus.turnOn();
                } catch (_) {
                  AppSettings.openAppSettings(
                      type: AppSettingsType.bluetooth);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
