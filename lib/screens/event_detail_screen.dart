import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/components/event_card.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/localization/texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/stores/event_store.dart';

const _white = ConstantColor.pureWhite;

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventModel event;

  void _confirmDelete(BuildContext context) {
    final store = context.read<EventStore>();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: LocaleKeys.delete.tr(),
      text: LocaleKeys.areYouSure.tr(),
      confirmBtnText: LocaleKeys.yes.tr(),
      onConfirmBtnTap: () async {
        Navigator.pop(context); // dialog
        Navigator.pop(context); // detail
        await store.delete(event);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = eventColor(event);
    final description = event.eventDescription ?? '';
    final upcoming = event.eventDate.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(
            Icons.chevron_left_outlined,
            color: _white,
            size: 40,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: color,
        ),
        backgroundColor: color,
        elevation: 0,
      ),
      body: SafeArea(
        // Centered and width-capped so tablets don't get a lone strip at the top.
        child: Center(
          child: SingleChildScrollView(
            padding: context.paddingNormal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.eventTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    description.isEmpty
                        ? LocaleKeys.noDescription.tr()
                        : description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _white,
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _InfoRow(
                    icon: Icons.event,
                    text: formatEventDate(
                      event.eventDate,
                      context.locale.toString(),
                    ),
                  ),
                  if (event.notify && upcoming)
                    _InfoRow(
                      icon: Icons.notifications_active,
                      text: reminderLabel(
                        ReminderPeriod.tryParse(event.reminder),
                      ),
                    ),
                  const SizedBox(height: 48),
                  Center(
                    child: IconButton(
                      onPressed: () => _confirmDelete(context),
                      tooltip: LocaleKeys.delete.tr(),
                      icon: const Icon(Icons.delete, size: 40, color: _white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: _white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
