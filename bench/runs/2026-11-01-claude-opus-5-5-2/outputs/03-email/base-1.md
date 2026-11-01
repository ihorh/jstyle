**Subject: 0.4.0 release: ship now or wait? I need your decision**

Hi Priya,

The 0.4.0 release of splitlane is ready except for one problem. I need you to decide whether we ship it now or wait.

**What 0.4.0 fixes**

The main fix is for the billing and support analytics teams. Right now, when a customer note in their CRM export contains a line break, splitlane cuts that customer's record in two. Their import then rejects the whole file. 0.4.0 fixes this, and both teams are blocked until they have it. There are also a few smaller fixes, including a clearer warning when a record is too long and had to be shortened.

**The problem**

On Windows only: suppose someone runs splitlane, opens one of the output files in Excel, and then runs splitlane again while it's still open. splitlane stops partway through. Some files are new, some are left over from the earlier run, and nothing tells the user which is which. They could go on to use a mix of old and new data without knowing.

We don't know how many of our users are on Windows, because we don't collect that information. Billing and support analytics don't use Windows, so this problem doesn't affect them.

Fixing it properly means changing how splitlane saves every file. I haven't estimated how long that would take, and I don't want to guess.

**Your options**

1. **Ship 0.4.0 now.** The release notes would warn Windows users to close the output files before running splitlane again. The two blocked teams get their fix right away. Windows users stay at risk until the follow-up fix is done.
2. **Wait until the Windows problem is fixed.** No one gets a release with a known problem. But the two teams stay blocked for a length of time I can't give you yet.

**Two more things you should know**

- Holding the release wouldn't remove this kind of risk completely. If splitlane hits a file it can't read, it stops and leaves behind whatever it had written up to that point. That happens on every system, and it's already true of the version people use today. The proper fix for the Windows problem would fix this as well, so I'd do them together.
- 0.4.0 renames the output files. They used to be called "chunk_1.csv" and will now be "part-0001.csv". Anyone with scripts that look for the old names will have to update them. I'll tell billing and support before they upgrade.

**My recommendation**

I'd ship now (option 1), with a clear warning for Windows users, and start on the proper fix straight away. The fix for the two blocked teams is real and has been tested, the Windows problem has a simple workaround, and waiting has no end date yet. I'm happy to go with option 2 if you'd rather not ship anything with a known problem.

Could you let me know which you'd prefer? If you'd like to talk it through, I can do that too.

Thanks,
Devi
