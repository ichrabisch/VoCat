import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vocat_mobile/models/folder.dart';
import 'package:vocat_mobile/theme/app_theme.dart';
import 'package:vocat_mobile/widgets/language_app_bar.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard.dart';
import 'flashcard_study_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:vocat_mobile/services/auth_service.dart';
import 'package:vocat_mobile/models/word.dart';
import 'word_detail_screen.dart';
import 'dart:io';
import '../config/api_config.dart';
import 'package:vocat_mobile/widgets/pending_paragraphs_sheet.dart';
import 'package:vocat_mobile/screens/saved_paragraphs_screen.dart';
import 'package:vocat_mobile/screens/word_matching_game_screen.dart';
import 'package:vocat_mobile/screens/word_scramble_game_screen.dart';
import 'package:vocat_mobile/widgets/game_selection_sheet.dart';
import 'package:vocat_mobile/services/notification_service.dart';

class FlashcardListScreen extends StatefulWidget {
  final String? folderId;
  final String? folderName;

  const FlashcardListScreen({super.key, this.folderId, this.folderName});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final Set<Word> _selectedWords = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.folderId != null) {
      // Load words when entering a folder
      Provider.of<FlashcardProvider>(
        context,
        listen: false,
      ).getWordsInFolder(widget.folderId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: LanguageAppBar(
          isSearching: _isSearching,
          onSearchToggle: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
          searchController: _searchController,
          title: widget.folderName ?? 'Flashcardlar',
          onBackPressed:
              widget.folderId != null
                  ? () => Navigator.of(context).pop()
                  : null,
          currentSort: Provider.of<FlashcardProvider>(context).currentSort,
          onSortChanged: (SortOption option) {
            Provider.of<FlashcardProvider>(
              context,
              listen: false,
            ).setSortOption(option);
          },
          actions: [
            IconButton(
              icon: const Icon(Icons.notification_add, color: Colors.white),
              onPressed: () async {
                // Test immediate notification
                await NotificationService.showTestNotification();

                // Or test scheduled notification if you have a word
                final words = await Provider.of<FlashcardProvider>(
                  context,
                  listen: false,
                ).getWordsInFolder(widget.folderId ?? '');

                if (words.isNotEmpty) {
                  await NotificationService.scheduleTestNotification(
                    words.first,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Test notification scheduled for 5 seconds from now',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Consumer<FlashcardProvider>(
            builder: (context, provider, child) {
              var items = provider.getItemsInFolder(widget.folderId);

              if (_isSearching && _searchController.text.isNotEmpty) {
                final searchTerm = _searchController.text.toLowerCase();
                items =
                    items.where((item) {
                      if (item is Folder) {
                        return item.name.toLowerCase().contains(searchTerm);
                      } else if (item is Word) {
                        return item.wordText.toLowerCase().contains(searchTerm);
                      }
                      return false;
                    }).toList();
              }

              return ListView.separated(
                key: ValueKey(provider.currentSort),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is Folder) {
                    return _buildFolderTile(context, item, provider);
                  } else if (item is Word) {
                    return _buildWordTile(item);
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'saved',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedParagraphsScreen(),
                    ),
                  ),
              child: const Icon(Icons.book),
            ),
            const SizedBox(width: 8),
            if (_isSelectionMode)
              FloatingActionButton.extended(
                heroTag: 'generate',
                onPressed: _generateParagraph,
                label: const Text('Generate Paragraph'),
                icon: const Icon(Icons.auto_stories),
              )
            else
              FloatingActionButton(
                heroTag: 'add',
                onPressed: () => _showAddOptions(context),
                backgroundColor: AppTheme.accentColor,
                child: const Icon(Icons.add),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildFolderTile(
    BuildContext context,
    Folder folder,
    FlashcardProvider provider,
  ) {
    final folderCards =
        provider.flashcards
            .where((card) => card.folderId == folder.folderId)
            .toList();
    final count = folderCards.length;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.folder_outlined),
      title: Text(
        folder.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text('$count kelime'),
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showFolderOptions(context, folder, folderCards),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FlashcardListScreen(
                  folderId: folder.folderId,
                  folderName: folder.name,
                ),
          ),
        );
      },
    );
  }

  Widget _buildWordTile(Word word) {
    final isSelected = _selectedWords.contains(word);
    final textColor = isSelected ? Colors.blue.shade700 : Colors.black87;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.15),
      selectedColor: Colors.blue.shade700,
      tileColor: isSelected ? Colors.blue.withOpacity(0.15) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:
            isSelected
                ? const BorderSide(color: Colors.blue, width: 2)
                : BorderSide.none,
      ),
      leading: Stack(
        children: [
          word.imageUrl != null
              ? Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(ApiConfig.getImageUrl(word.imageUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
              : const Icon(Icons.text_fields_outlined),
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Text(
        word.wordText,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word.translation,
            style: TextStyle(color: textColor.withOpacity(0.8)),
          ),
          if (word.definition != null)
            Text(
              word.definition!,
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Level ${word.masteryLevel}',
          style: const TextStyle(color: Colors.blue),
        ),
      ),
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _toggleWordSelection(word);
        });
      },
      onTap:
          _isSelectionMode
              ? () => _toggleWordSelection(word)
              : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(word: word),
                ),
              ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_outlined, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                const Text('New Folder'),
              ],
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Folder name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<FlashcardProvider>(
                      context,
                      listen: false,
                    ).createFolder(
                      controller.text,
                      parentFolderId: widget.folderId,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddFlashcardDialog(folderId: widget.folderId),
    );
  }

  void _showAddOptions(BuildContext context) {
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
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('New Folder'),
                  subtitle: const Text('Create a new category for words'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddFolderDialog(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.translate, color: Colors.green),
                  ),
                  title: const Text('New Word'),
                  subtitle: const Text('Add a new word to learn'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddCardDialog(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showFolderOptions(
    BuildContext context,
    Folder folder,
    List<Flashcard> folderCards,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.blue),
                ),
                title: const Text('Learn Words'),
                subtitle: const Text('Practice with flashcards'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FlashcardStudyScreen(cards: folderCards),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list_alt, color: Colors.green),
                ),
                title: const Text('Word List'),
                subtitle: const Text('View all words in this folder'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement word list view
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.games, color: Colors.purple),
                ),
                title: const Text('Play Games'),
                subtitle: const Text('Learn through games'),
                onTap: () async {
                  Navigator.pop(context);
                  final words = await Provider.of<FlashcardProvider>(
                    context,
                    listen: false,
                  ).getWordsInFolder(folder.folderId);

                  if (words.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No words available for games'),
                        ),
                      );
                    }
                    return;
                  }

                  if (mounted) {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => GameSelectionSheet(words: words),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
    );
  }

  void _toggleWordSelection(Word word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
        if (_selectedWords.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedWords.add(word);
      }
    });
  }

  Future<void> _generateParagraph() async {
    if (_selectedWords.isEmpty) return;

    String promptType = 'story';
    String targetAudience = 'general';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generate Paragraph'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: promptType,
                  decoration: const InputDecoration(
                    labelText: 'Prompt Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'story', child: Text('Story')),
                    DropdownMenuItem(
                      value: 'dialogue',
                      child: Text('Dialogue'),
                    ),
                    DropdownMenuItem(
                      value: 'description',
                      child: Text('Description'),
                    ),
                  ],
                  onChanged: (value) => promptType = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: targetAudience,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('Advanced'),
                    ),
                  ],
                  onChanged: (value) => targetAudience = value!,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(context, {
                      'promptType': promptType,
                      'targetAudience': targetAudience,
                    }),
                child: const Text('Generate'),
              ),
            ],
          ),
    );

    if (result != null && mounted) {
      try {
        final words = _selectedWords.map((w) => w.wordText).toList();
        final success = await Provider.of<FlashcardProvider>(
          context,
          listen: false,
        ).generateParagraph(
          words,
          promptType: result['promptType']!,
          targetAudience: result['targetAudience']!,
        );

        if (success && mounted) {
          setState(() {
            _selectedWords.clear();
            _isSelectionMode = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Paragraph generation started'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View',
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedParagraphsScreen(),
                      ),
                    ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start paragraph generation'),
            ),
          );
        }
      }
    }
  }

  void _showPendingResults(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const PendingParagraphsSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddFlashcardDialog extends StatefulWidget {
  final String? folderId;

  const AddFlashcardDialog({super.key, this.folderId});

  @override
  State<AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.translate, color: Colors.green),
                ),
                const SizedBox(width: 16),
                const Text('Add New Word', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Word',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Definition (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exampleController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Example Sentence (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _imageFile = null),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(
                  _imageFile!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _saveWord,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : Colors.green,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveWord() async {
    if (_wordController.text.isEmpty || _translationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both word and translation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = AuthService();
    final userId = await authService.getUserId();
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final word = Word(
        wordId: const Uuid().v4(),
        wordText: _wordController.text,
        translation: _translationController.text,
        definition:
            _definitionController.text.isNotEmpty
                ? _definitionController.text
                : null,
        exampleSentence:
            _exampleController.text.isNotEmpty ? _exampleController.text : null,
        folderId: widget.folderId ?? '',
        userId: userId,
        createdAt: DateTime.now(),
        lastReviewed: DateTime.now(),
        base64Image:
            _imageFile != null
                ? base64Encode(File(_imageFile!.path).readAsBytesSync())
                : null,
      );

      final success = await Provider.of<FlashcardProvider>(
        context,
        listen: false,
      ).createWord(word);

      if (success) {
        await Provider.of<FlashcardProvider>(
          context,
          listen: false,
        ).refreshData();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Word added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add word'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding word'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    super.dispose();
  }
}
