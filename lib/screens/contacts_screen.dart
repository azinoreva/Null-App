import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../engine/database/app_database.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/contact_card.dart';
import '../widgets/display/navigation.dart';
import 'modals/get_contact_modal.dart';
import 'modals/friend_request_list.dart';
import '../engine/media_handling/connection_scan_service.dart';
import '../engine/functions/people/networkfxn.dart' as network_functions;
import '../engine/network/people/pick_contact.dart';
import 'modals/share_contact_modal.dart';
import 'chat_screen.dart';
import 'chatting.dart';
import 'settings_screen.dart';
import 'updates_screen.dart';

/// Contacts screen: contact list owned by Riverpod ([contactsProvider]) and
/// kept alive, so leaving the screen and returning renders the cached
/// contacts instantly.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  List<ContactsNetworkData> _networks = const [];
  Set<String> _networkContactIds = const {};
  String? _selectedNetworkId;

  Future<void> _loadNetworks() async {
    final database = ref.read(appDatabaseProvider);
    final networks = await database.contactsNetworkDao.getAllNetworks();
    if (!mounted) return;
    setState(() => _networks = networks);
  }

  Future<void> _selectNetwork(String? networkId) async {
    if (networkId == null) {
      setState(() {
        _selectedNetworkId = null;
        _networkContactIds = const {};
      });
      return;
    }
    final ids = await ref
        .read(appDatabaseProvider)
        .contactNetworkMembersDao
        .getContactIdsInNetwork(networkId);
    if (!mounted) return;
    setState(() {
      _selectedNetworkId = networkId;
      _networkContactIds = ids.toSet();
    });
  }

  Future<void> _createNetwork() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Network'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Network name'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;

    final serverId = _networks.isEmpty ? 'local' : _networks.first.serverId;
    final networkId = await network_functions.createContactNetwork(
      ref.read(appDatabaseProvider).contactsNetworkDao,
      networkName: name,
      serverId: serverId,
    );
    await _loadNetworks();
    await _selectNetwork(networkId);
  }

  Future<void> _openContactChat(ContactData contact) async {
    final database = ref.read(appDatabaseProvider);
    final conversation = await database.conversationsDao.getConversationById(
      contact.contactId,
    );
    if (conversation == null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await database.conversationsDao.upsertConversation(
        Conversation(
          conversationId: contact.contactId,
          conversationType: 0,
          lastMessageId: null,
          lastMessageTime: null,
          unreadCount: 0,
          muted: 0,
          pinned: 0,
          archived: 0,
          draft: null,
          serverId: contact.serverId,
          createdAt: now,
          updatedAt: now,
          sound: null,
          badge: 0,
          vibration: 0,
        ),
      );
    }
    final taskServer = await database.serversDao.getServerById(
      contact.serverId,
    );
    await ref
        .read(taskQueueProvider)
        .queueTask(
          functionName: 'ensureDhFlow',
          args: [contact.contactId, contact.serverId],
          serverId: taskServer == null ? null : contact.serverId,
        );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Chatting(
          conversationId: contact.contactId,
          displayName: contact.displayName,
          avatarUrl: contact.avatarUrl,
          status: contact.isOnline,
          conversationType: 0,
        ),
      ),
    );
  }

  Future<void> _deleteContact(ContactData contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text(
          'Remove ${contact.displayName} and its conversation from this device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final database = ref.read(appDatabaseProvider);
    await database.transaction(() async {
      final tasks = await database.tasksDao.getIncompleteTasks();
      for (final task in tasks) {
        if (task.functionName == 'ensureDhFlow' &&
            task.functionArgs.contains(contact.contactId)) {
          await database.tasksDao.deleteTask(task.taskId);
        }
      }
      await (database.delete(database.conversations)..where(
            (conversation) =>
                conversation.conversationId.equals(contact.contactId),
          ))
          .go();
      await database.contactsDao.deleteContact(contact.contactId);
    });
    await ref.read(contactsProvider.notifier).refresh();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(pendingContactsProvider.notifier).checkInbox());
      unawaited(_loadNetworks());
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);
    final pendingContacts =
        ref.watch(pendingContactsProvider).value ?? const <ReceivedContact>[];

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
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }
      },
      child: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load contacts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Theme.of(context)
                      .extension<AppColorScheme>()
                      ?.textInputColor ??
                  AppColorScheme.dark.textInputColor,
            ),
          ),
        ),
        data: (rows) => ContactsListScreen(
          contacts: _selectedNetworkId == null
              ? rows
              : rows
                    .where(
                      (contact) =>
                          _networkContactIds.contains(contact.contactId),
                    )
                    .toList(growable: false),
          networks: _networks,
          selectedNetworkId: _selectedNetworkId,
          onNetworkSelected: _selectNetwork,
          onCreateNetwork: _createNetwork,
          pendingContacts: pendingContacts,
          onOpenPendingContacts: () => _openPendingContacts(pendingContacts),
          onOpenContactChat: _openContactChat,
          onLongPressContact: _showContactActions,
          onAddContact: () async {
            final added = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.9,
                child: AddConnectionScreen(
                  onConnectionScanned: (raw, {required isManualPin}) async {
                    await receiveContact(
                      database: ref.read(appDatabaseProvider),
                      taskQueue: ref.read(taskQueueProvider),
                      scannedValue: raw,
                      isManualPin: isManualPin,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  onShareContact: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => ShareContactModal(
                        database: ref.read(appDatabaseProvider),
                        taskQueue: ref.read(taskQueueProvider),
                      ),
                    );
                  },
                ),
              ),
            );
            if (added == true && context.mounted) {
              await ref.read(contactsProvider.notifier).refresh();
            }
          },
          onOpenSettings: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ),
    );
  }

  Future<void> _openPendingContacts(List<ReceivedContact> contacts) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FriendRequestsListModal(
        requests: contacts.map(_toRequestData).toList(growable: false),
        onAcceptRequest: (request) async {
          await ref
              .read(pendingContactsProvider.notifier)
              .accept(_toReceivedContact(request));
          await ref.read(contactsProvider.notifier).refresh();
        },
        onDeclineRequest: (request) => ref
            .read(pendingContactsProvider.notifier)
            .decline(_toReceivedContact(request)),
        onAcceptAll: () async {
          for (final contact in contacts) {
            await ref.read(pendingContactsProvider.notifier).accept(contact);
          }
          await ref.read(contactsProvider.notifier).refresh();
        },
        onDeclineAll: () async {
          for (final contact in contacts) {
            await ref.read(pendingContactsProvider.notifier).decline(contact);
          }
        },
      ),
    );
  }

  Future<void> _showContactActions(ContactData contact) async {
    final action = await showModalBottomSheet<_ContactAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit contact'),
              onTap: () => Navigator.pop(sheetContext, _ContactAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_outlined),
              title: const Text('Add to Network'),
              onTap: () => Navigator.pop(sheetContext, _ContactAction.network),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete contact'),
              onTap: () => Navigator.pop(sheetContext, _ContactAction.delete),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case _ContactAction.edit:
        await _editContact(contact);
      case _ContactAction.network:
        await _addContactToNetwork(contact);
      case _ContactAction.delete:
        await _deleteContact(contact);
      case null:
        break;
    }
  }

  Future<void> _editContact(ContactData contact) async {
    final nameController = TextEditingController(text: contact.displayName);
    final bioController = TextEditingController(text: contact.bio);
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save != true || !mounted) {
      nameController.dispose();
      bioController.dispose();
      return;
    }
    final database = ref.read(appDatabaseProvider);
    await (database.update(database.contacts)..where(
          (contactRow) => contactRow.contactId.equals(contact.contactId),
        ))
        .write(
          ContactsCompanion(
            nickname: Value(nameController.text.trim()),
            bio: Value(bioController.text.trim()),
          ),
        );
    nameController.dispose();
    bioController.dispose();
    await ref.read(contactsProvider.notifier).refresh();
  }

  Future<void> _addContactToNetwork(ContactData contact) async {
    if (_networks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create a Network before adding contacts.'),
          ),
        );
      }
      return;
    }
    final networkId = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final network in _networks)
              ListTile(
                leading: const Icon(Icons.circle_outlined),
                title: Text(network.networkName),
                onTap: () => Navigator.pop(sheetContext, network.networkId),
              ),
          ],
        ),
      ),
    );
    if (networkId == null || !mounted) return;
    try {
      await ref
          .read(appDatabaseProvider)
          .contactNetworkMembersDao
          .addMember(networkId, contact.contactId);
      if (_selectedNetworkId == networkId) await _selectNetwork(networkId);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact is already in that Network.')),
      );
    }
  }

  FriendRequestData _toRequestData(ReceivedContact contact) {
    final avatarUrl = contact.avatar == null || contact.avatar!.isEmpty
        ? 'https://api.dicebear.com/7.x/avataaars/png?seed='
              '${Uri.encodeComponent(contact.contactId)}&size=128'
        : 'data:image/png;base64,${contact.avatar}';
    return FriendRequestData(
      contactId: contact.contactId,
      serverId: contact.serverId,
      publicKey: contact.publicKey,
      dhPublicKey: contact.dhPublicKey,
      avatarUrl: avatarUrl,
      name: contact.nickname,
      title: contact.title,
      bio: contact.bio,
    );
  }

  ReceivedContact _toReceivedContact(FriendRequestData request) {
    final avatar = request.avatarUrl.startsWith('data:image/png;base64,')
        ? request.avatarUrl.substring('data:image/png;base64,'.length)
        : null;
    return ReceivedContact(
      contactId: request.contactId,
      serverId: request.serverId,
      nickname: request.name,
      title: request.title,
      bio: request.bio,
      publicKey: request.publicKey,
      dhPublicKey: request.dhPublicKey,
      avatar: avatar,
    );
  }
}

enum _ContactAction { edit, network, delete }

/// Contacts list screen: title row, search field, and a floating add-contact button,
/// and an alphabetically-grouped contact list built entirely from [contacts].
///
/// This screen does NOT include the bottom navbar - it's meant to be wrapped
/// by whatever navbar container you already have.
class ContactsListScreen extends StatefulWidget {
  final List<ContactData> contacts;
  final List<ContactsNetworkData> networks;
  final String? selectedNetworkId;
  final ValueChanged<String?>? onNetworkSelected;
  final VoidCallback? onCreateNetwork;
  final List<ReceivedContact> pendingContacts;
  final VoidCallback? onOpenPendingContacts;
  final VoidCallback? onAddContact;
  final VoidCallback? onOpenSettings;
  final Future<void> Function(ContactData contact)? onOpenContactChat;
  final Future<void> Function(ContactData contact)? onLongPressContact;

  const ContactsListScreen({
    super.key,
    required this.contacts,
    this.networks = const [],
    this.selectedNetworkId,
    this.onNetworkSelected,
    this.onCreateNetwork,
    this.pendingContacts = const [],
    this.onOpenPendingContacts,
    this.onAddContact,
    this.onOpenSettings,
    this.onOpenContactChat,
    this.onLongPressContact,
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

    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
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
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpenContactChat == null
                      ? null
                      : () => widget.onOpenContactChat!(contact),
                  onLongPress: widget.onLongPressContact == null
                      ? null
                      : () => widget.onLongPressContact!(contact),
                  child: ContactCard(
                    avatarUrl: contact.avatarUrl,
                    displayName: contact.displayName,
                    isOnline: contact.isOnline,
                  ),
                ),
              ),
              if (widget.onLongPressContact != null)
                IconButton(
                  tooltip: 'Contact options',
                  onPressed: () => widget.onLongPressContact!(contact),
                  icon: const Icon(Icons.more_vert),
                ),
            ],
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
                  if (widget.pendingContacts.isNotEmpty)
                    IconButton(
                      onPressed: widget.onOpenPendingContacts,
                      tooltip: 'Contact requests',
                      icon: Badge(
                        label: Text('${widget.pendingContacts.length}'),
                        backgroundColor: AppColors.lightGreen,
                        textColor: AppColors.pureWhite,
                        child: Icon(
                          Icons.person_add_alt_outlined,
                          color: theme.textInputColor,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: widget.onOpenSettings,
                    icon: Icon(
                      Icons.settings_outlined,
                      color: theme.textInputColor,
                    ),
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

              if (widget.networks.isNotEmpty ||
                  widget.onCreateNetwork != null) ...[
                SizedBox(
                  height: 42.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _NetworkFilterButton(
                        label: '+',
                        selected: false,
                        tooltip: 'Create Network',
                        onPressed: widget.onCreateNetwork ?? () {},
                      ),
                      _NetworkFilterButton(
                        label: 'All',
                        selected: widget.selectedNetworkId == null,
                        onPressed: () => widget.onNetworkSelected?.call(null),
                      ),
                      for (final network in widget.networks)
                        _NetworkFilterButton(
                          label: network.networkName,
                          selected:
                              widget.selectedNetworkId == network.networkId,
                          onPressed: () =>
                              widget.onNetworkSelected?.call(network.networkId),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],

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
            child: Icon(
              Icons.person_add_alt_outlined,
              color: theme.buttonContentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkFilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final String? tooltip;
  final VoidCallback onPressed;

  const _NetworkFilterButton({
    required this.label,
    required this.selected,
    this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final isCreateButton = label == '+';
    final displayLabel = label.length > 6
        ? '${label.substring(0, 6)}...'
        : label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: tooltip ?? label,
        child: SizedBox(
          width: isCreateButton ? 42.0 : null,
          height: 42.0,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: selected
                  ? theme.primaryGreen
                  : AppColors.mutedSlate,
              backgroundColor: selected
                  ? theme.primaryGreen.withAlpha(35)
                  : theme.border.withAlpha(90),
              shape: isCreateButton
                  ? const CircleBorder()
                  : const StadiumBorder(),
              padding: isCreateButton
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 14.0),
            ),
            child: Text(
              displayLabel.isEmpty ? '?' : displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
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
