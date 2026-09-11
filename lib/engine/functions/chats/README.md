# `lib/engine/functions/chats` — Chat / Conversation Task Functions

Executable functions for sending, receiving, and negotiating encrypted
1-to-1 conversations.

| File | Purpose |
|---|---|
| `01_send_message.dart` | `sendChatMessage(...)` — encrypts plaintext with `NullCrypto.encryptMessage()` (advancing the sending ratchet), builds the wire payload (`chain_index`, `ciphertext`, `nonce`, `mac`), stores the message locally, and sends it via `SendMessageService`. AAD is bound to the `conversationId`. |
| `recieve_message.dart` | `receiveChatMessage(...)` — parse the wire payload, decrypt with `NullCrypto.decryptMessage()` (advancing the receiving ratchet), and persist (plaintext kept alongside ciphertext). Called from the SSE/pull flow. |
| `handshake.dart` | `startEncryptedConversation(...)` — the **initiator** side of the 2-phase handshake: ① sign a transcript and send the ephemeral DH public key, retrying with backoff until the peer replses; ② send an AES-GCM "ok null" confirmation once the symmetric key is stored. On success, marks the session established and clears the `HandshakeRegistry`. |
| `recieve_handshake.dart` | `handleIncomingHandshakeMessage(...)` — the **receiver** side for message types 0/1: verify the signature against the canonical transcript, derive the shared secret (X25519 ECDH), persist the key in `Sessions`, and signal the `HandshakeRegistry`. Also handles the "confirmation" message. |
| `handshake_registry.dart.dart` | ⚠️ note the double `.dart` extension. `HandshakeRegistry` — process-local `Completer`-based coordination so the initiator can await each handshake phase. |
| `conversation_function.dart` | Conversation CRUD for the DB: `createConversation`, `updateConversationFields`, `deleteConversationById`. |
| `22_contact.dart` | `receiveContactDetails(...)` — decrypts a received encrypted identity card (vCard), parses it, and saves/updates the contact row with `connectionStatus = 1`. |

## How sending actually works end-to-end

```
UI send → ChatInput.onSendMessage
       → (task engine) 01_send_message.dart
           → NullCrypto.encryptMessage (ratchet ✓)
           → SendMessageService POST /api/message
```

An established session is required first (`handshake.dart`); that state lives
in the `Sessions` table and the `SessionsDao`.