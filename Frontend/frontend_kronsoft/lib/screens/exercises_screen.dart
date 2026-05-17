import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'exercise_detail_screen.dart';
import 'workout_history_screen.dart';
import 'workout_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<dynamic> _exercises = [];
  List<dynamic> _favorites = [];
  List<dynamic> _workouts = [];
  bool _loading = true;

  String? _selectedBodyPart;
  String? _selectedDifficulty;

  final List<String> _bodyParts = [
    'All',
    'Forearm',
    'Biceps',
    'Triceps',
    'Back',
    'Legs',
    'Shoulders',
    'Chest',
    'Core',
    'Neck',
    'Cardio',
  ];
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getExercises(
          bodyPart: _selectedBodyPart?.toLowerCase(),
          difficulty: _selectedDifficulty?.toLowerCase(),
          search: _searchController.text.trim(),
        ),
        _api.getFavoriteExercises(),
        _api.getWorkouts(),
      ]);
      if (mounted) {
        setState(() {
          _exercises = results[0];
          _favorites = results[1];
          _workouts = results[2];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading exercises: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  void _showQuickLogBottomSheet(Map<String, dynamic> exercise) {
    int sets = exercise['sets'] ?? 3;
    int reps = exercise['repetitions'] ?? 15;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (stateContext, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: context.appColors.surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(modalContext).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Log Exercise',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['name'] ?? 'Exercise',
                  style: TextStyle(
                    color: context.appColors.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalCounter(
                        'Sets',
                        sets,
                        () => setModalState(() => sets++),
                        () => setModalState(() {
                          if (sets > 1) sets--;
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModalCounter(
                        'Reps',
                        reps,
                        () => setModalState(() => reps++),
                        () => setModalState(() {
                          if (reps > 1) reps--;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: context.appColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Add notes (optional)...',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                AccentButton(
                  label: 'Save Log',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final colors = context.appColors;

                    try {
                      await _api.logExercise({
                        'exerciseId': exercise['_id'],
                        'sets': sets,
                        'repetitions': reps,
                        'notes': notesController.text.trim(),
                      });
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('${exercise['name']} logged successfully! ✓'),
                          backgroundColor: colors.successColor,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to log: $e'),
                          backgroundColor: colors.dangerColor,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalCounter(
    String label,
    int value,
    VoidCallback onInc,
    VoidCallback onDec,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              color: context.appColors.accentColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: onDec,
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onInc,
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    String bodyPart = 'chest';
    String difficulty = 'medium';
    int sets = 3;
    int reps = 15;
    int duration = 5;
    String category = 'Strength';
    String mediaUrl = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: const Text('New Custom Exercise'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name*',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        onSaved: (v) => name = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description*',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        onSaved: (v) => description = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: bodyPart,
                        decoration: const InputDecoration(
                          labelText: 'Body Part',
                          prefixIcon: Icon(Icons.accessibility_new_rounded),
                        ),
                        items: _bodyParts
                            .where((e) => e != 'All')
                            .map((e) => DropdownMenuItem(
                                  value: e.toLowerCase(),
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => bodyPart = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          prefixIcon: Icon(Icons.speed_rounded),
                        ),
                        items: _difficulties
                            .where((e) => e != 'All')
                            .map((e) => DropdownMenuItem(
                                  value: e.toLowerCase(),
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => difficulty = v!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '3',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Sets'),
                              validator: (v) =>
                                  int.tryParse(v ?? '') == null ? 'Invalid' : null,
                              onSaved: (v) => sets = int.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: '15',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Reps'),
                              validator: (v) =>
                                  int.tryParse(v ?? '') == null ? 'Invalid' : null,
                              onSaved: (v) => reps = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: '5',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Minutes)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        validator: (v) =>
                            int.tryParse(v ?? '') == null ? 'Invalid' : null,
                        onSaved: (v) => duration = int.parse(v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: 'Strength',
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        onSaved: (v) => category = v?.trim() ?? 'Strength',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Video Explanation Link',
                          prefixIcon: Icon(Icons.video_library_outlined),
                          hintText: 'https://youtube.com/...',
                        ),
                        onSaved: (v) => mediaUrl = v?.trim() ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final colors = context.appColors;

                    try {
                      await _api.createExercise({
                        'name': name,
                        'description': description,
                        'bodyPart': bodyPart,
                        'difficulty': difficulty,
                        'sets': sets,
                        'repetitions': reps,
                        'durationMinutes': duration,
                        'category': category,
                        if (mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
                      });
                      navigator.pop();
                      _loadData();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Custom exercise "$name" created! ✓'),
                          backgroundColor: colors.successColor,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to create: $e'),
                          backgroundColor: colors.dangerColor,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateWorkoutDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    List<String> selectedIds = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: const Text('Create Custom Workout'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Workout Name*',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) => name = v!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 2,
                      onSaved: (v) => description = v?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Exercises*',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.appColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.appColors.divider),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _exercises.length,
                          itemBuilder: (itemContext, i) {
                            final ex = _exercises[i];
                            final id = ex['_id'] as String;
                            final isSelected = selectedIds.contains(id);
                            return CheckboxListTile(
                              title: Text(
                                ex['name'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                ex['bodyPart'] ?? '',
                                style: const TextStyle(fontSize: 11),
                              ),
                              value: isSelected,
                              activeColor: context.appColors.accentColor,
                              onChanged: (bool? val) {
                                setDialogState(() {
                                  if (val == true) {
                                    selectedIds.add(id);
                                  } else {
                                    selectedIds.remove(id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (selectedIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one exercise')),
                      );
                      return;
                    }
                    formKey.currentState!.save();
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final colors = context.appColors;

                    try {
                      await _api.createWorkout({
                        'name': name,
                        'description': description,
                        'exercises': selectedIds,
                      });
                      navigator.pop();
                      _loadData();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Workout routine "$name" created successfully! ✓'),
                          backgroundColor: colors.successColor,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to create workout: $e'),
                          backgroundColor: colors.dangerColor,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCapsuleTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCapsuleTabItem(0, 'All')),
          Expanded(child: _buildCapsuleTabItem(1, 'Favorites')),
          Expanded(child: _buildCapsuleTabItem(2, 'Workouts')),
        ],
      ),
    );
  }

  Widget _buildCapsuleTabItem(int index, String label) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.accentColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : context.appColors.textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutsList() {
    if (_workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_copy_rounded,
              size: 56,
              color: context.appColors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No workouts created yet',
              style: TextStyle(color: context.appColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateWorkoutDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create My Workout'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: context.appColors.accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _workouts.length,
        separatorBuilder: (sepContext, sepIndex) => const SizedBox(height: 16),
        itemBuilder: (listContext, i) {
          final w = _workouts[i];
          final exercisesCount = (w['exercises'] as List?)?.length ?? 0;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            borderColor: context.appColors.accentColor.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        w['name'] ?? 'Workout Routine',
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.appColors.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.appColors.accentColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        '$exercisesCount EXERCISES',
                        style: TextStyle(
                          color: context.appColors.accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (w['description'] != null && (w['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    w['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailScreen(workout: w),
                          ),
                        ).then((value) => _loadData());
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                      label: const Text(
                        'Start Routine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: const Text('Recovery Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
            ).then((value) => _loadData()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCapsuleTabBar(),
          _buildSearchBar(),
          if (_tabController.index == 0) ...[
            const SizedBox(height: 6),
            _buildBodyPartFilter(),
            const SizedBox(height: 10),
            _buildDifficultyFilter(),
            const SizedBox(height: 14),
          ],
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.accentColor,
                    ),
                  )
                : _tabController.index == 0
                    ? _buildExerciseGrid(_exercises)
                    : _tabController.index == 1
                        ? _buildExerciseGrid(_favorites, isFavorites: true)
                        : _buildWorkoutsList(),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddExerciseDialog,
              tooltip: 'Add Custom Exercise',
              child: const Icon(Icons.add_rounded),
            )
          : _tabController.index == 2
              ? FloatingActionButton(
                  onPressed: _showCreateWorkoutDialog,
                  tooltip: 'Create Custom Workout',
                  child: const Icon(Icons.playlist_add_rounded),
                )
              : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.appColors.accentColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.appColors.accentGlow.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (text) => _loadData(),
          style: TextStyle(color: context.appColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search exercises...',
            hintStyle: TextStyle(color: context.appColors.textHint, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: context.appColors.accentColor, size: 20),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyPartFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _bodyParts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final part = _bodyParts[i];
          final isSelected = (_selectedBodyPart == null && part == 'All') ||
              _selectedBodyPart?.toLowerCase() == part.toLowerCase();

          IconData icon;
          switch (part.toLowerCase()) {
            case 'all':
              icon = Icons.grid_view_rounded;
              break;
            case 'forearm':
            case 'biceps':
            case 'triceps':
              icon = Icons.fitness_center_rounded;
              break;
            case 'legs':
              icon = Icons.directions_run_rounded;
              break;
            case 'back':
              icon = Icons.accessibility_new_rounded;
              break;
            case 'shoulders':
              icon = Icons.sports_gymnastics_rounded;
              break;
            case 'chest':
              icon = Icons.shield_rounded;
              break;
            case 'core':
              icon = Icons.circle_outlined;
              break;
            case 'neck':
              icon = Icons.face_retouching_natural_rounded;
              break;
            case 'cardio':
              icon = Icons.favorite_rounded;
              break;
            default:
              icon = Icons.fitness_center_rounded;
          }

          return GestureDetector(
            onTap: () {
              setState(() => _selectedBodyPart = part == 'All' ? null : part);
              _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.appColors.accentColor
                    : context.appColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? context.appColors.accentColor
                      : context.appColors.accentColor.withValues(alpha: 0.1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.appColors.accentColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? Colors.white : context.appColors.accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    part,
                    style: TextStyle(
                      color: isSelected ? Colors.white : context.appColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: _difficulties.map((diff) {
          final isSelected = (_selectedDifficulty == null && diff == 'All') ||
              _selectedDifficulty?.toLowerCase() == diff.toLowerCase();
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDifficulty = diff == 'All' ? null : diff);
                _loadData();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.appColors.surfaceColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  diff,
                  style: TextStyle(
                    color: isSelected ? context.appColors.accentColor : context.appColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseGrid(List<dynamic> list, {bool isFavorites = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorites ? Icons.favorite_border_rounded : Icons.fitness_center_rounded,
              size: 56,
              color: context.appColors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              isFavorites ? 'No favorites yet' : 'No exercises found',
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: context.appColors.accentColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.88,
        ),
        itemCount: list.length,
        itemBuilder: (gridContext, i) {
          final ex = list[i];
          final isFav = _favorites.any((f) => f['_id'] == ex['_id']);
          return _ExerciseCard(
            exercise: ex,
            isFavorite: isFav,
            onFavoriteToggle: () async {
              await _api.toggleFavoriteExercise(ex['_id']);
              _loadData();
            },
            onLogPressed: () => _showQuickLogBottomSheet(ex),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: ex),
                ),
              );
              _loadData();
            },
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLogPressed;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onLogPressed,
    required this.onTap,
  });

  IconData get _bodyPartIcon {
    switch ((exercise['bodyPart'] ?? '').toString().toLowerCase()) {
      case 'forearm':
      case 'biceps':
      case 'triceps':
        return Icons.fitness_center_rounded;
      case 'legs':
        return Icons.directions_run_rounded;
      case 'back':
        return Icons.accessibility_new_rounded;
      case 'chest':
        return Icons.shield_rounded;
      case 'shoulders':
        return Icons.sports_gymnastics_rounded;
      case 'core':
        return Icons.circle_outlined;
      case 'neck':
        return Icons.face_retouching_natural_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return context.appColors.successColor;
      case 'medium':
        return context.appColors.warningColor;
      case 'hard':
        return context.appColors.dangerColor;
      default:
        return context.appColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = exercise['name'] ?? 'Exercise';
    final bodyPart = exercise['bodyPart'] ?? 'Custom';
    final difficulty = exercise['difficulty'] ?? 'medium';
    final sets = exercise['sets'] ?? 3;
    final reps = exercise['repetitions'] ?? 15;
    final duration = exercise['durationMinutes'] ?? 5;
    final diffColor = _getDifficultyColor(context, difficulty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.appColors.accentColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.appColors.accentGlow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.appColors.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _bodyPartIcon,
                          size: 16,
                          color: context.appColors.accentColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.appColors.accentColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 9, color: context.appColors.textHint),
                            const SizedBox(width: 3),
                            Text(
                              '${duration}m',
                              style: TextStyle(
                                color: context.appColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sets sets × $reps reps',
                    style: TextStyle(
                      color: context.appColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bodyPart.toUpperCase(),
                          style: TextStyle(
                            color: context.appColors.accentColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: diffColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            difficulty.toUpperCase(),
                            style: TextStyle(
                              color: diffColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.appColors.accentColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 12,
                        color: isFavorite
                            ? context.appColors.dangerColor
                            : context.appColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: onLogPressed,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.appColors.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.accentColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_task_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
