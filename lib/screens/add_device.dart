import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hydrosee/widgets/button/button_primary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

// package
import 'package:loading_animation_widget/loading_animation_widget.dart';

// widget
import 'package:hydrosee/widgets/button/action_button.dart';
import 'package:hydrosee/widgets/card/iot_device_card.dart';
import 'package:hydrosee/widgets/card/ioT_loading_card.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// bool bluethootIsOn = false;

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
    try {
      await result.device.connect(
        timeout: Duration(seconds: 15),
        license: License.free,
      );

      String deviceName = result.device.platformName.isNotEmpty
          ? result.device.platformName
          : result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : "ESP32";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terhubung ke $deviceName")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghubungkan: $e")),
      );
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
                          LoadingAnimationWidget.inkDrop(color: AppColor.primary_5, size: 24),
                          SizedBox(height: 5,),
                          Text(
                            "mendeteksi perangkat...",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColor.primary_3,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                      // Column(
                      //   children: [
                      //     IotLoadingCard(),
                      //     IotLoadingCard(),
                      //     IotLoadingCard(),
                      //     IotLoadingCard(),
                      //   ],
                      // ),

                    // list device
                    ...scanResults.map((r) {
                      return IotDeviceCard(
                        deviceName: r.device.platformName.isNotEmpty
                            ? r.device.platformName
                            : r.advertisementData.advName,
                        onPressed: () => _connectDevice(r),
                      );
                    }).toList(),
                    // BARU: Tampilan jika scanResults kosong dan scanning selesai
                    if (!isScanning && scanResults.isEmpty)
                      _buildBluetoothOffView(),
                  ],
                )
              : Column(
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
                    ])
        ],
      )),
    );
  }

  Widget _buildBluetoothOffView() {
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
    );
  }
}
