import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/app_theme.dart';
import '../../engine/media_handling/media_storage.dart';
import '../../widgets/buttons/send_button.dart';

enum _MediaKind { image, video, file }

/// "Automatic message" modal.
///
/// This widget is intentionally decoupled from AppSettings - it doesn't
/// read or write it directly. Instead:
///  - the caller passes in the current values ([initialMessage],
///    [initialMedia]) to seed the fields, and
///  - [onSave] is called with the final (text, media) once the user taps
///    "Save Message" - it's up to the caller (see
///    `AppSettings.editAutomaticMessage`) to actually persist that.
///
/// Newly-attached media is still copied into the app's internal media
/// folder via [MediaStorageService] as soon as it's picked, so whatever
/// ends up in [onSave]'s media list is always an internal path the app
/// owns - not a temp picker path or a remote URL.
class AutomaticMessageModal extends StatefulWidget {
  final String? initialMessage;
  final List<String> initialMedia;
  final Future<void> Function(String message, List<String> media) onSave;
  final VoidCallback? onCancel;

  const AutomaticMessageModal({
    super.key,
    this.initialMessage,
    this.initialMedia = const <String>[],
    required this.onSave,
    this.onCancel,
  });

  @override
  State<AutomaticMessageModal> createState() => _AutomaticMessageModalState();
}

class _AutomaticMessageModalState extends State<AutomaticMessageModal> {
  late final TextEditingController _messageController;
  late List<String> _attachedMedia;
  bool _isProcessingMedia = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage ?? '');
    _attachedMedia = List<String>.from(widget.initialMedia);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<String?> _pickMediaSource(_MediaKind kind) async {
    final type = switch (kind) {
      _MediaKind.image => FileType.image,
      _MediaKind.video => FileType.video,
      _MediaKind.file => FileType.any,
    };
    final result = await FilePicker.pickFiles(type: type);
    return result.isEmpty ? null : result.single.path;
  }

  Future<void> _handleAttach(_MediaKind kind) async {
    final sourceUrl = await _pickMediaSource(kind);
    if (sourceUrl == null) return;

    setState(() => _isProcessingMedia = true);
    try {
      final internalUrl = await MediaStorageService.copyMediaToInternalStorage(sourceUrl);
      if (!mounted) return;
      setState(() {
        _attachedMedia.add(internalUrl);
      });
    } catch (e) {
      // TODO: surface an error to the user if copying the media fails.
    } finally {
      if (mounted) setState(() => _isProcessingMedia = false);
    }
  }

  void _removeAttachedMedia(String path) {
    setState(() {
      _attachedMedia.remove(path);
    });
  }

  void _toggleEmojiPicker() {
    // TODO: show an emoji picker and insert the result into the message.
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleSaveMessage() async {
    setState(() => _isSaving = true);
    await widget.onSave(_messageController.text, _attachedMedia);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final fillColor = theme.border.withAlpha(90);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Automatic message',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _handleCancel,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          // Message content label
          Text(
            'MESSAGE CONTENT',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.mutedSlate,
            ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8.0),

          // Message text area
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 4,
              minLines: 4,
              cursorColor: theme.primaryGreen,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.body,
                color: theme.textInputColor,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(14.0),
                border: InputBorder.none,
              ),
            ),
          ),

          // Attached media chips
          if (_attachedMedia.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _attachedMedia.map((path) {
                final fileName = path.split(RegExp(r'[\\/]')).last;
                return Chip(
                  backgroundColor: fillColor,
                  label: Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: theme.textInputColor,
                    ),
                  ),
                  deleteIcon: Icon(Icons.close, size: 16.0, color: AppColors.mutedSlate),
                  onDeleted: () => _removeAttachedMedia(path),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 10.0),

          // Attachment icons + emoji
          Row(
            children: [
              if (_isProcessingMedia)
                SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: theme.primaryGreen,
                  ),
                )
              else ...[
                IconButton(
                  onPressed: () => _handleAttach(_MediaKind.image),
                  icon: Icon(Icons.image_outlined, color: AppColors.mutedSlate),
                  tooltip: 'Attach image',
                ),
                IconButton(
                  onPressed: () => _handleAttach(_MediaKind.video),
                  icon: Icon(Icons.videocam_outlined, color: AppColors.mutedSlate),
                  tooltip: 'Attach video',
                ),
                IconButton(
                  onPressed: () => _handleAttach(_MediaKind.file),
                  icon: Icon(Icons.attach_file, color: AppColors.mutedSlate),
                  tooltip: 'Attach file',
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: _toggleEmojiPicker,
                icon: Icon(Icons.emoji_emotions_outlined, color: AppColors.mutedSlate),
                tooltip: 'Emoji',
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          // Footer buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : _handleCancel,
                child: Text(
                  'Cancel',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              SendButton(
                text: 'Save Message',
                icon: Icons.send,
                iconPosition: IconPosition.left,
                isLocked: _isSaving,
                onPressed: _handleSaveMessage,
                textType: AppTextType.body,
              ),
            ],
          ),
        ],
      ),
    );
  }
}