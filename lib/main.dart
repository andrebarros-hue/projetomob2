import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "app/app_services.dart";
import "app/navigation.dart";
import "app/session_store.dart";
import "scenes/login/login_view.dart";
import "scenes/shell/app_shell.dart";

void main() {
  // O app já nasce ligado ao mock embutido. Para o mock HTTP, troque a linha
  // abaixo por: AppServices.http("http://10.0.2.2:4010/v1")
  // O passo a passo está em COMO-CONECTAR-AO-MOCK.pdf.
  runApp(CicloApp(services: AppServices.mock()));
}

class CicloApp extends StatefulWidget {
  const CicloApp({required this.services, super.key});

  final AppServices services;

  @override
  State<CicloApp> createState() => _CicloAppState();
}

class _CicloAppState extends State<CicloApp> {
  final session = SessionStore();

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ciclo",
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: CicloTheme.light(),
      home: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          if (!session.isSignedIn) {
            return LoginView(services: widget.services, session: session);
          }
          return AppShell(services: widget.services, session: session);
        },
      ),
    );
  }
}
