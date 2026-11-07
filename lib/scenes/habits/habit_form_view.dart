import "package:ciclo_core/ciclo_core.dart";
import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

import "../../app/habit_style.dart";
import "../shell/habits_controller.dart";

class HabitFormView extends StatefulWidget {
  const HabitFormView({required this.controller, this.habit, super.key});

  final HabitsController controller;
  final Habit? habit;

  @override
  State<HabitFormView> createState() => _HabitFormViewState();
}

class _HabitFormViewState extends State<HabitFormView> {
  late final title = TextEditingController(text: widget.habit?.title ?? "");
  late final description = TextEditingController(text: widget.habit?.description ?? "");
  late String icon = widget.habit?.icon ?? "leaf";
  late String color = widget.habit?.color ?? "terracotta";
  late String frequency = widget.habit?.frequency ?? "Todos os dias";
  bool saving = false;
  String? banner;
  Map<String, String> fields = {};

  bool get editing => widget.habit != null;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      banner = null;
      fields = {};
    });
    try {
      await widget.controller.save(
        HabitDraft(
          title: title.text.trim(),
          description: description.text.trim(),
          icon: icon,
          color: color,
          frequency: frequency,
          weekdays: List<int>.from(frequencyWeekdays[frequency] ?? const [1, 2, 3, 4, 5, 6, 7]),
        ),
        id: widget.habit?.id,
      );
      if (mounted) Navigator.pop(context);
    } on ApiException catch (error) {
      setState(() {
        banner = error.message;
        fields = error.fields;
      });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing ? "Editar hábito" : "Novo hábito")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          CTextField(
            controller: title,
            label: "O que você quer repetir?",
            error: fields["title"],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          CTextField(
            controller: description,
            label: "Uma frase para lembrar",
            error: fields["description"],
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          const Text("Ícone", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in habitIconKeys)
                GestureDetector(
                  onTap: () => setState(() => icon = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: icon == key ? CicloColors.ink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CIconBox(
                      glyph: habitGlyph(key),
                      color: icon == key ? CicloColors.softAccent : CicloColors.sandSoft,
                      size: 52,
                    ),
                  ),
                ),
            ],
          ),
          if (fields["icon"] != null) ...[
            const SizedBox(height: 6),
            Text(fields["icon"]!, style: const TextStyle(color: CicloColors.danger, fontSize: 12)),
          ],
          const SizedBox(height: 22),
          const Text("Cor", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final key in habitColorKeys)
                GestureDetector(
                  onTap: () => setState(() => color = key),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: habitInk(key),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == key ? CicloColors.ink : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text("Frequência", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in frequencyWeekdays.keys)
                CChip(
                  label: label,
                  selected: frequency == label,
                  onTap: () => setState(() => frequency = label),
                ),
            ],
          ),
          if (banner != null) ...[
            const SizedBox(height: 16),
            Text(banner!, style: const TextStyle(color: CicloColors.danger, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 22),
          CButton(
            label: saving ? "Salvando..." : (editing ? "Salvar alterações" : "Criar hábito"),
            icon: Icons.check,
            loading: saving,
            onPressed: saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
