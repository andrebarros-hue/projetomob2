import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:ciclo/main.dart";
import "package:ciclo/app/app_services.dart";

void main() {
  test("login da conta demo devolve o token do contrato", () async {
    final server = CicloMockServer(latency: Duration.zero);
    final body = await server.handle(
      method: "POST",
      path: "/auth/login",
      body: {"email": "lia@ciclo.app", "password": "123456"},
    );
    expect(body["token"], "mock-token-usr_001");
    expect((body["user"] as Map)["name"], "Lia Martins");
  });

  test("senha errada da Lia é 401", () async {
    final server = CicloMockServer(latency: Duration.zero);
    await expectLater(
      server.handle(
        method: "POST",
        path: "/auth/login",
        body: {"email": "lia@ciclo.app", "password": "errada"},
      ),
      throwsA(isA<ApiException>().having((error) => error.status, "status", 401)),
    );
  });

  test("login sem campos é 422", () async {
    final server = CicloMockServer(latency: Duration.zero);
    await expectLater(
      server.handle(
        method: "POST",
        path: "/auth/login",
        body: {"email": "", "password": ""},
      ),
      throwsA(
        isA<ApiException>().having((error) => error.fields.containsKey("email"), "email", true),
      ),
    );
  });

  test("listar hábitos sem token é 401", () async {
    final server = CicloMockServer(latency: Duration.zero);
    await expectLater(
      server.handle(method: "GET", path: "/habits"),
      throwsA(isA<ApiException>().having((error) => error.status, "status", 401)),
    );
  });

  test("concluir um hábito previsto aumenta a sequência", () async {
    final server = CicloMockServer(latency: Duration.zero);
    final login = await server.handle(
      method: "POST",
      path: "/auth/login",
      body: {"email": "lia@ciclo.app", "password": "123456"},
    );
    final token = login["token"] as String;
    final list = await server.handle(method: "GET", path: "/habits", token: token);
    final habits = (list["data"] as List).cast<Map<dynamic, dynamic>>();
    final today = DateTime.now().weekday;
    final pending = habits.firstWhere(
      (habit) =>
          habit["completedToday"] != true &&
          (habit["weekdays"] as List).contains(today),
    );
    final updated = await server.handle(
      method: "PATCH",
      path: "/habits/${pending["id"]}/completion",
      token: token,
      body: {"completed": true, "completedAt": DateTime.now().toIso8601String()},
    );
    expect(updated["data"]["completedToday"], isTrue);
    expect(updated["data"]["streak"], (pending["streak"] as int) + 1);
    expect(updated["message"], "Ciclo atualizado");
  });

  test("criar hábito inválido é 422 e um válido entra na lista", () async {
    final server = CicloMockServer(latency: Duration.zero);
    final login = await server.handle(
      method: "POST",
      path: "/auth/login",
      body: {"email": "lia@ciclo.app", "password": "123456"},
    );
    final token = login["token"] as String;
    await expectLater(
      server.handle(
        method: "POST",
        path: "/habits",
        token: token,
        body: {"title": "", "icon": "nope", "frequency": ""},
      ),
      throwsA(isA<ApiException>().having((error) => error.status, "status", 422)),
    );
    final created = await server.handle(
      method: "POST",
      path: "/habits",
      token: token,
      body: {
        "title": "Meditar 5 min",
        "icon": "meditate",
        "color": "terracotta",
        "frequency": "Todos os dias",
        "weekdays": [1, 2, 3, 4, 5, 6, 7],
        "description": "Só sentar.",
      },
    );
    expect(created["data"]["title"], "Meditar 5 min");
    expect(created["data"]["streak"], 0);
  });

  testWidgets("a entrada mostra o convite e o botão", (tester) async {
    await tester.pumpWidget(CicloApp(services: AppServices.mock(latency: Duration.zero)));
    expect(find.text("Pequenos passos.\nUm ciclo inteiro."), findsOneWidget);
    expect(find.text("Entrar no Ciclo"), findsOneWidget);
    expect(find.byType(CButton), findsOneWidget);
  });
}
