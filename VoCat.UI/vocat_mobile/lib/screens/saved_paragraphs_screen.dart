import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import '../models/paragraph_result.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class SavedParagraphsScreen extends StatefulWidget {
  const SavedParagraphsScreen({super.key});

  @override
  State<SavedParagraphsScreen> createState() => _SavedParagraphsScreenState();
}

class _SavedParagraphsScreenState extends State<SavedParagraphsScreen> {
  Future<Map<String, List<ParagraphResult>>>? _paragraphsFuture;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadParagraphs();
  }

  void _loadParagraphs() {
    _paragraphsFuture = StorageService.getSavedParagraphs();
    setState(() {});
  }

  Future<void> _deleteParagraph(String words, ParagraphResult paragraph) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Paragraph'),
            content: const Text(
              'Are you sure you want to delete this paragraph?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await StorageService.deleteParagraph(words, paragraph);
      _loadParagraphs(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paragraph deleted')));
      }
    }
  }

  Widget _buildFormattedParagraph(String paragraph, List<String> words) {
    return RichText(
      text: TextSpan(
        children:
            paragraph.split(' ').map((word) {
              final cleanWord =
                  word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
              final isHighlighted = words
                  .map((w) => w.toLowerCase())
                  .contains(cleanWord);

              return TextSpan(
                text: '$word ',
                style: TextStyle(
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal,
                  color: isHighlighted ? AppTheme.accentColor : Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                ),
                recognizer:
                    isHighlighted
                        ? (TapGestureRecognizer()
                          ..onTap = () => _showWordInfo(context, cleanWord))
                        : null,
              );
            }).toList(),
      ),
    );
  }

  void _showWordInfo(BuildContext context, String word) async {
    // Get word info from provider
    final wordInfo = await Provider.of<FlashcardProvider>(
      context,
      listen: false,
    ).getWordByText(word);

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              word,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wordInfo != null) ...[
                  Text(
                    'Translation:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wordInfo.translation,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (wordInfo.definition != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Definition:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wordInfo.definition!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ] else
                    const Text('Word information not found'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _filterParagraphs(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  void _copyParagraph(String paragraph) {
    Clipboard.setData(ClipboardData(text: paragraph));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paragraph copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareParagraph(ParagraphResult result) async {
    try {
      await Share.share(
        '${result.paragraph}\n\nWords: ${result.words.join(", ")}\n'
        'Type: ${result.promptType} | Audience: ${result.targetAudience}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share paragraph')),
        );
      }
    }
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text);

    List<TextSpan> spans = [];
    int start = 0;
    String lowercaseText = text.toLowerCase();
    String lowercaseQuery = query.toLowerCase();

    while (true) {
      int index = lowercaseText.indexOf(lowercaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: WordAppBar(
          title: 'Saved Paragraphs',
          onBackPressed: () => Navigator.pop(context),
          isLoading: false,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filterParagraphs('');
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterParagraphs,
                  decoration: InputDecoration(
                    hintText: 'Search words or paragraphs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: FutureBuilder<Map<String, List<ParagraphResult>>>(
                  future: _paragraphsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No saved paragraphs',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Generate New Paragraph'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredData =
                        _searchQuery.isEmpty
                            ? snapshot.data!
                            : Map.fromEntries(
                              snapshot.data!.entries.where((entry) {
                                final wordsMatch = entry.key
                                    .toLowerCase()
                                    .contains(_searchQuery);
                                final paragraphsMatch = entry.value.any(
                                  (p) =>
                                      p.paragraph?.toLowerCase().contains(
                                        _searchQuery,
                                      ) ??
                                      false,
                                );
                                return wordsMatch || paragraphsMatch;
                              }),
                            );

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredData.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final words = filteredData.keys.elementAt(index);
                        final paragraphs = filteredData[words]!;

                        return ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.auto_stories,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          title:
                              _searchQuery.isEmpty
                                  ? Text(
                                    words,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                  : _buildHighlightedText(words, _searchQuery),
                          children:
                              paragraphs
                                  .map(
                                    (result) => InkWell(
                                      onLongPress:
                                          () => _deleteParagraph(words, result),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            result.paragraph != null
                                                ? _searchQuery.isEmpty
                                                    ? _buildFormattedParagraph(
                                                      result.paragraph!,
                                                      words.split(', '),
                                                    )
                                                    : _buildHighlightedText(
                                                      result.paragraph!,
                                                      _searchQuery,
                                                    )
                                                : const Text(
                                                  'No content',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    height: 1.5,
                                                  ),
                                                ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    result.promptType,
                                                    style: TextStyle(
                                                      color:
                                                          AppTheme.accentColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    result.targetAudience,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed:
                                                      () => _copyParagraph(
                                                        result.paragraph!,
                                                      ),
                                                  tooltip: 'Copy paragraph',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.share),
                                                  onPressed:
                                                      () => _shareParagraph(
                                                        result,
                                                      ),
                                                  tooltip: 'Share paragraph',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
