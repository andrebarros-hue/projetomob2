import assert from "node:assert/strict";
import test from "node:test";

import { createApi } from "./logic.mjs";

const now = () => new Date(2026, 9, 30, 12, 0, 0);

test("login da Lia e listagem", () => {
  const api = createApi(now);
  const login = api.handle({
    method: "POST",
    path: "/auth/login",
    body: { email: "lia@ciclo.app", password: "123456" },
  });
  assert.equal(login.status, 200);
  assert.equal(login.body.token, "mock-token-usr_001");
  const list = api.handle({ method: "GET", path: "/habits", token: login.body.token });
  assert.equal(list.status, 200);
  assert.equal(list.body.data.length, 5);
});

test("senha errada é 401 e campo vazio é 422", () => {
  const api = createApi(now);
  const denied = api.handle({
    method: "POST",
    path: "/auth/login",
    body: { email: "lia@ciclo.app", password: "errada" },
  });
  assert.equal(denied.status, 401);
  assert.equal(denied.body.error.code, "INVALID_CREDENTIALS");
  const invalid = api.handle({
    method: "POST",
    path: "/auth/login",
    body: { email: "lia", password: "" },
  });
  assert.equal(invalid.status, 422);
  assert.ok(invalid.body.error.fields.email);
});

test("conclusão aumenta a sequência", () => {
  const api = createApi(now);
  const token = api.handle({
    method: "POST",
    path: "/auth/login",
    body: { email: "lia@ciclo.app", password: "123456" },
  }).body.token;
  const list = api.handle({ method: "GET", path: "/habits", token: token });
  const pending = list.body.data.find((habit) => habit.id === "hab_003");
  const updated = api.handle({
    method: "PATCH",
    path: "/habits/hab_003/completion",
    token,
    body: { completed: true, completedAt: "2026-10-30T12:00:00-03:00" },
  });
  assert.equal(updated.status, 200);
  assert.equal(updated.body.data.completedToday, true);
  assert.equal(updated.body.data.streak, pending.streak + 1);
  assert.equal(updated.body.user.completedCount, 19);
});

test("criar hábito inválido e válido", () => {
  const api = createApi(now);
  const token = api.handle({
    method: "POST",
    path: "/auth/login",
    body: { email: "ana@escola.com", password: "abcd" },
  }).body.token;
  const bad = api.handle({
    method: "POST",
    path: "/habits",
    token,
    body: { title: "", icon: "nope", frequency: "" },
  });
  assert.equal(bad.status, 422);
  const created = api.handle({
    method: "POST",
    path: "/habits",
    token,
    body: {
      title: "Meditar 5 min",
      icon: "meditate",
      color: "terracotta",
      frequency: "Todos os dias",
      description: "Só sentar.",
    },
  });
  assert.equal(created.status, 201);
  assert.equal(created.body.data.id, "hab_010");
});
