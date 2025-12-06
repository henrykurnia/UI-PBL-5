import 'package:flutter/material.dart';

class WifiInputDialog extends StatefulWidget {
  final String initialSsid;

  const WifiInputDialog({Key? key, required this.initialSsid}) : super(key: key);

  @override
  _WifiInputDialogState createState() => _WifiInputDialogState();
}

class _WifiInputDialogState extends State<WifiInputDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _ssid;
  String? _password;

  @override
  void initState() {
    super.initState();
    _ssid = widget.initialSsid;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Masukkan Jaringan WiFi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: _ssid, // Bisa diisi dengan nama perangkat BLE
              decoration: const InputDecoration(labelText: 'SSID (Nama WiFi)'),
              validator: (value) => value == null || value.isEmpty ? 'SSID tidak boleh kosong' : null,
              onSaved: (value) => _ssid = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? 'Password tidak boleh kosong' : null,
              onSaved: (value) => _password = value,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(null), // Mengembalikan null jika dibatalkan
        ),
        ElevatedButton(
          child: const Text('Kirim Konfigurasi'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              // Mengembalikan Map berisi kredensial
              Navigator.of(context).pop({
                'ssid': _ssid!,
                'password': _password!,
              });
            }
          },
        ),
      ],
    );
  }
}