# Contrato de API — Ciclo v1

Base URL do mock embutido (simulada, sem rede): `https://mock.ciclo.app/v1`

Base URL do mock HTTP local: `http://10.0.2.2:4010/v1` no emulador Android, `http://localhost:4010/v1` no simulador iOS ou no computador.

Todas as rotas, menos `POST /auth/login` e `GET /health`, exigem:

```http
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

Datas em `completedAt` seguem ISO-8601. Datas de histórico são `YYYY-MM-DD` no fuso do aparelho. Dias da semana: 1 = segunda … 7 = domingo.

Erro padrão:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Revise os campos destacados.",
    "fields": { "title": "Diga o que você quer repetir." }
  }
}
```

Códigos usados: `401 UNAUTHORIZED`, `401 INVALID_CREDENTIALS`, `404 NOT_FOUND`, `422 VALIDATION_ERROR`, `503 UPSTREAM_UNAVAILABLE`.

## GET `/health`

Não exige token.

Response `200`:

```json
{
  "status": "ok",
  "service": "ciclo-mock",
  "version": "1",
  "baseUrl": "https://mock.ciclo.app/v1"
}
```

## POST `/auth/login`

Request:

```json
{ "email": "lia@ciclo.app", "password": "123456" }
```

Response `200`:

```json
{
  "token": "mock-token-usr_001",
  "user": {
    "id": "usr_001",
    "name": "Lia Martins",
    "email": "lia@ciclo.app",
    "initials": "LM",
    "completedCount": 18
  }
}
```

Erros:

- `422` se o e-mail for inválido ou a senha vier vazia. `fields.email` e `fields.password` dizem o motivo.
- `401 INVALID_CREDENTIALS` se o e-mail já existe e a senha não confere. A conta demo é esse caso.
- Um e-mail novo com senha de 4 caracteres ou mais cria uma sessão. A senha fica gravada no mock para o próximo login.

## POST `/auth/logout`

Header com o token. Response `200`: `{ "ok": true }`. Sem token: `401`.

## GET `/me`

Response `200`:

```json
{ "user": { "id": "usr_001", "name": "Lia Martins", "email": "lia@ciclo.app", "initials": "LM", "completedCount": 18 } }
```

## GET `/habits`

Response `200`:

```json
{
  "data": [
    {
      "id": "hab_001",
      "title": "Beber água",
      "icon": "water",
      "color": "terracotta",
      "frequency": "Todos os dias",
      "weekdays": [1, 2, 3, 4, 5, 6, 7],
      "completedToday": true,
      "streak": 7,
      "description": "Manter uma garrafinha por perto durante o dia.",
      "history": ["2026-10-30", "2026-10-29"]
    }
  ],
  "meta": { "total": 5, "completedToday": 2, "dueToday": 5 },
  "user": { "id": "usr_001", "name": "Lia Martins", "email": "lia@ciclo.app", "initials": "LM", "completedCount": 18 }
}
```

`history` lista só os dias em que o hábito foi marcado. `streak` é recalculado a partir desse histórico. `completedToday` é verdadeiro se a data de hoje está em `history`.

## GET `/habits/{id}`

Response `200`: `{ "data": { } }` com o mesmo objeto de hábito. `404` se o id não existe.

## POST `/habits`

Request:

```json
{
  "title": "Meditar 5 min",
  "frequency": "Todos os dias",
  "weekdays": [1, 2, 3, 4, 5, 6, 7],
  "icon": "meditate",
  "color": "terracotta",
  "description": "Só sentar."
}
```

`weekdays` pode ser omitido se `frequency` for uma destas: `Todos os dias`, `Dias úteis`, `Seg, Qua, Sex`, `Fins de semana`.

Response `201`:

```json
{
  "data": {
    "id": "hab_010",
    "title": "Meditar 5 min",
    "icon": "meditate",
    "color": "terracotta",
    "frequency": "Todos os dias",
    "weekdays": [1, 2, 3, 4, 5, 6, 7],
    "completedToday": false,
    "streak": 0,
    "description": "Só sentar.",
    "history": []
  },
  "user": { "id": "usr_001", "name": "Lia Martins", "email": "lia@ciclo.app", "initials": "LM", "completedCount": 18 }
}
```

`422` quando falta título, o ícone não está no catálogo, a cor não está no tema, a frequência vem vazia ou a descrição passa de 280 caracteres.

Ícones aceitos: `water`, `leaf`, `book`, `meditate`, `sun`, `moon`, `journal`, `apple`.

Cores aceitas: `terracotta`, `green`, `sand`, `ink`.

## PATCH `/habits/{id}`

Mesmo corpo do POST. Campos ausentes permanecem. Response `200` com `data` e `user`. `404` se não existe. `422` se algum campo enviado for inválido.

## PATCH `/habits/{id}/completion`

Request:

```json
{ "completed": true, "completedAt": "2026-10-30T21:15:00-03:00" }
```

`completed` é obrigatório. `completedAt` é informativo; o mock usa a data local de hoje.

Response `200`:

```json
{
  "data": { "id": "hab_002", "completedToday": true, "streak": 4 },
  "message": "Ciclo atualizado",
  "user": { "id": "usr_001", "completedCount": 19 }
}
```

O objeto `data` vem completo, no mesmo formato da lista. Se `completed` for `false`, `message` é `Marcado como pendente` e a sequência do dia sai do histórico.

`422` se `completed` não for booleano. `404` se o hábito não existe.

## DELETE `/habits/{id}`

Response `200`:

```json
{ "ok": true, "user": { "id": "usr_001", "completedCount": 18 } }
```

Se o hábito estava feito hoje, `completedCount` diminui.

## POST `/dev/reset`

Rota só do mock. Devolve a lista de exemplo. Mesma resposta de `GET /habits`. Não faz parte de uma API de produção.

## Hábito de exemplo

| id | título | frequência | feito hoje | sequência |
| --- | --- | --- | --- | --- |
| hab_001 | Beber água | Todos os dias | sim | 7 |
| hab_002 | Caminhar 20 min | Seg, Qua, Sex | não | 3 |
| hab_003 | Ler antes de dormir | Todos os dias | não | 12 |
| hab_004 | Alongar de manhã | Dias úteis | não | 4 |
| hab_005 | Anotar o dia | Todos os dias | sim | 5 |
