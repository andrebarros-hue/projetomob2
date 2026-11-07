class ApiException implements Exception {
  ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.fields = const {},
  });

  final int status;
  final String code;
  final String message;
  final Map<String, String> fields;

  @override
  String toString() => message;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.completedCount,
  });

  final String id;
  final String name;
  final String email;
  final String initials;
  final int completedCount;

  UserProfile copyWith({int? completedCount}) {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      initials: initials,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "initials": initials,
    "completedCount": completedCount,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: "${json["id"]}",
      name: "${json["name"] ?? ""}",
      email: "${json["email"] ?? ""}",
      initials: "${json["initials"] ?? ""}",
      completedCount: json["completedCount"] is num
          ? (json["completedCount"] as num).toInt()
          : 0,
    );
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final UserProfile user;
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.weekdays,
    required this.completedToday,
    required this.streak,
    required this.description,
    required this.history,
  });

  final String id;
  final String title;
  final String icon;
  final String color;
  final String frequency;
  final List<int> weekdays;
  final bool completedToday;
  final int streak;
  final String description;
  final List<String> history;

  bool isDueOn(DateTime date) => weekdays.contains(date.weekday);

  Habit copyWith({
    String? title,
    String? icon,
    String? color,
    String? frequency,
    List<int>? weekdays,
    bool? completedToday,
    int? streak,
    String? description,
    List<String>? history,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      completedToday: completedToday ?? this.completedToday,
      streak: streak ?? this.streak,
      description: description ?? this.description,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "icon": icon,
    "color": color,
    "frequency": frequency,
    "weekdays": weekdays,
    "completedToday": completedToday,
    "streak": streak,
    "description": description,
    "history": history,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final weekdays = json["weekdays"];
    final history = json["history"];
    return Habit(
      id: "${json["id"]}",
      title: "${json["title"] ?? ""}",
      icon: "${json["icon"] ?? "leaf"}",
      color: "${json["color"] ?? "terracotta"}",
      frequency: "${json["frequency"] ?? ""}",
      weekdays: weekdays is List
          ? weekdays.map((item) => (item as num).toInt()).toList()
          : const [1, 2, 3, 4, 5, 6, 7],
      completedToday: json["completedToday"] == true,
      streak: json["streak"] is num ? (json["streak"] as num).toInt() : 0,
      description: "${json["description"] ?? ""}",
      history: history is List
          ? history.map((item) => "$item").toList()
          : const [],
    );
  }
}

class HabitDraft {
  const HabitDraft({
    required this.title,
    required this.frequency,
    required this.icon,
    this.color = "terracotta",
    this.description = "",
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
  });

  final String title;
  final String frequency;
  final String icon;
  final String color;
  final String description;
  final List<int> weekdays;

  Map<String, dynamic> toJson() => {
    "title": title,
    "frequency": frequency,
    "icon": icon,
    "color": color,
    "description": description,
    "weekdays": weekdays,
  };
}

class HabitPage {
  const HabitPage({
    required this.habits,
    required this.total,
    required this.completedToday,
    required this.dueToday,
    required this.user,
  });

  final List<Habit> habits;
  final int total;
  final int completedToday;
  final int dueToday;
  final UserProfile user;
}

class HabitMutation {
  const HabitMutation({required this.habit, required this.user, this.message});

  final Habit habit;
  final UserProfile user;
  final String? message;
}

const habitIconKeys = [
  "water",
  "leaf",
  "book",
  "meditate",
  "sun",
  "moon",
  "journal",
  "apple",
];

const habitIconLabels = {
  "water": "Água",
  "leaf": "Caminhada",
  "book": "Leitura",
  "meditate": "Pausa",
  "sun": "Manhã",
  "moon": "Noite",
  "journal": "Diário",
  "apple": "Comida",
};

const habitColorKeys = ["terracotta", "green", "sand", "ink"];

const frequencyWeekdays = {
  "Todos os dias": [1, 2, 3, 4, 5, 6, 7],
  "Dias úteis": [1, 2, 3, 4, 5],
  "Seg, Qua, Sex": [1, 3, 5],
  "Fins de semana": [6, 7],
};

Map<String, dynamic> jsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw ApiException(
    status: 500,
    code: "BAD_RESPONSE",
    message: "Resposta incompleta do mock.",
  );
}
