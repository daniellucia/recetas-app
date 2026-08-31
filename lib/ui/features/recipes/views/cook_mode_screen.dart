import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Modo cocina: un paso por pantalla, a pantalla completa, con la pantalla
/// del dispositivo bloqueada mientras dura (no se apaga sola).
class CookModeScreen extends StatefulWidget {
  const CookModeScreen({super.key, required this.steps});

  final List<String> steps;

  @override
  State<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends State<CookModeScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.steps.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Paso ${_index + 1} de ${widget.steps.length}'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / widget.steps.length,
            minHeight: 3,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.steps.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: Text(
                    widget.steps[i],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _index == widget.steps.length - 1
                        ? () => Navigator.of(context).pop()
                        : () => _goTo(_index + 1),
                    child: Text(
                      _index == widget.steps.length - 1 ? 'Terminar' : 'Siguiente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
