import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/paragraph_result.dart';

class PendingParagraphsSheet extends StatelessWidget {
  const PendingParagraphsSheet({super.key});

  void _showParagraphDialog(BuildContext context, ParagraphResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Generated Paragraph'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Words: ${result.words.join(", ")}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(result.paragraph ?? 'No paragraph available'),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${result.promptType}\nAudience: ${result.targetAudience}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.pendingParagraphs.length,
          itemBuilder: (context, index) {
            final result = provider.pendingParagraphs[index];
            return ListTile(
              title: Text(result.words.join(", ")),
              subtitle: Text(
                result.isPending ? 'Pending...' : 'Ready to view',
                style: TextStyle(
                  color: result.isPending ? Colors.orange : Colors.green,
                ),
              ),
              trailing:
                  result.isPending
                      ? const CircularProgressIndicator()
                      : IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showParagraphDialog(context, result),
                      ),
            );
          },
        );
      },
    );
  }
}
