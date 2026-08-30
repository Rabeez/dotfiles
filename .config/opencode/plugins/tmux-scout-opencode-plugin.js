// tmux-scout-opencode-plugin version: v2
// OpenCode event bridge for tmux-scout. It spawns the generic tmux-scout hook
// so events still work when the optional watchdog bridge is disabled.
import { spawnSync } from "child_process";

const HOOK_PATH = "/Users/rabeezriaz/dotfiles/.config/tmux/plugins/tmux-scout/scripts/hooks/generic.js";
const NODE = process.env.TMUX_SCOUT_NODE || "node";
const ENV_KEYS = ["TMUX", "TMUX_PANE", "TERM_PROGRAM", "ITERM_SESSION_ID", "TERM_SESSION_ID", "KITTY_WINDOW_ID", "KITTY_LISTEN_ON"];

function runHook(payload) {
  try {
    spawnSync(NODE, [HOOK_PATH, "--agent", "opencode"], {
      input: JSON.stringify(payload),
      encoding: "utf-8",
      stdio: ["pipe", "ignore", "ignore"],
      env: { ...process.env }
    });
  } catch {}
}

function makePayload(hookEventName, sessionID, cwd, extra = {}) {
  return {
    hook_event_name: hookEventName,
    session_id: "opencode-" + sessionID,
    cwd: cwd || process.env.PWD || ".",
    ...extra
  };
}

function subagentFields(properties) {
  return properties && properties.agent_id ? { agent_id: properties.agent_id } : {};
}

export default async () => {
  const msgRoles = new Map();
  const assistantTextBySession = new Map();
  const userTextBySession = new Map();
  const sessionCwd = new Map();
  const sessionTitle = new Map();
  const childSessions = new Set();

  function clearSessionMessageState(sessionID) {
    for (const [messageID, meta] of msgRoles) {
      if (meta.sessionID !== sessionID) continue;
      msgRoles.delete(messageID);
      assistantTextBySession.delete(messageID);
      userTextBySession.delete(messageID);
    }
  }

  function textPart(store, messageID, partID, text) {
    let parts = store.get(messageID);
    if (!parts) {
      parts = new Map();
      store.set(messageID, parts);
    }
    if (text) parts.set(partID, text);
    else parts.delete(partID);
    return Array.from(parts.values()).map(v => String(v || "").trim()).filter(Boolean).join("\n");
  }

  function toolName(raw) {
    const value = String(raw || "Tool");
    return value.charAt(0).toUpperCase() + value.slice(1);
  }

  return {
    "event": async ({ event }) => {
      try {
        const t = event.type;
        const p = event.properties || {};
        const extra = subagentFields(p);

        // Keep childSessions filtering aligned with the reference behavior. OpenCode task parts
        // and parentID sessions are child agents and must never mutate the
        // top-level session state.
        if (t === "message.part.updated" && p.part?.type === "tool" && p.part?.tool === "task") {
          const childSessionID = p.part.state?.metadata?.sessionId;
          if (childSessionID) childSessions.add(childSessionID);
        }
        if (t === "session.created" && p.info?.parentID) {
          childSessions.add(p.info.id);
        }
        if (p.sessionID && childSessions.has(p.sessionID)) return;

        if (t === "session.created" && p.info) {
          if (childSessions.has(p.info.id)) return;
          const sid = p.info.id;
          const cwd = p.info.directory || "";
          sessionCwd.set(sid, cwd);
          const title = p.info.title || p.info.name || "";
          if (title) sessionTitle.set(sid, title);
          runHook(makePayload("SessionStart", sid, cwd, { session_title: title, ...extra }));
          return;
        }

        if (t === "session.deleted" && p.info) {
          const sid = p.info.id;
          if (childSessions.has(sid)) {
            childSessions.delete(sid);
            return;
          }
          runHook(makePayload("SessionEnd", sid, sessionCwd.get(sid), {
            last_assistant_message: assistantTextBySession.get(sid),
            session_title: sessionTitle.get(sid),
            ...extra
          }));
          sessionCwd.delete(sid);
          assistantTextBySession.delete(sid);
          sessionTitle.delete(sid);
          clearSessionMessageState(sid);
          return;
        }

        if (t === "session.updated" && p.info) {
          const sid = p.info.id;
          if (childSessions.has(sid)) return;
          if (p.info.directory) sessionCwd.set(sid, p.info.directory);
          const title = p.info.title || p.info.name || "";
          if (title) sessionTitle.set(sid, title);
          if (p.info.time?.archived) {
            runHook(makePayload("SessionEnd", sid, sessionCwd.get(sid), {
              last_assistant_message: assistantTextBySession.get(sid),
              session_title: sessionTitle.get(sid),
              ...extra
            }));
            sessionCwd.delete(sid);
            assistantTextBySession.delete(sid);
            sessionTitle.delete(sid);
            clearSessionMessageState(sid);
          }
          return;
        }

        if (t === "session.status" && p.sessionID && p.status?.type === "idle") {
          runHook(makePayload("Stop", p.sessionID, sessionCwd.get(p.sessionID), {
            last_assistant_message: assistantTextBySession.get(p.sessionID),
            session_title: sessionTitle.get(p.sessionID),
            ...extra
          }));
          return;
        }

        if (t === "message.updated" && p.info?.id && p.info?.sessionID) {
          if (childSessions.has(p.info.sessionID)) return;
          msgRoles.set(p.info.id, { role: p.info.role, sessionID: p.info.sessionID });
          return;
        }

        if (t === "message.part.updated" && p.part?.type === "text" && p.part?.messageID) {
          const meta = msgRoles.get(p.part.messageID);
          if (!meta) return;
          if (childSessions.has(meta.sessionID)) return;
          if (meta.role === "user") {
            if (p.part.synthetic === true || p.part.ignored === true) return;
            const prompt = textPart(userTextBySession, p.part.messageID, p.part.id || p.part.messageID, p.part.text || "");
            if (prompt) runHook(makePayload("UserPromptSubmit", meta.sessionID, sessionCwd.get(meta.sessionID), { prompt, ...extra }));
            return;
          }
          if (meta.role === "assistant") {
            const text = textPart(assistantTextBySession, p.part.messageID, p.part.id || p.part.messageID, p.part.text || "");
            if (text) {
              assistantTextBySession.set(meta.sessionID, text);
              runHook(makePayload("AssistantMessageUpdate", meta.sessionID, sessionCwd.get(meta.sessionID), {
                assistant_message_preview: text,
                session_title: sessionTitle.get(meta.sessionID),
                ...extra
              }));
            }
            return;
          }
        }

        if (t === "message.part.updated" && p.part?.type === "tool" && p.part?.sessionID) {
          const st = p.part.state?.status;
          const sid = p.part.sessionID;
          if (childSessions.has(sid)) return;
          const name = toolName(p.part.tool);
          if (st === "running" || st === "pending") {
            runHook(makePayload("PreToolUse", sid, sessionCwd.get(sid), {
              tool_name: name,
              tool_input: p.part.state?.input || {},
              ...extra
            }));
            return;
          }
          if (st === "completed" || st === "error") {
            runHook(makePayload("PostToolUse", sid, sessionCwd.get(sid), { tool_name: name, ...extra }));
          }
          return;
        }

        if (t === "permission.asked" && p.id && p.sessionID) {
          if (childSessions.has(p.sessionID)) return;
          const name = toolName(p.permission);
          const patterns = p.patterns || [];
          runHook(makePayload("PermissionRequest", p.sessionID, sessionCwd.get(p.sessionID), {
            tool_name: name,
            tool_input: { patterns, metadata: p.metadata, command: p.permission === "bash" ? patterns.join(" && ") : undefined },
            permission_description: patterns[0] || name,
            ...extra
          }));
          return;
        }

        if (t === "permission.replied" && p.sessionID) {
          if (childSessions.has(p.sessionID)) return;
          runHook(makePayload("PostToolUse", p.sessionID, sessionCwd.get(p.sessionID), extra));
          return;
        }

        if (t === "question.asked" && p.id && p.sessionID) {
          if (childSessions.has(p.sessionID)) return;
          const questions = Array.isArray(p.questions) ? p.questions : [];
          runHook(makePayload("QuestionAsked", p.sessionID, sessionCwd.get(p.sessionID), {
            question_text: questions.map(q => q.question).filter(Boolean).join("; ") || "OpenCode has a question",
            ...extra
          }));
          return;
        }

        if ((t === "question.replied" || t === "question.rejected") && p.sessionID) {
          if (childSessions.has(p.sessionID)) return;
          runHook(makePayload("PostToolUse", p.sessionID, sessionCwd.get(p.sessionID), extra));
        }
      } catch {}
    },
    "shell.env": async (_input, output) => {
      output.env.TMUX_SCOUT_ACTIVE = "1";
      for (const key of ENV_KEYS) {
        if (process.env[key]) output.env["TMUX_SCOUT_" + key] = process.env[key];
      }
    }
  };
};
