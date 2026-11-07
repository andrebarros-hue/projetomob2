import "models.dart";
import "transport.dart";

abstract interface class AuthRepository {
  Future<AuthSession> signIn({required String email, required String password});
  Future<void> signOut(String token);
}

abstract interface class HabitRepository {
  Future<HabitPage> list(String token);
  Future<Habit> getById(String token, String id);
  Future<HabitMutation> create(String token, HabitDraft draft);
  Future<HabitMutation> update(String token, String id, HabitDraft draft);
  Future<HabitMutation> toggle(
    String token,
    String id, {
    required bool completed,
  });
  Future<UserProfile> delete(String token, String id);
}

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this.transport);

  final ApiTransport transport;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final json = await transport.request(
      method: "POST",
      path: "/auth/login",
      body: {"email": email.trim(), "password": password},
    );
    return AuthSession(
      token: "${json["token"]}",
      user: UserProfile.fromJson(jsonMap(json["user"])),
    );
  }

  @override
  Future<void> signOut(String token) async {
    await transport.request(method: "POST", path: "/auth/logout", token: token);
  }
}

class RemoteHabitRepository implements HabitRepository {
  RemoteHabitRepository(this.transport);

  final ApiTransport transport;

  @override
  Future<HabitPage> list(String token) async {
    final json = await transport.request(
      method: "GET",
      path: "/habits",
      token: token,
    );
    return _page(json);
  }

  @override
  Future<Habit> getById(String token, String id) async {
    final json = await transport.request(
      method: "GET",
      path: "/habits/$id",
      token: token,
    );
    return Habit.fromJson(jsonMap(json["data"]));
  }

  @override
  Future<HabitMutation> create(String token, HabitDraft draft) async {
    final json = await transport.request(
      method: "POST",
      path: "/habits",
      token: token,
      body: draft.toJson(),
    );
    return _mutation(json);
  }

  @override
  Future<HabitMutation> update(String token, String id, HabitDraft draft) async {
    final json = await transport.request(
      method: "PATCH",
      path: "/habits/$id",
      token: token,
      body: draft.toJson(),
    );
    return _mutation(json);
  }

  @override
  Future<HabitMutation> toggle(
    String token,
    String id, {
    required bool completed,
  }) async {
    final json = await transport.request(
      method: "PATCH",
      path: "/habits/$id/completion",
      token: token,
      body: {
        "completed": completed,
        "completedAt": DateTime.now().toIso8601String(),
      },
    );
    return _mutation(json);
  }

  @override
  Future<UserProfile> delete(String token, String id) async {
    final json = await transport.request(
      method: "DELETE",
      path: "/habits/$id",
      token: token,
    );
    return UserProfile.fromJson(jsonMap(json["user"]));
  }

  HabitPage _page(Map<String, dynamic> json) {
    final data = json["data"];
    final meta = jsonMap(json["meta"]);
    final habits = data is List
        ? data.map((item) => Habit.fromJson(jsonMap(item))).toList()
        : <Habit>[];
    return HabitPage(
      habits: habits,
      total: meta["total"] is num ? (meta["total"] as num).toInt() : habits.length,
      completedToday: meta["completedToday"] is num
          ? (meta["completedToday"] as num).toInt()
          : 0,
      dueToday: meta["dueToday"] is num ? (meta["dueToday"] as num).toInt() : 0,
      user: UserProfile.fromJson(jsonMap(json["user"])),
    );
  }

  HabitMutation _mutation(Map<String, dynamic> json) {
    return HabitMutation(
      habit: Habit.fromJson(jsonMap(json["data"])),
      user: UserProfile.fromJson(jsonMap(json["user"])),
      message: json["message"] as String?,
    );
  }
}
