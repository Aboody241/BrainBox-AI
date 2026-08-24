import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/rename_conversation_usecase.dart';
import '../../domain/usecases/toggle_pin_conversation_usecase.dart';
import 'conversation_card.dart';

class RecentChatsView extends StatefulWidget {
  const RecentChatsView({super.key});

  @override
  State<RecentChatsView> createState() => _RecentChatsViewState();
}

class _RecentChatsViewState extends State<RecentChatsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isSearchVisible = false;

  final List<ConversationItem> _conversations = [];

  static final List<ConversationItem> _fallbackSeedConversations = [
    ConversationItem(
      id: '1',
      title: 'Quantum Computing Concepts',
      lastMessage:
          'Quantum computing is a new type of computing that uses quantum mechanics to process information.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      isPinned: true,
    ),
    ConversationItem(
      id: '2',
      title: 'Flutter Clean Architecture Guide',
      lastMessage:
          'Let’s organize the data, domain, and presentation layers with strong separation of concerns.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isPinned: true,
    ),
    ConversationItem(
      id: '3',
      title: 'Tokyo 5-Day Travel Plan',
      lastMessage:
          'Here is your complete itinerary for exploring Shibuya, Asakusa, Akihabara, and Mount Fuji.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isPinned: false,
    ),
    ConversationItem(
      id: '4',
      title: 'Creative Story Ideas for Sci-Fi Novel',
      lastMessage:
          'In a world where memories can be transferred through neural synchronization...',
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isPinned: false,
    ),
    ConversationItem(
      id: '5',
      title: 'Weekly Workout & Nutrition Routine',
      lastMessage:
          'High protein meal plan combined with 4-day hypertrophy split focus.',
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPinned: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    if (sl.isRegistered<GetConversationsUseCase>()) {
      final getUseCase = sl<GetConversationsUseCase>();
      final result = await getUseCase();
      if (!mounted) return;

      result.when(
        success: (list) {
          setState(() {
            _conversations.clear();
            if (list.isEmpty) {
              _conversations.addAll(_fallbackSeedConversations);
            } else {
              _conversations.addAll(list.map(ConversationItem.fromEntity));
            }
          });
        },
        failure: (_) {
          if (_conversations.isEmpty) {
            setState(() {
              _conversations.addAll(_fallbackSeedConversations);
            });
          }
        },
      );
    } else {
      if (_conversations.isEmpty) {
        setState(() {
          _conversations.addAll(_fallbackSeedConversations);
        });
      }
    }
  }

  List<ConversationItem> get _filteredConversations {
    final query = _searchController.text.trim().toLowerCase();
    return _conversations.where((item) {
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.lastMessage.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'Pinned') {
        return item.isPinned;
      }
      return true;
    }).toList();
  }

  Map<String, List<ConversationItem>> _groupConversations(
      List<ConversationItem> items) {
    final Map<String, List<ConversationItem>> groups = {
      'TODAY': [],
      'YESTERDAY': [],
      'PREVIOUS 7 DAYS': [],
    };

    final now = DateTime.now();

    for (final item in items) {
      final diff = now.difference(item.updatedAt);
      if (diff.inDays == 0 && now.day == item.updatedAt.day) {
        groups['TODAY']!.add(item);
      } else if (diff.inDays <= 1) {
        groups['YESTERDAY']!.add(item);
      } else {
        groups['PREVIOUS 7 DAYS']!.add(item);
      }
    }

    return groups;
  }

  Future<void> _handlePinToggle(ConversationItem item) async {
    setState(() {
      item.isPinned = !item.isPinned;
    });

    if (sl.isRegistered<TogglePinConversationUseCase>()) {
      final toggleUseCase = sl<TogglePinConversationUseCase>();
      await toggleUseCase(item.id);
    }

    if (mounted) {
      AppSnackBar.showInfo(
        context,
        message: item.isPinned
            ? '"${item.title}" pinned to top'
            : '"${item.title}" unpinned',
      );
    }
  }

  Future<void> _handleDelete(ConversationItem item) async {
    setState(() {
      _conversations.remove(item);
    });

    if (sl.isRegistered<DeleteConversationUseCase>()) {
      final deleteUseCase = sl<DeleteConversationUseCase>();
      await deleteUseCase(item.id);
    }

    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        message: 'Conversation deleted',
      );
    }
  }

  Future<void> _handleRename(ConversationItem item, String newTitle) async {
    setState(() {
      item.title = newTitle;
    });

    if (sl.isRegistered<RenameConversationUseCase>()) {
      final renameUseCase = sl<RenameConversationUseCase>();
      await renameUseCase(item.id, newTitle);
    }

    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        message: 'Conversation renamed to "$newTitle"',
      );
    }
  }

  Future<void> _navigateToChat(String conversationId) async {
    await context.pushNamed(
      AppRoutes.chatName,
      pathParameters: {'id': conversationId},
    );
    await _loadConversations();
  }

  Future<void> _startNewChat() async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    await context.pushNamed(
      AppRoutes.chatName,
      pathParameters: {'id': newId},
    );
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;
    final grouped = _groupConversations(filtered);
    final hasItems = filtered.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Title, Search & New Chat Actions
        _buildHeader(context),

        const SizedBox(height: AppSpacing.sm),

        // Collapsible Animated Search Bar
        _buildAnimatedSearchBar(),

        // Filter Chips (All / Pinned)
        _buildFilterChips(),

        const SizedBox(height: AppSpacing.xs),

        // Grouped Conversations List or Empty State
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadConversations,
            color: AppColors.primary,
            child: hasItems
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xxl,
                    ),
                    children: [
                      if (grouped['TODAY']!.isNotEmpty)
                        _buildDateSection(
                          title: 'TODAY',
                          items: grouped['TODAY']!,
                        ),
                      if (grouped['YESTERDAY']!.isNotEmpty)
                        _buildDateSection(
                          title: 'YESTERDAY',
                          items: grouped['YESTERDAY']!,
                        ),
                      if (grouped['PREVIOUS 7 DAYS']!.isNotEmpty)
                        _buildDateSection(
                          title: 'PREVIOUS 7 DAYS',
                          items: grouped['PREVIOUS 7 DAYS']!,
                        ),
                    ],
                  )
                : _buildEmptyState(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent chats',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_conversations.length} conversation${_conversations.length == 1 ? '' : 's'} saved',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Toggle Button
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                  }
                });
              },
              icon: Icon(
                _isSearchVisible
                    ? Icons.search_off_rounded
                    : Icons.search_rounded,
                color: _isSearchVisible
                    ? AppColors.primary
                    : AppColors.textPrimary,
                size: 24,
              ),
              tooltip: 'Search conversations',
            ),
            const SizedBox(width: AppSpacing.xxs),

            // Start New Chat Button
            InkWell(
              onTap: _startNewChat,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'New Chat',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedSearchBar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: _isSearchVisible
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search chats by topic or message...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', _conversations.length),
            const SizedBox(width: AppSpacing.xs),
            _buildFilterChip(
              'Pinned',
              _conversations.where((c) => c.isPinned).length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
      checkmarkColor: isSelected ? Colors.white : AppColors.textSecondary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12.5,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildDateSection({
    required String title,
    required List<ConversationItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xs,
            left: 2,
          ),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...items.map(
          (conversation) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: ConversationCard(
              conversation: conversation,
              onTap: () => _navigateToChat(conversation.id),
              onPinToggle: () => _handlePinToggle(conversation),
              onDelete: () => _handleDelete(conversation),
              onRename: (newTitle) => _handleRename(conversation, newTitle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    isSearching
                        ? Icons.search_off_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 34,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isSearching ? 'No matching chats' : 'No conversations yet',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isSearching
                    ? 'Try searching with different keywords.'
                    : 'Start a new conversation with BrainBox AI and it will be saved here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!isSearching)
                AppButton(
                  text: 'Start New Chat',
                  onPressed: _startNewChat,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
