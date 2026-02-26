const IDLE_DELAY_MS = 1500
const TITLE = "OpenCode"
const IDLE_MSG = "Agent is ready for input"
const PERMISSION_MSG = "Agent needs permission to continue"

export default async function notifier(ctx) {
	const isKitty = process.env.TERM === "xterm-kitty" || !!process.env.KITTY_WINDOW_ID

	const pendingTimers = new Map()
	const notifiedSessions = new Set()
	const sessionActivitySinceIdle = new Set()
	const notificationVersions = new Map()
	const executingNotifications = new Set()
	const subagentSessions = new Set()

	function cancelPending(sessionID) {
		const timer = pendingTimers.get(sessionID)
		if (timer) {
			clearTimeout(timer)
			pendingTimers.delete(sessionID)
		}
		sessionActivitySinceIdle.add(sessionID)
		notificationVersions.set(sessionID, (notificationVersions.get(sessionID) ?? 0) + 1)
	}

	function markActivity(sessionID) {
		cancelPending(sessionID)
		if (!executingNotifications.has(sessionID)) {
			notifiedSessions.delete(sessionID)
		}
	}

	async function sendNotification(sessionID, message) {
		if (isKitty) {
			await ctx.$`kitten notify --app-name ${TITLE} --sound-name system --identifier ${sessionID} ${TITLE} ${message}`.nothrow().quiet()
			return
		}
		if (process.platform === "darwin") {
			const escaped = message.replace(/\\/g, "\\\\").replace(/"/g, '\\"')
			await ctx.$`osascript -e ${"display notification \"" + escaped + "\" with title \"" + TITLE + "\""}`.nothrow().quiet()
			ctx.$`afplay /System/Library/Sounds/Glass.aiff`.nothrow().quiet()
			return
		}
		if (process.platform === "linux") {
			await ctx.$`notify-send ${TITLE} ${message}`.nothrow().quiet()
			ctx.$`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`.nothrow().quiet()
		}
	}

	async function executeNotification(sessionID, version, message) {
		if (executingNotifications.has(sessionID)) {
			pendingTimers.delete(sessionID)
			return
		}
		if (notificationVersions.get(sessionID) !== version) {
			pendingTimers.delete(sessionID)
			return
		}
		if (sessionActivitySinceIdle.has(sessionID)) {
			sessionActivitySinceIdle.delete(sessionID)
			pendingTimers.delete(sessionID)
			return
		}
		if (notifiedSessions.has(sessionID)) {
			pendingTimers.delete(sessionID)
			return
		}
		executingNotifications.add(sessionID)
		try {
			notifiedSessions.add(sessionID)
			await sendNotification(sessionID, message)
		} finally {
			executingNotifications.delete(sessionID)
			pendingTimers.delete(sessionID)
			if (sessionActivitySinceIdle.has(sessionID)) {
				notifiedSessions.delete(sessionID)
				sessionActivitySinceIdle.delete(sessionID)
			}
		}
	}

	function scheduleIdle(sessionID) {
		if (notifiedSessions.has(sessionID)) return
		if (pendingTimers.has(sessionID)) return
		if (executingNotifications.has(sessionID)) return
		sessionActivitySinceIdle.delete(sessionID)
		const version = (notificationVersions.get(sessionID) ?? 0) + 1
		notificationVersions.set(sessionID, version)
		const timer = setTimeout(() => {
			executeNotification(sessionID, version, IDLE_MSG)
		}, IDLE_DELAY_MS)
		pendingTimers.set(sessionID, timer)
	}

	function deleteSession(sessionID) {
		cancelPending(sessionID)
		notifiedSessions.delete(sessionID)
		sessionActivitySinceIdle.delete(sessionID)
		notificationVersions.delete(sessionID)
		executingNotifications.delete(sessionID)
		subagentSessions.delete(sessionID)
	}

	return {
		event: async ({ event }) => {
			const props = event.properties

			if (event.type === "session.created") {
				const info = props?.info
				if (!info?.id) return
				if (info.parentID) {
					subagentSessions.add(info.id)
				}
				markActivity(info.id)
				return
			}

			if (event.type === "session.idle") {
				const sessionID = props?.sessionID
				if (!sessionID) return
				if (subagentSessions.has(sessionID)) return
				scheduleIdle(sessionID)
				return
			}

			if (event.type === "message.updated") {
				const sessionID = props?.info?.sessionID
				if (sessionID) markActivity(sessionID)
				return
			}

			if (event.type === "session.deleted") {
				const id = props?.info?.id
				if (id) deleteSession(id)
				return
			}

			if (event.type === "permission.updated") {
				const sessionID = props?.sessionID
				if (!sessionID) return
				if (subagentSessions.has(sessionID)) return
				markActivity(sessionID)
				await sendNotification(sessionID, PERMISSION_MSG)
			}
		},
	}
}
