import 'package:flutter/material.dart';

class GratitudeJournalPopup extends StatefulWidget {
  final VoidCallback onClose;

  const GratitudeJournalPopup({super.key, required this.onClose});

  @override
  State<GratitudeJournalPopup> createState() => _GratitudeJournalPopupState();
}

class _GratitudeJournalPopupState extends State<GratitudeJournalPopup> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    // Ideally save the gratitude entry here
    // For now, just close
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2E6), // Match paper color
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gratitude Journal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                      fontFamily: 'Serif', // Gives it a journal feel
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF4A4A4A)),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'What are you grateful for right now?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A6A6A),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'I am grateful for...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
