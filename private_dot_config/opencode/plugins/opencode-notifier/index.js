import { fileURLToPath } from "node:url"

const TITLE = "OpenCode"
const notify_script = fileURLToPath(new URL("./notify.sh", import.meta.url))

const sanitize = (value, pattern) => {
  if (!value) return ""
  return pattern.test(value) ? value : ""
}

const build_payload = (title, message) => {
  const payload = { title, message }

  const kitty_window_id = sanitize(process.env.KITTY_WINDOW_ID, /^\d+$/)
  const kitty_listen_on = sanitize(
    process.env.KITTY_LISTEN_ON,
    /^[A-Za-z0-9:/@._-]+$/,
  )

  if (kitty_window_id) payload.kitty_window_id = kitty_window_id
  if (kitty_listen_on) payload.kitty_listen_on = kitty_listen_on

  return payload
}

export const server = async (ctx) => {
  const notify = async (title, message) => {
    const payload_json = JSON.stringify(build_payload(title, message))
    await ctx.$`sh ${notify_script} ${payload_json}`.nothrow().quiet()
  }

  const notified_sessions = new Map()

  const should_notify_idle = (session_id) => {
    const now = Date.now()
    const previous = notified_sessions.get(session_id) ?? 0

    if (now - previous < 2000) return false

    notified_sessions.set(session_id, now)
    return true
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const session_id = event.properties?.sessionID
        if (session_id && should_notify_idle(session_id)) {
          await notify(TITLE, "Session complete")
        }
        return
      }

      if (
        event.type === "session.status" &&
        event.properties?.status?.type === "idle"
      ) {
        const session_id = event.properties?.sessionID
        if (session_id && should_notify_idle(session_id)) {
          await notify(TITLE, "Session complete")
        }
        return
      }

      if (event.type === "session.error") {
        await notify(TITLE, "Session error")
        return
      }

      if (
        event.type === "permission.updated" ||
        event.type === "permission.asked"
      ) {
        await notify(TITLE, "Permission requested")
        return
      }

      if (event.type === "question.asked") {
        await notify(TITLE, "Question requested")
      }
    },
  }
}

export default server
