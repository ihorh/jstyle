Hi devi, a suggestion before this merges. I'm not blocking it.

As I read the branch, it counts every row first so it can show a percentage, then reads the file again to split it. That means two full passes over the input. On our biggest exports the counting pass alone takes a noticeable amount of time. I haven't timed it, so I can't say how much yet. I can get numbers if that would help.

**My idea: skip the pre-count and stream.** Instead of a percentage, show rows processed and chunks written as they happen, e.g. `1,240,000 rows · 13 chunks written`. Then we only read the input once. `split_file()` already reads row by row, so I think the change stays in the CLI code on this branch and `split.py` doesn't need restructuring.

**The cost:** no percentage and no ETA. I know you've heard from users who want the bar, and I'm not dismissing that. A live counter shows something is happening but doesn't tell you how long is left.

**A possible middle ground:** estimate the percentage from bytes read divided by file size. That needs no pre-count, so we'd keep one pass and still show a bar. The catch is that rows vary in length, so the estimate will be off on files with long notes fields. It might be fine if we label it as approximate. I'm not sure it's accurate enough, and you know better than I do what users expect from the bar.

Do any of these work for you? Options:
1. Keep the pre-count as it is.
2. Counter only, one pass.
3. Byte-based estimated percentage, one pass.

I'm happy to pair on whichever one you pick, or to time the pre-count on a large export first so we're deciding with real numbers.
