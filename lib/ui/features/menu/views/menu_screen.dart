import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/menu.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/recipe_image.dart';
import '../view_models/menu_view_model.dart';

const _dayOrder = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];
const _mealOrder = ['lunch', 'dinner'];

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú semanal')),
      body: Consumer<MenuViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null && viewModel.menu == null) {
            return AppErrorView(error: viewModel.error!, onRetry: viewModel.load);
          }
          final menu = viewModel.menu;
          if (menu == null) {
            return EmptyState(
              icon: Icons.calendar_view_week_outlined,
              title: 'No hay ningún menú activo',
              subtitle: 'Activa un menú semanal desde la web para verlo aquí.',
              action: OutlinedButton(
                onPressed: viewModel.load,
                child: const Text('Actualizar'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: viewModel.load,
            child: _MenuGrid(menu: menu, viewModel: viewModel),
          );
        },
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.menu, required this.viewModel});

  final Menu menu;
  final MenuViewModel viewModel;

  Map<String, Map<String, List<MenuItem>>> _group() {
    final grouped = <String, Map<String, List<MenuItem>>>{
      for (final day in _dayOrder) day: {for (final meal in _mealOrder) meal: []},
    };
    for (final item in menu.items) {
      grouped.putIfAbsent(item.dayOfWeek, () => {for (final m in _mealOrder) m: []});
      grouped[item.dayOfWeek]!.putIfAbsent(item.mealType, () => []);
      grouped[item.dayOfWeek]![item.mealType]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(menu.name, style: Theme.of(context).textTheme.titleLarge),
        if (menu.activeWeekStart != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Semana del ${menu.activeWeekStart}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        for (final day in _dayOrder)
          _DaySection(
            dayLabel: _labelFor(grouped[day]!, day),
            meals: grouped[day]!,
            viewModel: viewModel,
          ),
      ],
    );
  }

  String _labelFor(Map<String, List<MenuItem>> meals, String dayKey) {
    for (final list in meals.values) {
      if (list.isNotEmpty) return list.first.dayLabel;
    }
    return _fallbackDayLabels[dayKey] ?? dayKey;
  }
}

const _fallbackDayLabels = {
  'monday': 'Lunes',
  'tuesday': 'Martes',
  'wednesday': 'Miércoles',
  'thursday': 'Jueves',
  'friday': 'Viernes',
  'saturday': 'Sábado',
  'sunday': 'Domingo',
};

const _fallbackMealLabels = {'lunch': 'Comida', 'dinner': 'Cena'};

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.dayLabel,
    required this.meals,
    required this.viewModel,
  });

  final String dayLabel;
  final Map<String, List<MenuItem>> meals;
  final MenuViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dayLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final meal in _mealOrder)
                _MealRow(
                  mealLabel: meals[meal]?.firstOrNull?.mealLabel ??
                      _fallbackMealLabels[meal]!,
                  items: meals[meal] ?? const [],
                  viewModel: viewModel,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.mealLabel,
    required this.items,
    required this.viewModel,
  });

  final String mealLabel;
  final List<MenuItem> items;
  final MenuViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(mealLabel, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: items.isEmpty
                ? Text('Sin receta', style: theme.textTheme.bodySmall)
                : Column(
                    children: items
                        .map((item) => _MenuItemTile(
                              item: item,
                              isMarking: viewModel.markingItemIds.contains(item.id),
                              onMarkCooked: () => viewModel.markItemCooked(item),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.isMarking,
    required this.onMarkCooked,
  });

  final MenuItem item;
  final bool isMarking;
  final VoidCallback onMarkCooked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/recetas/${item.recipe.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              RecipeImage(
                imageUrl: item.recipe.imageUrl,
                height: 36,
                width: 36,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.recipe.title,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isMarking)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    item.isCooked
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: item.isCooked ? theme.colorScheme.primary : null,
                  ),
                  onPressed: item.isCooked ? null : onMarkCooked,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
