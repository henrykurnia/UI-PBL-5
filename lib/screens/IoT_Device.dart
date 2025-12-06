import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hydrosee/widgets/button/button_primary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:async';

// package
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:custom_quick_alert/custom_quick_alert.dart';

// theme (Pastikan ini sesuai dengan path Anda)
import 'package:hydrosee/theme/colors.dart';

// widget (Pastikan ini sesuai dengan path Anda)
import 'package:hydrosee/widgets/card/ioT_status_card.dart';
import 'package:hydrosee/widgets/button/action_button.dart';
import 'package:hydrosee/widgets/popup/wifiInputDialog.dart';

// =========================================================================
// WIDGET UTAMA (IOT DEVICE)
// =========================================================================

const String serverUuid = '4fafc201-1fb5-459e-8fcc-c9c9c331914b';
const String charUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

class IotDevice extends StatefulWidget {
  const IotDevice({super.key});

  @override
  State<IotDevice> createState() => _IotDeviceState();
}

class _IotDeviceState extends State<IotDevice> {
  // 1. Inisialisasi Firestore dan Stream
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _devicesStream; // Menggunakan Stream untuk real-time updates

  // Konstanta Timeout (2 menit dalam milidetik)
  final int OFFLINE_TIMEOUT_MS = 120000; 

  // Mengambil user ID saat ini. Ganti 'guest_user' jika logic Auth Anda berbeda.
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  BluetoothAdapterState bluethootState = BluetoothAdapterState.unknown;
  bool bluethootIsOn = false;
  bool isScanning = false;
  bool isConnecting = false;

  // Perlu untuk menyimpan hasil scan sementara (walaupun tidak digunakan di UI ini)
  List<ScanResult> scanResults = []; 
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    // 2. Memuat data perangkat secara real-time saat inisialisasi State
    _devicesStream = _getIotDevicesStream();
    
  }

  // 3. Fungsi yang mengembalikan Stream dari Firestore (menggunakan .snapshots())
  Stream<QuerySnapshot> _getIotDevicesStream() { 
    // Jika user ID null (belum login), kembalikan Stream kosong
    if (_currentUserId == 'guest_user') {
      return Stream.empty();
    }
    
    // Filter perangkat berdasarkan ID pengguna yang login dan mendengarkan perubahan
    return _firestore.collection('devices')
                     .where('userId', isEqualTo: _currentUserId)
                     .snapshots(); // PENTING: snapshots() untuk StreamBuilder
  }

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

  Future<void> _checkBluethootState() async {
    bluethootState = await FlutterBluePlus.adapterState.first;
    setState(() {
      bluethootIsOn = bluethootState == BluetoothAdapterState.on;
    });
  }

  Future<bool> _checkPermisionsAndState() async {
    // Meminta izin jika belum ada
    await _checkPermisions();

    // 1. Cek jika semua izin penting sudah diberikan
    bool granted = await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted;

    if (!granted) {
      // Tampilkan snackbar atau dialog jika izin ditolak
      if (mounted) { // Selalu cek mounted sebelum showSnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Izin Bluetooth/Lokasi dibutuhkan."),
            action: SnackBarAction(
              label: 'Buka Pengaturan',
              onPressed: () => AppSettings.openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    // 2. Cek status Bluetooth
    await _checkBluethootState(); // Perbarui status
    if (bluethootState != BluetoothAdapterState.on) {
      // Tampilkan pesan jika Bluetooth mati
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bluetooth mati. Mohon nyalakan Bluetooth Anda.")),
        );
      }
      return false;
    }

    return true; // Siap untuk rekonfigurasi
  }

  // Fungsi baru untuk memeriksa status kesiapan sebelum scan
  // Di dalam class _IotDeviceState
  Future<void> _reconfigureDevice(String deviceId, String deviceName) async {
    if (isConnecting) return;
    setState(() { isConnecting = true; });

    bool isReady = await _checkPermisionsAndState();
    if (!isReady) {
      setState(() { isConnecting = false; });
      return;
    }

    // ✅ PERBAIKAN: Scan dengan listener yang proper
    CustomQuickAlert.loading(
      title: 'Mencari Perangkat',
      message: 'Memindai Bluetooth...',
    );

    ScanResult? result;
    bool found = false;

    // Listener untuk hasil scan
    final scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (r.device.remoteId.str == deviceId) {
          result = r;
          found = true;
        }
      }
    });

    // Mulai scan
    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    // Tunggu hingga timeout atau device ditemukan
    for (int i = 0; i < 20 && !found; i++) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    await FlutterBluePlus.stopScan();
    await scanSub.cancel();

    CustomQuickAlert.dismiss();

    if (result == null) {
      await CustomQuickAlert.error(
        title: 'Perangkat Tidak Ditemukan',
        message: 'Pastikan $deviceName menyala dan Bluetooth aktif.',
        borderRadius: 20,
      );
      setState(() { isConnecting = false; });
      return;
    }

    // Lanjut ke dialog WiFi...
    final wifiCredentials = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => WifiInputDialog(initialSsid: deviceName),
    );

    if (wifiCredentials == null) {
      setState(() { isConnecting = false; });
      return;
    }

    final ssid = wifiCredentials['ssid']!;
    final password = wifiCredentials['password']!;

    CustomQuickAlert.loading(
      title: 'Mengirim Konfigurasi',
      message: 'Menghubungkan ke $deviceName...',
    );

    try {
      await result!.device.connect(
        license: License.free,
        timeout: Duration(seconds: 15),
      );

      final services = await result!.device.discoverServices();
      final reconfigPayload = '$ssid|$password|$deviceId';

      final targetServiceUuid = Guid(serverUuid);
      final targetCharUuid = Guid(charUuid);

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

      await charToWrite.write(reconfigPayload.codeUnits, withoutResponse: false);
      
      await result!.device.disconnect();

      CustomQuickAlert.dismiss();
      await CustomQuickAlert.success(
        title: 'Berhasil',
        message: 'Konfigurasi WiFi berhasil diperbarui.',
        autoCloseDuration: Duration(seconds: 2),
      );

    } catch (e) {
      CustomQuickAlert.dismiss();
      await CustomQuickAlert.error(
        title: 'Gagal',
        message: 'Gagal mengirim konfigurasi: $e',
      );
    } finally {
      try {
        await result?.device.disconnect();
      } catch (_) {}
      setState(() { isConnecting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary_0,
      body: Column(
        children: [
          // ====================================================
          // HEADER DAN BUTTONS
          // ====================================================
          const SizedBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button Back
                ActionButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                ),
                Text(
                  'Daftar Perangkat IoT',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary_5
                  ),
                ),
                // Button Tambah Perangkat
                ActionButton(
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/device_add');
                  }
                ),
              ],
            ),
          ),

          // ====================================================
          // DAFTAR PERANGKAT (MENGGUNAKAN STREAM BUILDER)
          // ====================================================
          
          Expanded( // Wajib agar ListView tahu batas tingginya
            child: StreamBuilder<QuerySnapshot>( // ✅ Menggunakan StreamBuilder
              stream: _devicesStream, // ✅ Menggunakan Stream
              builder: (context, snapshot) {
                
                // --- STATE 1: LOADING ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- STATE 2: ERROR ---
                if (snapshot.hasError) {
                  return Center(child: Text('Error memuat data: ${snapshot.error}'));
                }

                // --- STATE 3: DATA SUKSES (Data tersedia) ---
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final devices = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      // final deviceData = devices[index].data() as Map<String, dynamic>;

                      // final deviceName = deviceData['name'] ?? 'Unknown Device';
                      
                      // // 1. Ambil timestamp 'lastSeen' dari Firestore (asumsi integer/number)
                      // final lastSeenTimestamp = deviceData['lastSeen'] as int?; 
                      
                      // bool isOnline = false;

                      // if (lastSeenTimestamp != null) {
                      //     // 2. Hitung selisih waktu
                      //     final now = DateTime.now().millisecondsSinceEpoch;
                      //     final timeDifference = now - lastSeenTimestamp;
                          
                      //     // 3. Logika Penentuan Status Heartbeat
                      //     // Perangkat online jika timeDifference lebih kecil dari 2 menit (OFFLINE_TIMEOUT_MS)
                      //     isOnline = timeDifference < OFFLINE_TIMEOUT_MS;
                      // } else {
                      //     // Jika field 'lastSeen' belum ada atau null
                      //     isOnline = false;
                      // }
                      
                      // final deviceData = devices[index].data() as Map<String, dynamic>;
                      // final String deviceId = deviceData['macaddress'];
                      // final deviceName = deviceData['name'] ?? 'Unknown Device';
                      final deviceDoc = devices[index]; // Ambil QueryDocumentSnapshot
                      final deviceData = deviceDoc.data() as Map<String, dynamic>;
                      
                      // PERBAIKAN: Ambil deviceId dari ID dokumen, bukan dari field data.
                      final String deviceId = deviceDoc.id; 
                      
                      final deviceName = deviceData['name'] ?? 'Unknown Device';

                      final mqttStatus = deviceData['status'] as String? ?? 'online';

                      //  Ambil sebagai objek Timestamp dari Firestore
                      final lastSeenFirestore = deviceData['lastSeen'] as Timestamp?; 

                      bool isOnline = false;

                      if (mqttStatus.toLowerCase() == 'offline') {
                        isOnline = false;
                      } else if (lastSeenFirestore != null) { 
                        
                        //  Konversi Timestamp ke milidetik sebelum perhitungan
                        final lastSeenTimestamp = lastSeenFirestore.millisecondsSinceEpoch;
                        
                        final now = DateTime.now().millisecondsSinceEpoch;
                        final timeDifference = now - lastSeenTimestamp;
                        
                        isOnline = timeDifference < OFFLINE_TIMEOUT_MS;
                      } else {
                        isOnline = false;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: IotStatusCard(
                          deviceName: deviceName, 
                          isOnline: isOnline,
                          onTap: () => _reconfigureDevice(deviceId, deviceName),
                        ),
                      );
                    },
                  );
                }
                
                // --- STATE 4: DATA KOSONG ---
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                            'Belum ada perangkat terdaftar.',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColor.primary_4,
                                fontWeight: FontWeight.w500
                            ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            'Silakan tambahkan perangkat baru.',
                            style: GoogleFonts.inter(color: AppColor.primary_5),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}