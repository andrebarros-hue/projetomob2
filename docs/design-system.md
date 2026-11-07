# Design system — Ciclo

## Tema

Ciclo é um app de hábitos para quem prefere constância gentil a metas agressivas. A direção visual é editorial e orgânica: papel quente, tinta escura, terracota e verde botânico.

## Tipografia

- Títulos: Fraunces, peso 600. Arquivos em `assets/fonts/fraunces-*.ttf`.
- Texto e controles: Outfit, pesos 400 a 700. Arquivos em `assets/fonts/outfit-*.ttf`.
- Headline: 36 / altura 1.05.
- Título de tela: 28 / altura 1.12.
- Título de seção: 20 / peso 600.
- Corpo: 16 / altura 1.45.
- Apoio: 14, cor muted.

## Cor

| Token | Hex | Uso |
| --- | --- | --- |
| canvas | `#F6F3EE` | Fundo das telas |
| surface | `#FFFCF8` | Cards e campos |
| ink | `#1F1E1B` | Texto e botão primário |
| muted | `#6F6C66` | Texto secundário |
| line | `#E4DDD2` | Fios e trilhos |
| accent | `#B4573F` | Ação e foco |
| softAccent | `#F4E4DC` | Fundo terracota |
| green | `#3F6B52` | Feito e confirmação |
| softGreen | `#E4EFE7` | Fundo verde |
| sand | `#8C7358` | Cor de hábito |
| sandSoft | `#F3ECDF` | Fundo areia |
| danger | `#9A3B32` | Erro |
| dangerSoft | `#F8E6E2` | Fundo de erro |

## Espaço e raio

- Passo de 4: 4, 8, 12, 16, 24, 32.
- Margem de tela: 24.
- Raio de card: 24.
- Raio de controle: 16.
- Alvo de toque mínimo: 48.

## Componentes

Ficam em `packages/ciclo_design_system` e aparecem na aba Sistema:

`CButton`, `CCard`, `CTextField`, `CChip`, `CIconBox`, `CSectionTitle`, `CProgressBar`, `CEmptyState`, `CErrorState`, `CAvatar`, `CNavBar`, `CicloTheme`.

## Ícones de hábito

A API guarda uma chave, não um emoji. A interface traduz:

| Chave | Significado |
| --- | --- |
| water | Água |
| leaf | Caminhada |
| book | Leitura |
| meditate | Pausa |
| sun | Manhã |
| moon | Noite |
| journal | Diário |
| apple | Comida |

Cores de hábito: `terracotta`, `green`, `sand`, `ink`.

## Princípios

1. Uma decisão principal por tela.
2. Respiro antes de densidade.
3. Progresso visível, sem placar agressivo.
4. Toda lista tem carregando, erro com retry e vazio.
