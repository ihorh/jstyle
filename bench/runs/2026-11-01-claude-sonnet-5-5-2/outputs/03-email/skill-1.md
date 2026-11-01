**Subject:** Decision needed: ship splitlane 0.4.0 now, or wait for a Windows fix?

Hi Priya,

I need you to decide whether we ship splitlane 0.4.0 now or hold it until a Windows bug is fixed. I recommend shipping now.

**What 0.4.0 gives us**
- Billing and support analytics have been blocked since September. splitlane breaks any record whose text contains a line break, such as a customer note, into two broken records, and their importer rejects the whole file. 0.4.0 fixes this. Both teams run on Linux.
- Another new feature protects against a different problem. A single stray quotation mark can make splitlane treat the rest of a file as one giant record. Now it damages at most one record and prints how many it cut at the end of the run. Maya's team will check for that message in their scripts.
- `--rows 0` used to make splitlane loop forever. It now stops with an error message.
- When splitlane can't read a file's text encoding, it now stops with an error and a distinct exit code (3), so scripts can tell this failure apart.
- The output files are renamed from `chunk_1.csv` to `part-0001.csv`. Anyone whose scripts look for the old names will need to update them.

Everything above is merged and tested on Linux and macOS.

**The Windows problem (issue #57)**
Suppose someone re-runs splitlane into a folder that already holds files from an earlier run, and one of those files is open in Excel. Windows won't let splitlane replace an open file. splitlane stops with an error that doesn't say which file caused it. By then it has already replaced the files before that one. The folder is left with a mix of new and old files, and the user can't tell which is which. This doesn't happen on Linux or macOS.

We don't know how many of our users are on Windows, because splitlane collects no usage data. The bug only appears when a user re-runs into an existing folder with a file open in Excel.

**Your options**
1. **Ship 0.4.0 now, with a known-issue note for Windows.** The note would tell Windows users to close their output files in Excel, or use a fresh folder, before re-running. Billing and support analytics are unblocked right away. The risk is that some Windows user hits the bug and gets a confusing mix of files before we fix it.
2. **Hold 0.4.0 until #57 is fixed.** Nobody gets the mixed-files bug, but the two blocked teams keep waiting. I haven't estimated the fix. It means changing splitlane to write into a temporary folder and move everything into place at the end, which touches every place it writes files. I can give you an estimate if you want to weigh this option.

**My recommendation:** option 1. Two teams are blocked now, the Windows bug needs a specific set of circumstances, and the error stops the run instead of silently producing bad output. I'd then fix #57 in the next release. This is my judgment, and I can't back it with Windows usage numbers.

Please reply with "ship" or "hold". If you pick ship, I'll write the Windows note and release it right away.

Thanks,
Devi
