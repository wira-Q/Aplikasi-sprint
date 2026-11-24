import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart'; // Memanggil halaman Dashboard
import 'searchScreen.dart';
import 'dashboardProfil.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap menu bawah (Home, Search, Profile)
  final List<Widget> _pages = [
  const Dashboard(), // Indeks 0: Home
   const SearchScreen(),// Indeks 1: Search (sementara)
    const DashboardProfil(), // Indeks 2: Profile (sementara)
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      // Menampilkan halaman sesuai tab yang aktif
      body: _pages[_currentIndex],

      // Bottom Navigation Bar terpusat
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}