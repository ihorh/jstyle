I'd add one note before you send this. The email says 0.3.1 probably already has the Windows problem. That's my reading of the code, not something from devi's notes, so devi should confirm it first.

---

**Subject:** 0.4.0 release: I need your decision

Hi Priya,

splitlane takes one large CSV file (a spreadsheet saved as plain text) and splits it into smaller files. The next version, 0.4.0, is ready except for one problem that affects only Windows users. I need you to decide whether we release it now or wait for a fix.

**What 0.4.0 fixes.** Billing and support analytics have been waiting for this release since September. Their customer exports include notes with line breaks in them. Right now splitlane cuts each of those customer records in two, so their import rejects the file. 0.4.0 keeps those records whole. Both teams use Linux, and we've tested everything in this release on Linux and macOS.

**The Windows problem.** Each time someone runs splitlane, it overwrites the smaller files from their previous run, one by one. On Windows, if one of those old files is open in Excel, splitlane stops with an error when it reaches that file. By then it has already overwritten the files before that one, and the error doesn't say which ones. The folder ends up with a mix of new and old files that look alike. Closing Excel and running splitlane again fixes the folder. But someone who misses the error, or ignores it, could go on to use the mixed files.

From the code, the current version (0.3.1) seems to have the same problem, so holding 0.4.0 may not protect Windows users at all.

**The fix.** To fix this properly, splitlane would have to save the new files somewhere else first and only replace the old ones once every new file is saved. That means changing every part of the code that saves files, so it isn't a quick patch, and I haven't estimated it yet. We also don't know how many of our users are on Windows, because splitlane doesn't collect usage data.

**Your options:**

1. **Release 0.4.0 now**, with a note telling Windows users about the problem and how to avoid it: close the files in Excel before running splitlane. Billing and support analytics get their fix right away.
2. **Hold 0.4.0 until the Windows problem is fixed.** Billing and support analytics keep waiting, and I can't tell you yet for how long.

If an estimate for the fix would help you decide, I can work one out first.

Thanks,
devi
