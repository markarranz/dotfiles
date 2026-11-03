import json
import os
from pathlib import Path
import subprocess
import sys
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[1]


def run_modifier(script, current):
    return subprocess.run(
        [sys.executable, "-c", script],
        input=current,
        text=True,
        capture_output=True,
        check=True,
    ).stdout


class CodexSettingsTests(unittest.TestCase):
    def test_work_and_personal_settings(self):
        current = '''notify = ["local-notifier"]
[tui]
status_line = [
    "model-with-reasoning", # existing item
    "current-dir",
]
screen_reader_detection_done = true
[plugins."local-plugin"]
enabled = true
[mcp_servers.circleci]
command = "retired-server"
[mcp_servers.circleci.env]
OLD = "value"
'''
        for for_work in (True, False):
            with self.subTest(for_work=for_work):
                script = subprocess.run(
                    [
                        "chezmoi", "execute-template",
                        "--override-data", json.dumps({"forWork": for_work}),
                        "--file", str(ROOT / "private_dot_codex/modify_private_config.toml.tmpl"),
                    ],
                    text=True,
                    capture_output=True,
                    check=True,
                ).stdout
                output = run_modifier(script, current)
                data = tomllib.loads(output)
                for plugin in ("documents", "presentations", "spreadsheets"):
                    self.assertEqual(
                        data["plugins"][f"{plugin}@openai-primary-runtime"]["enabled"],
                        not for_work,
                    )
                self.assertEqual(data["notify"], ["local-notifier"])
                self.assertTrue(data["plugins"]["local-plugin"]["enabled"])
                self.assertTrue(data["tui"]["screen_reader_detection_done"])
                usage_items = {
                    "five-hour-limit", "weekly-limit",
                    "thread-credits", "estimated-thread-cost",
                }
                self.assertEqual(
                    set(data["tui"]["status_line"]) & usage_items,
                    set() if for_work else usage_items,
                )
                self.assertEqual(len(data["tui"]["status_line"]), 8 if for_work else 12)
                self.assertNotIn("circleci", data.get("mcp_servers", {}))
                self.assertEqual(run_modifier(script, output), output)
                tomllib.loads(run_modifier(script, ""))


class ClaudeSettingsTests(unittest.TestCase):
    def test_retired_hooks_removed_and_other_hooks_preserved(self):
        home = os.environ["HOME"]
        notification = {"type": "command", "command": "bash ~/.claude/hooks/notify.sh"}
        current = json.dumps({
            "hooks": {
                "Notification": [{"hooks": [
                    notification,
                    {"command": f"python3 {home}/.claude/hooks/agent-control-state-tracker.local.py"},
                ]}],
                "SessionStart": [{"hooks": [
                    {"command": f"{home}/.claude/hooks/session-start.local.sh"},
                    {"command": f"{home}/.mempalace/mempalace-hook.sh session-start"},
                ]}],
            },
            "editorMode": "vim",
        })
        script = (ROOT / "private_dot_claude/modify_private_settings.json").read_text()
        output = run_modifier(script, current)
        data = json.loads(output)
        self.assertEqual(data["hooks"], {"Notification": [{"hooks": [notification]}]})
        self.assertEqual(data["editorMode"], "vim")
        self.assertEqual(run_modifier(script, output), output)


if __name__ == "__main__":
    unittest.main()
