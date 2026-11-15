import contextlib
import io
import importlib.util
import os
import pathlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

helper_path = pathlib.Path(__file__).with_name("open_nvim.py")
if not helper_path.exists():
    helper_path = helper_path.with_name("executable_open_nvim.py")
helper_spec = importlib.util.spec_from_file_location("open_nvim", helper_path)
helper = importlib.util.module_from_spec(helper_spec)
helper_spec.loader.exec_module(helper)


def window(identifier, command='zsh'):
    return {'id': identifier, 'is_active': True,
            'foreground_processes': [{'cmdline': [command]}]}


class WindowSelectionTests(unittest.TestCase):
    def setUp(self):
        self.tree = [{'is_focused': True, 'tabs': [
            {'id': 3, 'title': 'project', 'windows': [window(3), window(5, 'nvim')]},
            {'id': 5, 'title': 'unrelated', 'is_active': True,
             'active_window_history': [99], 'windows': [window(11)]},
        ]}]

    def test_live_session_id_ignores_other_focused_tab(self):
        with patch.dict(os.environ, {'KITTY_WINDOW_ID': '3'}):
            tab, current = helper.find_current_tab(self.tree)
        self.assertEqual(helper.pick_window(tab, current, None)['id'], 5)

    def test_missing_or_stale_session_does_not_use_focus_or_history(self):
        for identifier in ('', '99'):
            with self.subTest(identifier=identifier), patch.dict(os.environ, {'KITTY_WINDOW_ID': identifier}):
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    helper.find_current_tab(self.tree)

    def test_explicit_editor_overrides_wrong_live_session(self):
        with patch.dict(os.environ, {'KITTY_WINDOW_ID': '11'}):
            tab, current = helper.find_current_tab(self.tree, requested_window='5')
        self.assertEqual(helper.pick_window(tab, current, '5')['id'], 5)

    def test_explicit_tab_can_select_empty_editor_tab(self):
        tab, current = helper.find_current_tab(self.tree, requested_tab='5')
        self.assertIsNone(helper.pick_window(tab, current, None))
        self.assertEqual(helper.active_window_id(tab), '11')

    def test_conflicting_or_missing_explicit_targets_fail(self):
        for kwargs in ({'requested_window': '5', 'requested_tab': '5'},
                       {'requested_window': '99'}, {'requested_tab': '99'}):
            with self.subTest(kwargs=kwargs), self.assertRaises(SystemExit):
                helper.find_current_tab(self.tree, **kwargs)

    def test_explicit_shell_is_not_an_editor(self):
        tab, current = helper.find_current_tab(self.tree, requested_window='11')
        with self.assertRaises(SystemExit):
            helper.pick_window(tab, current, '11')

    def test_multiple_editors_do_not_pick_arbitrarily(self):
        self.tree[0]['tabs'][0]['windows'].append(window(8, 'nvim'))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            helper.pick_window(self.tree[0]['tabs'][0], '3', None)

    def test_launch_matches_containing_tab_not_same_numbered_tab(self):
        # Window 5 belongs to tab 3; tab 5 is unrelated.
        def launch(command):
            selector = command[command.index('--match') + 1]
            kind, identifier = selector.split(':')
            tabs = self.tree[0]['tabs']
            if kind == 'id':
                target = next(t for t in tabs if str(t['id']) == identifier)
            else:
                target = next(t for t in tabs if any(str(w['id']) == identifier for w in t['windows']))
            self.assertEqual(target['id'], 3)
            self.assertEqual(command[command.index('--source-window') + 1], 'id:5')
            return type('Result', (), {'stdout': '14\n'})()
        with patch.object(helper, 'run', side_effect=launch):
            self.assertEqual(helper.launch_nvim_window('5', '/tmp/file.go', 132), '14')


class EditCommandTests(unittest.TestCase):
    def test_special_paths_open_exact_file_at_requested_position(self):
        with tempfile.TemporaryDirectory() as directory:
            for name in ("a$b[1].txt", "space 'quote' \\ # % |.txt", "line\nbreak.txt"):
                with self.subTest(name=name):
                    path = pathlib.Path(directory) / name
                    path.write_text("first\nsecond line\n")
                    commands = helper.edit_command(path, 2, 3)[2:].rstrip("\r").split("\r")
                    arguments = ["nvim", "--headless", "-u", "NONE", "-i", "NONE"]
                    for command in commands:
                        arguments.extend(["-c", command.removeprefix(":")])
                    expected = helper.json.dumps(str(path)).replace("'", "''")
                    check = (
                        f"if expand('%:p') !=# json_decode('{expected}') || line('.') != 2 || col('.') != 3 | cquit | endif"
                    )
                    result = subprocess.run(
                        arguments + ["-c", check, "-c", "qa!"],
                        capture_output=True,
                        text=True,
                        timeout=10,
                        env={**os.environ, "NVIM_LOG_FILE": str(pathlib.Path(directory) / "nvim.log")},
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
