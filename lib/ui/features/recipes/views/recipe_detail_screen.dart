import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/ingredient_line.dart';
import '../../../../data/models/recipe_detail.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/recipe_image.dart';
import '../view_models/recipe_detail_view_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeDetailViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.recipe == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.recipe == null) {
            return SafeArea(
              child: AppErrorView(
                error: viewModel.error ?? Exception('No se pudo cargar.'),
                onRetry: viewModel.reload,
              ),
            );
          }
          return _RecipeDetailBody(viewModel: viewModel);
        },
      ),
    );
  }
}

class _RecipeDetailBody extends StatelessWidget {
  const _RecipeDetailBody({required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final recipe = viewModel.recipe!;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: RecipeImage(
              imageUrl: recipe.imageUrl,
              borderRadius: BorderRadius.zero,
            ),
          ),
          actions: [
            IconButton(
              key: const ValueKey('recipe-detail-favorite'),
              onPressed: viewModel.isTogglingFavorite
                  ? null
                  : viewModel.toggleFavorite,
              icon: Icon(
                recipe.isFavorited
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: recipe.isFavorited ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(recipe.title, style: theme.textTheme.headlineSmall),
              if (recipe.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(recipe.description!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              _RatingRow(recipe: recipe, viewModel: viewModel),
              if (recipe.categories.isNotEmpty || recipe.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ChipsWrap(recipe: recipe),
              ],
              const SizedBox(height: 20),
              _InfoRow(recipe: recipe),
              const SizedBox(height: 20),
              _ServingsSelector(recipe: recipe, viewModel: viewModel),
              const SizedBox(height: 24),
              Text('Ingredientes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...recipe.ingredients.map((i) => _IngredientTile(ingredient: i)),
              const SizedBox(height: 24),
              Text('Instrucciones', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _Instructions(recipe: recipe),
              const SizedBox(height: 28),
              _Actions(recipe: recipe, viewModel: viewModel),
            ]),
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.recipe, required this.viewModel});

  final RecipeDetail recipe;
  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        RatingStars(
          rating: (recipe.myRating ?? 0).toDouble(),
          size: 24,
          onRate: viewModel.isRating ? null : viewModel.rate,
        ),
        const SizedBox(width: 10),
        if (recipe.averageRating != null)
          Text(
            '${recipe.averageRating!.toStringAsFixed(1)} '
            '(${recipe.ratingsCount ?? 0})',
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _ChipsWrap extends StatelessWidget {
  const _ChipsWrap({required this.recipe});

  final RecipeDetail recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...recipe.categories.map((c) => Chip(label: Text(c))),
        ...recipe.tags.map((t) => Chip(label: Text(t))),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.recipe});

  final RecipeDetail recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[
      if (recipe.difficultyLabel != null)
        _InfoItem(icon: Icons.bar_chart_rounded, label: recipe.difficultyLabel!),
      if (recipe.prepTimeMinutes != null)
        _InfoItem(
          icon: Icons.timer_outlined,
          label: 'Prep. ${recipe.prepTimeMinutes} min',
        ),
      if (recipe.cookTimeMinutes != null)
        _InfoItem(
          icon: Icons.soup_kitchen_outlined,
          label: 'Cocción ${recipe.cookTimeMinutes} min',
        ),
      _InfoItem(
        icon: Icons.restaurant_outlined,
        label: 'Cocinada ${recipe.timesCooked} veces',
      ),
    ];
    return DefaultTextStyle(
      style: theme.textTheme.bodySmall!,
      child: Wrap(spacing: 16, runSpacing: 8, children: items),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _ServingsSelector extends StatelessWidget {
  const _ServingsSelector({required this.recipe, required this.viewModel});

  final RecipeDetail recipe;
  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text('Raciones', style: theme.textTheme.titleSmall),
        const Spacer(),
        IconButton.outlined(
          onPressed: viewModel.isUpdatingServings
              ? null
              : () => viewModel.setServings(recipe.servings - 1),
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: viewModel.isUpdatingServings
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('${recipe.servings}', style: theme.textTheme.titleMedium),
          ),
        ),
        IconButton.outlined(
          onPressed: viewModel.isUpdatingServings
              ? null
              : () => viewModel.setServings(recipe.servings + 1),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.ingredient});

  final IngredientLine ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = ingredient.quantity == ingredient.quantity.roundToDouble()
        ? ingredient.quantity.toInt().toString()
        : ingredient.quantity.toStringAsFixed(1);
    final unit = ingredient.unit ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              ingredient.notes == null
                  ? ingredient.name
                  : '${ingredient.name} (${ingredient.notes})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: ingredient.isMain ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text('$quantity $unit'.trim(), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions({required this.recipe});

  final RecipeDetail recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (recipe.hasSteps) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < recipe.instructionsSteps!.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recipe.instructionsSteps![i],
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Text(
      recipe.instructionsText ?? 'Sin instrucciones.',
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.recipe, required this.viewModel});

  final RecipeDetail recipe;
  final RecipeDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recipe.hasSteps)
          OutlinedButton.icon(
            onPressed: () => context.push('/recetas/${recipe.slug}/modo-cocina',
                extra: recipe.instructionsSteps),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Modo cocina'),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: viewModel.isMarkingCooked
              ? null
              : () async {
                  await viewModel.markCooked();
                  if (context.mounted && viewModel.cookedMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(viewModel.cookedMessage!)),
                    );
                  }
                },
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Marcar como cocinada'),
        ),
      ],
    );
  }
}
