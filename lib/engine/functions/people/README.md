# `lib/engine/functions/people` — Contact, Group & Network Functions

Executable task functions for managing people: contacts, connection
requests, groups, group members, contact networks (lists), and the user's own
profile.

| File | Purpose |
|---|---|
| `connection_request.dart` | Connection-request lifecycle for local DB: `createConnectionRequest` (generates a UUID, pending status, intro + expiry), `acceptConnectionRequest`, `rejectConnectionRequest` (also sweeps expired requests > 30 days). |
| `contact_invitation.dart` | `sendContactInvitation(identityDao, serverId)` — reads the user's public key and asks the server for an invite link/token via `SendContactService.generateInvite()`. |
| `save_contacts.dart` | `saveContact(...)` — insert-or-update a contact (avatar as BLOB, `connectionStatus` default 1 / pending). Sets `conversationId = contactId`. |
| `save_user_details.dart` | `saveProfile(...)` — partial update of the `Identity` row (display name / bio / avatar). |
| `sendmycontact.dart` | `sendContactDetails(...)` — builds the identity card JSON, encrypts it with the *current user's* own public key (sealed box), and ships it as message type 22 (vCard). `sendContactDetailsBack(...)` does the same but encrypts for the *recipient's* public key — completing a mutually exchanged vCard handshake. |
| `groupsfxn.dart` | Group CRUD: `createGroup` (UUID, current identity as owner, generates a symmetric group key via `GroupKey.generate()` for private groups, refuses public groups for now; resolves avatar via compression or Dicebear), `saveGroup` (`isOwner = 0`), `updateGroupFields` (owner-only gating on `ownerId` / `groupDesc`). |
| `group_membersfxn.dart` | Group-member CRUD: `createGroupMember`, `editGroupMember` (partial updates), `deleteGroupMember`. |
| `networkfxn.dart` | Contact-network (list) management: `createContactNetwork`, `addContactsToNetwork` (transactional bulk insert), `deleteNetworkAndMembers` (members first, then network, transactional), `removeContactFromNetwork`. |

All of these simply mutate the local Drift database through the DAOs in
`lib/engine/database/queries/`; anything requiring a server call delegates to
`lib/engine/network/`.