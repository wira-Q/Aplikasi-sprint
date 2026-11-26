
import 'package:flutter/material.dart';
import 'dasboard_page.dart';

class Onboarding3Page extends StatefulWidget {
  const Onboarding3Page({super.key});

  @override
  State<Onboarding3Page> createState() => _Onboarding3PageState();
}

class _Onboarding3PageState extends State<Onboarding3Page> {
  final Color navy = const Color(0xFF243F8F);

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController websiteController =
      TextEditingController();

  final TextEditingController contactController =
      TextEditingController();

  String selectedContactType = 'Email';

  @override
  void dispose() {
    descriptionController.dispose();
    websiteController.dispose();
    contactController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN DATA DAN MASUK DASHBOARD
  void simpanData() {
    if (descriptionController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi deskripsi dan kontak perusahaan terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    if (selectedContactType == 'Email' &&
        !contactController.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan alamat email yang valid.'),
        ),
      );
      return;
    }

    // PINDAH KE DASHBOARD
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // TOMBOL KEMBALI
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: Color(0xFF40516B),
                    ),
                    padding: EdgeInsets.zero,
                  ),

                  // PROGRESS BAR
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 65,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E7F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 65,
                            height: 4,
                            decoration: BoxDecoration(
                              color: navy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Text(
                    '3/3',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: navy,
                        size: 23,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // TITLE
                    Text(
                      'Buat perusahaan lebih menarik',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tambahkan informasi tambahan agar kandidat '
                      'lebih yakin untuk bergabung.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8290A5),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // FORM CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DESKRIPSI PERUSAHAAN
                          const Text(
                            'Deskripsi Perusahaan *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: descriptionController,
                            maxLines: 4,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText:
                                  'Ceritakan tentang perusahaan kamu, '
                                  'visi, misi, dan apa yang membuat '
                                  'perusahaan kamu unik...',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8290A5),
                                height: 1.5,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 65),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                  color: Color(0xFF8290A5),
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF0F4F8),
                              alignLabelWithHint: true,
                              contentPadding: const EdgeInsets.all(12),
                              counterStyle: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8290A5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // WEBSITE
                          const Text(
                            'Website (Opsional)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: websiteController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              hintText: 'https://example.com',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8290A5),
                              ),
                              prefixIcon: const Icon(
                                Icons.language,
                                size: 16,
                                color: Color(0xFF8290A5),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF0F4F8),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // KONTAK PERUSAHAAN
                          const Text(
                            'Kontak Perusahaan *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // PILIH EMAIL / WHATSAPP
                          Container(
                            height: 38,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              children: [
                                // EMAIL
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedContactType = 'Email';
                                        contactController.clear();
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedContactType == 'Email'
                                            ? navy
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedContactType == 'Email'
                                                  ? Colors.white
                                                  : const Color(0xFF536176),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // WHATSAPP
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedContactType = 'WhatsApp';
                                        contactController.clear();
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            selectedContactType == 'WhatsApp'
                                                ? navy
                                                : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'WhatsApp',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedContactType == 'WhatsApp'
                                                  ? Colors.white
                                                  : const Color(0xFF536176),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // INPUT KONTAK
                          TextField(
                            controller: contactController,
                            keyboardType:
                                selectedContactType == 'Email'
                                    ? TextInputType.emailAddress
                                    : TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: selectedContactType == 'Email'
                                  ? 'nama@perusahaan.com'
                                  : '08xxxxxxxxxx',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8290A5),
                              ),
                              prefixIcon: Icon(
                                selectedContactType == 'Email'
                                    ? Icons.mail_outline
                                    : Icons.phone_outlined,
                                size: 16,
                                color: const Color(0xFF8290A5),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF0F4F8),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL SIMPAN
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Simpan & Masuk Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        size: 17,
                      ),
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
}
