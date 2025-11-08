import 'package:flutter/material.dart';

class MenuBarWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MenuBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<MenuBarWidget> createState() => _MenuBarWidgetState();
}

class _MenuBarWidgetState extends State<MenuBarWidget> {
  final List<_MenuItem> _menuItems = [
    _MenuItem('Beranda', Icons.home_rounded),
    _MenuItem('Cuaca', Icons.cloud_rounded),
    _MenuItem('Riwayat', Icons.history_rounded),
    _MenuItem('Profil', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF173501),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_menuItems.length, (index) {
          final isSelected = widget.selectedIndex == index;
          final item = _menuItems[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 0,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFFE9EEE5) // background ketika dipilih
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => widget.onItemTapped(index),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    // ubah warna icon ketika dipilih
                    color: isSelected
                        ? const Color(0xFF173501) // hijau tua saat aktif
                        : Color(0xFFE9EEE5) // putih saat tidak aktif
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: Color(0xFF173501), // teks ikut hijau
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;

  _MenuItem(this.title, this.icon);
}
