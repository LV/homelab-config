"""Clipboard smoke tests. Pass the built copy and pasta executables as arguments.

Optionally pass the evaluated programs.neovim.initLua file as a third argument.
Uses only Python's standard library, plus nvim for the optional editor test.
"""

import base64
import errno
import fcntl
import os
from pathlib import Path
import pty
import select
import stat
import subprocess
import sys
import tempfile
import termios
import time
import unittest

COPY, PASTA = map(os.path.abspath, sys.argv[1:3])
INIT_LUA = os.path.abspath(sys.argv[3]) if len(sys.argv) > 3 else None
sys.argv = sys.argv[:1]


class ClipboardTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = {
            **os.environ,
            "HOME": str(self.root),
            "XDG_STATE_HOME": str(self.root / "state"),
            "TERM": "xterm-256color",
        }

    def run_command(self, executable, data=None, env=None):
        # A fresh session ensures there is no controlling terminal to overwrite.
        return subprocess.run(
            [executable], input=data, capture_output=True, env=env or self.env,
            start_new_session=True, timeout=15,
        )

    def copy_with_terminal(self, data, term):
        master, slave = pty.openpty()
        try:
            with tempfile.TemporaryFile() as source:
                source.write(data)
                source.seek(0)

                def attach_terminal():
                    os.setsid()
                    fcntl.ioctl(slave, termios.TIOCSCTTY, 0)

                process = subprocess.Popen(
                    [COPY], stdin=source, stdout=slave, stderr=slave,
                    env={**self.env, "TERM": term}, pass_fds=(slave,),
                    preexec_fn=attach_terminal,
                )
                self.addCleanup(lambda: process.poll() is None and process.kill())
                os.close(slave)
                slave = None
                output = bytearray()
                deadline = time.monotonic() + 15
                while True:
                    remaining = deadline - time.monotonic()
                    if remaining <= 0 or not select.select([master], [], [], remaining)[0]:
                        self.fail("copy timed out while writing OSC 52")
                    try:
                        chunk = os.read(master, 65536)
                    except OSError as error:
                        if error.errno == errno.EIO:
                            break
                        raise
                    if not chunk:
                        break
                    output.extend(chunk)
                self.assertEqual(process.wait(timeout=5), 0, output)
                return bytes(output)
        finally:
            os.close(master)
            if slave is not None:
                os.close(slave)

    def test_local_roundtrip_and_permissions(self):
        result = self.run_command(COPY, "héllo\nworld\n\n".encode())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b"")
        saved = self.root / "state/clipboard"
        self.assertEqual(saved.read_bytes(), "héllo\nworld".encode())
        self.assertEqual(stat.S_IMODE(saved.stat().st_mode), 0o600)
        self.assertEqual(list(saved.parent.glob(".clipboard.*")), [])
        result = self.run_command(PASTA)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, saved.read_bytes())

    def test_empty_clipboard(self):
        self.assertEqual(self.run_command(COPY, b"\n\n").returncode, 0)
        result = self.run_command(PASTA)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b"")

    def test_default_state_location(self):
        env = dict(self.env)
        del env["XDG_STATE_HOME"]
        result = self.run_command(COPY, b"fallback", env)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / ".local/state/clipboard").read_bytes(), b"fallback")

    def test_missing_clipboard(self):
        result = self.run_command(PASTA)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"no saved clipboard", result.stderr)

    def test_osc52_including_large_payload(self):
        for payload in (b"", "hello 🌍\nsecond line".encode(), b"x" * 262144):
            with self.subTest(size=len(payload)):
                output = self.copy_with_terminal(payload + b"\n", "xterm-256color")
                self.assertEqual(output, b"\x1b]52;c;" + base64.b64encode(payload) + b"\x07")
                self.assertEqual((self.root / "state/clipboard").read_bytes(), payload)

    def test_console_and_dumb_terminals_only_save_locally(self):
        for term in ("linux", "dumb", ""):
            with self.subTest(term=term):
                self.assertEqual(self.copy_with_terminal(b"console\n", term), b"")
                self.assertEqual((self.root / "state/clipboard").read_bytes(), b"console")

    @unittest.skipUnless(INIT_LUA, "no Neovim initLua supplied")
    def test_neovim_sends_osc52_via_ui(self):
        script = self.root / "ui-test.lua"
        script.write_text('''
local emitted = {}
vim.api.nvim_ui_send = function(data) table.insert(emitted, data) end
vim.fn.setreg("+", "editor copy\\n", "v")
assert(vim.fn.getreg("+") == "editor copy")
local expected = string.char(27) .. "]52;c;"
  .. vim.base64.encode("editor copy") .. string.char(27) .. "\\\\"
assert(#emitted == 1 and emitted[1] == expected, "missing OSC 52 UI message")
for _, term in ipairs({ "linux", "dumb", "" }) do
  vim.env.TERM = term
  vim.fn.setreg("+", "local only", "v")
  assert(vim.fn.getreg("+") == "local only")
end
assert(#emitted == 1, "console must not emit OSC 52")
vim.cmd("qa!")
''')
        result = subprocess.run(
            ["nvim", "--headless", "-i", "NONE", "-u", INIT_LUA, "-l", str(script)],
            env=self.env, capture_output=True, start_new_session=True, timeout=20,
        )
        self.assertEqual(result.returncode, 0, result.stderr.decode())

    @unittest.skipUnless(INIT_LUA, "no Neovim initLua supplied")
    def test_neovim_registers(self):
        script = self.root / "test.lua"
        script.write_text('''
local function check()
  assert(vim.fn.has("clipboard") == 1)
  assert(vim.o.clipboard == "", "ordinary yanks must stay local")
  for _, reg in ipairs({ "+", "*" }) do
    vim.fn.setreg(reg, "from Neovim", "v")
    assert(vim.fn.getreg(reg) == "from Neovim")
  end
  local output = vim.fn.system({ vim.env.TEST_COPY_BIN }, "from shell")
  assert(vim.v.shell_error == 0, output)
  assert(vim.fn.getreg("+") == "from shell", "paste must read the saved file")
  vim.fn.setreg("+", "", "v")
  assert(vim.fn.getreg("+") == "")
end
local ok, err = pcall(check)
if not ok then
  io.stderr:write(tostring(err) .. "\\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
''')
        result = subprocess.run(
            ["nvim", "--headless", "-i", "NONE", "-u", INIT_LUA, "-l", str(script)],
            env={**self.env, "TEST_COPY_BIN": COPY},
            capture_output=True, start_new_session=True, timeout=20,
        )
        self.assertEqual(result.returncode, 0, result.stderr.decode())


if __name__ == "__main__":
    unittest.main(verbosity=2)
