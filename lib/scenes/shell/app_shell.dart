import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/app_services.dart";
import "../../app/session_store.dart";
import "../design_system/design_system_view.dart";
import "../habits/habit_detail_view.dart";
import "../habits/habit_form_view.dart";
import "../habits/habits_view.dart";
import "../home/home_view.dart";
import "../profile/profile_view.dart";
import "habits_controller.dart";

class AppShell extends StatefulWidget {
  const AppShell({required this.services, required this.session, super.key});

  final AppServices services;
  final SessionStore session;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final HabitsController controller = HabitsController(
    services: widget.services,
    session: widget.session,
  );
  int tab = 0;

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openDetail(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HabitDetailView(
          controller: controller,
          habitId: habit.id,
          onEdit: () {
            final current = controller.byId(habit.id);
            if (current != null) _openForm(current);
          },
        ),
      ),
    );
  }

  Future<void> _openForm([Habit? habit]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HabitFormView(controller: controller, habit: habit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          HomeView(
            controller: controller,
            session: widget.session,
            onOpen: _openDetail,
            onSeeAll: () => setState(() => tab = 1),
          ),
          HabitsView(
            controller: controller,
            onOpen: _openDetail,
            onCreate: () => _openForm(),
          ),
          DesignSystemView(modeLabel: widget.services.modeLabel),
          ProfileView(
            controller: controller,
            session: widget.session,
            services: widget.services,
          ),
        ],
      ),
      bottomNavigationBar: CNavBar(
        index: tab,
        onChanged: (value) => setState(() => tab = value),
        items: const [
          CNavDestination(label: "Hoje", icon: Icons.wb_sunny_outlined),
          CNavDestination(label: "Hábitos", icon: Icons.loop),
          CNavDestination(label: "Sistema", icon: Icons.palette_outlined),
          CNavDestination(label: "Perfil", icon: Icons.person_outline),
        ],
      ),
    );
  }
}
