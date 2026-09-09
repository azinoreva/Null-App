import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/contact_card.dart';
import '../widgets/display/navigation.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  final List<ContactData> contacts;

  const ContactsScreen({
    super.key,
    this.contacts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationShell(
      currentTab: NavigationTab.contacts,
      onTabSelected: (tab) {
        if (tab == NavigationTab.chats) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        }
      },
      child: ContactsListScreen(contacts: contacts),
    );
  }
}

/// Simple data holder for one contact entry.
///
/// [displayName] follows the same "Name - Title" convention used by
/// [ContactCard] (e.g. "Alice Johnson - Product Designer").
class ContactData {
  final String avatarUrl;
  final String displayName;
  final int isOnline;

  const ContactData({
    required this.avatarUrl,
    required this.displayName,
    required this.isOnline,
  });

  /// Just the name portion, used for sorting / grouping by letter.
  String get name {
    final dashIndex = displayName.indexOf('-');
    return dashIndex == -1 ? displayName.trim() : displayName.substring(0, dashIndex).trim();
  }
}

/// Contacts list screen: title row, search field, "Add New Contact" button,
/// and an alphabetically-grouped contact list built entirely from [contacts].
///
/// This screen does NOT include the bottom navbar - it's meant to be wrapped
/// by whatever navbar container you already have.
class ContactsListScreen extends StatefulWidget {
  final List<ContactData> contacts;
  final VoidCallback? onAddContact;

  const ContactsListScreen({
    super.key,
    required this.contacts,
    this.onAddContact,
  });

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleAddContact() {
    if (widget.onAddContact != null) {
      widget.onAddContact!();
    }
    // else: no-op for now, wire up onAddContact from the parent when ready.
  }

  List<ContactData> get _filteredContacts {
    final filtered = _query.isEmpty
        ? List<ContactData>.from(widget.contacts)
        : widget.contacts
            .where((c) => c.displayName.toLowerCase().contains(_query))
            .toList();

    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final contacts = _filteredContacts;

    // Build a flat list of widgets: a letter-section header, then the
    // contacts under it, repeated per letter group.
    final List<Widget> listItems = [];
    String? currentLetter;
    for (final contact in contacts) {
      final letter = contact.name.isEmpty ? '#' : contact.name[0].toUpperCase();
      if (letter != currentLetter) {
        currentLetter = letter;
        listItems.add(_SectionHeader(letter: letter, theme: theme));
      }
      listItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ContactCard(
            avatarUrl: contact.avatarUrl,
            displayName: contact.displayName,
            isOnline: contact.isOnline,
          ),
        ),
      );
    }

    return Container(
      color: theme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),

          // Title row
          Row(
            children: [
              Icon(Icons.people_alt_outlined, color: theme.textInputColor),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Contacts',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _handleAddContact,
                icon: Icon(Icons.person_add_alt_outlined, color: theme.textInputColor),
                tooltip: 'Add contact',
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Search field
          TextField(
            controller: _searchController,
            style: AppTypography.getTextStyle(
              context,
              AppTextType.body,
              color: theme.textInputColor,
            ),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: AppTypography.getTextStyle(
                context,
                AppTextType.body,
                color: AppColors.mutedSlate,
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.mutedSlate),
              filled: true,
              fillColor: theme.border.withAlpha(90),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Add New Contact button (dashed outline)
          _DashedButton(
            onTap: _handleAddContact,
            theme: theme,
          ),
          const SizedBox(height: 12.0),

          // Contact list
          Expanded(
            child: listItems.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.body,
                        color: AppColors.mutedSlate,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    children: listItems,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String letter;
  final AppColorScheme theme;

  const _SectionHeader({required this.letter, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(90),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        letter,
        style: AppTypography.getTextStyle(
          context,
          AppTextType.tiny,
          color: AppColors.mutedSlate,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppColorScheme theme;

  const _DashedButton({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.0),
      child: CustomPaint(
        painter: _DashedRRectPainter(color: AppColors.mutedSlate, radius: 30.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add_alt_outlined, size: 18.0, color: AppColors.mutedSlate),
              const SizedBox(width: 8.0),
              Text(
                'Add New Contact',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.mutedSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedRRectPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) => false;
}