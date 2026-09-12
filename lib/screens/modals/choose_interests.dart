import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';
import '../../engine/functions/settings/categories.dart';

const int _kBatchSize = 5;

/// "What do you want to see?" interest-selection modal.
///
/// Decoupled from AppSettings, same as AutomaticMessageModal - it just
/// takes [initialSelected] to seed the picker and reports back via
/// [onDone]. Whoever presents it (e.g. an `AppSettings.editFeedControl`
/// style method) is responsible for persisting the result.
///
/// Behavior:
///  - Categories load [ _kBatchSize] (5) at a time as the user scrolls,
///    covering the full [Categories] enum.
///  - Tapping a row toggles it: selected rows stay in the list (highlighted
///    + checked) rather than disappearing, matching the mockup.
///  - Selecting a category bumps the remaining, not-yet-loaded categories
///    from the same [CategoryGroup] to the front of the queue, so the next
///    batch loaded favors "related" topics.
///  - Selected categories also show as removable chips up top; removing
///    one there just unchecks it (it stays in the list, unhighlighted).
class InterestSelectionModal extends StatefulWidget {
  final List<Categories> initialSelected;
  final Future<void> Function(List<Categories> selected) onDone;
  final VoidCallback? onSkip;

  const InterestSelectionModal({
    super.key,
    this.initialSelected = const <Categories>[],
    required this.onDone,
    this.onSkip,
  });

  @override
  State<InterestSelectionModal> createState() => _InterestSelectionModalState();
}

class _InterestSelectionModalState extends State<InterestSelectionModal> {
  final ScrollController _scrollController = ScrollController();
  late List<Categories> _selected;
  late List<Categories> _loaded;
  late List<Categories> _remainingPool;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = List<Categories>.from(widget.initialSelected);

    // Put any pre-selected categories at the front so they're visible (and
    // checked) as soon as the modal opens, matching the mockup.
    final ordered = List<Categories>.from(Categories.values)
      ..sort((a, b) {
        final aSel = _selected.contains(a) ? 0 : 1;
        final bSel = _selected.contains(b) ? 0 : 1;
        return aSel.compareTo(bSel);
      });

    _loaded = ordered.take(_kBatchSize).toList();
    _remainingPool = ordered.skip(_kBatchSize).toList();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _remainingPool.isEmpty) return;
    const threshold = 200.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_remainingPool.isEmpty) return;
    setState(() {
      final next = _remainingPool.take(_kBatchSize).toList();
      _loaded.addAll(next);
      _remainingPool.removeRange(0, next.length);
    });
  }

  void _toggleCategory(Categories c) {
    setState(() {
      if (_selected.contains(c)) {
        _selected.remove(c);
      } else {
        _selected.add(c);
        // Bump not-yet-loaded categories from the same group to the front
        // of the queue, so the next batch favors related topics.
        final sameGroup = _remainingPool.where((x) => x.group == c.group).toList();
        final others = _remainingPool.where((x) => x.group != c.group).toList();
        _remainingPool = [...sameGroup, ...others];
      }
    });
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleDone() async {
    setState(() => _isSaving = true);
    await widget.onDone(_selected);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

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
          // Logo row
          Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.explore_outlined, size: 18.0, color: theme.buttonContentColor),
              ),
              const SizedBox(width: 10.0),
              Text(
                'InterestFlow',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          Text(
            'What do you want to see?',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.largeTitle,
              color: theme.textInputColor,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Select your interests to personalize your feed.',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.body,
              color: AppColors.mutedSlate,
            ),
          ),
          const SizedBox(height: 16.0),

          // Selected chips
          if (_selected.isNotEmpty) ...[
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selected.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: theme.primaryGreen.withAlpha(45),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: theme.primaryGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.label,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.tiny,
                          color: theme.textInputColor,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6.0),
                      InkWell(
                        onTap: () => _toggleCategory(c),
                        customBorder: const CircleBorder(),
                        child: Icon(Icons.close, size: 14.0, color: theme.textInputColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
          ],

          // Category list (infinite scroll, 5 at a time)
          Flexible(
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: _loaded.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final category = _loaded[index];
                final isSelected = _selected.contains(category);
                return _CategoryRow(
                  theme: theme,
                  category: category,
                  isSelected: isSelected,
                  onTap: () => _toggleCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),

          Text(
            'Select your favorite topics to personalize your feed. You can change this later.',
            textAlign: TextAlign.center,
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.mutedSlate,
            ),
          ),
          const SizedBox(height: 12.0),

          SizedBox(
            width: double.infinity,
            child: SendButton(
              text: 'Done',
              icon: Icons.check,
              iconPosition: IconPosition.right,
              isLocked: _isSaving,
              onPressed: _handleDone,
              textType: AppTextType.body,
            ),
          ),
          const SizedBox(height: 4.0),
          Center(
            child: TextButton(
              onPressed: _isSaving ? null : _handleSkip,
              child: Text(
                'Skip for now',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.mutedSlate,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final AppColorScheme theme;
  final Categories category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.theme,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    const overrides = <Categories, IconData>{
      Categories.politics: Icons.public,
      Categories.technology: Icons.memory,
      Categories.music: Icons.music_note,
      Categories.business: Icons.show_chart,
      Categories.travel: Icons.flight,
    };
    final override = overrides[category];
    if (override != null) return override;

    switch (category.group) {
      case CategoryGroup.news:
        return Icons.newspaper_outlined;
      case CategoryGroup.business:
        return Icons.show_chart;
      case CategoryGroup.tech:
        return Icons.memory;
      case CategoryGroup.health:
        return Icons.favorite_border;
      case CategoryGroup.education:
        return Icons.school_outlined;
      case CategoryGroup.entertainment:
        return Icons.movie_outlined;
      case CategoryGroup.sports:
        return Icons.sports_soccer;
      case CategoryGroup.interests:
        return Icons.category_outlined;
      case CategoryGroup.society:
        return Icons.groups_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryGreen.withAlpha(40) : theme.border.withAlpha(70),
          borderRadius: BorderRadius.circular(16.0),
          border: isSelected ? Border.all(color: theme.primaryGreen) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryGreen : AppColors.mutedSlate.withAlpha(60),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                _icon,
                size: 16.0,
                color: isSelected ? theme.buttonContentColor : theme.textInputColor,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                category.label,
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: isSelected ? theme.textInputColor : AppColors.mutedSlate,
                ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (isSelected)
              Container(
                width: 22.0,
                height: 22.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14.0, color: theme.buttonContentColor),
              ),
          ],
        ),
      ),
    );
  }
}