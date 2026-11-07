const weekdaysLong = [
  "segunda",
  "terça",
  "quarta",
  "quinta",
  "sexta",
  "sábado",
  "domingo",
];

const monthsLong = [
  "janeiro",
  "fevereiro",
  "março",
  "abril",
  "maio",
  "junho",
  "julho",
  "agosto",
  "setembro",
  "outubro",
  "novembro",
  "dezembro",
];

String formatLongDate(DateTime date) {
  return "${weekdaysLong[date.weekday - 1]}, ${date.day} de ${monthsLong[date.month - 1]}";
}

String greetingFor(DateTime date) {
  if (date.hour < 12) return "Bom dia";
  if (date.hour < 18) return "Boa tarde";
  return "Boa noite";
}

String firstName(String name) {
  final parts = name.trim().split(" ");
  return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
}
