import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/utils/job_display.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/job_service.dart';
import 'halamanLamar.dart';

class DetailLowongan extends StatefulWidget {
  const DetailLowongan({super.key, required this.idJob});

  final int idJob;

  @override
  State<DetailLowongan> createState() => _DetailLowonganState();
}

class _DetailLowonganState extends State<DetailLowongan> {
  final JobService _jobService = JobService();
  final ApplicationService _applications = ApplicationService();

  JobModel? _job;
  bool _hasApplied = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
    _checkApplied();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final job = await _jobService.getJobById(widget.idJob);
      if (!mounted) return;
      setState(() {
        _job = job;
        _errorMessage = job == null
            ? 'Lowongan tidak ditemukan atau sudah tidak tersedia.'
            : null;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat lowongan. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  /// Gagal memeriksa tidak menghalangi: database tetap menolak lamaran ganda.
  Future<void> _checkApplied() async {
    try {
      final applied = await _applications.hasApplied(widget.idJob);
      if (!mounted) return;
      setState(() => _hasApplied = applied);
    } catch (_) {
      // Tombol tetap aktif.
    }
  }

  Future<void> _openApply(JobModel job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HalamanLamar(idJob: job.idJob)),
    );
    // Kembali dari halaman lamar: periksa ulang apakah sudah melamar.
    if (mounted) _checkApplied();
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final canApply = job != null && job.isOpen && !_hasApplied;

    String buttonText = 'Lamar pekerjaan';
    if (_hasApplied) {
      buttonText = 'Sudah melamar';
    } else if (job != null && job.isExpired) {
      buttonText = 'Lowongan sudah berakhir';
    } else if (job != null && !job.isOpen) {
      buttonText = 'Lowongan sudah ditutup';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: _buildBody(job),

      // TOMBOL LAMAR PEKERJAAN DI BAWAH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canApply ? () => _openApply(job) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2862E8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Info tanggal tutup lowongan. Tidak tampil jika tanpa batas waktu.
  Widget _deadlineBox(JobModel job) {
    final d = job.deadline;
    if (d == null) return const SizedBox.shrink();

    final expired = job.isExpired;
    final left = job.daysLeft;
    String text;
    if (expired) {
      text = 'Lowongan berakhir pada ${DateFormatId.date(d)}';
    } else {
      text = 'Lowongan ditutup pada ${DateFormatId.date(d)}';
      if (left != null && left <= 7) {
        text += left == 0 ? ' (hari terakhir)' : ' (tinggal $left hari)';
      }
    }
    final urgent = expired || (left != null && left <= 7);
    final color = expired
        ? Colors.red
        : (urgent ? const Color(0xFFB7791F) : Colors.grey.shade700);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.event_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(JobModel? job) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (job == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'Lowongan tidak ditemukan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    final salary = JobDisplay.salary(job.salary);
    final workSystem = job.workSystem?.trim();
    final education = job.education?.trim();
    final qualifications = <String>[
      if (education != null && education.isNotEmpty) 'Pendidikan: $education',
      ...JobDisplay.skillList(job.skills),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KARTU UTAMA INFO LOWONGAN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Logo & Nama Perusahaan
                Row(
                  children: [
                    CompanyLogo(path: job.companyLogo, size: 40, radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        job.companyName ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Judul Posisi Pekerjaan
                Text(
                  job.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Chip Atribut (Lokasi, Jenis pekerjaan, Sistem kerja)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.location_on_outlined, job.location),
                    _buildInfoChip(
                      Icons.work_outline,
                      JobTypeLabels.of(job.jobType),
                    ),
                    if (workSystem != null && workSystem.isNotEmpty)
                      _buildInfoChip(Icons.home_work_outlined, workSystem),
                  ],
                ),

                const SizedBox(height: 12),

                // Kotak Gaji
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    salary.isEmpty ? 'Gaji tidak dicantumkan' : salary,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Tanggal lowongan ditutup
                _deadlineBox(job),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // TENTANG PEKERJAAN
          Text(
            'Tentang pekerjaan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          // KUALIFIKASI (hanya jika ada datanya)
          if (qualifications.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Kualifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...qualifications.map(_buildQualificationItem),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget helper untuk chip informasi di kartu
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk poin kualifikasi
  Widget _buildQualificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
