import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';
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

  final List<ConversationItem> _conversations = [
    ConversationItem(
      id: '1',
      title: 'Quantum Computing Concepts',
      lastMessage:
          'Quantum computing is a new type of computing that uses quantum mechanics to process information.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      isPinned: true,
      icon: Icons.psychology_outlined,
      iconBgColor: const Color(0xFFE9EDF5),
      iconColor: const Color(0xFF2563EB),
    ),
    ConversationItem(
      id: '2',
      title: 'Flutter Clean Architecture Guide',
      lastMessage:
          'Let’s organize the data, domain, and presentation layers with strong separation of concerns.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isPinned: true,
      icon: Icons.code_rounded,
      iconBgColor: const Color(0xFFE6F4EA),
      iconColor: const Color(0xFF16A34A),
    ),
    ConversationItem(
      id: '3',
      title: 'Tokyo 5-Day Travel Plan',
      lastMessage:
          'Here is your complete itinerary for exploring Shibuya, Asakusa, Akihabara, and Mount Fuji.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isPinned: false,
      icon: Icons.flight_takeoff_rounded,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
    ),
    ConversationItem(
      id: '4',
      title: 'Creative Story Ideas for Sci-Fi Novel',
      lastMessage:
          'In a world where memories can be transferred through neural synchronization...',
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isPinned: false,
      icon: Icons.auto_stories_outlined,
      iconBgColor: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF9333EA),
    ),
    ConversationItem(
      id: '5',
      title: 'Weekly Workout & Nutrition Routine',
      lastMessage:
          'High protein meal plan combined with 4-day hypertrophy split focus.',
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPinned: false,
      icon: Icons.fitness_center_rounded,
      iconBgColor: const Color(0xFFFFE4E6),
      iconColor: const Color(0xFFE11D48),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _handlePinToggle(ConversationItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
    });
    AppSnackBar.showInfo(
      context,
      message: item.isPinned
          ? '"${item.title}" pinned to top'
          : '"${item.title}" unpinned',
    );
  }

  void _handleDelete(ConversationItem item) {
    setState(() {
      _conversations.remove(item);
    });

    AppSnackBar.showSuccess(
      context,
      message: 'Conversation deleted',
    );
  }

  void _handleRename(ConversationItem item, String newTitle) {
    setState(() {
      item.title = newTitle;
    });
    AppSnackBar.showSuccess(
      context,
      message: 'Renamed to "$newTitle"',
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;
    final grouped = _groupConversations(filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildHeaderBar(),

            // Search Bar (if expanded)
            if (_isSearchVisible) _buildSearchBar(),

            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: AppSpacing.xs),

            // Content List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedConversationsList(grouped),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.chatPath('new'));
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'New Chat',
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Chats',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
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
                  _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.push(AppRoutes.chatPath('new'));
                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            icon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pinned'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(
                filter == 'Pinned' ? 'Pinned 📌' : filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                ),
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupedConversationsList(
      Map<String, List<ConversationItem>> grouped) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      children: [
        for (final entry in grouped.entries)
          if (entry.value.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.xs,
                left: 4,
              ),
              child: Text(
                entry.key,
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            for (final item in entry.value)
              ConversationCard(
                conversation: item,
                onTap: () => context.push(AppRoutes.chatPath(item.id)),
                onPinToggle: () => _handlePinToggle(item),
                onDelete: () => _handleDelete(item),
                onRename: (newTitle) => _handleRename(item, newTitle),
              ),
          ],
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFECEEF1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 38,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Recent Chats',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Start a conversation with BrainBox AI to explore any topic or solve complex problems.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.chatPath('new'));
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Start New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
