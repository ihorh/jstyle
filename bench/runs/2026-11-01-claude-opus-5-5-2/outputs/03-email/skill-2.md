Subject: splitlane 0.4.0: should we release now or wait for a Windows fix?

Hi Priya,

The next version of splitlane, 0.4.0, is ready apart from one problem. I need you to decide whether we release it now or wait for a fix.

What's ready: everything planned for 0.4.0 is finished and tested on Linux and macOS. It includes the fix that billing and support analytics are waiting for. Some notes in their customer exports contain line breaks, and splitlane was splitting each of those customers into two broken rows, so their import tools rejected the files. Both teams run splitlane on Linux, so the problem below doesn't affect them.

The problem only affects Windows. splitlane takes a large CSV file (a spreadsheet saved as plain text) and splits it into smaller files. Here is when it goes wrong. Someone runs splitlane, opens one of the smaller files in Excel, and then runs splitlane again while that file is still open. splitlane then stops with an error partway through. By that point it has already replaced some of the old files with new ones, and the error doesn't say which files it replaced. The person is left with a folder of new and old files mixed together, with no easy way to tell them apart, and could pass out-of-date data on without noticing.

I know how to fix it properly. The fix changes every place where splitlane saves a file, though, and I haven't estimated how long it will take. We also don't know how many of our users are on Windows, because splitlane doesn't collect any usage data.

The two options:

1. Release 0.4.0 now, with a note that warns Windows users about the problem and tells them to close the files in Excel before running splitlane again. Billing and support analytics get their fix right away. Windows users who miss the note could still run into the problem.
2. Hold 0.4.0 until the Windows problem is fixed. We don't release anything with a known problem, but billing and support analytics keep waiting, and I can't yet tell you for how long.

Which would you prefer? I'm happy to talk it through if that helps.

Thanks,
devi
