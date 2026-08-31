import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/import_view_model.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartir')),
      body: Consumer<ImportViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Importar una receta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pega la URL de un vídeo de YouTube o de un producto de una '
                  'tienda online. Puede tardar hasta un minuto en analizarla.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'https://…',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: viewModel.isLoading || _controller.text.trim().isEmpty
                      ? null
                      : () => viewModel.importFromUrl(_controller.text),
                  icon: viewModel.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    viewModel.isLoading ? 'Importando…' : 'Importar',
                  ),
                ),
                if (viewModel.isLoading) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Analizando con IA, esto puede tardar…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  _ResultCard(
                    icon: Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    lines: [viewModel.errorMessage!],
                  ),
                ],
                if (viewModel.lastResult != null) ...[
                  const SizedBox(height: 20),
                  if (viewModel.lastResult!.imported.isNotEmpty)
                    _ResultCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      lines: viewModel.lastResult!.imported
                          .map((title) => 'Importada «$title».')
                          .toList(),
                    ),
                  if (viewModel.lastResult!.skipped.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ResultCard(
                      icon: Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      lines: viewModel.lastResult!.skipped
                          .map((title) => 'Ya existía «$title», omitida.')
                          .toList(),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.icon, required this.color, required this.lines});

  final IconData icon;
  final Color color;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines
                    .map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(line),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
