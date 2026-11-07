// @ts-nocheck
export const baseUrl = "https://mock.ciclo.app/v1";

export const iconKeys = ["water", "leaf", "book", "meditate", "sun", "moon", "journal", "apple"];
export const colorKeys = ["terracotta", "green", "sand", "ink"];
export const frequencies = {
  "Todos os dias": [1, 2, 3, 4, 5, 6, 7],
  "Dias úteis": [1, 2, 3, 4, 5],
  "Seg, Qua, Sex": [1, 3, 5],
  "Fins de semana": [6, 7],
};

export function isoDate(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function weekday(date) {
  const day = date.getDay();
  return day === 0 ? 7 : day;
}

export function computeStreak(history, weekdays, now) {
  const done = new Set(history);
  const cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (!done.has(isoDate(cursor))) cursor.setDate(cursor.getDate() - 1);
  let streak = 0;
  for (let guard = 0; guard < 400; guard += 1) {
    if (weekdays.includes(weekday(cursor))) {
      if (!done.has(isoDate(cursor))) break;
      streak += 1;
    }
    cursor.setDate(cursor.getDate() - 1);
  }
  return streak;
}

function historyForStreak(now, streak, completedToday, weekdays) {
  const dates = [];
  let remaining = streak;
  const cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (!completedToday) cursor.setDate(cursor.getDate() - 1);
  for (let guard = 0; remaining > 0 && guard < 400; guard += 1) {
    if (weekdays.includes(weekday(cursor))) {
      dates.push(isoDate(cursor));
      remaining -= 1;
    }
    cursor.setDate(cursor.getDate() - 1);
  }
  return dates;
}

function makeHabit(now, spec) {
  const history = historyForStreak(now, spec.streak, spec.completedToday, spec.weekdays);
  return {
    ...spec,
    weekdays: [...spec.weekdays],
    history,
    completedToday: history.includes(isoDate(now)),
    streak: computeStreak(history, spec.weekdays, now),
  };
}

export function seedHabits(now) {
  return [
    makeHabit(now, {
      id: "hab_001",
      title: "Beber água",
      icon: "water",
      color: "terracotta",
      frequency: "Todos os dias",
      weekdays: frequencies["Todos os dias"],
      streak: 7,
      completedToday: true,
      description: "Manter uma garrafinha por perto durante o dia.",
    }),
    makeHabit(now, {
      id: "hab_002",
      title: "Caminhar 20 min",
      icon: "leaf",
      color: "green",
      frequency: "Seg, Qua, Sex",
      weekdays: frequencies["Seg, Qua, Sex"],
      streak: 3,
      completedToday: false,
      description: "Uma volta no quarteirão já conta.",
    }),
    makeHabit(now, {
      id: "hab_003",
      title: "Ler antes de dormir",
      icon: "book",
      color: "sand",
      frequency: "Todos os dias",
      weekdays: frequencies["Todos os dias"],
      streak: 12,
      completedToday: false,
      description: "Dez páginas, sem notificações por perto.",
    }),
    makeHabit(now, {
      id: "hab_004",
      title: "Alongar de manhã",
      icon: "sun",
      color: "green",
      frequency: "Dias úteis",
      weekdays: frequencies["Dias úteis"],
      streak: 4,
      completedToday: false,
      description: "Cinco minutos no chão da sala, antes do celular.",
    }),
    makeHabit(now, {
      id: "hab_005",
      title: "Anotar o dia",
      icon: "journal",
      color: "ink",
      frequency: "Todos os dias",
      weekdays: frequencies["Todos os dias"],
      streak: 5,
      completedToday: true,
      description: "Três linhas sobre o que ficou e o que pode esperar.",
    }),
  ];
}

function validEmail(email) {
  const at = email.indexOf("@");
  if (at <= 0) return false;
  const dot = email.indexOf(".", at);
  return dot > at + 1 && !email.includes(" ");
}

function nameFromEmail(email) {
  const parts = email.split("@")[0].split(/[._-]+/).filter(Boolean);
  if (!parts.length) return "Convidado";
  return parts
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join(" ");
}

function initials(name) {
  const letters = name.split(" ").filter(Boolean).slice(0, 2).map((part) => part[0].toUpperCase()).join("");
  return letters || "C";
}

function fail(status, code, message, fields = {}) {
  return { status, body: { error: { code, message, fields } } };
}

function withToday(habit, now) {
  const today = isoDate(now);
  return {
    ...habit,
    completedToday: habit.history.includes(today),
    streak: computeStreak(habit.history, habit.weekdays, now),
  };
}

export function createApi(now = () => new Date()) {
  const accounts = new Map();
  accounts.set("lia@ciclo.app", {
    password: "123456",
    user: {
      id: "usr_001",
      name: "Lia Martins",
      email: "lia@ciclo.app",
      initials: "LM",
      completedCount: 18,
    },
  });
  const tokens = new Map();
  let habits = seedHabits(now());
  let sequence = 10;
  let failNext = false;

  function requireEmail(token) {
    if (!token) return fail(401, "UNAUTHORIZED", "Envie o header Authorization: Bearer {token}.");
    const email = tokens.get(token);
    if (!email || !accounts.has(email)) {
      return fail(401, "UNAUTHORIZED", "Sessão inválida. Entre de novo.");
    }
    return email;
  }

  function page(email) {
    habits = habits.map((habit) => withToday(habit, now()));
    const due = habits.filter((habit) => habit.weekdays.includes(weekday(now()))).length;
    const done = habits.filter((habit) => habit.completedToday).length;
    return {
      status: 200,
      body: {
        data: habits,
        meta: { total: habits.length, completedToday: done, dueToday: due },
        user: accounts.get(email).user,
      },
    };
  }

  function weekdaysFrom(body, frequency) {
    if (Array.isArray(body.weekdays) && body.weekdays.length) {
      return [...new Set(body.weekdays.map(Number).filter((day) => day >= 1 && day <= 7))].sort((a, b) => a - b);
    }
    return frequencies[frequency] ? [...frequencies[frequency]] : [];
  }

  function validateDraft(body, partial) {
    const fields = {};
    const title = String(body.title ?? "").trim();
    const icon = String(body.icon ?? "").trim();
    const frequency = String(body.frequency ?? "").trim();
    const color = String(body.color ?? "").trim() || "terracotta";
    const description = String(body.description ?? "").trim();
    const touches = (key) => !partial || Object.prototype.hasOwnProperty.call(body, key);
    if (touches("title")) {
      if (!title) fields.title = "Diga o que você quer repetir.";
      if (title.length > 60) fields.title = "Use até 60 caracteres.";
    }
    if (touches("icon") && !iconKeys.includes(icon)) fields.icon = "Escolha um ícone do catálogo.";
    if (touches("frequency") || touches("weekdays")) {
      if (!frequency) fields.frequency = "Escolha uma frequência.";
      if (!weekdaysFrom(body, frequency).length) fields.weekdays = "Marque ao menos um dia.";
    }
    if (touches("color") && !colorKeys.includes(color)) fields.color = "Cor fora do tema.";
    if (touches("description") && description.length > 280) fields.description = "Use até 280 caracteres.";
    return { fields, title, icon, frequency, color, description, weekdays: weekdaysFrom(body, frequency) };
  }

  function handle({ method, path, token, body = {} }) {
    if (failNext) {
      failNext = false;
      return fail(503, "UPSTREAM_UNAVAILABLE", "O mock não respondeu. Tente de novo em instantes.");
    }
    const segments = path.split("?")[0].split("/").filter(Boolean);
    const verb = method.toUpperCase();

    if (verb === "GET" && segments.join("/") === "health") {
      return { status: 200, body: { status: "ok", service: "ciclo-mock", version: "1", baseUrl } };
    }
    if (verb === "POST" && segments.join("/") === "auth/login") {
      const email = String(body.email ?? "").trim();
      const password = String(body.password ?? "");
      const fields = {};
      if (!validEmail(email)) fields.email = "Informe um e-mail válido.";
      if (!password) fields.password = "Informe a senha.";
      if (Object.keys(fields).length) return fail(422, "VALIDATION_ERROR", "Revise e-mail e senha.", fields);
      const known = accounts.get(email);
      if (known) {
        if (known.password !== password) return fail(401, "INVALID_CREDENTIALS", "E-mail ou senha não conferem.");
      } else if (password.length < 4) {
        return fail(422, "VALIDATION_ERROR", "A senha precisa ter ao menos 4 caracteres.", {
          password: "Use 4 caracteres ou mais.",
        });
      } else {
        const name = nameFromEmail(email);
        const id = `usr_${String(accounts.size + 1).padStart(3, "0")}`;
        accounts.set(email, {
          password,
          user: { id, name, email, initials: initials(name), completedCount: 0 },
        });
      }
      const account = accounts.get(email);
      const nextToken = `mock-token-${account.user.id}`;
      tokens.set(nextToken, email);
      return { status: 200, body: { token: nextToken, user: account.user } };
    }

    const auth = requireEmail(token);
    if (typeof auth !== "string") return auth;
    const email = auth;

    if (verb === "POST" && segments.join("/") === "auth/logout") {
      for (const [key, value] of tokens) if (value === email) tokens.delete(key);
      return { status: 200, body: { ok: true } };
    }
    if (verb === "GET" && segments.join("/") === "me") {
      return { status: 200, body: { user: accounts.get(email).user } };
    }
    if (verb === "POST" && segments.join("/") === "dev/reset") {
      habits = seedHabits(now());
      return page(email);
    }
    if (segments[0] === "habits" && segments.length === 1 && verb === "GET") return page(email);
    if (segments[0] === "habits" && segments.length === 1 && verb === "POST") {
      const draft = validateDraft(body, false);
      if (Object.keys(draft.fields).length) {
        return fail(422, "VALIDATION_ERROR", "Revise os campos destacados.", draft.fields);
      }
      const habit = withToday(
        {
          id: `hab_${String(sequence).padStart(3, "0")}`,
          title: draft.title,
          icon: draft.icon,
          color: draft.color,
          frequency: draft.frequency,
          weekdays: draft.weekdays,
          description: draft.description,
          history: [],
          completedToday: false,
          streak: 0,
        },
        now(),
      );
      sequence += 1;
      habits = [...habits, habit];
      return { status: 201, body: { data: habit, user: accounts.get(email).user } };
    }
    if (segments[0] === "habits" && segments.length === 2) {
      const habit = habits.find((item) => item.id === segments[1]);
      if (!habit) return fail(404, "NOT_FOUND", "Hábito não encontrado.");
      if (verb === "GET") return { status: 200, body: { data: withToday(habit, now()) } };
      if (verb === "DELETE") {
        habits = habits.filter((item) => item.id !== habit.id);
        if (habit.completedToday) {
          const account = accounts.get(email);
          account.user = { ...account.user, completedCount: Math.max(0, account.user.completedCount - 1) };
        }
        return { status: 200, body: { ok: true, user: accounts.get(email).user } };
      }
      if (verb === "PATCH") {
        const draft = validateDraft({ ...habit, ...body }, true);
        if (Object.keys(draft.fields).length) {
          return fail(422, "VALIDATION_ERROR", "Revise os campos destacados.", draft.fields);
        }
        const updated = withToday(
          {
            ...habit,
            title: draft.title || habit.title,
            icon: draft.icon || habit.icon,
            color: draft.color || habit.color,
            frequency: draft.frequency || habit.frequency,
            weekdays: draft.weekdays.length ? draft.weekdays : habit.weekdays,
            description: Object.prototype.hasOwnProperty.call(body, "description") ? draft.description : habit.description,
          },
          now(),
        );
        habits = habits.map((item) => (item.id === habit.id ? updated : item));
        return { status: 200, body: { data: updated, user: accounts.get(email).user } };
      }
    }
    if (segments[0] === "habits" && segments[2] === "completion" && verb === "PATCH") {
      const habit = habits.find((item) => item.id === segments[1]);
      if (!habit) return fail(404, "NOT_FOUND", "Hábito não encontrado.");
      if (typeof body.completed !== "boolean") {
        return fail(422, "VALIDATION_ERROR", "Informe se o hábito foi feito.", { completed: "Use true ou false." });
      }
      const today = isoDate(now());
      const history = [...habit.history];
      const had = history.includes(today);
      if (body.completed && !had) history.push(today);
      if (!body.completed && had) history.splice(history.indexOf(today), 1);
      const updated = withToday({ ...habit, history }, now());
      habits = habits.map((item) => (item.id === habit.id ? updated : item));
      if (body.completed !== had) {
        const account = accounts.get(email);
        const next = account.user.completedCount + (body.completed ? 1 : -1);
        account.user = { ...account.user, completedCount: Math.max(0, next) };
      }
      return {
        status: 200,
        body: {
          data: updated,
          message: body.completed ? "Ciclo atualizado" : "Marcado como pendente",
          user: accounts.get(email).user,
        },
      };
    }
    return fail(404, "NOT_FOUND", "Rota não encontrada.");
  }

  return {
    handle,
    triggerFailure() {
      failNext = true;
    },
  };
}
