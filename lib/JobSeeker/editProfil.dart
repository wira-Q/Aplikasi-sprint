import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  // Controller untuk setiap form input
  final TextEditingController _nameController = TextEditingController(text: 'Aqeela Calista');
  final TextEditingController _emailController = TextEditingController(text: 'user123@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '+62845909876523');
  final TextEditingController _dateController = TextEditingController(text: '19, July 2009');
  final TextEditingController _addressController = TextEditingController(text: 'Jl. User no 5, Jawa Timur');
  final TextEditingController _statusController = TextEditingController(text: 'Fresh Graduate');

  // Variabel pilihan Gender
  String? _selectedGender = 'Perempuan';
  final List<String> _genderOptions = ['Perempuan', 'Laki-laki'];

  // Fungsi untuk memilih tanggal lahir interaktif
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2009, 7, 19),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // Format sederhana tanggal
        String day = picked.day.toString();
        const months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        String month = months[picked.month - 1];
        int year = picked.year;
        _dateController.text = '$day, $month $year';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _addressController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // BAGIAN ATAS: App Bar (Back & Title & Check Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Simpan (Centang)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.white, size: 24),
                    onPressed: () {
                      // Aksi ketika tombol simpan diklik
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil berhasil diperbarui!')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // FOTO PROFIL & KETERANGAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/profil.png', // Sesuaikan asset foto profil
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                            color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 40, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubah Data?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ubah data diri mu sebaik dan sedetail mungkin dengan 100% data diri asli!',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KONTEN UTAMA: KOTAK FORM PUTIH DENGAN SUDUT MELENGKUNG
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Name
                      _buildInputField(
                        label: 'Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // 2. Email
                      _buildInputField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 3. Telephone
                      _buildInputField(
                        label: 'Telephone',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // 4. Date (Tanggal Lahir dengan DatePicker)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateController,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Colors.blue.shade100, width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF203F8B), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. Address
                      _buildInputField(
                        label: 'Address',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),

                      // 6. Status
                      _buildInputField(
                        label: 'Status',
                        controller: _statusController,
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),

                      // 7. Gender (Dropdown)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.blue.shade100, width: 1.2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                items: _genderOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk merapikan text field input
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.blue.shade100, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF203F8B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}