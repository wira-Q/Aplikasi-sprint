import 'package:flutter/material.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/widgets/lamaran_detail_widgets.dart';
import 'package:sprint/models/interview_model.dart';

class DetailDisetujui extends StatelessWidget {
  const DetailDisetujui({super.key, required this.idApplication});

  final int idApplication;

  @override
  Widget build(BuildContext context) {
    return LamaranDetailLoader(
      idApplication: idApplication,
      builder: (context, application, interviews) {
        // Interview yang sudah selesai (otomatis saat lamaran diterima).
        final done = interviews
            .where((i) => i.status == InterviewStatus.selesai)
            .firstOrNull;

        return [
          // 1. KARTU INFORMASI PERUSAHAAN & POSISI (status Disetujui)
          LamaranCompanyCard(application: application),
          const SizedBox(height: 20),

          // 2. JADWAL INTERVIEW (strip jika tidak ada riwayat interview)
          const LamaranSectionTitle('Jadwal Interview'),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: [
              LamaranInfoRow(
                icon: Icons.calendar_today_outlined,
                text: done == null
                    ? '-'
                    : DateFormatId.dayDate(done.interviewDate),
              ),
              LamaranInfoRow(
                icon: Icons.access_time_rounded,
                text: done == null
                    ? '-'
                    : 'Pukul ${DateFormatId.time(done.interviewDate)}',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. LINK GOOGLE MEET (sudah tidak berlaku)
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
                icon: Icons.celebration_outlined,
                text:
                    'Selamat! Lamaran Anda untuk posisi '
                    '${application.jobTitle ?? '-'} dinyatakan diterima.',
              ),
            ],
          ),
        ];
      },
    );
  }
}
