import "package:ciclo_core/ciclo_core.dart";

class AppServices {
  AppServices({
    required this.auth,
    required this.habits,
    required this.transport,
  });

  factory AppServices.mock({
    Duration latency = const Duration(milliseconds: 320),
  }) {
    final transport = MockTransport(latency: latency);
    return AppServices(
      auth: RemoteAuthRepository(transport),
      habits: RemoteHabitRepository(transport),
      transport: transport,
    );
  }

  factory AppServices.http(String baseUrl) {
    final transport = HttpTransport(baseUrl: baseUrl);
    return AppServices(
      auth: RemoteAuthRepository(transport),
      habits: RemoteHabitRepository(transport),
      transport: transport,
    );
  }

  final AuthRepository auth;
  final HabitRepository habits;
  final ApiTransport transport;

  String get modeLabel {
    final current = transport;
    if (current is HttpTransport) return "HTTP ${current.baseUrl}";
    return "Mock embutido · ${CicloMockServer.baseUrl}";
  }

  void failNext() {
    final current = transport;
    if (current is MockTransport) {
      current.server.database.failNext = true;
    }
  }

  Future<void> restoreSamples(String token) {
    return transport.request(method: "POST", path: "/dev/reset", token: token);
  }
}
