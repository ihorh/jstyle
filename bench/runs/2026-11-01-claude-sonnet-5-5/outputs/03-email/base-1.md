Subject: Decision needed: ship splitlane 0.4.0 now, or hold for a Windows fix?

Hi Priya,

I need a decision from you on 0.4.0: ship it now, or hold it until one Windows problem is fixed. I recommend shipping now with a warning for Windows users.

**What 0.4.0 fixes**
- **Multi-line notes (#42):** The CRM exports have notes with line breaks inside them. Today splitlane cuts one customer into two broken rows, and the importer then rejects the whole file. 0.4.0 keeps those notes in one row. The billing and support analytics teams have been blocked on this since September, and both run on Linux.
- **Damaged quote marks:** A single stray quote mark can no longer ruin the rest of a file. At worst one row is cut short. The run now prints how many rows were cut, and Maya's team has said they'll check for that message in their scripts.
- **Smaller fixes:** `--rows 0` now gives an error instead of running forever. A file that can't be read in the expected text encoding now stops with a clear error.

Everything above is tested on Linux and macOS.

**The Windows problem (#57)**
- **When it happens:** On Windows, if a chunk file from an earlier run is still open in Excel, splitlane crashes when it tries to replace that file.
- **What the user is left with:** The chunks written before the crash are already new, and the error doesn't say which ones. The user ends up with a mix of new and old files and no obvious way to tell them apart.
- **The fix:** Splitlane would write everything to a temporary folder and move it into place at the end. That touches every place we write files, and I haven't estimated the time yet.
- **How many users it affects:** I can't say. We have no data on how many of our users are on Windows.

**Your two options**
1. **Ship now:** The two blocked teams get unblocked immediately. Windows users get a written warning to close their chunk files in Excel before re-running. Anyone who misses the warning can still end up with mixed files.
2. **Hold until #57 is fixed:** Nobody gets the mixed-file risk, but the blocked teams wait for a fix that has no date yet.

**Why I recommend shipping now:** The teams waiting on #42 are certain and already blocked. The Windows risk is real but needs a specific mistake (an open file) and an unknown number of users. We can also fix it in the next release.

**Two other things to know before you decide**
- **File names changed:** Output files are now named `part-0001.csv` instead of `chunk_1.csv`. Anyone whose scripts look for the old names will need to update them, so I'd put that at the top of the release notes.
- **A bad file can leave a partial output:** If a file can't be read partway through (for example, a Latin-1 export), splitlane stops with an error but leaves the chunk it had already written. I saw this on `customers-2026-10.csv`, which left one partial chunk of 183 rows. It's the same kind of leftover-files problem as #57, but it comes from a different cause. The temporary-folder fix would cover it too.

Let me know which way you want to go. If you say ship, I'll write the Windows warning and release today.

Thanks,
Devi
