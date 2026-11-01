**Subject:** 0.4.0: ship now, or wait for a Windows fix?

Hi Priya,

0.4.0 is ready apart from one problem. I need you to decide whether we ship it now or wait until that problem is fixed.

**What 0.4.0 brings**

The main fix is for issue #42. Until now, when a customer's notes contained a line break, splitlane split that customer's record in two. Billing and support analytics are both waiting for this fix. The release also gives clearer error messages. Everything in it has been tested on Linux and macOS.

There's one change the teams should know about before they upgrade. The output files get new names: `chunk_1.csv` becomes `part-0001.csv`. Any script that looks for the old names will need updating.

**The problem**

On Windows, splitlane crashes if someone has one of the files from an earlier run open in Excel when it tries to replace that file. By then it has already replaced the files before that one, and the error message doesn't say how far it got. The person ends up with a folder that mixes new files with old ones, and no easy way to tell which is which.

These points matter for the decision:

- It only happens on Windows. Billing and support analytics both run on Linux, so this problem doesn't affect them.
- The current version, 0.3.1, has the same problem. Holding 0.4.0 back doesn't protect Windows users. They would keep running 0.3.1, which has it too.
- We don't know how many of our users are on Windows, because we don't collect that information.
- Fixing it properly means changing how splitlane saves every file. It would write all the files to a temporary place first, then move them into the folder only once the run has finished. I haven't estimated how long that will take.

The same mix of old and new files can also happen on any system, in two other cases. If a run stops partway, for example because the input file isn't in the format splitlane expects, the files written so far stay in the folder. And if a new run produces fewer files than the last one, the leftover files from the last run stay behind. The fix above would cover these cases too.

**The options**

1. **Ship 0.4.0 now, with a warning for Windows users.** The warning would tell them to close the files in Excel before they run splitlane. Billing and support analytics get their fix right away. Windows users still have the problem they already have today, but now they're warned about it.
2. **Hold 0.4.0 until the Windows fix is done.** Windows users get the fix and the new release together. Billing and support analytics keep waiting, for a length of time I can't estimate yet.

If it would help, I can estimate the fix before you decide. Just let me know which option you'd like.

Thanks,
devi
