import os
from pathlib import Path
import subprocess
import tempfile
import unittest


MODULE = Path(__file__).resolve().parents[1] / "private_dot_config/zsh/node-completions.zsh"


class CompletionCacheTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.tool = self.root / "node"
        self.log = self.root / "calls"
        self.env = dict(os.environ, XDG_CACHE_HOME=str(self.root / "cache"),
                        TEST_LOG=str(self.log))
        self.write_tool("one")

    def write_tool(self, value, fail=False):
        self.tool.write_text(
            '#!/bin/sh\nprintf "call\\n" >> "$TEST_LOG"\n'
            + ('exit 1\n' if fail else f"printf 'completion_value={value}\\n'\n")
        )
        self.tool.chmod(0o700)

    def run_shell(self, extra="", dependency=""):
        script = '''
source "$1"
_load_node_completion node "$2" "$3" --completion-bash || exit 1
print -r -- "$completion_value"
'''
        return subprocess.run(
            ["zsh", "-f", "-c", script + extra, "test", str(MODULE),
             str(self.tool), dependency], env=self.env, text=True,
            capture_output=True,
        )

    def calls(self):
        return len(self.log.read_text().splitlines())

    def test_cold_warm_and_same_shell(self):
        result = self.run_shell('_load_node_completion node "$2" "$3" --completion-bash\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "one")
        self.assertEqual(self.calls(), 1)
        result = self.run_shell()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "one")
        self.assertEqual(self.calls(), 1)

    def test_changed_executable(self):
        self.assertEqual(self.run_shell().returncode, 0)
        self.write_tool("version_two")
        result = self.run_shell()
        self.assertEqual(result.stdout.strip(), "version_two")
        self.assertEqual(self.calls(), 2)

    def test_changed_path(self):
        self.assertEqual(self.run_shell().returncode, 0)
        self.tool = self.root / "other node"
        self.write_tool("other")
        self.assertEqual(self.run_shell().stdout.strip(), "other")
        self.assertEqual(self.calls(), 2)

    def test_changed_package_metadata(self):
        package = self.root / "package.json"
        package.write_text('{"version":"1"}')
        self.assertEqual(self.run_shell(dependency=str(package)).returncode, 0)
        package.write_text('{"version":"2.0"}')
        self.assertEqual(self.run_shell(dependency=str(package)).returncode, 0)
        self.assertEqual(self.calls(), 2)

    def test_failure_preserves_cache_and_retries(self):
        self.assertEqual(self.run_shell().returncode, 0)
        cache = self.root / "cache/zsh/completions/node.zsh"
        original = cache.read_text()
        self.write_tool("", fail=True)
        self.assertNotEqual(self.run_shell().returncode, 0)
        self.assertNotEqual(self.run_shell().returncode, 0)
        self.assertEqual(cache.read_text(), original)
        self.assertEqual(self.calls(), 3)

    def test_unwritable_cache_falls_back(self):
        blocked = self.root / "not_a_directory"
        blocked.write_text("")
        self.env["XDG_CACHE_HOME"] = str(blocked)
        result = self.run_shell()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "one")


if __name__ == "__main__":
    unittest.main()
