import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/format.dart";
import "../../app/session_store.dart";
import "../habits/habit_tile.dart";
import "../shell/habits_controller.dart";

class HomeView extends StatelessWidget {
  const HomeView({
    required this.controller,
    required this.session,
    required this.onOpen,
    required this.onSeeAll,
    super.key,
  });

  final HabitsController controller;
  final SessionStore session;
  final ValueChanged<Habit> onOpen;
  final VoidCallback onSeeAll;

  Future<void> _toggle(BuildContext context, Habit habit) async {
    final message = await controller.toggle(habit);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListenableBuilder(
      listenable: Listenable.merge([controller, session]),
      builder: (context, _) {
        final user = session.user;
        final due = controller.items.where((habit) => habit.isDueOn(now)).toList();
        final done = due.where((habit) => habit.completedToday).length;
        final progress = due.isEmpty ? 0.0 : done / due.length;

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: CicloColors.accent,
            onRefresh: controller.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user == null ? greetingFor(now) : "${greetingFor(now)}, ${firstName(user.name)}",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatLongDate(now),
                            style: const TextStyle(color: CicloColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CAvatar(initials: user?.initials ?? "C"),
                  ],
                ),
                const SizedBox(height: 22),
                CCard(
                  color: CicloColors.ink,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seu ritmo de hoje",
                        style: TextStyle(color: CicloColors.sandSoft),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        due.isEmpty ? "Dia livre" : "$done de ${due.length}",
                        style: const TextStyle(
                          fontFamily: "Fraunces",
                          color: CicloColors.surface,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        due.isEmpty
                            ? "Nenhum hábito marcado para hoje."
                            : "hábitos previstos para hoje",
                        style: const TextStyle(color: CicloColors.sandSoft),
                      ),
                      const SizedBox(height: 16),
                      CProgressBar(value: progress),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CSectionTitle("Para hoje", action: onSeeAll),
                const SizedBox(height: 12),
                if (controller.error != null && controller.ready) ...[
                  CErrorState(message: controller.error!, onRetry: controller.load),
                  const SizedBox(height: 12),
                ],
                if (!controller.ready && controller.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(color: CicloColors.accent)),
                  )
                else if (controller.error != null && !controller.ready)
                  CErrorState(message: controller.error!, onRetry: controller.load)
                else if (due.isEmpty)
                  const CEmptyState(
                    title: "Nada previsto",
                    message: "Hoje não tem hábito na agenda. Você pode olhar a lista completa ou descansar.",
                  )
                else
                  ...due.map(
                    (habit) => HabitTile(
                      habit: habit,
                      busy: controller.busyId == habit.id,
                      onOpen: () => onOpen(habit),
                      onToggle: () => _toggle(context, habit),
                    ),
                  ),
                const SizedBox(height: 8),
                CCard(
                  color: CicloColors.softGreen,
                  child: Text(
                    "Você completou ${user?.completedCount ?? 0} ciclos neste mês. Consistência nasce do que se repete.",
                    style: const TextStyle(
                      color: CicloColors.green,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
