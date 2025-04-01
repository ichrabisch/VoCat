import 'package:flutter/material.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';

class LanguageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final TextEditingController searchController;
  final String title;
  final VoidCallback? onBackPressed;
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;
  final List<Widget>? actions;

  const LanguageAppBar({
    super.key,
    required this.isSearching,
    required this.onSearchToggle,
    required this.searchController,
    required this.title,
    this.onBackPressed,
    required this.currentSort,
    required this.onSortChanged,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7393B3), Color(0xFF64B5F6)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  if (onBackPressed != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBackPressed,
                    ),
                  IconButton(
                    icon: Icon(
                      isSearching ? Icons.arrow_back : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: onSearchToggle,
                  ),
                  if (!isSearching) ...[
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showSortMenu(context),
                    ),
                  ] else
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search words...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      ),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            if (!isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildLanguageButton('Türkçe', true)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(child: _buildLanguageButton('English', false)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String language, bool isSource) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSource ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isSource ? Icons.arrow_drop_down : Icons.arrow_drop_up,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sort_by_alpha,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text('Sort Alphabetically'),
                  trailing: Radio<SortOption>(
                    value: SortOption.alphabetical,
                    groupValue: currentSort,
                    onChanged: (value) {
                      onSortChanged(value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('Sort by Date Created'),
                  trailing: Radio<SortOption>(
                    value: SortOption.dateCreated,
                    groupValue: currentSort,
                    onChanged: (value) {
                      onSortChanged(value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
