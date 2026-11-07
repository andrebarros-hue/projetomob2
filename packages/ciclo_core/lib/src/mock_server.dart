import "models.dart";

typedef Clock = DateTime Function();

class _Account {
  _Account({required this.password, required this.user});

  String password;
  UserProfile user;
}

class MockDatabase {
  MockDatabase({Clock? clock}) : clock = clock ?? DateTime.now {
    accounts["lia@ciclo.app"] = _Account(
      password: "123456",
      user: const UserProfile(
        id: "usr_001",
        name: "Lia Martins",
        email: "lia@ciclo.app",
        initials: "LM",
        completedCount: 18,
      ),
    );
    habits = seedHabits(this.clock);
  }

  final Clock clock;
  final Map<String, _Account> accounts = {};
  final Map<String, String> tokens = {};
  late List<Habit> habits;
  bool failNext = false;
  int sequence = 10;
}

class CicloMockServer {
  CicloMockServer({
    this.latency = const Duration(milliseconds: 280),
    Clock? clock,
    MockDatabase? database,
  }) : clock = clock ?? DateTime.now,
       database = database ?? MockDatabase(clock: clock ?? DateTime.now);

  static const baseUrl = "https://mock.ciclo.app/v1";

  final Duration latency;
  final Clock clock;
  final MockDatabase database;

  Future<Map<String, dynamic>> handle({
    required String method,
    required String path,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    if (database.failNext) {
      database.failNext = false;
      throw ApiException(
        status: 503,
        code: "UPSTREAM_UNAVAILABLE",
        message: "O mock não respondeu. Tente de novo em instantes.",
      );
    }

    final segments = path
        .split("?")
        .first
        .split("/")
        .where((part) => part.isNotEmpty)
        .toList();
    final verb = method.toUpperCase();
    final payload = body ?? const <String, dynamic>{};

    if (segments.length == 1 && segments[0] == "health" && verb == "GET") {
      return {
        "status": "ok",
        "service": "ciclo-mock",
        "version": "1",
        "baseUrl": baseUrl,
      };
    }
    if (segments.length == 2 &&
        segments[0] == "auth" &&
        segments[1] == "login" &&
        verb == "POST") {
      return _login(payload);
    }
    if (segments.length == 2 &&
        segments[0] == "auth" &&
        segments[1] == "logout" &&
        verb == "POST") {
      final email = _requireEmail(token);
      database.tokens.removeWhere((_, value) => value == email);
      return {"ok": true};
    }
    if (segments.length == 1 && segments[0] == "me" && verb == "GET") {
      final email = _requireEmail(token);
      return {"user": database.accounts[email]!.user.toJson()};
    }
    if (segments.length == 2 &&
        segments[0] == "dev" &&
        segments[1] == "reset" &&
        verb == "POST") {
      final email = _requireEmail(token);
      database.habits = seedHabits(database.clock);
      return _page(email);
    }
    if (segments.length == 1 && segments[0] == "habits") {
      final email = _requireEmail(token);
      if (verb == "GET") return _page(email);
      if (verb == "POST") {
        final habit = _create(payload);
        database.habits = [...database.habits, habit];
        return {
          "data": habit.toJson(),
          "user": database.accounts[email]!.user.toJson(),
        };
      }
    }
    if (segments.length == 2 && segments[0] == "habits") {
      final email = _requireEmail(token);
      final id = segments[1];
      if (verb == "GET") return {"data": _find(id).toJson()};
      if (verb == "PATCH") {
        final updated = _applyDraft(_find(id), payload);
        _replace(updated);
        return {
          "data": updated.toJson(),
          "user": database.accounts[email]!.user.toJson(),
        };
      }
      if (verb == "DELETE") {
        final habit = _find(id);
        database.habits = database.habits
            .where((item) => item.id != id)
            .toList();
        if (habit.completedToday) {
          final account = database.accounts[email]!;
          final next = account.user.completedCount - 1;
          account.user = account.user.copyWith(
            completedCount: next < 0 ? 0 : next,
          );
        }
        return {"ok": true, "user": database.accounts[email]!.user.toJson()};
      }
    }
    if (segments.length == 3 &&
        segments[0] == "habits" &&
        segments[2] == "completion" &&
        verb == "PATCH") {
      final email = _requireEmail(token);
      return _complete(email, segments[1], payload);
    }

    throw ApiException(
      status: 404,
      code: "NOT_FOUND",
      message: "Rota não encontrada.",
    );
  }

  Map<String, dynamic> _login(Map<String, dynamic> body) {
    final fields = <String, String>{};
    final email = (body["email"] as String?)?.trim() ?? "";
    final password = body["password"] as String? ?? "";
    if (!_validEmail(email)) {
      fields["email"] = "Informe um e-mail válido.";
    }
    if (password.isEmpty) {
      fields["password"] = "Informe a senha.";
    }
    if (fields.isNotEmpty) {
      throw ApiException(
        status: 422,
        code: "VALIDATION_ERROR",
        message: "Revise e-mail e senha.",
        fields: fields,
      );
    }

    final known = database.accounts[email];
    if (known != null) {
      if (known.password != password) {
        throw ApiException(
          status: 401,
          code: "INVALID_CREDENTIALS",
          message: "E-mail ou senha não conferem.",
        );
      }
    } else if (password.length < 4) {
      throw ApiException(
        status: 422,
        code: "VALIDATION_ERROR",
        message: "A senha precisa ter ao menos 4 caracteres.",
        fields: const {"password": "Use 4 caracteres ou mais."},
      );
    } else {
      final name = _nameFromEmail(email);
      final id =
          "usr_${(database.accounts.length + 1).toString().padLeft(3, "0")}";
      database.accounts[email] = _Account(
        password: password,
        user: UserProfile(
          id: id,
          name: name,
          email: email,
          initials: _initials(name),
          completedCount: 0,
        ),
      );
    }

    final account = database.accounts[email]!;
    final token = "mock-token-${account.user.id}";
    database.tokens[token] = email;
    return {"token": token, "user": account.user.toJson()};
  }

  String _requireEmail(String? token) {
    if (token == null || token.isEmpty) {
      throw ApiException(
        status: 401,
        code: "UNAUTHORIZED",
        message: "Envie o header Authorization: Bearer {token}.",
      );
    }
    final email = database.tokens[token];
    if (email == null || !database.accounts.containsKey(email)) {
      throw ApiException(
        status: 401,
        code: "UNAUTHORIZED",
        message: "Sessão inválida. Entre de novo.",
      );
    }
    return email;
  }

  Map<String, dynamic> _page(String email) {
    final refreshed = database.habits
        .map((habit) => _withToday(habit))
        .toList();
    database.habits = refreshed;
    final due = refreshed.where((habit) => habit.isDueOn(clock())).length;
    final done = refreshed.where((habit) => habit.completedToday).length;
    return {
      "data": refreshed.map((habit) => habit.toJson()).toList(),
      "meta": {"total": refreshed.length, "completedToday": done, "dueToday": due},
      "user": database.accounts[email]!.user.toJson(),
    };
  }

  Habit _create(Map<String, dynamic> body) {
    final fields = <String, String>{};
    final title = (body["title"] as String?)?.trim() ?? "";
    final icon = (body["icon"] as String?)?.trim() ?? "";
    final frequency = (body["frequency"] as String?)?.trim() ?? "";
    final color = ((body["color"] as String?)?.trim().isNotEmpty ?? false)
        ? (body["color"] as String).trim()
        : "terracotta";
    final description = (body["description"] as String?)?.trim() ?? "";
    final weekdays = _weekdaysFrom(body, frequency);

    if (title.isEmpty) fields["title"] = "Diga o que você quer repetir.";
    if (title.length > 60) fields["title"] = "Use até 60 caracteres.";
    if (!habitIconKeys.contains(icon)) {
      fields["icon"] = "Escolha um ícone do catálogo.";
    }
    if (frequency.isEmpty) fields["frequency"] = "Escolha uma frequência.";
    if (weekdays.isEmpty) fields["weekdays"] = "Marque ao menos um dia.";
    if (!habitColorKeys.contains(color)) fields["color"] = "Cor fora do tema.";
    if (description.length > 280) {
      fields["description"] = "Use até 280 caracteres.";
    }
    if (fields.isNotEmpty) {
      throw ApiException(
        status: 422,
        code: "VALIDATION_ERROR",
        message: "Revise os campos destacados.",
        fields: fields,
      );
    }

    final id = "hab_${(database.sequence++).toString().padLeft(3, "0")}";
    return Habit(
      id: id,
      title: title,
      icon: icon,
      color: color,
      frequency: frequency,
      weekdays: weekdays,
      completedToday: false,
      streak: 0,
      description: description,
      history: const [],
    );
  }

  Habit _applyDraft(Habit current, Map<String, dynamic> body) {
    final fields = <String, String>{};
    var title = current.title;
    var icon = current.icon;
    var color = current.color;
    var frequency = current.frequency;
    var description = current.description;
    var weekdays = current.weekdays;

    if (body.containsKey("title")) {
      title = (body["title"] as String?)?.trim() ?? "";
      if (title.isEmpty) fields["title"] = "Diga o que você quer repetir.";
      if (title.length > 60) fields["title"] = "Use até 60 caracteres.";
    }
    if (body.containsKey("icon")) {
      icon = (body["icon"] as String?)?.trim() ?? "";
      if (!habitIconKeys.contains(icon)) {
        fields["icon"] = "Escolha um ícone do catálogo.";
      }
    }
    if (body.containsKey("color")) {
      color = (body["color"] as String?)?.trim() ?? "";
      if (!habitColorKeys.contains(color)) fields["color"] = "Cor fora do tema.";
    }
    if (body.containsKey("frequency") || body.containsKey("weekdays")) {
      frequency = body.containsKey("frequency")
          ? ((body["frequency"] as String?)?.trim() ?? "")
          : current.frequency;
      if (frequency.isEmpty) fields["frequency"] = "Escolha uma frequência.";
      weekdays = _weekdaysFrom(body, frequency);
      if (weekdays.isEmpty) fields["weekdays"] = "Marque ao menos um dia.";
    }
    if (body.containsKey("description")) {
      description = (body["description"] as String?)?.trim() ?? "";
      if (description.length > 280) {
        fields["description"] = "Use até 280 caracteres.";
      }
    }
    if (fields.isNotEmpty) {
      throw ApiException(
        status: 422,
        code: "VALIDATION_ERROR",
        message: "Revise os campos destacados.",
        fields: fields,
      );
    }

    return _withToday(
      current.copyWith(
        title: title,
        icon: icon,
        color: color,
        frequency: frequency,
        description: description,
        weekdays: weekdays,
      ),
    );
  }

  Map<String, dynamic> _complete(
    String email,
    String id,
    Map<String, dynamic> body,
  ) {
    if (body["completed"] is! bool) {
      throw ApiException(
        status: 422,
        code: "VALIDATION_ERROR",
        message: "Informe se o hábito foi feito.",
        fields: const {"completed": "Use true ou false."},
      );
    }
    final want = body["completed"] as bool;
    final habit = _find(id);
    final today = isoDate(clock());
    final history = [...habit.history];
    final had = history.contains(today);
    if (want && !had) history.add(today);
    if (!want && had) history.remove(today);
    final updated = _withToday(habit.copyWith(history: history));
    _replace(updated);
    if (want != had) {
      final account = database.accounts[email]!;
      final next = account.user.completedCount + (want ? 1 : -1);
      account.user = account.user.copyWith(completedCount: next < 0 ? 0 : next);
    }
    return {
      "data": updated.toJson(),
      "message": want ? "Ciclo atualizado" : "Marcado como pendente",
      "user": database.accounts[email]!.user.toJson(),
    };
  }

  Habit _find(String id) {
    for (final habit in database.habits) {
      if (habit.id == id) return habit;
    }
    throw ApiException(
      status: 404,
      code: "NOT_FOUND",
      message: "Hábito não encontrado.",
    );
  }

  void _replace(Habit habit) {
    database.habits = [
      for (final item in database.habits)
        if (item.id == habit.id) habit else item,
    ];
  }

  Habit _withToday(Habit habit) {
    final today = isoDate(clock());
    return habit.copyWith(
      completedToday: habit.history.contains(today),
      streak: computeStreak(habit.history, habit.weekdays, clock()),
    );
  }

  List<int> _weekdaysFrom(Map<String, dynamic> body, String frequency) {
    final raw = body["weekdays"];
    if (raw is List && raw.isNotEmpty) {
      final days =
          raw
              .map((item) => (item as num).toInt())
              .where((day) => day >= 1 && day <= 7)
              .toSet()
              .toList()
            ..sort();
      return days;
    }
    return List<int>.from(frequencyWeekdays[frequency] ?? const []);
  }
}

String isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, "0");
  final month = date.month.toString().padLeft(2, "0");
  final day = date.day.toString().padLeft(2, "0");
  return "$year-$month-$day";
}

int computeStreak(List<String> history, List<int> weekdays, DateTime now) {
  final done = history.toSet();
  var cursor = DateTime(now.year, now.month, now.day);
  if (!done.contains(isoDate(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  var guard = 0;
  while (guard < 400) {
    if (weekdays.contains(cursor.weekday)) {
      if (!done.contains(isoDate(cursor))) break;
      streak += 1;
    }
    cursor = cursor.subtract(const Duration(days: 1));
    guard += 1;
  }
  return streak;
}

List<String> historyForStreak({
  required Clock clock,
  required int streak,
  required bool completedToday,
  required List<int> weekdays,
}) {
  final dates = <String>[];
  var remaining = streak;
  var cursor = DateTime(clock().year, clock().month, clock().day);
  if (!completedToday) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var guard = 0;
  while (remaining > 0 && guard < 400) {
    if (weekdays.contains(cursor.weekday)) {
      dates.add(isoDate(cursor));
      remaining -= 1;
    }
    cursor = cursor.subtract(const Duration(days: 1));
    guard += 1;
  }
  return dates;
}

List<Habit> seedHabits(Clock clock) {
  Habit make({
    required String id,
    required String title,
    required String icon,
    required String color,
    required String frequency,
    required List<int> weekdays,
    required int streak,
    required bool completedToday,
    required String description,
  }) {
    final history = historyForStreak(
      clock: clock,
      streak: streak,
      completedToday: completedToday,
      weekdays: weekdays,
    );
    return Habit(
      id: id,
      title: title,
      icon: icon,
      color: color,
      frequency: frequency,
      weekdays: List<int>.from(weekdays),
      completedToday: completedToday,
      streak: computeStreak(history, weekdays, clock()),
      description: description,
      history: history,
    );
  }

  return [
    make(
      id: "hab_001",
      title: "Beber água",
      icon: "water",
      color: "terracotta",
      frequency: "Todos os dias",
      weekdays: frequencyWeekdays["Todos os dias"]!,
      streak: 7,
      completedToday: true,
      description: "Manter uma garrafinha por perto durante o dia.",
    ),
    make(
      id: "hab_002",
      title: "Caminhar 20 min",
      icon: "leaf",
      color: "green",
      frequency: "Seg, Qua, Sex",
      weekdays: frequencyWeekdays["Seg, Qua, Sex"]!,
      streak: 3,
      completedToday: false,
      description: "Uma volta no quarteirão já conta.",
    ),
    make(
      id: "hab_003",
      title: "Ler antes de dormir",
      icon: "book",
      color: "sand",
      frequency: "Todos os dias",
      weekdays: frequencyWeekdays["Todos os dias"]!,
      streak: 12,
      completedToday: false,
      description: "Dez páginas, sem notificações por perto.",
    ),
    make(
      id: "hab_004",
      title: "Alongar de manhã",
      icon: "sun",
      color: "green",
      frequency: "Dias úteis",
      weekdays: frequencyWeekdays["Dias úteis"]!,
      streak: 4,
      completedToday: false,
      description: "Cinco minutos no chão da sala, antes do celular.",
    ),
    make(
      id: "hab_005",
      title: "Anotar o dia",
      icon: "journal",
      color: "ink",
      frequency: "Todos os dias",
      weekdays: frequencyWeekdays["Todos os dias"]!,
      streak: 5,
      completedToday: true,
      description: "Três linhas sobre o que ficou e o que pode esperar.",
    ),
  ];
}

bool _validEmail(String email) {
  final at = email.indexOf("@");
  if (at <= 0) return false;
  final dot = email.indexOf(".", at);
  return dot > at + 1 && !email.contains(" ");
}

String _nameFromEmail(String email) {
  final local = email.split("@").first;
  final parts = local.split(RegExp(r"[._\-]+")).where((part) => part.isNotEmpty);
  if (parts.isEmpty) return "Convidado";
  return parts
      .map((part) {
        final lower = part.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(" ");
}

String _initials(String name) {
  final parts = name.split(" ").where((part) => part.isNotEmpty).take(2);
  final letters = parts.map((part) => part[0].toUpperCase()).join();
  return letters.isEmpty ? "C" : letters;
}
