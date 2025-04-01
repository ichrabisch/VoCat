import 'package:flutter/material.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import '../models/word.dart';
import '../config/api_config.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _wordController.text = widget.word.wordText;
    _translationController.text = widget.word.translation;
    _definitionController.text = widget.word.definition ?? '';
    _exampleController.text = widget.word.exampleSentence ?? '';
  }

  Future<void> _updateWord() async {
    setState(() => _isLoading = true);
    try {
      final updatedWord = Word(
        wordId: widget.word.wordId,
        wordText: _wordController.text,
        translation: _translationController.text,
        definition: _definitionController.text,
        exampleSentence: _exampleController.text,
        folderId: widget.word.folderId,
        userId: widget.word.userId,
        createdAt: widget.word.createdAt,
        lastReviewed: widget.word.lastReviewed,
        masteryLevel: widget.word.masteryLevel,
        imageUrl: widget.word.imageUrl,
        base64Image:
            _imageFile != null
                ? base64Encode(_imageFile!.readAsBytesSync())
                : null,
      );

      final success = await Provider.of<FlashcardProvider>(
        context,
        listen: false,
      ).updateWord(updatedWord);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Word updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update word')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WordAppBar(
        title: 'Kelimeyi düzenle',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateWord,
            tooltip: 'Save',
          ),
        ],
        isLoading: _isLoading,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Word input field
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _wordController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('Transkripsiyon'),
                _buildActionButton('Örnek'),
                _buildActionButton('DeepL'),
              ],
            ),
            const SizedBox(height: 24),

            // Translation section
            TextField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: 'Translation',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _translationController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Definition',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _definitionController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exampleController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Example',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _exampleController.clear(),
                ),
              ),
            ),

            // Image section
            const SizedBox(height: 24),
            if (_imageFile != null || widget.word.imageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _imageFile != null
                            ? Image.file(
                              _imageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              ApiConfig.getImageUrl(widget.word.imageUrl!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        if (_imageFile != null)
                          IconButton(
                            onPressed: () => setState(() => _imageFile = null),
                            icon: const Icon(Icons.clear),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Image'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(text),
    );
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
