import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scheduler/components/event_card.dart';
import 'package:scheduler/components/fade_out_builder.dart';
import 'package:scheduler/components/settings_drawer.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/screens/create_event_screen.dart';
import 'package:scheduler/screens/event_detail_screen.dart';
import 'package:scheduler/services/path_service.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:scheduler/stores/settings_store.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.askForRating = true,
    this.drawerOpen = false,
  });

  /// Off for screenshot runs.
  final bool askForRating;
  final bool drawerOpen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _splashDuration = Duration(milliseconds: 350);
  static const _maxSlide = 225.0;
  static const _minDragStartEdge = 60.0;
  static const _maxDragStartEdge = _maxSlide - 16;

  late final _drawer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: widget.drawerOpen ? 1 : 0,
  );
  final _fabKey = RectGetter.createGlobalKey();
  Rect? _splash;
  bool _canBeDragged = false;

  @override
  void initState() {
    super.initState();
    if (widget.askForRating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskRating());
    }
  }

  @override
  void dispose() {
    _drawer.dispose();
    super.dispose();
  }

  void _maybeAskRating() {
    final settings = context.read<SettingsStore>();
    if (!canRate || settings.isRated || context.read<EventStore>().count < 2) {
      return;
    }
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: LocaleKeys.rateMyApp.tr(),
      text: LocaleKeys.wouldYouPleaseRate.tr(),
      confirmBtnText: LocaleKeys.rate.tr(),
      cancelBtnText: LocaleKeys.later.tr(),
      showCancelBtn: true,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        settings.setRated();
        openStoreReview();
      },
    );
  }

  void _toggleDrawer() =>
      _drawer.isDismissed ? _drawer.forward() : _drawer.reverse();

  void _onDragStart(DragStartDetails details) {
    final x = details.globalPosition.dx;
    _canBeDragged =
        (_drawer.isDismissed && x < _minDragStartEdge) ||
        (_drawer.isCompleted && x > _maxDragStartEdge);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) _drawer.value += details.primaryDelta! / _maxSlide;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_drawer.isDismissed || _drawer.isCompleted) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() >= 365) {
      _drawer.fling(velocity: velocity / MediaQuery.sizeOf(context).width);
    } else {
      _drawer.value < .5 ? _drawer.reverse() : _drawer.forward();
    }
  }

  Future<void> _openCreate() async {
    setState(() => _splash = RectGetter.getRectFromKey(_fabKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.sizeOf(context);
      setState(() => _splash = _splash?.inflate(1.3 * size.longestSide));
    });
    await Future.delayed(_splashDuration + const Duration(milliseconds: 50));
    if (!mounted) return;
    final saved = await Navigator.push<bool>(
      context,
      FadeRouteBuilder(page: const CreateEventScreen()),
    );
    if (!mounted) return;
    setState(() => _splash = null);
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.successfullySaved.tr())),
      );
    }
  }

  void _openDetail(EventModel event) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
  );

  void _confirmDeleteAll() {
    final store = context.read<EventStore>();
    if (store.count == 0) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: LocaleKeys.areYouSure.tr(),
      text: LocaleKeys.allEventsWillBeDeleted.tr(),
      confirmBtnText: LocaleKeys.yes.tr(),
      onConfirmBtnTap: () {
        store.deleteAll();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _drawer,
        builder: (context, child) => PopScope(
          // Back closes the drawer first.
          canPop: _drawer.isDismissed,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _drawer.reverse();
          },
          child: Stack(
            children: [
              const Positioned.fill(child: SettingsDrawer()),
              Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(_maxSlide * _drawer.value, 0, 0, 1)
                  ..scaleByDouble(
                    1 - .3 * _drawer.value,
                    1 - .3 * _drawer.value,
                    1,
                    1,
                  ),
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  // Tapping the shrunk page closes the drawer.
                  onTap: _drawer.isDismissed ? null : _drawer.reverse,
                  child: AbsorbPointer(
                    absorbing: !_drawer.isDismissed,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(LocaleKeys.events.tr()),
                leading: IconButton(
                  onPressed: _toggleDrawer,
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).openAppDrawerTooltip,
                  icon: const Icon(Icons.sort, size: 30),
                ),
                actions: [
                  PopupMenuButton<int>(
                    onSelected: (_) => _confirmDeleteAll(),
                    color: ConstantColor.deepTeal,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    iconSize: 30,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text(
                          LocaleKeys.deleteAll.tr(),
                          style: const TextStyle(
                            color: ConstantColor.pureWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              floatingActionButton: RectGetter(
                key: _fabKey,
                child: FloatingActionButton(
                  onPressed: _openCreate,
                  tooltip: LocaleKeys.saveEvent.tr(),
                  child: const Icon(Icons.add),
                ),
              ),
              body: _EventList(onOpen: _openDetail),
            ),
            if (_splash case final rect?)
              AnimatedPositioned.fromRect(
                duration: _splashDuration,
                rect: rect,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ConstantColor.normalOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.onOpen});

  final ValueChanged<EventModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventStore>().events;
    final stacked = context.select<SettingsStore, bool>((s) => s.stackedList);
    if (events.isEmpty) return const _EmptyState();

    Widget card(EventModel e) => GestureDetector(
      key: ValueKey(e.key),
      onTap: () => onOpen(e),
      child: EventCard(event: e),
    );

    return Padding(
      padding: context.paddingLow,
      child: stacked
          ? StackedCardCarousel(
              initialOffset: 0,
              spaceBetweenItems: 190,
              items: [for (final e in events) card(e)],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [for (final e in events) card(e)],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context); // rebuild once new strings load
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: Text(LocaleKeys.thereIsNoEvent.tr())),
        Positioned(
          bottom: 50,
          right: 80,
          child: Column(
            children: [
              Text(
                LocaleKeys.addFromHere.tr(),
                style: const TextStyle(color: ConstantColor.transparentGrey),
              ),
              Image.asset(
                '${PathService.IMAGE_BASE_PATH}curly-arrow.png',
                scale: 1.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// iOS can only link to the App Store once [ConstantText.appStoreId] is set.
bool get canRate =>
    defaultTargetPlatform != TargetPlatform.iOS ||
    ConstantText.appStoreId.isNotEmpty;

String get storeLink =>
    defaultTargetPlatform == TargetPlatform.iOS &&
        ConstantText.appStoreId.isNotEmpty
    ? ConstantText.appStoreLink
    : ConstantText.playStoreLink;

Future<void> openStoreReview() => launchUrl(
  Uri.parse(
    defaultTargetPlatform == TargetPlatform.iOS
        ? ConstantText.appStoreReviewLink
        : ConstantText.playStoreLink,
  ),
  mode: LaunchMode.externalApplication,
);
