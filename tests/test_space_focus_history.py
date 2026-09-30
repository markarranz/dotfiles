import contextlib
import importlib.util
import io
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "history", Path(__file__).parents[1] / "private_dot_config/yabai/executable_space_focus_history.py")
history = importlib.util.module_from_spec(spec)
spec.loader.exec_module(history)


class HistoryTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.spaces = [{"index": 1, "uuid": "one"}, {"index": 2, "uuid": "two"}]
        self.windows = [dict(id=i, pid=i + 100, app=f"app-{i}", space=1,
                             role="AXWindow", subrole="AXStandardWindow",
                             **{"has-focus": i == 2, "has-ax-reference": True})
                        for i in (1, 2)]
        self.focused = self.windows[1]
        self.patch_temp = patch.object(history.tempfile, "gettempdir", return_value=self.directory.name)
        self.patch_query = patch.object(history, "query", side_effect=self.query)
        self.patch_temp.start()
        self.patch_query.start()
        self.addCleanup(self.patch_temp.stop)
        self.addCleanup(self.patch_query.stop)

    def query(self, *args):
        if args == ("--windows", "--window"):
            return dict(self.focused)
        if args == ("--spaces",):
            return self.spaces
        if args[0] == "--spaces":
            return next(s for s in self.spaces if s["index"] == int(args[2]))
        return [w for w in self.windows if w["space"] == int(args[2])]

    def preferred(self, index="1"):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            history.run("preferred", index)
        return output.getvalue().strip()

    def test_no_history(self):
        self.assertEqual(self.preferred(), "")

    def test_last_focused_not_first_window(self):
        history.run("remember")
        self.assertEqual(self.preferred(), "2")

    def test_latest_focus_wins(self):
        history.run("remember")
        self.focused = self.windows[0]
        self.focused["has-focus"] = True
        history.run("remember")
        self.assertEqual(self.preferred(), "1")

    def test_space_renumbering(self):
        history.run("remember")
        self.spaces[0]["index"] = 3
        for window in self.windows:
            window["space"] = 3
        self.assertEqual(self.preferred("3"), "2")

    def test_unavailable_or_reused_window(self):
        history.run("remember")
        for key, value in [("is-hidden", True), ("is-minimized", True),
                           ("is-sticky", True), ("pid", 999),
                           ("space", 2), ("has-ax-reference", False)]:
            with self.subTest(key=key):
                original = dict(self.focused)
                self.focused[key] = value
                self.assertEqual(self.preferred(), "")
                self.focused.clear()
                self.focused.update(original)

    def test_closed_window(self):
        history.run("remember")
        self.windows.pop()
        self.assertEqual(self.preferred(), "")

    def test_dialog_does_not_replace_history(self):
        history.run("remember")
        self.focused = dict(self.windows[0], subrole="AXSystemDialog")
        history.run("remember")
        self.assertEqual(self.preferred(), "2")

    def test_stale_focus_does_not_replace_history(self):
        history.run("remember")
        real_query = self.query
        count = 0

        def query(*args):
            nonlocal count
            if args == ("--windows", "--window"):
                count += 1
                return dict(self.windows[0 if count == 1 else 1], **{"has-focus": True})
            return real_query(*args)

        with patch.object(history, "query", side_effect=query):
            history.run("remember")
        self.assertEqual(self.preferred(), "2")


if __name__ == "__main__":
    unittest.main()
