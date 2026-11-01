I couldn't see devi's `progress-bar` branch from this checkout, so the comment describes it using only what tomasz's notes say about it. The notes also say tomasz never timed the counting pass. The comment says that too, and offers to time it rather than claiming it's slow.

---

Hi devi, I'd like to suggest a change before this merges.

To show a percentage, the branch counts every row first and then splits, so splitlane reads the whole input twice. On our biggest exports the counting pass alone takes a noticeable while. I haven't timed it yet, but I can if you'd like numbers first.

My suggestion is to drop the pre-count and show rows processed and chunks written instead of a percentage. That way splitlane reads the input once. `split_file()` already reads row by row, so as far as I can tell the change is all in the branch's CLI code.

The cost is that we lose the percentage and any ETA. I know you've heard from users who want the bar, so I don't want to just take it away. There's a middle ground: estimate the percentage from bytes read divided by file size. It doesn't need a pre-count either. It's only an estimate, though. Rows vary in length, so on files with long notes fields the bar will run unevenly. Whether that's good enough depends on what users rely on the bar for. You know that better than I do.

What do you think: rows processed only, the byte-based estimate, or something else?
