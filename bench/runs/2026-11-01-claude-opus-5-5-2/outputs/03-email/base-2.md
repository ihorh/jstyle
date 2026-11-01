**Subject:** splitlane 0.4.0: ship now or wait? I need your call

Hi Priya,

Release 0.4.0 is ready except for one problem. I need you to decide whether we ship it now or wait for a fix.

**Why it matters:** The billing and support analytics teams have been blocked since September. Their customer exports include notes that run over several lines, and the current version splits those notes into broken rows that their systems reject. 0.4.0 fixes that. Both teams run on Linux, where 0.4.0 is fully tested.

**The problem:** On Windows, if someone has an old output file open in Excel when they run splitlane again, the tool stops partway through. Some files are new and some are still from the old run. The error message doesn't say which ones, so the person can't easily tell.

**How to avoid it:** Close Excel first, or send each run's output to a new, empty folder.

**Your options:**

1. **Ship now** and include a note warning Windows users about this, with the workaround. The two blocked teams get their fix right away.
2. **Wait** until the Windows problem is fixed. Fixing it properly means changing how splitlane saves every file. I haven't estimated how long that will take, so I can't promise a date. The two teams stay blocked until it's done.

We have no data on how many of our users are on Windows, so I can't tell you how many people the problem would affect.

**Also in 0.4.0:** The output files get new names. "chunk_1.csv" becomes "part-0001.csv". Any scripts that look for the old names will need a one-time update, so we'll need to announce this clearly whichever option you choose.

**My recommendation:** Option 1. The fix for the two teams is a real, current need. The Windows problem only happens in a specific situation and has a simple workaround. I'd start on the Windows fix right after release.

It's your call. If you can let me know this week, I'll either publish the release or tell the two teams it's delayed.

Thanks,
devi
