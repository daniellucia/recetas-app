import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/recipe_summary.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/recipe_image.dart';
import '../view_models/recipes_list_view_model.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 240) {
      context.read<RecipesListViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      body: Consumer<RecipesListViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              _Filters(viewModel: viewModel),
              Expanded(child: _buildBody(context, viewModel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RecipesListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.items.isEmpty) {
      return AppErrorView(
        error: viewModel.error!,
        onRetry: viewModel.refresh,
      );
    }
    if (viewModel.items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No se encontraron recetas',
        subtitle: viewModel.favoritesOnly
            ? 'No tienes recetas favoritas con ese filtro.'
            : 'Prueba con otra búsqueda.',
      );
    }
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: viewModel.items.length + (viewModel.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= viewModel.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final recipe = viewModel.items[index];
          return _RecipeCard(
            recipe: recipe,
            onTap: () => context.push('/recetas/${recipe.slug}'),
            onToggleFavorite: () => viewModel.toggleFavorite(recipe),
          );
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.viewModel});

  final RecipesListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: viewModel.setQuery,
            decoration: const InputDecoration(
              hintText: 'Buscar recetas…',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                label: const Text('Favoritas'),
                avatar: const Icon(Icons.favorite_rounded, size: 16),
                selected: viewModel.favoritesOnly,
                onSelected: viewModel.setFavoritesOnly,
              ),
              const Spacer(),
              DropdownButtonHideUnderline(
                child: DropdownButton<RecipeSortOption>(
                  value: viewModel.sort,
                  borderRadius: BorderRadius.circular(12),
                  items: RecipeSortOption.values
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) viewModel.setSort(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final RecipeSummary recipe;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipeImage(
                imageUrl: recipe.imageUrl,
                height: 72,
                width: 72,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (recipe.categories.isNotEmpty)
                      Text(
                        recipe.categories.join(' · '),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (recipe.averageRating != null) ...[
                          RatingStars(rating: recipe.averageRating!, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            recipe.averageRating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (recipe.prepTimeMinutes != null ||
                            recipe.cookTimeMinutes != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.schedule_rounded,
                              size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            '${(recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0)} min',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('favorite-${recipe.slug}'),
                onPressed: onToggleFavorite,
                icon: Icon(
                  recipe.isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: recipe.isFavorited ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
