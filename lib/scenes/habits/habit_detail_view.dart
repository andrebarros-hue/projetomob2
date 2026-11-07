import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/habit_style.dart";
import "../shell/habits_controller.dart";

class HabitDetailView extends StatelessWidget {
  const HabitDetailView({
    required this.controller,
    required this.habitId,
    required this.onEdit,
    super.key,
  });

  final HabitsController controller;
  final String habitId;
  final VoidCallback onEdit;

  Future<void> _toggle(BuildContext context, Habit habit) async {
    final message = await controller.toggle(habit);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _delete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CicloColors.surface,
        title: const Text("Tirar este hábito?"),
        content: Text("“${habit.title}” sai da sua lista. O histórico deste ciclo também."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remover", style: TextStyle(color: CicloColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await controller.remove(habit.id);
      if (context.mounted) Navigator.pop(context);
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final habit = controller.byId(habitId);
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: CEmptyState(
                title: "Hábito removido",
                message: "Ele não está mais na lista.",
              ),
            ),
          );
        }
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        const labels = ["S", "T", "Q", "Q", "S", "S", "D"];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Detalhe"),
            actions: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _delete(context, habit),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Row(
                children: [
                  CIconBox(glyph: habitGlyph(habit.icon), color: habitSoft(habit.color)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(habit.frequency, style: const TextStyle(color: CicloColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                habit.completedToday ? "Você fez isso hoje." : "Ainda dá tempo hoje.",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                "A constância não precisa ser perfeita. Ela só precisa continuar.",
                style: TextStyle(color: CicloColors.muted, fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 22),
              CCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sequência atual", style: TextStyle(color: CicloColors.muted)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${habit.streak}",
                          style: const TextStyle(
                            fontFamily: "Fraunces",
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 8),
                          child: Text("dias", style: TextStyle(color: CicloColors.muted, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var index = 0; index < 7; index++)
                          _DayDot(
                            label: labels[index],
                            done: habit.history.contains(isoDate(monday.add(Duration(days: index)))),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text("Sobre este hábito", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                habit.description.isEmpty ? "Um espaço para cuidar do que importa." : habit.description,
                style: const TextStyle(color: CicloColors.muted, fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 24),
              CButton(
                label: habit.completedToday ? "Marcar como pendente" : "Marcar como feito",
                icon: habit.completedToday ? Icons.undo : Icons.check,
                loading: controller.busyId == habit.id,
                onPressed: controller.busyId == habit.id ? null : () => _toggle(context, habit),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? CicloColors.green : CicloColors.line,
            shape: BoxShape.circle,
          ),
          child: done ? const Icon(Icons.check, size: 16, color: CicloColors.surface) : null,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: CicloColors.muted)),
      ],
    );
  }
}
