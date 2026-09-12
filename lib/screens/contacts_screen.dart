import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/contact_card.dart';
import '../widgets/display/navigation.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'updates_screen.dart';

/// Contacts screen: contact list owned by Riverpod ([contactsProvider]) and
/// kept alive, so leaving the screen and returning renders the cached
/// contacts instantly.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);

    return AdaptiveNavigationShell(
      currentTab: NavigationTab.contacts,
      onTabSelected: (tab) {
        if (tab == NavigationTab.contacts) return;
        if (tab == NavigationTab.chats) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
          return;
        }
        if (tab == NavigationTab.updates) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UpdatesScreen()),
          );
          return;
        }
        if (tab == NavigationTab.settings) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      child: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load contacts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                      .extension<AppColorScheme>()
                      ?.textInputColor ??
                  AppColorScheme.dark.textInputColor,
            ),
          ),
        ),
        data: (rows) => ContactsListScreen(
          contacts: rows,
          onOpenSettings: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ),
    );
  }
}

/// Contacts list screen: title row, search field, and a floating add-contact button,
/// and an alphabetically-grouped contact list built entirely from [contacts].
///
/// This screen does NOT include the bottom navbar - it's meant to be wrapped
/// by whatever navbar container you already have.
class ContactsListScreen extends StatefulWidget {
  final List<ContactData> contacts;
  final VoidCallback? onAddContact;
  final VoidCallback? onOpenSettings;

  const ContactsListScreen({
    super.key,
    required this.contacts,
    this.onAddContact,
    this.onOpenSettings,
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

    return Stack(
      children: [
        Container(
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
                onPressed: widget.onOpenSettings,
                icon: Icon(Icons.settings_outlined, color: theme.textInputColor),
                tooltip: 'Settings',
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
        ),
        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            onPressed: _handleAddContact,
            backgroundColor: theme.primaryGreen,
            tooltip: 'Add contact',
            child: Icon(Icons.person_add_alt_outlined, color: theme.buttonContentColor),
          ),
        ),
      ],
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

