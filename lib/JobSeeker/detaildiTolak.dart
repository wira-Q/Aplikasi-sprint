import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/lamaran_detail_widgets.dart';

class DetailDiTolak extends StatelessWidget {
  const DetailDiTolak({super.key, required this.idApplication});

  final int idApplication;

  @override
  Widget build(BuildContext context) {
    return LamaranDetailLoader(
      idApplication: idApplication,
      builder: (context, application, interviews) {
        return [
          // 1. KARTU INFORMASI PERUSAHAAN & POSISI (status Ditolak)
          LamaranCompanyCard(application: application),
          const SizedBox(height: 20),

          // 2. JADWAL INTERVIEW (strip: interview dibatalkan saat ditolak)
          const LamaranSectionTitle('Jadwal Interview'),
          const SizedBox(height: 10),
          const LamaranInfoBox(
            children: [
              LamaranInfoRow(icon: Icons.calendar_today_outlined, text: '-'),
              LamaranInfoRow(icon: Icons.access_time_rounded, text: '-'),
            ],
          ),
          const SizedBox(height: 20),

          // 3. LINK GOOGLE MEET (strip)
          const LamaranSectionTitle('Link Google meet'),
          const SizedBox(height: 10),
          const LamaranInfoBox(
            children: [
              LamaranInfoRow(
                icon: Icons.video_call_rounded,
                iconColor: Color.fromARGB(255, 255, 238, 49),
                text: '-',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. KETERANGAN (kalimat standar dari sistem)
          const LamaranSectionTitle('Keterangan', requiredMark: true),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: [
              LamaranInfoRow(
                icon: Icons.info_outline,
                text:
                    'Lamaran Anda untuk posisi ${application.jobTitle ?? '-'} '
                    'belum dapat dilanjutkan. Jangan menyerah, coba lowongan '
                    'lainnya.',
              ),
            ],
          ),
        ];
      },
    );
  }
}
