**Pitch: drop the pre-count, make it one pass**

Hi devi, nice work on the progress bar. I'd like to suggest a change before this merges.

**The concern:** the branch counts all rows before splitting so it can show a percentage. That means reading the whole input twice. I haven't timed it, but on our biggest exports the first pass alone takes a noticeable while before anything visibly happens.

**The idea:** drop the pre-count and show "rows processed" and chunks written instead of a percentage. That gives one pass over the input. `split_file()` already reads row by row, so the change should be confined to this branch's CLI code.

**The tradeoff:** we'd lose the percentage and ETA, and I know some users like the bar. I expect you'll have a view on that, since you've heard from the people asking for it.

**A possible middle ground:** estimate progress as bytes read divided by file size. It needs no pre-count and still gives a percentage. I'm not sure it's accurate enough, because rows vary in length and the estimate would drift on files with long notes. It might be good enough for a progress bar, or it might look wrong often enough to annoy people.

**Next steps:** I can time the pre-count on one of the large exports so we have a real number. Would you be open to trying the bytes-read version on this branch? If it looks reasonable on a few real files, we could go with that. If not, we can talk about the plain counters.
