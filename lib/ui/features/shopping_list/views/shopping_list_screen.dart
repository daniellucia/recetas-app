import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/shopping_list.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../view_models/shopping_list_view_model.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de la compra')),
      body: Consumer<ShoppingListViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null && viewModel.shoppingList == null) {
            return AppErrorView(error: viewModel.error!, onRetry: viewModel.load);
          }
          final list = viewModel.shoppingList;
          if (list == null || list.items.isEmpty) {
            return EmptyState(
              icon: Icons.checklist_outlined,
              title: 'No hay lista de la compra',
              subtitle: 'Activa un menú semanal con recetas para generarla.',
              action: OutlinedButton(
                onPressed: viewModel.load,
                child: const Text('Actualizar'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: viewModel.load,
            child: _GroupedList(list: list, viewModel: viewModel),
          );
        },
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.list, required this.viewModel});

  final ShoppingList list;
  final ShoppingListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final main = list.items.where((i) => i.isMain).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final rest = list.items.where((i) => !i.isMain).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          '${list.servings} raciones',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (main.isNotEmpty) ...[
          _SectionHeader(title: 'Ingredientes principales'),
          for (final item in main)
            _ShoppingTile(
              item: item,
              checked: viewModel.checkedIds.contains(item.ingredientId),
              onChanged: () => viewModel.toggle(item.ingredientId),
            ),
        ],
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'Otros ingredientes'),
          for (final item in rest)
            _ShoppingTile(
              item: item,
              checked: viewModel.checkedIds.contains(item.ingredientId),
              onChanged: () => viewModel.toggle(item.ingredientId),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _ShoppingTile extends StatelessWidget {
  const _ShoppingTile({
    required this.item,
    required this.checked,
    required this.onChanged,
  });

  final ShoppingListItem item;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(1);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: checked,
        onChanged: (_) => onChanged(),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: checked ? TextDecoration.lineThrough : null,
            color: checked ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        secondary: Text(
          '$quantity ${item.unit ?? ''}'.trim(),
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
