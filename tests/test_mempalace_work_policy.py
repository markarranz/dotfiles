import json
import os
from pathlib import Path
import subprocess
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[1]


def render(path, work):
    return subprocess.check_output(
        ["chezmoi", "execute-template", "--override-data", json.dumps({"forWork": work}),
         "-f", str(ROOT / path)], text=True,
    )


def modify(script, text):
    return subprocess.check_output(["python3", "-c", script], input=text, text=True)


class WorkPolicyTest(unittest.TestCase):
    def test_codex_policy(self):
        home = os.environ["HOME"]
        original = f'''
[mcp_servers.mempalace]
command = "mempalace-mcp"
[hooks]
load_path = "{home}/.mempalace/codex-hooks.json"
[hooks.state."{home}/.mempalace/codex-hooks.json:stop:0:0"]
enabled = true
[hooks.state."browser:plugin.json#hooks[0]:stop:0:0"]
enabled = true
[sandbox_workspace_write]
writable_roots = ["{home}/.mempalace", "/tmp/keep"]
'''
        for work in (True, False):
            script = render("private_dot_codex/modify_private_config.toml.tmpl", work)
            output = modify(script, original)
            result = tomllib.loads(output)
            self.assertEqual("mempalace" in result.get("mcp_servers", {}), not work)
            self.assertEqual("load_path" in result["hooks"], not work)
            self.assertTrue(result["hooks"]["state"]["browser:plugin.json#hooks[0]:stop:0:0"]["enabled"])
            if work:
                self.assertEqual(result["sandbox_workspace_write"]["writable_roots"], ["/tmp/keep"])
            self.assertEqual(modify(script, output), output)

    def test_claude_policy(self):
        original = '{"mcpServers":{"mempalace":{},"keep":{}},"other":"unchanged"}'
        for work in (True, False):
            script = render("modify_private_dot_claude.json.tmpl", work)
            output = modify(script, original)
            expected = json.loads(original)
            if work:
                del expected["mcpServers"]["mempalace"]
            self.assertEqual(json.loads(output), expected)
            self.assertEqual(modify(script, output), output)

    def test_instructions(self):
        for work in (True, False):
            self.assertEqual("MemPalace" in render("private_dot_codex/AGENTS.md.tmpl", work), not work)


if __name__ == "__main__":
    unittest.main()
