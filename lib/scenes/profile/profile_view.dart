import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/app_services.dart";
import "../../app/session_store.dart";
import "../shell/habits_controller.dart";

class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.controller,
    required this.session,
    required this.services,
    super.key,
  });

  final HabitsController controller;
  final SessionStore session;
  final AppServices services;

  Future<void> _signOut() async {
    final token = session.token;
    try {
      if (token != null) await services.auth.signOut(token);
    } on Object {
      // A sessão local sai mesmo se o mock não responder.
    }
    session.signOut();
  }

  Future<void> _fail(BuildContext context) async {
    services.failNext();
    await controller.load();
    if (!context.mounted) return;
    final message = controller.error ?? "O mock respondeu normalmente.";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restore(BuildContext context) async {
    final message = await controller.restore();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? "Exemplos restaurados.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, session]),
      builder: (context, _) {
        final user = session.user;
        final doneToday = controller.items.where((habit) => habit.completedToday).length;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
            children: [
              Text("Perfil", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 18),
              CCard(
                child: Row(
                  children: [
                    CAvatar(initials: user?.initials ?? "C", size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? "Convidado", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(user?.email ?? "", style: const TextStyle(color: CicloColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _Stat(value: "${user?.completedCount ?? 0}", label: "ciclos no mês")),
                  const SizedBox(width: 10),
                  Expanded(child: _Stat(value: "${controller.bestStreak}", label: "maior sequência")),
                  const SizedBox(width: 10),
                  Expanded(child: _Stat(value: "$doneToday", label: "feitos hoje")),
                ],
              ),
              const SizedBox(height: 18),
              CCard(
                color: CicloColors.sandSoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Conexão", style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(services.modeLabel, style: const TextStyle(height: 1.4)),
                    const SizedBox(height: 8),
                    const Text(
                      "Os repositórios falam com um transporte. Hoje ele é o mock embutido. O PDF mostra como apontar para o servidor HTTP.",
                      style: TextStyle(color: CicloColors.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CButton(
                label: "Simular falha do mock",
                icon: Icons.cloud_off_outlined,
                variant: CButtonVariant.secondary,
                onPressed: () => _fail(context),
              ),
              const SizedBox(height: 10),
              CButton(
                label: "Restaurar exemplos",
                icon: Icons.restart_alt,
                variant: CButtonVariant.secondary,
                onPressed: () => _restore(context),
              ),
              const SizedBox(height: 10),
              CButton(
                label: "Sair",
                icon: Icons.logout,
                variant: CButtonVariant.ghost,
                onPressed: _signOut,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontFamily: "Fraunces", fontSize: 26, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: CicloColors.muted, fontSize: 12, height: 1.3)),
        ],
      ),
    );
  }
}
