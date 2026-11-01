Subject: Decision needed: ship splitlane 0.4.0 now, or wait for a Windows fix?

Hi Priya,

splitlane 0.4.0 is ready, and I need your decision on whether to release it now or hold it. I recommend releasing now.

**What 0.4.0 gives us**
- It fixes the bug (#42) that is blocking the billing and support analytics teams. Their CRM exports have notes with line breaks in them, and splitlane was cutting those customers' records in half. Their importer then rejected the whole file. Both teams are waiting on this release.
- It also stops a bad file from making the tool hang or swallow the rest of the data. If one record is corrupted, only that record is damaged, and the tool reports how many were affected at the end of the run.
- Files that can't be read now stop with a clear error message.
- It's tested and working on Linux and macOS.

**The one open problem (#57, Windows only)**
If someone runs splitlane a second time into the same output folder, and one of the files from the first run is open in Excel, Windows won't let splitlane overwrite it. The tool stops partway through. The files written before that point are new, and the rest are still the old ones. The error message doesn't say which is which, so the person could end up with a mix of old and new data without realizing it.

Both teams that are waiting run on Linux, so this doesn't affect them. We don't know how many of our other users are on Windows, because we have no usage tracking.

**Your options**
1. **Release now, with a note for Windows users.** The note would say: close any output files in Excel before re-running, or use an empty output folder. The two waiting teams get unblocked immediately. The risk is that a Windows user misses the note and gets a mixed set of files.
2. **Hold the release until #57 is fixed.** This is the safer choice for Windows users. But the fix means changing how every file gets written, and I haven't estimated how long it would take. Billing and support analytics would stay blocked for that whole time.

I recommend option 1. The Windows problem only appears in a specific situation that a warning note covers, and there's a known workaround. Holding the release means a certain, ongoing cost to two teams in order to avoid a risk we can't size. I'd start on the #57 fix right after release.

**Two other things to know**
- Output files are now named `part-0001.csv`, `part-0002.csv` and so on, instead of `chunk_1.csv`, `chunk_2.csv`. Any script that looks for the old names will need updating. I'd mention this in the release announcement, and Maya's teams should check their scripts.
- If the input file can't be read, for example because it uses a different text encoding, the tool stops with an error. It can leave one partly written file in the output folder when that happens. The error message does appear, but the leftover file is easy to miss.

Let me know which way you'd like to go. If you choose option 1, I can publish today and send out the Windows note with it.

Thanks,
Devi
