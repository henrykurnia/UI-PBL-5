import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hydrosee/widgets/button/button_primary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
// import 'path/to/constants.dart';

import 'package:firebase_auth/firebase_auth.dart';

// package
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

// services
import 'package:hydrosee/services/api_service.dart';

// widget
import 'package:hydrosee/widgets/button/action_button.dart';
import 'package:hydrosee/widgets/card/iot_device_card.dart';
import 'package:hydrosee/widgets/popup/wifiInputDialog.dart';
// import 'package:hydrosee/widgets/card/ioT_loading_card.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// bool bluethootIsOn = false;

// lib/constants.dart
const String serverUuid = '4fafc201-1fb5-459e-8fcc-c9c9c331914b';
const String charUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  List<ScanResult> scanResults = [];

  bool isScanning = false;
  BluetoothAdapterState bluethootState = BluetoothAdapterState.unknown;

  bool bluethootIsOn = false;
  bool _autoScanStarted = false;
  bool isConnecting = false;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> _checkPermisions() async {
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _listenBluethootState();
    // _checkBluethootState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenBluethootState();
      _checkBluethootState();
    });
  }

  // Fungsi baru untuk memeriksa status kesiapan sebelum scan
  Future<bool> _checkPermisionsAndState() async {
    // Meminta izin jika belum ada
    await _checkPermisions();

    // 1. Cek jika semua izin penting sudah diberikan
    bool granted = await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted;

    if (!granted) {
      // Tampilkan snackbar atau dialog jika izin ditolak
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Izin Bluetooth/Lokasi dibutuhkan."),
          action: SnackBarAction(
            label: 'Buka Pengaturan',
            onPressed: () => AppSettings.openAppSettings(),
          ),
        ),
      );
      return false;
    }

    // 2. Cek status Bluetooth
    await _checkBluethootState(); // Perbarui status
    if (bluethootState != BluetoothAdapterState.on) {
      // Jika Bluetooth mati, jangan lanjutkan scan
      return false;
    }

    return true; // Siap untuk scan
  }

  Future<void> _checkBluethootState() async {
    bluethootState = await FlutterBluePlus.adapterState.first;
    setState(() {
      bluethootIsOn = bluethootState == BluetoothAdapterState.on;
    });
  }

  void _listenBluethootState() {
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        bluethootState = state;
        bluethootIsOn = state == BluetoothAdapterState.on;
      });

      // if (state == BluetoothAdapterState.off) {
      //   _autoScanStarted = false;   // <-- penting
      // }

      if (state == BluetoothAdapterState.on && !_autoScanStarted) {
        _autoScanStarted = true;
        _startScan();
      }
    });
  }

  Future<void> _requestEnabledBluethoot() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      // Jika turnOn() gagal (misalnya, di Android 12+ tanpa izin BLUETOOTH_CONNECT),
      // Anda mencoba membuka pengaturan Bluetooth.
      AppSettings.openAppSettings(
        type: AppSettingsType.bluetooth,
      );
    }
  }

  Future<void> _startScan() async {
    // if (isScanning) return;
    // if (bluethootState != BluetoothAdapterState.on) return;

    // await _checkPermisions();
    bool isReady = await _checkPermisionsAndState(); // Lihat poin 3
    if (!isReady) return; // Hentikan jika izin atau Bluetooth belum siap

    if (isScanning) return;
    if (bluethootState != BluetoothAdapterState.on) return;

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: 10),
      withServices: [],
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results.where((r) {
          String name = r.device.platformName.toUpperCase();
          String adv = r.advertisementData.advName.toUpperCase();
          return name.contains("ESP32") || adv.contains("ESP32");
        }).toList();
      });
    });

    // stop scan setelah timeout
    await Future.delayed(Duration(seconds: 10));
    await FlutterBluePlus.stopScan();

    // cancel stream
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    setState(() {
      isScanning = false;
      // Tambahkan baris ini agar auto-scan bisa berjalan lagi jika user manual scan
      _autoScanStarted = false;
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectDevice(ScanResult result) async {
    // Pastikan tidak ada scanning lagi saat connect
    if (isScanning) await FlutterBluePlus.stopScan(); 

    // Safety check untuk user login. currentUser bisa bernilai null.
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Pengguna belum login.")),
      );
      return;
    }
    
    // final String userId = currentUser.uid; 
    final String deviceId = result.device.remoteId.str; 
    
    // Logic penentuan nama perangkat
    final String deviceName = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : result.advertisementData.advName.isNotEmpty
            ? result.advertisementData.advName
            : "ESP32-hydrosee";

    if (isConnecting) return;
    setState(() { isConnecting = true; });

    final Map<String, String>? wifiCredentials = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => WifiInputDialog(
            // Anda bisa menampilkan nama jaringan yang sudah terdeteksi
            initialSsid: result.device.name, 
        ),
    );

    // Cek jika user membatalkan input
    if (wifiCredentials == null) {
        setState(() { isConnecting = false; });
        return;
    }

    final String ssid = wifiCredentials['ssid']!;
    final String password = wifiCredentials['password']!;

    // 1. TAMPILKAN LOADING POPUP (CustomQuickAlert)
    CustomQuickAlert.loading(
      title: 'Proses Pendaftaran Alat',
      message: 'Sedang mencoba menghubungkan dan mendaftarkan $deviceName. Mohon tunggu.',
      backgroundColor: AppColor.primary_05,
      borderRadius: 20,
    );

    try {
        // A. KONEKSI BLUETOOTH
        await result.device.connect(timeout: Duration(seconds: 15), license: License.free);
        final services = await result.device.discoverServices(); 
        
        await ApiService.registerDevice(
          deviceId: deviceId, // MAC Address dari BLE
          deviceName: deviceName,
        );
        print("✅ Berhasil registrasi di Server Flask");
        // ---------------------------------------------------------
        
        // --- C. KIRIM KONFIGURASI KE ESP32 VIA BLE (Tetap sama) ---
        
        final String pairingPayload = '$ssid|$password|$deviceId';
        
        final targetServiceUuid = Guid(serverUuid);
        final targetCharUuid = Guid(charUuid);

        // final services = await result.device.discoverServices();
        BluetoothCharacteristic? charToWrite;

        for (var service in services) {
            if (service.uuid == targetServiceUuid) {
                for (var char in service.characteristics) {
                    if (char.uuid == targetCharUuid) {
                        charToWrite = char;
                        break;
                    }
                }
            }
        }

        if (charToWrite == null) {
            throw Exception("Characteristic BLE tidak ditemukan.");
        }
        
        // Tulis Payload
        final List<int> bytes = pairingPayload.codeUnits;
        await charToWrite.write(bytes, withoutResponse: false);

        CustomQuickAlert.dismiss();
        await Future.delayed(Duration(milliseconds: 300));
        
        await CustomQuickAlert.success(
          title: 'Berhasil!',
          message: 'Perangkat $deviceName berhasil didaftarkan dan dikonfigurasi.',
          confirmText: 'OK',
          backgroundColor: AppColor.primary_0,
          titleColor: AppColor.primary_5,
          messageColor: AppColor.primary_3,
          borderRadius: 20,
          confirmBtnColor: AppColor.primary_4,
          autoCloseDuration: Duration(seconds: 3),
        );
        
        // E. NAVIGASI
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(
            context, 
            '/device', 
            arguments: result.device, 
        );

    } catch (e) {
      // String errorMessage = 'Koneksi atau pendaftaran gagal: ${e.toString()}';
      
      // if (e.toString().contains("timeout") || e.toString().contains("disconnected")) {
      //     errorMessage = "Koneksi ke perangkat BLE terputus atau waktu koneksi habis. Coba ulangi.";
      // } else if (e.toString().contains("Characteristic BLE tidak ditemukan")) {
      //     errorMessage = "Terjadi kesalahan protokol (UUID). Pastikan ESP32 sudah memulai layanan BLE.";
      // }

      CustomQuickAlert.dismiss();
      await Future.delayed(Duration(milliseconds: 300));
      
      String errorMessage = 'Koneksi atau pendaftaran gagal: ${e.toString()}';
      
      if (e.toString().contains("timeout") || e.toString().contains("disconnected")) {
        errorMessage = "Koneksi ke perangkat BLE terputus atau waktu koneksi habis. Coba ulangi.";
      }
      
      await CustomQuickAlert.error(
        title: 'Gagal',
        message: errorMessage,
        confirmText: 'Tutup',
        backgroundColor: AppColor.primary_0,
        titleColor: AppColor.danger,
        borderRadius: 20,
      );
      
    } finally {
      // Pastikan isConnecting kembali ke false
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary_0,
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // button back
                ActionButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/device');
                    }),
                Text(
                  'Tambah Perangkat IoT',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary_5),
                ),
                // button tambah
                // SizedBox(width: 30,)
                bluethootIsOn && !isScanning
                    ? ActionButton(
                        // Gunakan widget ActionButton yang sudah ada
                        icon: Icons.refresh,
                        onPressed: _startScan,
                      )
                    : SizedBox(
                        width: 30,
                      ), // Jaga keseimbangan tata letak
              ],
            ),
          ),
          bluethootIsOn
              ? Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    // loading
                    if (isScanning)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.inkDrop(
                              color: AppColor.primary_5, size: 24),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "mendeteksi perangkat...",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColor.primary_3,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                    // list device
                    ...scanResults.map((r) {
                      return IotDeviceCard(
                        deviceName: r.device.platformName.isNotEmpty
                            ? r.device.platformName
                            : r.advertisementData.advName,
                        // onPressed: () => _connectDevice(r),
                        onPressed: isConnecting ? null : () => _connectDevice(r),
                      );
                    }).toList(),
                    // BARU: Tampilan jika scanResults kosong dan scanning selesai
                    if (!isScanning && scanResults.isEmpty)
                      _buildNotFoundView(),
                  ],
                )
              : _buildBluetoothOffView()
        ],
      )),
    );
  }

  Widget _buildNotFoundView(){
    // Isi dengan Container/Column yang menampilkan ilustrasi dan tombol "Nyalakan Bluetooth"
    // Ini adalah widget yang sudah Anda buat, hanya dipindahkan ke fungsi.
    // ... (kode Anda yang menampilkan 'Perangkat Tidak Ditemukan' saat Bluetooth OFF)
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        children: [
          Image.asset(
            'assets/ilustrations/iot_not_found.png',
            width: 276,
            height: 200,
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            'Perangkat Tidak Ditemukan',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.danger,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Pastikan perangkat Iotmu berjalan dan menyalakan fitur bluethooth',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.primary_3),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          // SizedBox(
          //   width: double.infinity,
          //   child: ButtonPrimary(
          //       text: 'Nyalakan Bluethooth',
          //       onPressed: () {
          //         _requestEnabledBluethoot();
          //       }),
          // ),
        ],
      ),
    );
  }
  

  Widget _buildBluetoothOffView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          SizedBox(
            height: 100,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Image.asset(
                  'assets/ilustrations/iot_not_found.png',
                  width: 276,
                  height: 200,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Bluethooth Anda Mati',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.danger,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nyalakan Bluetooth di perangkat anda untuk mendeteksi device IoT ',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.primary_3),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ButtonPrimary(
                      text: 'Nyalakan Bluethooth',
                      onPressed: () {
                        _requestEnabledBluethoot();
                      }),
                ),
              ],
            ),
          )
        ]);
  }
}
