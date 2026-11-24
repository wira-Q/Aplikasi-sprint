import 'package:flutter/material.dart';

import 'job_store.dart';
import 'lowongan_saya_page.dart';
import 'applicants_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  // 0 = Home, 1 = Applicants, 2 = Profile
  final int initialIndex;

  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectedIndex == 2
          ? ProfilePage(onBack: () => setState(() => selectedIndex = 0))
          : SafeArea(
              child: selectedIndex == 0
                  ? _dashboardContent()
                  : ApplicantsPage(
                      onBack: () => setState(() => selectedIndex = 0),
                    ),
            ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _dashboardContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 30),
                _sectionTitle('Ringkasan', '30 hari terakhir', () {}),
                const SizedBox(height: 12),
                _summaryCards(),
                const SizedBox(height: 23),
                _sectionTitle('Lowongan Aktif', 'Lihat semua', _openLowongan),
                const SizedBox(height: 12),
                _dashboardJobCard(
                  'Product Designer',
                  'Malang',
                  'Full-time',
                  '48',
                ),
                const SizedBox(height: 10),
                _dashboardJobCard(
                  'Frontend Developer',
                  'Surabaya',
                  'Kontrak',
                  '31',
                ),
                const SizedBox(height: 22),
                _sectionTitle(
                  'Pelamar Terbaru',
                  'Lihat semua',
                  () => setState(() => selectedIndex = 1),
                ),
                const SizedBox(height: 12),
                _applicantCard(),
              ],
            ),
          ),
        ),
        _createJobButton(),
      ],
    );
  }

  // Dashboard menuju halaman Lowongan Saya
  void _openLowongan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LowonganSayaPage()),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.business_center_outlined,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KarsaHire',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Halo, PT KarsaHire!',
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Siap temukan talenta terbaik?',
                style: TextStyle(color: textGrey, fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: textDark,
            size: 23,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                action,
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: primaryBlue,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 108,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Active Jobs',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    _summaryIcon(
                      Icons.business_center_outlined,
                      Colors.white,
                      const Color(0xFF3858A2),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '6',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '+2 bulan ini',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 108,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFE),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Applicants',
                        style: TextStyle(color: textGrey, fontSize: 10),
                      ),
                    ),
                    _summaryIcon(
                      Icons.people_alt_outlined,
                      primaryBlue,
                      const Color(0xFFEAF1FF),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '184',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        '+24 minggu ini',
                        style: TextStyle(color: textGrey, fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: iconColor, size: 17),
    );
  }

  Widget _dashboardJobCard(
    String title,
    String location,
    String type,
    String applicants,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: textGrey, size: 12),
              const SizedBox(width: 3),
              Text(
                location,
                style: const TextStyle(color: textGrey, fontSize: 9),
              ),
              const SizedBox(width: 8),
              const Text(
                '•',
                style: TextStyle(color: textGrey, fontSize: 10),
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: const TextStyle(color: textGrey, fontSize: 9),
              ),
              const Spacer(),
              const Icon(Icons.people_alt_rounded, color: primaryBlue, size: 13),
              const SizedBox(width: 3),
              Text(
                applicants,
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _applicantCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _applicantRow(
            'AP',
            'Alya Putri',
            'UI UX Designer...',
            const Color(0xFFDDEBFF),
          ),
          _applicantRow(
            'RP',
            'Raka Pradana',
            'Frontend Developer',
            const Color(0xFFFFF1C9),
          ),
          _applicantRow(
            'NS',
            'Nadya Sari',
            'Backend Developer...',
            const Color(0xFFD9F9E7),
          ),
        ],
      ),
    );
  }

  Widget _applicantRow(
    String initials,
    String name,
    String position,
    Color avatarColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  position,
                  style: const TextStyle(color: textGrey, fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Baru',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Dashboard membuka Lowongan Saya terlebih dahulu
  Widget _createJobButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 7),
      child: SizedBox(
        width: double.infinity,
        height: 43,
        child: ElevatedButton.icon(
          onPressed: _openLowongan,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            'Buat Lowongan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F2F6))),
      ),
      child: Row(
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.people_outline_rounded, 'Applicants', 1),
          _navItem(Icons.person_outline_rounded, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? primaryBlue : const Color(0xFFAAB3C2),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? primaryBlue : textGrey,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}