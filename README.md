# Ciclo
Aplicativo Flutter de hábitos para Android, com interface em português e funcionamento offline por meio de um mock embutido.

## Execução rápida no Android Studio

1. Instale o Flutter SDK e os plugins **Flutter** e **Dart** no Android Studio.
2. Abra a pasta `Ciclo` — é a pasta que contém `pubspec.yaml`.
3. Execute `flutter pub get` no terminal do Android Studio.
4. Inicie um emulador Android ou conecte um aparelho com Depuração USB ativada.
5. Selecione o dispositivo e pressione **Run**.
6. Entre com `lia@ciclo.app` e `123456`.

O app já começa conectado ao mock em memória. Não é necessário iniciar Node.js para a primeira execução.

## Estrutura principal

| Caminho | Responsabilidade |
| --- | --- |
| `lib/` | Telas, navegação e estado da sessão |
| `packages/ciclo_core/` | Modelos, repositórios, transporte e mock embutido |
| `packages/ciclo_design_system/` | Tema, tokens e componentes visuais |
| `mock/` | Mock HTTP opcional em Node.js |
| `docs/api.md` | Contrato de requests, responses e erros |
| `docs/conectar-ao-mock.md` | Guia textual da integração |
| `COMO-CONECTAR-AO-MOCK.pdf` | Guia completo para apresentação e configuração |

## Alternar entre mock embutido e mock HTTP

O padrão está em `lib/main.dart`:

```dart
runApp(CicloApp(services: AppServices.mock()));
```

Para usar o servidor HTTP local no emulador Android, troque por:

```dart
runApp(CicloApp(services: AppServices.http("http://10.0.2.2:4010/v1")));
```

O Android já possui `INTERNET` e `usesCleartextTraffic` configurados para o mock local.

## Iniciar o mock HTTP opcional

Com Node.js 18 ou superior, na raiz de `Ciclo`:

```bash
node mock/server.mjs
curl http://localhost:4010/v1/health
```

Para validar o contrato do servidor:

```bash
node --test mock/logic.test.mjs
```

## Credenciais de demonstração

- E-mail: `lia@ciclo.app`
- Senha: `123456`

A cópia entregue contém somente o app Flutter/Android, documentação, testes e mock. Arquivos auxiliares do workspace e do gerador não fazem parte dela.
