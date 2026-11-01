Subject: Decision needed: release splitlane 0.4.0 now, or wait for a Windows fix?

Hi Priya,

I need you to decide whether we release splitlane 0.4.0 now or hold it until a Windows problem is fixed. I recommend releasing now and telling Windows users about the problem.

**Why release.** splitlane cuts a big CSV file into smaller files. Until now it has broken any customer record that has a line break inside a quoted field, such as a multi-line note. It splits that record into two broken rows (issue #42). 0.4.0 fixes this. Billing and support analytics have been waiting on the fix since September, and both run on Linux. The release is tested on Linux and macOS.

**The Windows problem (issue #57).** On Windows, splitlane crashes if it needs to overwrite an output file that is open in Excel. That happens when someone re-runs the tool into a folder from an earlier run. By then it has already overwritten some files, and the error doesn't say which ones. The folder then holds a mix of new and old files. The user sees an error, so nothing goes wrong unnoticed. The risk is that someone uses the mixed folder anyway. I don't know of any other damage, such as lost files.

**The options**

1. **Release now, with a known-issue note for Windows.** Billing and support analytics get unblocked. Windows users still hit the crash if they re-run with files open in Excel. I expect they can avoid it by closing those files or writing to a new folder, but I haven't tested that.
2. **Hold until #57 is fixed.** Nobody hits the crash, but the two teams stay blocked. The fix means writing the new files to a temporary folder and moving them into place at the end. That touches every place the tool writes files, and I haven't estimated how long it would take. I can't tell you whether it's days or weeks.

**What I can't tell you.** I don't know how many of our users are on Windows, because we collect no usage data. That is why I lean toward the option that gets the Linux teams moving, and the crash at least shows up as an error.

**A second change you should know about.** 0.4.0 renames the output files, from `chunk_1.csv` to `part-0001.csv`. Any script that looks for the old names will stop finding the files. This is not a second decision for you, but I'd like to put it at the top of the release notes. I haven't checked whether billing or support analytics use the old names. I can ask them before we publish.

If you agree, I'll publish 0.4.0 with both notes. If you'd rather wait, tell me and I'll start on #57 and give you an estimate first.

Thanks,
Devi
