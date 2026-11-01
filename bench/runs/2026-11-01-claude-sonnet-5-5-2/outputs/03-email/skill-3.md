**Subject:** Decision needed: ship splitlane 0.4.0 now, or wait for a Windows fix?

Hi Priya,

I need you to decide whether we release splitlane 0.4.0 now, or hold it until one Windows problem is fixed.

**Why 0.4.0 matters**
The billing team and the support analytics team can't use splitlane on their CRM exports today. When a note in the export contains a line break, splitlane cuts that customer's record in two, and their importer rejects the whole file. 0.4.0 fixes this. Both teams run on Linux, and the fix has been tested on Linux and macOS. The release also makes splitlane report when it had to cut an over-long row short, so the loss no longer goes unnoticed.

**The Windows problem**
On Windows only, splitlane can fail when you run it a second time into a folder that already holds files from an earlier run. If one of those old files is open in Excel, Windows won't let splitlane overwrite it, and splitlane stops with an error. By then it has already replaced the files before that one. The error doesn't say which ones, so the user is left with a mix of new and old files and no way to tell them apart. That could pass unnoticed and feed wrong data into someone's work.

I can fix this properly, but the fix touches every place splitlane writes a file. I haven't estimated it, so I can't tell you how long a hold would be. We also have no usage data, so I don't know how many of our users are on Windows.

**One more change to know about**
0.4.0 renames the output files from `chunk_1.csv` to `part-0001.csv`. Anyone whose scripts look for the old names will need to update them. We had a user's pipeline break from a rename like this before. It's in the changelog and the README, but I'd mention it in the release announcement as well.

**Your options**
1. **Ship 0.4.0 now, with a known-issue note for Windows.** The note would tell Windows users to close the old files before re-running. Billing and support analytics get unblocked right away. The risk is that a Windows user misses the note and ends up with mixed files.
2. **Hold 0.4.0 until the Windows problem is fixed.** Nobody gets the mixed-file risk, but both teams stay blocked for an unknown time.

I lean toward option 1, because two teams are blocked now and the Windows problem only appears when someone re-runs over files that are still open. If you'd rather not take the risk, option 2 is a reasonable call. Tell me which you prefer and I'll act on it.

Thanks,
Devi
