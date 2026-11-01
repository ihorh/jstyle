# 0.4.0 Release Status

Notes from devi, 2026-10-28.

- Everything in the Unreleased changelog section is merged and tested on Linux
  and macOS.
- Blocker: #57, Windows only. If a chunk file from an earlier run is open in
  Excel, splitlane crashes with `PermissionError` when it tries to overwrite
  it. The chunks before that one are already written, and the error does not
  say which. The user ends up with a mix of new and old chunks.
- Fixing #57 properly means writing chunks to a temp directory and moving them
  into place at the end. I haven't estimated it. It touches every write path.
- Billing and support analytics are waiting for the #42 fix. Both run on
  Linux.
- We don't know how many of our users are on Windows. No telemetry.
- Priya owns the release decision. Options as I see them:
  1. Ship 0.4.0 now, with a known-issue note for Windows.
  2. Hold 0.4.0 until #57 is fixed.
- Priya isn't technical, and needs the choice in plain terms.
