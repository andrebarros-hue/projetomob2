import "package:flutter/material.dart";

import "tokens.dart";

enum CButtonVariant { primary, accent, secondary, ghost, danger }

class CButton extends StatelessWidget {
  const CButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = CButtonVariant.primary,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CButtonVariant variant;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final palette = _palette(variant, enabled);
    final radius = BorderRadius.circular(CicloRadius.md);
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 54,
      child: Material(
        color: palette.background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: palette.foreground,
                    ),
                  )
                else if (icon != null) ...[
                  Icon(icon, size: 18, color: palette.foreground),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: "Outfit",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _ButtonPalette _palette(CButtonVariant variant, bool enabled) {
    if (!enabled) {
      return const _ButtonPalette(
        CicloColors.line,
        CicloColors.muted,
        CicloColors.line,
      );
    }
    return switch (variant) {
      CButtonVariant.primary => const _ButtonPalette(
        CicloColors.ink,
        CicloColors.surface,
        CicloColors.ink,
      ),
      CButtonVariant.accent => const _ButtonPalette(
        CicloColors.accent,
        CicloColors.surface,
        CicloColors.accent,
      ),
      CButtonVariant.secondary => const _ButtonPalette(
        CicloColors.surface,
        CicloColors.ink,
        CicloColors.line,
      ),
      CButtonVariant.ghost => const _ButtonPalette(
        Colors.transparent,
        CicloColors.ink,
        Colors.transparent,
      ),
      CButtonVariant.danger => const _ButtonPalette(
        CicloColors.danger,
        CicloColors.surface,
        CicloColors.danger,
      ),
    };
  }
}

class _ButtonPalette {
  const _ButtonPalette(this.background, this.foreground, this.border);
  final Color background;
  final Color foreground;
  final Color border;
}

class CCard extends StatelessWidget {
  const CCard({
    required this.child,
    this.color = CicloColors.surface,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(CicloRadius.lg);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: color == CicloColors.ink ? CicloColors.ink : CicloColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class CSectionTitle extends StatelessWidget {
  const CSectionTitle(this.title, {this.action, this.actionLabel = "Ver tudo", super.key});

  final String title;
  final VoidCallback? action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(onPressed: action, child: Text(actionLabel)),
      ],
    );
  }
}

class CIconBox extends StatelessWidget {
  const CIconBox({
    required this.glyph,
    this.color = CicloColors.softAccent,
    this.size = 56,
    super.key,
  });

  final String glyph;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(glyph, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}

class CTextField extends StatelessWidget {
  const CTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.error,
    this.icon,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.suffix,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? error;
  final IconData? icon;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontFamily: "Outfit",
        color: CicloColors.ink,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}

class CChip extends StatelessWidget {
  const CChip({required this.label, required this.selected, this.onTap, super.key});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CicloColors.ink : CicloColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CicloRadius.pill),
        side: BorderSide(color: selected ? CicloColors.ink : CicloColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CicloRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? CicloColors.surface : CicloColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class CProgressBar extends StatelessWidget {
  const CProgressBar({required this.value, this.track = const Color(0x33FFFFFF), this.fill = CicloColors.softAccent, super.key});

  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CicloRadius.pill),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8,
        backgroundColor: track,
        color: fill,
      ),
    );
  }
}

class CEmptyState extends StatelessWidget {
  const CEmptyState({required this.title, required this.message, this.action, super.key});

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return CCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CIconBox(glyph: "◌", color: CicloColors.sandSoft),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class CErrorState extends StatelessWidget {
  const CErrorState({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return CCard(
      color: CicloColors.dangerSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Não foi desta vez",
            style: TextStyle(
              fontFamily: "Fraunces",
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: CicloColors.danger,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: CicloColors.ink, height: 1.4)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            CButton(
              label: "Tentar de novo",
              icon: Icons.refresh,
              variant: CButtonVariant.danger,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class CAvatar extends StatelessWidget {
  const CAvatar({required this.initials, this.size = 44, super.key});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CicloColors.ink,
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: CicloColors.surface,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
          fontFamily: "Outfit",
        ),
      ),
    );
  }
}

class CNavDestination {
  const CNavDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class CNavBar extends StatelessWidget {
  const CNavBar({
    required this.items,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<CNavDestination> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CicloColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CicloRadius.lg)),
        side: BorderSide(color: CicloColors.line),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 22,
                          color: i == index ? CicloColors.accent : CicloColors.muted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 12,
                            fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                            color: i == index ? CicloColors.ink : CicloColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
