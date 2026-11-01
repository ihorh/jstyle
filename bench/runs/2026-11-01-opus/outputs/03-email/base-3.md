**Subject:** 0.4.0 release: I need your decision on timing

Hi Priya,

Version 0.4.0 is ready except for one problem, and I need you to decide whether we release it now or wait for a fix.

**What 0.4.0 gives us**

The main fix is for billing and support analytics, who have been waiting on it since September. Their customer exports have notes that run over several lines, and right now splitlane breaks those notes apart, so their imports fail. 0.4.0 fixes that. Both teams work on Linux, where everything in this release has been tested and works.

**The problem**

It only affects Windows. If someone has one of splitlane's output files open in Excel and runs splitlane again, it crashes partway through. Some files are already updated, others still hold the old data, and the error message doesn't say which is which. The person could end up working with a mix of new and old data without realizing it.

The real fix is to have splitlane prepare all the files somewhere else first and swap them all in at the very end. It's a big change because it touches every place we save files. I haven't estimated it yet, so I can't give you a date.

We also don't know how many of our users are on Windows, because we don't collect that information.

**Your options**

1. **Release 0.4.0 now** with a note warning Windows users to close the output files before running splitlane. Billing and support analytics get unblocked right away. The Windows risk stays until the later fix.
2. **Wait until the Windows problem is fixed.** No one is exposed to the mixed-data risk, but billing and support analytics stay blocked for an unknown amount of time.

**Two other things to know before you decide**

- **The half-finished problem isn't only on Windows.** In a recent test on a file saved in an unexpected format, splitlane stopped with a clear error, but it left a partly written file behind. The warning in option 1 wouldn't cover that case. The same real fix would solve both.
- **0.4.0 renames the output files.** They go from "chunk_1.csv" to "part-0001.csv". Any team whose scripts look for the old names will need to update them when they upgrade. A rename like this has broken someone's setup before, so whichever option you choose, I'd tell the teams ahead of time.

If you can let me know which option you'd like, I'll take it from there. I'm also happy to talk it through.

Thanks,
Devi
