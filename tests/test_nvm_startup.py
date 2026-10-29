import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "private_dot_config/zsh/exports.zsh.tmpl"
GUARD = SOURCE.read_text().split("_nvm_args=()", 1)[1].split(
    'if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]', 1
)[0]


class NvmStartupTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.nvm = self.root / "nvm"
        self.version = self.nvm / "versions/node/v24.22.1"
        self.bin = self.version / "bin"
        self.system = self.root / "system"
        for directory in (self.bin, self.system):
            directory.mkdir(parents=True)
            for tool in ("node", "npm"):
                executable = directory / tool
                executable.write_text("#!/bin/sh\nexit 0\n")
                executable.chmod(0o700)
        (self.nvm / "alias").mkdir()
        (self.nvm / "alias/default").write_text("v24.22.1\n")
        self.env = dict(os.environ, NVM_DIR=str(self.nvm), NVM_BIN=str(self.bin),
                        NVM_INC=str(self.version / "include/node"),
                        MANPATH=str(self.version / "share/man"), PREFIX="",
                        NPM_CONFIG_PREFIX="", npm_config_prefix="")

    def check(self, expected, system_first=False, changes=None):
        env = self.env | (changes or {})
        directories = [str(self.bin), str(self.system)]
        if system_first:
            directories.reverse()
        script = 'path=("$1" "$2")\n_nvm_args=()\n' + GUARD + '\nprint -r -- "${_nvm_args[*]}"'
        result = subprocess.run(["/bin/zsh", "-f", "-c", script, "test", *directories],
                                env=env, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), expected)

    def test_active_environment(self):
        self.check("--no-use")

    def test_login_path_reordering(self):
        self.check("--no-use", system_first=True)

    def test_missing_environment(self):
        self.check("", changes={"NVM_BIN": "", "NVM_INC": ""})

    def test_changed_default(self):
        (self.nvm / "alias/default").write_text("v22.20.0\n")
        self.check("", system_first=True)

    def test_dynamic_default(self):
        (self.nvm / "alias/default").write_text("lts/*\n")
        self.check("", system_first=True)

    def test_missing_executable(self):
        (self.bin / "npm").unlink()
        self.check("")

    def test_inconsistent_environment(self):
        self.check("", changes={"NVM_INC": "/wrong"})
        self.check("", changes={"MANPATH": ""})

    def test_prefix_override(self):
        self.check("", changes={"NPM_CONFIG_PREFIX": "/custom"})


if __name__ == "__main__":
    unittest.main()
