import 'package:flutter/material.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/widgets/lamaran_detail_widgets.dart';

class DetailDiproses extends StatelessWidget {
  const DetailDiproses({super.key, required this.idApplication});

  final int idApplication;

  @override
  Widget build(BuildContext context) {
    return LamaranDetailLoader(
      idApplication: idApplication,
      builder: (context, application, interviews) {
        final message = application.message?.trim();
        final sentAt = application.appliedAt;

        return [
          LamaranCompanyCard(application: application),
          const SizedBox(height: 20),

          const LamaranSectionTitle('Status Lamaran'),
          const SizedBox(height: 10),
          LamaranInfoBox(
            children: [
              const LamaranInfoRow(
                icon: Icons.hourglass_empty_rounded,
                text: 'Lamaran Anda sedang diproses oleh recruiter.',
              ),
              if (sentAt != null)
                LamaranInfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Dikirim ${DateFormatId.dateTime(sentAt)}',
                ),
            ],
          ),

          if (message != null && message.isNotEmpty) ...[
            const SizedBox(height: 20),
            const LamaranSectionTitle('Pesan Anda untuk recruiter'),
            const SizedBox(height: 10),
            LamaranInfoBox(
              children: [
                LamaranInfoRow(icon: Icons.message_outlined, text: message),
              ],
            ),
          ],
        ];
      },
    );
  }
}
