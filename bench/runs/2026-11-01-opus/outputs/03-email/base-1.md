**Subject:** 0.4.0 release: ship now or wait? (need your call)

Hi Priya,

The 0.4.0 release is ready except for one known problem. I need you to decide whether we ship it now or hold it until that problem is fixed.

**What 0.4.0 fixes**

The main fix is the one billing and support analytics have been waiting on since September. Customer notes that contain line breaks no longer get split into broken rows that their import rejects. There are also a few smaller fixes. Everything is tested on Linux and Mac, which is what both teams use.

**The known problem**

splitlane cuts one big file into many smaller ones. If a run fails partway through, it leaves a half-finished set of files behind, mixed in with files from the previous run, and it doesn't say which files are new and which are old. Someone who misses the failure could load a mix of old and new data.

I first raised this as a Windows-only issue. It happens there when one of the output files is open in Excel. Since then I've found it's wider than that. Any run that stops partway leaves the same mix of files, on any computer, including the Linux machines billing and support analytics use. One example is an input file saved in an unexpected format. What limits the damage is that the run always ends with a clear error, so a person or script that checks for errors will see it.

Two things matter for your decision:

- **This isn't new in 0.4.0.** As far as I can tell, the current version behaves the same way, because the way we write files hasn't changed. Holding 0.4.0 doesn't protect anyone from the problem. It only delays the fixes.
- **The proper fix isn't small.** We'd write everything to a scratch folder first and only move it into place once the run succeeds. That touches every part of the code that writes files, and I haven't estimated it yet.

**One thing for the release notes either way**

0.4.0 changes how the output files are named, from "chunk_1.csv" to "part-0001.csv". Anyone whose scripts look for the old names will break. This happened to a user once before, so it needs a prominent note. People should also empty their output folder before their first run with 0.4.0 so old and new files don't sit side by side.

**Your options**

1. **Ship 0.4.0 now.** The release notes would include a clear warning: "If a run fails, delete the output folder and run again. On Windows, close any output files open in Excel first." Billing and support analytics get their fix right away, and the proper fix comes in a later update.
2. **Hold 0.4.0 until the problem is fixed.** Nobody gets any of the fixes until then, and I can't yet say how long that will take.

We have no data on how many of our users are on Windows, so I can't tell you how many people the Excel case would affect.

My recommendation is option 1. The problem already exists in the version people use today, and two teams are blocked until we ship. If you'd like, I can estimate the proper fix before you decide.

Could you let me know which way you'd like to go?

Thanks,
Devi
