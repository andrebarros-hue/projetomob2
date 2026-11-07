import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../shell/habits_controller.dart";
import "habit_tile.dart";

class HabitsView extends StatefulWidget {
  const HabitsView({
    required this.controller,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  final HabitsController controller;
  final ValueChanged<Habit> onOpen;
  final VoidCallback onCreate;

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  final search = TextEditingController();
  String filter = "todos";

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<Habit> _visible(List<Habit> items) {
    final query = search.text.trim().toLowerCase();
    final now = DateTime.now();
    return items.where((habit) {
      if (query.isNotEmpty && !habit.title.toLowerCase().contains(query)) {
        return false;
      }
      return switch (filter) {
        "hoje" => habit.isDueOn(now),
        "pendentes" => !habit.completedToday,
        "feitos" => habit.completedToday,
        _ => true,
      };
    }).toList();
  }

  Future<void> _toggle(Habit habit) async {
    final message = await widget.controller.toggle(habit);
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final visible = _visible(widget.controller.items);
        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: CicloColors.accent,
            onRefresh: widget.controller.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
              children: [
                Text("Seus hábitos", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                const Text(
                  "O que você escolhe repetir cuida de você.",
                  style: TextStyle(color: CicloColors.muted),
                ),
                const SizedBox(height: 18),
                CTextField(
                  controller: search,
                  label: "Buscar",
                  icon: Icons.search,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in const [
                      ("todos", "Todos"),
                      ("hoje", "Hoje"),
                      ("pendentes", "Pendentes"),
                      ("feitos", "Feitos"),
                    ])
                      CChip(
                        label: item.$2,
                        selected: filter == item.$1,
                        onTap: () => setState(() => filter = item.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (widget.controller.error != null && widget.controller.ready) ...[
                  CErrorState(
                    message: widget.controller.error!,
                    onRetry: widget.controller.load,
                  ),
                  const SizedBox(height: 12),
                ],
                if (!widget.controller.ready && widget.controller.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator(color: CicloColors.accent)),
                  )
                else if (widget.controller.error != null && !widget.controller.ready)
                  CErrorState(
                    message: widget.controller.error!,
                    onRetry: widget.controller.load,
                  )
                else if (widget.controller.items.isEmpty)
                  CEmptyState(
                    title: "Nenhum hábito ainda",
                    message: "Comece por algo pequeno o bastante para caber hoje.",
                    action: CButton(
                      label: "Criar o primeiro",
                      icon: Icons.add,
                      onPressed: widget.onCreate,
                    ),
                  )
                else if (visible.isEmpty)
                  const CEmptyState(
                    title: "Nada com esse filtro",
                    message: "Troque a busca ou o filtro para ver o resto da lista.",
                  )
                else
                  ...visible.map(
                    (habit) => HabitTile(
                      habit: habit,
                      busy: widget.controller.busyId == habit.id,
                      onOpen: () => widget.onOpen(habit),
                      onToggle: () => _toggle(habit),
                    ),
                  ),
                const SizedBox(height: 8),
                CButton(
                  label: "Adicionar hábito",
                  icon: Icons.add,
                  onPressed: widget.onCreate,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
