import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

String habitGlyph(String key) {
  return switch (key) {
    "water" => "💧",
    "leaf" => "🌿",
    "book" => "📖",
    "meditate" => "🧘",
    "sun" => "☀️",
    "moon" => "🌙",
    "journal" => "✍️",
    "apple" => "🍎",
    _ => "✨",
  };
}

Color habitSoft(String key) {
  return switch (key) {
    "green" => CicloColors.softGreen,
    "sand" => CicloColors.sandSoft,
    "ink" => CicloColors.line,
    _ => CicloColors.softAccent,
  };
}

Color habitInk(String key) {
  return switch (key) {
    "green" => CicloColors.green,
    "sand" => CicloColors.sand,
    "ink" => CicloColors.ink,
    _ => CicloColors.accent,
  };
}
