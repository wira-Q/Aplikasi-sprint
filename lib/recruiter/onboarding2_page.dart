import 'package:flutter/material.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/recruiter/onboarding_draft.dart';
import 'onboarding3_page.dart';

class Onboarding2Page extends StatefulWidget {
  const Onboarding2Page({super.key});

  @override
  State<Onboarding2Page> createState() => _Onboarding2PageState();
}

class _Onboarding2PageState extends State<Onboarding2Page> {
  final Color navy = const Color(0xFF243F8F);

  late final TextEditingController addressController;

  String? selectedCity;
  String? selectedWorkSystem;

  // Kota dan sistem kerja mengikuti aturan database.
  final List<String> cities = JobOptions.locations;
  final List<String> workSystems = JobOptions.workSystems;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(
      text: CompanyOnboardingDraft.address,
    );
    selectedCity = CompanyOnboardingDraft.city;
    selectedWorkSystem = CompanyOnboardingDraft.workSystem;
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void _next() {
    final address = addressController.text.trim();
    if (selectedCity == null || address.isEmpty || selectedWorkSystem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua informasi terlebih dahulu.'),
        ),
      );
      return;
    }

    CompanyOnboardingDraft.city = selectedCity;
    CompanyOnboardingDraft.address = address;
    CompanyOnboardingDraft.workSystem = selectedWorkSystem;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Onboarding3Page()),
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
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
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
                            width: 43,
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
                    '2/3',
                    style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
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
                    // ICON LOKASI
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: navy,
                        size: 23,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // TITLE
                    Text(
                      'Dimana lokasi perusahaan?',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Lokasi membantu kandidat menemukan '
                      'pekerjaan kamu.',
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
                          // KOTA
                          const Text(
                            'Kota / Kabupaten *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 8),

                          DropdownButtonFormField<String>(
                            value: selectedCity,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Pilih kota / kabupaten',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8290A5),
                              ),
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: Color(0xFF8290A5),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF0F4F8),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(
                                  city,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                            },
                          ),

                          const SizedBox(height: 22),

                          // ALAMAT LENGKAP
                          const Text(
                            'Alamat Lengkap *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: addressController,
                            maxLines: 3,
                            maxLength: 200,
                            decoration: InputDecoration(
                              hintText:
                                  'Contoh: Jl. Melati No.12, Kec. '
                                  'Lowokwaru, Kota Malang',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8290A5),
                                height: 1.5,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 48),
                                child: Icon(
                                  Icons.insert_drive_file_outlined,
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

                          const SizedBox(height: 10),

                          // SISTEM KERJA
                          const Text(
                            'Sistem Kerja *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 7,
                            runSpacing: 10,
                            children: workSystems.map((system) {
                              final isSelected = selectedWorkSystem == system;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedWorkSystem = system;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? navy
                                        : const Color(0xFFF0F4F8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    system,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF536176),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL LANJUT
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _next,
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
                        'Lanjut',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 17),
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
