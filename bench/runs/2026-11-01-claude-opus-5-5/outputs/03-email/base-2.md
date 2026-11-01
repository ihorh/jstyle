**Subject: Decision needed: release splitlane 0.4.0 now, or wait for a Windows fix?**

Hi Priya,

I need you to decide on the 0.4.0 release. In short, it's ready except for one Windows problem, and the two teams waiting for it don't use Windows.

**What 0.4.0 fixes**

Billing and support analytics have been blocked since mid-September. Some notes in their customer exports contain line breaks, and splitlane currently cuts each of those customers into two broken records. Their import then rejects the whole file. 0.4.0 fixes this. It also has a few smaller fixes. Everything has been tested on Mac and Linux, which is what both teams use.

**The Windows problem**

On Windows, if someone has one of splitlane's output files open in Excel and runs splitlane again, it stops partway through. Some of the files are new and some are left over from the last run, and the error message doesn't say which are which. Someone could end up using a mix of old and new data without knowing it.

Two things put this in context:

- **It isn't new in 0.4.0.** The version people use today behaves the same way. Holding the release doesn't protect anyone from it.
- **It isn't only on Windows.** If a run stops partway for any other reason, the same mix happens on any computer. One example is an export saved in a format splitlane doesn't expect, and I have a log of this happening with a customer export.

The proper fix changes how splitlane saves every file, and it fixes both cases. I haven't estimated how long it will take.

**Your options**

1. **Release now with a warning.** Billing and support are unblocked right away. We tell all users, not just Windows users: close the output files before running splitlane again, and if a run fails, throw away that folder's output before using it.
2. **Hold until the fix is done.** Billing and support stay blocked for a period we don't know yet. Everyone else keeps the current version, which has the same problem.

**One more thing either way**

0.4.0 renames the output files, from "chunk_1.csv" to "part-0001.csv". Any script that looks for the old names will stop finding files. Folders from earlier runs will also end up holding both sets. We need to tell billing and support before they upgrade.

**My recommendation**

Option 1. Holding back doesn't remove the risk. It only keeps two teams blocked. If you agree, I'll put out the warning, talk to both teams about the new file names, and start on the proper fix next. I'll send you an estimate for that by the end of next week.

All I need from you is "option 1" or "option 2."

Thanks,
Devi
