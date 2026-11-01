Hi Devi, the progress bar looks good. I have one suggestion before this merges: drop the row pre-count.

To show a percentage, the branch reads the whole input once to count rows and then reads it again to split. On our biggest exports the first pass alone takes a noticeable while before anything appears on screen. I haven't timed it, so I can't say how long.

`split_file()` already reads row by row, so one pass is enough. The change would stay in the CLI code this branch adds. Instead of a percentage, the bar would show rows processed and chunks written, and updates would start immediately.

The cost is that we lose the percentage and the ETA. I know users ask for those, so I'd like to avoid giving them up. One option is to estimate the percentage as bytes read divided by file size. That needs no pre-count. The estimate drifts when row lengths vary, for example on files with long notes fields. I don't know whether it's accurate enough to be useful, and we'd have to try it on real exports to find out.

Which would you prefer: rows and chunks only, or the bytes-based estimate? I'm happy to prototype either on this branch if you want.
