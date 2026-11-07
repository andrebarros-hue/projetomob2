import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/habit_style.dart";

class HabitTile extends StatelessWidget {
  const HabitTile({
    required this.habit,
    required this.onOpen,
    required this.onToggle,
    this.busy = false,
    super.key,
  });

  final Habit habit;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CCard(
        padding: const EdgeInsets.all(14),
        onTap: onOpen,
        child: Row(
          children: [
            CIconBox(
              glyph: habitGlyph(habit.icon),
              color: habit.completedToday ? CicloColors.softGreen : habitSoft(habit.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${habit.frequency} · ${habit.streak} dias",
                    style: const TextStyle(color: CicloColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: busy ? null : onToggle,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      habit.completedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: habit.completedToday ? CicloColors.green : CicloColors.muted,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
