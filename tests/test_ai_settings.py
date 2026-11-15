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
[sandbox_workspace_write]
writable_roots = ["/tmp/keep"]
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
                        False,
                    )
                self.assertEqual(data["notify"], ["local-notifier"])
                self.assertEqual(data["sandbox_workspace_write"]["writable_roots"], ["/tmp/keep"])
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


    def test_valid_toml_forms_preserve_unmanaged_values(self):
        cases = [
            '''developer_instructions = """
[tui]
notifications = false
web_search = "disabled"
"""
[tui] # preferences
notifications = false
screen_reader_detection_done = true
''',
            '''"web_search" = "disabled"
tui.notifications = false
features = { hooks = false, custom = true }
[ 'plugins' . 'browser-use@openai-bundled' ] # local preference
enabled = false
local = "keep"
''',
            '''[mcp_servers] # servers
circleci = { command = "retired", env = { OLD = "value" }, extra = { key = true } }
keep = { command = "keep", args = ["a", "b"] }
[local]
empty = {}
items = [{ name = "first", nested = { value = true } }]
date = 2026-11-14
time = 12:34:56.123
timestamp = 2026-11-14T12:34:56Z
number = inf
text = "unicode é and control \\u007f"
''',
        ]
        for work in (True, False):
            script = subprocess.check_output(
                ["chezmoi", "execute-template", "--override-data", json.dumps({"forWork": work}),
                 "--file", str(ROOT / "private_dot_codex/modify_private_config.toml.tmpl")], text=True,
            )
            for current in cases:
                with self.subTest(work=work, current=current):
                    original = tomllib.loads(current)
                    output = run_modifier(script, current)
                    data = tomllib.loads(output)
                    self.assertEqual(data["web_search"], "live")
                    self.assertTrue(data["tui"]["notifications"])
                    self.assertTrue(data["features"]["hooks"])
                    for key in ("developer_instructions", "local"):
                        if key in original:
                            self.assertEqual(data[key], original[key])
                    self.assertTrue(data["tui"].get("screen_reader_detection_done", True))
                    self.assertTrue(data["features"].get("custom", True))
                    self.assertTrue(data["plugins"]["browser-use@openai-bundled"]["enabled"])
                    if "plugins" in original:
                        self.assertEqual(data["plugins"]["browser-use@openai-bundled"]["local"], "keep")
                    if "mcp_servers" in original:
                        self.assertNotIn("circleci", data["mcp_servers"])
                        self.assertEqual(data["mcp_servers"]["keep"], original["mcp_servers"]["keep"])
                    self.assertEqual(run_modifier(script, output), output)

    def test_invalid_input_emits_no_replacement(self):
        script = subprocess.check_output(
            ["chezmoi", "execute-template", "--file",
             str(ROOT / "private_dot_codex/modify_private_config.toml.tmpl")], text=True,
        )
        result = subprocess.run([sys.executable, "-c", script], input="[broken", text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")


class ClaudeSettingsTests(unittest.TestCase):
    def test_work_only_plugins_preserve_personal_preferences(self):
        keys = ("codex@openai-codex", "feature-dev@claude-plugins-official",
                "playground@claude-plugins-official", "playwright@claude-plugins-official")
        for work in (True, False):
            script = subprocess.check_output(
                ["chezmoi", "execute-template", "--override-data", json.dumps({"forWork": work}),
                 "--file", str(ROOT / "private_dot_claude/modify_private_settings.json.tmpl")], text=True,
            )
            for plugins in ({}, dict.fromkeys(keys, False), dict.fromkeys(keys, True)):
                with self.subTest(work=work, plugins=plugins):
                    output = run_modifier(script, json.dumps({"enabledPlugins": plugins}))
                    actual = json.loads(output)["enabledPlugins"]
                    for key in keys:
                        if work:
                            self.assertTrue(actual[key])
                        elif key in plugins:
                            self.assertEqual(actual[key], plugins[key])
                        else:
                            self.assertNotIn(key, actual)
                    self.assertEqual(run_modifier(script, output), output)

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
                ]}],
            },
            "editorMode": "vim",
        })
        script = subprocess.check_output(
            ["chezmoi", "execute-template", "--file",
             str(ROOT / "private_dot_claude/modify_private_settings.json.tmpl")], text=True,
        )
        output = run_modifier(script, current)
        data = json.loads(output)
        self.assertEqual(data["hooks"], {"Notification": [{"hooks": [notification]}]})
        self.assertEqual(data["editorMode"], "vim")
        self.assertEqual(run_modifier(script, output), output)


if __name__ == "__main__":
    unittest.main()
