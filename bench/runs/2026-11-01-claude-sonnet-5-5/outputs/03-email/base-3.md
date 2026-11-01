Subject: Decision needed: ship splitlane 0.4.0 now, or hold for a Windows fix?

Hi Priya,

I need a decision from you on splitlane 0.4.0. The release is ready, with one known problem on Windows. Do we ship now and warn Windows users, or hold the release until I fix it?

**What 0.4.0 gives us**
- It fixes #42, the bug that has billing and support analytics blocked. When a customer note in a CSV has a line break inside it, splitlane currently splits that customer into two broken rows, and the importer rejects the whole file. 0.4.0 keeps the note together.
- If a file has a stray quotation mark, that bug could previously ruin the rest of the file. Now it damages at most one row. The tool prints a count of any damaged rows at the end of a run, and Maya's team has said they will check for it in their scripts.
- `--rows 0` now stops with a clear message instead of running forever.
- A file that can't be read in the expected text encoding now stops with a clear error.
- All of this is tested on Linux and macOS. Billing and support analytics both run on Linux, so the fix reaches them as soon as we ship.

**The problem (#57, Windows only)**
If a file from an earlier run is still open in Excel, splitlane crashes when it tries to replace that file. The files it wrote before the crash stay on disk, and the error doesn't say which ones. The user is left with a mix of new and old files and no clear way to tell which is which.

We don't know how many of our users are on Windows, because we have no usage data.

**Two things you should also know**
- 0.4.0 renames the output files, for example from `chunk_1.csv` to `part-0001.csv`. This is a deliberate change. Anyone whose scripts look for the old names will break, and we broke a user's pipeline this way before. Whichever option you pick, the release notes should say this clearly.
- Related to the encoding error: if splitlane stops partway through a file, it leaves behind the output files it had already written. In my own test run, one partial file was left behind. A user could mistake it for complete output. It's the same kind of risk as #57, only milder.

**Your options**
1. **Ship 0.4.0 now, with a note about the Windows issue.** Billing and support analytics are unblocked right away. Windows users who keep old output open in Excel can hit the crash, so the note would tell them to close those files before running. The risk is a confusing result for some Windows users, and I can't say how many.
2. **Hold 0.4.0 until #57 is fixed.** Nobody hits the Windows problem. Billing and support analytics stay blocked in the meantime. The fix means changing how every output file is written, and I haven't estimated it, so I can't give you a date yet. I can give you an estimate if you want to weigh this option properly.

**My recommendation**
I'd ship now with the Windows note, and fix #57 in the next release. The two teams waiting are on Linux and can't be helped any other way. The Windows problem only appears when an old output file is open in Excel, and it can be avoided by closing the file first. The risk is real, but it's narrow, and holding the release leaves the two teams blocked for an unknown length of time. If you know of Windows users who rely on this tool, that would change my view.

Please tell me which option you prefer. If you choose to ship, I'll write the Windows note and the rename warning into the release notes before it goes out.

Thanks,
Devi
