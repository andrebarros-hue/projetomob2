# Mock HTTP

Mesmo contrato de `docs/api.md`, num processo separado.

```bash
node mock/server.mjs
```

Sobe em `http://localhost:4010/v1`. No emulador Android use `http://10.0.2.2:4010/v1`.

Para os testes do contrato:

```bash
node --test mock/logic.test.mjs
```

O app não precisa deste processo. `AppServices.mock()` já responde dentro do Flutter. Este servidor existe para o passo em que a turma troca o transporte, explicado no PDF.
