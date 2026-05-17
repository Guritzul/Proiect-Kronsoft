import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'exercise_detail_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _workoutDetails;
  List<dynamic> _allExercises = [];
  bool _loading = true;
  bool _loggingWholeWorkout = false;

  @override
  void initState() {
    super.initState();
    _loadWorkoutDetails();
  }

  Future<void> _loadWorkoutDetails() async {
    try {
      final results = await Future.wait([
        _api.getWorkoutById(widget.workout['_id']),
        _api.getExercises(),
      ]);
      if (mounted) {
        setState(() {
          _workoutDetails = results[0] as Map<String, dynamic>;
          _allExercises = results[1] as List<dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workout details: $e'),
            backgroundColor: context.appColors.dangerColor,
          ),
        );
      }
    }
  }

  Future<void> _logWholeWorkout() async {
    final exercises = _workoutDetails?['exercises'] as List?;
    if (exercises == null || exercises.isEmpty) return;

    setState(() => _loggingWholeWorkout = true);
    final colors = context.appColors;

    try {
      final futures = exercises.map((ex) {
        return _api.logExercise({
          'exerciseId': ex['_id'],
          'sets': ex['sets'] ?? 3,
          'repetitions': ex['repetitions'] ?? 15,
          'notes': 'Completed via "${_workoutDetails?['name'] ?? 'Workout'}" routine',
          'workoutName': _workoutDetails?['name'] ?? 'Workout',
        });
      }).toList();

      await Future.wait(futures);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout logged successfully! all ${exercises.length} exercises registered ✓'),
            backgroundColor: colors.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log workout exercises: $e'),
            backgroundColor: colors.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loggingWholeWorkout = false);
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
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(modalContext).viewInsets.bottom + 32),
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
                  'Log Exercise Activity',
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
                        () => setModalState(() { if (sets > 1) sets--; }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModalCounter(
                        'Reps',
                        reps,
                        () => setModalState(() => reps++),
                        () => setModalState(() { if (reps > 1) reps--; }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: context.appColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Add workout notes (optional)...',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                AccentButton(
                  label: 'Save Log Entry',
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
                        'workoutName': _workoutDetails?['name'] ?? 'Workout',
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
                          content: Text('Failed to log exercise: $e'),
                          backgroundColor: colors.dangerColor,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildModalCounter(String label, int value, VoidCallback onInc, VoidCallback onDec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: context.appColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('$value', style: TextStyle(color: context.appColors.accentColor, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: onDec,
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onInc,
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showEditWorkoutDialog() {
    final formKey = GlobalKey<FormState>();
    String name = _workoutDetails?['name'] ?? '';
    String description = _workoutDetails?['description'] ?? '';
    List<String> selectedIds = (_workoutDetails?['exercises'] as List?)
            ?.map((e) => e['_id'].toString())
            .toList() ??
        [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Workout Routine'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: 'Workout Name*',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      onSaved: (v) => name = v!.trim(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: description,
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
                          itemCount: _allExercises.length,
                          itemBuilder: (itemContext, i) {
                            final ex = _allExercises[i];
                            final id = ex['_id'] as String;
                            final isSelected = selectedIds.contains(id);
                            return CheckboxListTile(
                              title: Text(ex['name'] ?? '', style: const TextStyle(fontSize: 14)),
                              subtitle: Text(ex['bodyPart'] ?? '', style: const TextStyle(fontSize: 11)),
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
                      await _api.updateWorkout(widget.workout['_id'], {
                        'name': name,
                        'description': description,
                        'exercises': selectedIds,
                      });
                      navigator.pop();
                      _loadWorkoutDetails();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Workout updated successfully! ✓'),
                          backgroundColor: colors.successColor,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to update workout: $e'),
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
        }
      ),
    );
  }

  Future<void> _deleteWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: const Text('Are you sure you want to delete this workout routine? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.dangerColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final colors = context.appColors;
      try {
        await _api.deleteWorkout(widget.workout['_id']);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Workout routine deleted successfully'),
            backgroundColor: colors.successColor,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete workout: $e'),
            backgroundColor: colors.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _workoutDetails?['name'] ?? widget.workout['name'] ?? 'Workout';
    final description = _workoutDetails?['description'] ?? widget.workout['description'] ?? 'No description available.';

    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Workout',
            onPressed: _showEditWorkoutDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Workout',
            onPressed: _deleteWorkout,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accentColor,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                if (description.isNotEmpty) ...[
                  const SectionHeader(title: 'Workout Description'),
                  GlassCard(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SectionHeader(
                  title: 'Exercises (${_workoutDetails?['exercises']?.length ?? 0})',
                ),
                if (_workoutDetails == null ||
                    _workoutDetails!['exercises'] == null ||
                    (_workoutDetails!['exercises'] as List).isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 48,
                            color: context.appColors.textHint.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No exercises in this workout',
                            style: TextStyle(color: context.appColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (_workoutDetails!['exercises'] as List).length,
                    separatorBuilder: (sepContext, sepIndex) => const SizedBox(height: 12),
                    itemBuilder: (itemContext, i) {
                      final ex = _workoutDetails!['exercises'][i];
                      return _buildExerciseListItem(ex);
                    },
                  ),
                  const SizedBox(height: 32),
                  AccentButton(
                    label: 'Complete Workout Routine',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _loggingWholeWorkout,
                    onPressed: _logWholeWorkout,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildExerciseListItem(Map<String, dynamic> ex) {
    final name = ex['name'] ?? 'Exercise';
    final bodyPart = ex['bodyPart'] ?? '';
    final difficulty = ex['difficulty'] ?? 'medium';
    final sets = ex['sets'] ?? 3;
    final reps = ex['repetitions'] ?? 15;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.accentColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.appColors.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: context.appColors.accentColor,
            size: 22,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (bodyPart.isNotEmpty) ...[
                Text(
                  bodyPart.toUpperCase(),
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '•  $sets Sets x $reps Reps',
                style: TextStyle(
                  color: context.appColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DifficultyBadge(difficulty: difficulty),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_task_rounded, color: context.appColors.accentColor),
              onPressed: () => _showQuickLogBottomSheet(ex),
              tooltip: 'Quick Log Exercise',
              style: IconButton.styleFrom(
                backgroundColor: context.appColors.accentColor.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exercise: ex),
            ),
          ).then((value) => _loadWorkoutDetails());
        },
      ),
    );
  }
}
