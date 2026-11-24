import 'package:flutter/material.dart';

import 'buat_lowongan_page.dart';
import 'job_store.dart';
import 'dasboard_page.dart';
import 'detail_lowongan_page.dart';

class LowonganSayaPage extends StatefulWidget {
  const LowonganSayaPage({super.key});

  @override
  State<LowonganSayaPage> createState() => _LowonganSayaPageState();
}

class _LowonganSayaPageState extends State<LowonganSayaPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _addJob() async {
    final newJob = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const BuatLowonganPage(),
      ),
    );

    if (newJob != null && mounted) {
      setState(() {
        JobStore.jobs.insert(0, newJob);
      });
    }
  }

  void _editJob(int index) {
    final controller = TextEditingController(
      text: JobStore.jobs[index]['title'],
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Lowongan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nama Lowongan',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    JobStore.jobs[index]['title'] = controller.text.trim();
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _deleteJob(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Lowongan?'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus lowongan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  JobStore.jobs.removeAt(index);
                });
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Buka Dashboard langsung di tab tertentu (1 = Applicants, 2 = Profile)
  void _openDashboardTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(initialIndex: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = JobStore.jobs.where((job) {
      return job['title']
          .toString()
          .toLowerCase()
          .contains(searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 21,
          ),
        ),
        title: const Text(
          'Lowongan saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PENCARIAN
                  Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari Lowongan',
                        hintStyle: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: primaryBlue,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Lowongan',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DAFTAR LOWONGAN
                  ...filteredJobs.map((job) {
                    final index = JobStore.jobs.indexOf(job);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailLowonganPage(job: job),
                          ),
                        );
                      },
                      child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job['title'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                height: 25,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF4FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  iconSize: 16,
                                  icon: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          'Manage',
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.tune_rounded,
                                        color: primaryBlue,
                                        size: 15,
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editJob(index);
                                    } else if (value == 'delete') {
                                      _deleteJob(index);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: textGrey,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                job['location'].toString(),
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                job['type'].toString(),
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 9,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.people_alt_rounded,
                                color: primaryBlue,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                job['applicants'].toString(),
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    );
                  }),

                  if (filteredJobs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Text(
                          'Lowongan tidak ditemukan',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // TOMBOL BUAT LOWONGAN
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
            child: SizedBox(
              width: double.infinity,
              height: 43,
              child: ElevatedButton.icon(
                onPressed: _addJob,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 17,
                ),
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
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 57,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F2F6)),
        ),
      ),
      child: Row(
        children: [
          _navItem(
            Icons.home_outlined,
            'Home',
            () => Navigator.pop(context),
          ),
          _navItem(
            Icons.people_outline_rounded,
            'Applicants',
            () => _openDashboardTab(1),
          ),
          _navItem(
            Icons.person_outline_rounded,
            'Profile',
            () => _openDashboardTab(2),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primaryBlue),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}