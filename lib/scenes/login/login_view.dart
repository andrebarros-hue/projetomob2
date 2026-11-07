import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/app_services.dart";
import "../../app/session_store.dart";

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this.auth});

  final AuthRepository auth;
  final email = TextEditingController(text: "lia@ciclo.app");
  final password = TextEditingController(text: "123456");
  bool loading = false;
  bool obscure = true;
  String? banner;
  Map<String, String> fields = {};

  Future<AuthSession?> submit() async {
    loading = true;
    banner = null;
    fields = {};
    notifyListeners();
    try {
      return await auth.signIn(email: email.text, password: password.text);
    } on ApiException catch (error) {
      banner = error.message;
      fields = error.fields;
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({required this.services, required this.session, super.key});

  final AppServices services;
  final SessionStore session;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel model = LoginViewModel(auth: widget.services.auth);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = await model.submit();
    if (session != null) widget.session.signIn(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: CicloColors.ink,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.loop, color: CicloColors.surface, size: 30),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              "Pequenos passos.\nUm ciclo inteiro.",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Hábitos que cabem no dia. Sem cobrança, com presença.",
                              style: TextStyle(color: CicloColors.muted, fontSize: 16, height: 1.45),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CTextField(
                              controller: model.email,
                              label: "E-mail",
                              icon: Icons.mail_outline,
                              error: model.fields["email"],
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            CTextField(
                              controller: model.password,
                              label: "Senha",
                              icon: Icons.lock_outline,
                              obscure: model.obscure,
                              error: model.fields["password"],
                              textInputAction: TextInputAction.done,
                              suffix: IconButton(
                                onPressed: model.toggleObscure,
                                icon: Icon(
                                  model.obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            if (model.banner != null && model.fields.isEmpty) ...[
                              const SizedBox(height: 14),
                              CCard(
                                color: CicloColors.dangerSoft,
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  model.banner!,
                                  style: const TextStyle(color: CicloColors.danger, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            CButton(
                              label: model.loading ? "Entrando..." : "Entrar no Ciclo",
                              icon: Icons.arrow_forward,
                              loading: model.loading,
                              onPressed: model.loading ? null : _submit,
                            ),
                            const SizedBox(height: 14),
                            const CCard(
                              color: CicloColors.sandSoft,
                              padding: EdgeInsets.all(14),
                              child: Text(
                                "Demonstração: lia@ciclo.app e senha 123456. Outro e-mail entra com senha de 4 caracteres ou mais. A senha errada da Lia mostra o erro 401 do contrato.",
                                style: TextStyle(color: CicloColors.ink, height: 1.4, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
