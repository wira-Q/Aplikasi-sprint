import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/job_filter.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/paged_result.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/job_service.dart';
import 'filterLowongan.dart';
import 'detailLowongan.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final JobService _jobService = JobService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final PagedController<JobModel> _pager;
  Timer? _debounce;

  String _query = '';
  JobFilter _filter = const JobFilter();

  @override
  void initState() {
    super.initState();
    _pager = PagedController<JobModel>(
      fetch: _fetch,
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat lowongan. Periksa koneksi Anda.',
      onBackgroundError: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
    _pager.load(page: 0);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pager.dispose();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<PagedResult<JobModel>> _fetch(int page, int size) {
    return _jobService.getJobsPage(
      query: _query.isEmpty ? null : _query,
      location: _filter.location,
      jobType: _filter.jobType,
      page: page,
      pageSize: size,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {}); // memperbarui tombol hapus (X)
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query == _query) return;
      _query = query;
      _pager.load(page: 0);
    });
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<JobFilter>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterLowongan(
          initial: JobFilter(
            keyword: _query,
            location: _filter.location,
            jobType: _filter.jobType,
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    _debounce?.cancel();
    _filter = result;
    _query = (result.keyword ?? '').trim();
    _searchController.text = _query;
    _pager.load(page: 0);
  }

  Future<void> _goToPage(int page) async {
    await _pager.goTo(page);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // 1. SEARCH BAR & FILTER BUTTON
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari lowongan atau keahlian',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _debounce?.cancel();
                                    _searchController.clear();
                                    _query = '';
                                    _pager.load(page: 0);
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _openFilter,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. DAFTAR KARTU LOWONGAN (5 per halaman, tarik untuk memuat ulang)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _pager.load(spinner: false),
                  child: ListView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: _buildChildren(primaryColor),
                  ),
                ),
              ),

              // 3. NOMOR HALAMAN (dipasang tetap di bawah)
              PageBar(
                page: _pager.page,
                totalPages: _pager.totalPages,
                enabled: !_pager.isLoading,
                onPageSelected: _goToPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(Color primaryColor) {
    if (_pager.isLoading) {
      return const [
        SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_pager.error != null && _pager.items.isEmpty) {
      return [
        SizedBox(
          height: 260,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _pager.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextButton(
                  onPressed: () => _pager.load(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    if (_pager.items.isEmpty) {
      return [
        SizedBox(
          height: 260,
          child: Center(
            child: Text(
              'Lowongan tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ];
    }
    return _pager.items.map((job) => _buildJobCard(job, primaryColor)).toList();
  }

  Widget _buildJobCard(JobModel job, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLowongan(idJob: job.idJob),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CompanyLogo(path: job.companyLogo, size: 50, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.companyName ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        job.location,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          JobTypeLabels.of(job.jobType),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}
