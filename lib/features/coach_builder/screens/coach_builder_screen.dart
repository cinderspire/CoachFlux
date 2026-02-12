import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/constants/app_constants.dart';

class CoachBuilderScreen extends StatefulWidget {
  const CoachBuilderScreen({super.key});

  @override
  State<CoachBuilderScreen> createState() => _CoachBuilderScreenState();
}

class _CoachBuilderScreenState extends State<CoachBuilderScreen> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  String _emoji = '🤖';
  String _personality = 'warm';
  String _category = 'Productivity';
  final Set<String> _expertise = {};
  final _expertiseController = TextEditingController();

  final _emojis = ['🤖', '🧠', '🌟', '🦊', '🎯', '🌿', '⚡', '🔮', '🦉', '🐺', '🌊', '🎭'];
  final _personalities = ['warm', 'direct', 'analytical', 'playful', 'empathetic'];

  void _addExpertise() {
    final tag = _expertiseController.text.trim();
    if (tag.isNotEmpty && _expertise.length < 6) {
      setState(() {
        _expertise.add(tag);
        _expertiseController.clear();
      });
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for your coach')),
      );
      return;
    }
    final coach = Coach(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      emoji: _emoji,
      title: _titleController.text.trim().isEmpty ? 'Custom Coach' : _titleController.text.trim(),
      expertise: _expertise.toList(),
      personality: _personality,
      systemPrompt: _promptController.text.trim().isEmpty
          ? 'You are ${_nameController.text.trim()}, a helpful coach.'
          : _promptController.text.trim(),
      color: AppColors.primaryPeach,
      category: _category,
      createdBy: 'user',
    );
    Navigator.pop(context, coach);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _promptController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Coach', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            _buildPreview(),
            const SizedBox(height: 32),

            // Emoji picker
            Text('Avatar', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emojis.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryPeach.withValues(alpha: 0.15)
                          : AppColors.backgroundDarkElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Name
            _label('Name'),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
              decoration: const InputDecoration(hintText: 'e.g. ZenMaster'),
            ),
            const SizedBox(height: 20),

            // Title
            _label('Title'),
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
              decoration: const InputDecoration(hintText: 'e.g. Mindfulness & Focus Coach'),
            ),
            const SizedBox(height: 20),

            // Category
            _label('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.coachCategories.map((cat) {
                final active = cat == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryPeach.withValues(alpha: 0.15)
                          : AppColors.backgroundDarkElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(cat,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: active ? AppColors.primaryPeach : AppColors.textSecondaryDark)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Expertise tags
            _label('Expertise'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expertiseController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                    decoration: const InputDecoration(hintText: 'Add a tag'),
                    onSubmitted: (_) => _addExpertise(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addExpertise,
                  icon: const Icon(Icons.add_rounded, color: AppColors.primaryPeach),
                ),
              ],
            ),
            if (_expertise.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _expertise.map((t) => Chip(
                  label: Text(t, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryDark)),
                  backgroundColor: AppColors.backgroundDarkElevated,
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _expertise.remove(t)),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 20),

            // Personality
            _label('Personality'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _personality,
              dropdownColor: AppColors.backgroundDarkElevated,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
              items: _personalities.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p[0].toUpperCase() + p.substring(1)),
              )).toList(),
              onChanged: (v) => setState(() => _personality = v!),
            ),
            const SizedBox(height: 20),

            // System prompt
            _label('System Prompt'),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe how your coach should behave...',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark));

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryPeach.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'Your Coach' : _nameController.text,
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _titleController.text.isEmpty ? 'Custom Coach' : _titleController.text,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiarySage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_category,
                      style: AppTextStyles.caption.copyWith(color: AppColors.tertiarySage)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
