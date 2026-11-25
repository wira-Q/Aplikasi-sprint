import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/widgets/lamaran_detail_widgets.dart';
import 'package:sprint/models/interview_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailInterview extends StatelessWidget {
  const DetailInterview({super.key, required this.idApplication});

  final int idApplication;

  Future<void> _openLink(BuildContext context, String link) async {
    final messenger = ScaffoldMessenger.of(context);
    // Hanya link Google Meet yang dibuka, sama dengan aturan di database.
    if (MeetingRules.validateLink(link) != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Link meeting tidak valid.')),
      );
      return;
    }
    try {
      final opened = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka link meeting.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link meeting.')),
      );
    }
  }

  Future<void> _copyLink(BuildContext context, String link) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: link));
    messenger.showSnackBar(const SnackBar(content: Text('Link disalin.')));
  }

  @override
  Widget build(BuildContext context) {
    return LamaranDetailLoader(
      idApplication: idApplication,
      builder: (context, application, interviews) {
        // Interview aktif = yang berstatus Dijadwalkan.
        final active = interviews.where((i) => i.isScheduled).firstOrNull;
        final notes = active?.notes?.trim();

        return [
          // 1. KARTU INFORMASI PERUSAHAAN & POSISI
          LamaranCompanyCard(application: application),
          const SizedBox(height: 20),

          // 2. JADWAL INTERVIEW
          const LamaranSectionTitle('Jadwal Interview'),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: active == null
                ? const [
                    LamaranInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: 'Jadwal belum ditentukan oleh recruiter.',
                    ),
                  ]
                : [
                    LamaranInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: DateFormatId.dayDate(active.interviewDate),
                    ),
                    LamaranInfoRow(
                      icon: Icons.access_time_rounded,
                      text: 'Pukul ${DateFormatId.time(active.interviewDate)}',
                    ),
                  ],
          ),
          const SizedBox(height: 20),

          // 3. CATATAN RECRUITER
          const LamaranSectionTitle('Catatan recruiter', requiredMark: true),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: [
              LamaranInfoRow(
                icon: Icons.sticky_note_2_outlined,
                text: (notes == null || notes.isEmpty) ? '-' : notes,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. LINK GOOGLE MEET
          const LamaranSectionTitle('Link Google meet'),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: [
              if (active == null)
                const LamaranInfoRow(
                  icon: Icons.video_call_rounded,
                  iconColor: Color.fromARGB(255, 255, 238, 49),
                  text: '-',
                )
              else
                LamaranInfoRow(
                  icon: Icons.video_call_rounded,
                  iconColor: const Color.fromARGB(255, 255, 238, 49),
                  textColor: Colors.blue.shade700,
                  text: active.meetingLink,
                  onTap: () => _openLink(context, active.meetingLink),
                  trailing: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                    tooltip: 'Salin link',
                    onPressed: () => _copyLink(context, active.meetingLink),
                  ),
                ),
            ],
          ),
        ];
      },
    );
  }
}
