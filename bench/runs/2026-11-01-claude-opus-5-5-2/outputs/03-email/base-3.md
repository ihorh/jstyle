Subject: 0.4.0 release: ship now or wait? I need your call

Hi Priya,

The 0.4.0 release is ready apart from one problem. You own the release decision, so here are the two options and what each one costs.

**What 0.4.0 fixes**

The main fix is for the billing and support analytics teams. Their customer exports have notes that run over several lines, and the current version breaks each of those records in two. Their import then rejects the file. 0.4.0 fixes this, and both teams are blocked until it ships. Both teams work on Linux, where 0.4.0 is fully tested. It's also tested on Mac.

**The problem**

On Windows only, splitlane can crash partway through a job. This happens if someone runs it a second time while one of the files from the first run is still open in Excel. When it crashes, some files are new and some are left over from the first run, and the error doesn't say which are which. The person could end up using a mix of old and new data without knowing it.

There's a simple way to avoid it: write each run to a new, empty folder, or close Excel first.

The proper fix changes how splitlane saves every file. I haven't estimated how long it will take, so I can't promise a date. We also don't know how many of our users are on Windows, because we don't collect that information.

**The options**

1. **Ship 0.4.0 now** with a clear warning for Windows users and the workaround above. Billing and support analytics are unblocked right away. The risk is that some Windows user doesn't read the warning and hits the problem.
2. **Wait until the Windows problem is fixed.** No one gets a version with this known problem. Billing and support analytics stay blocked for an unknown length of time.

**My recommendation**

I'd go with option 1. Two teams we know about are blocked today. The Windows problem needs a specific set of circumstances, and there's an easy way to avoid it. I'd make the Windows fix the next thing I work on and release it as soon as it's ready.

**Two more things for the release notes, whichever option you pick**

- 0.4.0 changes the names of the files it creates. Anyone whose scripts look for the old names will need to update them. That's intended, but we should say it clearly so it doesn't catch anyone off guard.
- If splitlane can't read a file because of its format, it now stops with a clear error. It can still leave behind a partly written first file, though. The fix I'm planning for Windows should take care of this as well. Until then, people should ignore the output of any run that ends in an error.

Could you let me know which option you'd like by the end of the week? I'll handle the release and the notes either way.

Thanks,
Devi
