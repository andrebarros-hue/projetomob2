import "package:ciclo_design_system/ciclo_design_system.dart";
import "package:flutter/material.dart";

class DesignSystemView extends StatelessWidget {
  const DesignSystemView({required this.modeLabel, super.key});

  final String modeLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
        children: [
          Text("Ciclo / sistema", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            "Amostra dos tokens e componentes que seguram a interface.",
            style: TextStyle(color: CicloColors.muted, height: 1.4),
          ),
          const SizedBox(height: 26),
          const CSectionTitle("Cores"),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Swatch("Canvas", CicloColors.canvas, CicloColors.ink),
              _Swatch("Ink", CicloColors.ink, CicloColors.surface),
              _Swatch("Terracota", CicloColors.accent, CicloColors.surface),
              _Swatch("Verde", CicloColors.green, CicloColors.surface),
              _Swatch("Areia", CicloColors.sand, CicloColors.surface),
            ],
          ),
          const SizedBox(height: 28),
          const CSectionTitle("Tipografia"),
          const SizedBox(height: 8),
          Text("Headline / Fraunces 36", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text("Title / Outfit 20", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            "Body / Outfit 16 — cuidar da rotina também pode ser simples.",
            style: TextStyle(fontSize: 16, height: 1.45, color: CicloColors.muted),
          ),
          const SizedBox(height: 28),
          const CSectionTitle("Botões"),
          const SizedBox(height: 12),
          CButton(label: "Primário", icon: Icons.arrow_forward, onPressed: _noop),
          const SizedBox(height: 10),
          CButton(
            label: "Secundário",
            variant: CButtonVariant.secondary,
            onPressed: _noop,
          ),
          const SizedBox(height: 10),
          const CButton(label: "Desabilitado", onPressed: null),
          const SizedBox(height: 10),
          CButton(
            label: "Perigo",
            variant: CButtonVariant.danger,
            icon: Icons.delete_outline,
            onPressed: _noop,
          ),
          const SizedBox(height: 28),
          const CSectionTitle("Campos e chips"),
          const SizedBox(height: 12),
          const _SampleField(),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              CChip(label: "Hoje", selected: true),
              CChip(label: "Pendentes", selected: false),
            ],
          ),
          const SizedBox(height: 28),
          const CSectionTitle("Superfícies"),
          const SizedBox(height: 12),
          const CCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Card", style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  "Raio 24, superfície clara, fio de 1 px.",
                  style: TextStyle(color: CicloColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              CIconBox(glyph: "💧"),
              SizedBox(width: 10),
              CIconBox(glyph: "🌿", color: CicloColors.softGreen),
              SizedBox(width: 10),
              CIconBox(glyph: "📖", color: CicloColors.sandSoft),
            ],
          ),
          const SizedBox(height: 12),
          const CProgressBar(value: 0.66, track: CicloColors.line, fill: CicloColors.accent),
          const SizedBox(height: 28),
          const CSectionTitle("Estados"),
          const SizedBox(height: 12),
          const CEmptyState(
            title: "Lista vazia",
            message: "Quando não há hábitos, a tela explica o próximo passo.",
          ),
          const SizedBox(height: 12),
          const CErrorState(message: "Exemplo de falha do mock, com uma ação de tentar de novo."),
          const SizedBox(height: 28),
          const CSectionTitle("Contrato que a UI consome"),
          const SizedBox(height: 12),
          CCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const Text(
                  "POST /auth/login\nGET /habits\nPOST /habits\nPATCH /habits/{id}\nPATCH /habits/{id}/completion\nDELETE /habits/{id}",
                  style: TextStyle(height: 1.6, fontFamily: "Outfit"),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Requests, responses e erros estão em docs/api.md.",
                  style: TextStyle(color: CicloColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color, this.foreground);

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(CicloRadius.md),
              border: Border.all(color: CicloColors.line),
            ),
            child: Text(label, style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SampleField extends StatefulWidget {
  const _SampleField();

  @override
  State<_SampleField> createState() => _SampleFieldState();
}

class _SampleFieldState extends State<_SampleField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CTextField(controller: controller, label: "Campo", hint: "Escreva um hábito", icon: Icons.edit_outlined);
  }
}
