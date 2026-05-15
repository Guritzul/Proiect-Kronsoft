import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'exercise_detail_screen.dart';
import 'workout_history_screen.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
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
          difficulty: _selectedDifficulty,
          search: _searchController.text.trim(),
        ),
        _api.getFavoriteExercises(),
      ]);
      if (mounted) {
        setState(() {
          _exercises = results[0];
          _favorites = results[1];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.appColors.accentColor,
          labelColor: context.appColors.accentColor,
          unselectedLabelColor: context.appColors.textSecondary,
          tabs: const [Tab(text: 'All'), Tab(text: 'Favorites')],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_tabController.index == 0) _buildFilters(),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.accentColor,
                    ),
                  )
                : _tabController.index == 0
                    ? _buildExerciseGrid(_exercises)
                    : _buildExerciseGrid(_favorites, isFavorites: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _loadData(),
        style: TextStyle(color: context.appColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: Icon(Icons.search, color: context.appColors.textHint),
          filled: true,
          fillColor: context.appColors.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildFilterRow('Body Part', _bodyParts, _selectedBodyPart, (val) {
            setState(() => _selectedBodyPart = val == 'All' ? null : val);
            _loadData();
          }),
          const SizedBox(height: 8),
          _buildFilterRow('Difficulty', _difficulties, _selectedDifficulty,
              (val) {
            setState(() => _selectedDifficulty = val == 'All' ? null : val);
            _loadData();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, List<String> items, String? selected,
      Function(String) onSelect) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSelected = (selected == null && item == 'All') ||
              selected?.toLowerCase() == item.toLowerCase();
          return GestureDetector(
            onTap: () => onSelect(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.appColors.accentColor.withValues(alpha: 0.15)
                    : context.appColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? context.appColors.accentColor
                      : Colors.transparent,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: isSelected
                      ? context.appColors.accentColor
                      : context.appColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
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
              isFavorites ? Icons.favorite_border : Icons.fitness_center,
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final ex = list[i];
          final isFav = _favorites.any((f) => f['_id'] == ex['_id']);
          return _ExerciseCard(
            exercise: ex,
            isFavorite: isFav,
            onFavoriteToggle: () async {
              await _api.toggleFavoriteExercise(ex['_id']);
              _loadData();
            },
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
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  IconData get _bodyPartIcon {
    switch ((exercise['bodyPart'] ?? '').toString().toLowerCase()) {
      case 'forearm':
      case 'biceps':
      case 'triceps':
        return Icons.front_hand;
      case 'legs':
        return Icons.directions_walk;
      case 'back':
        return Icons.airline_seat_flat;
      case 'chest':
        return Icons.shield;
      case 'shoulders':
        return Icons.accessibility_new;
      case 'core':
        return Icons.circle;
      case 'neck':
        return Icons.face;
      case 'cardio':
        return Icons.favorite_border;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = exercise['name'] ?? 'Exercise';
    final bodyPart = exercise['bodyPart'] ?? '';
    final difficulty = exercise['difficulty'] ?? 'medium';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.appColors.surfaceColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.appColors.accentColor.withValues(alpha: 0.1),
                          context.appColors.surfaceColor,
                        ],
                      ),
                    ),
                    child: Icon(
                      _bodyPartIcon,
                      size: 44,
                      color:
                          context.appColors.accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (bodyPart.isNotEmpty)
                              Text(
                                bodyPart,
                                style: TextStyle(
                                  color: context.appColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            DifficultyBadge(difficulty: difficulty),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite
                      ? context.appColors.dangerColor
                      : context.appColors.textHint,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: context.appColors.cardColor.withValues(
                    alpha: 0.8,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
