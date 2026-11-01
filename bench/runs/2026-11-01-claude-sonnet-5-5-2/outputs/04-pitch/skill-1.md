Nice work on the progress bar, Devi. Users do ask for it. I'd like to propose one change before this merges.

The bar gets its percentage by counting all rows before splitting, so the input is read twice. I haven't timed it, but on our biggest exports the first pass alone takes a noticeable while before anything is written. `split_file()` already reads row by row, so one pass would be enough if we drop the pre-count.

What I'd suggest is to replace the percentage with a running "rows processed" count and the number of chunks written. The change is all in this branch's CLI code, and `split_file()` stays as it is. The cost is that we lose the percentage and the ETA, and I know some users like those.

There's a middle ground that keeps a percentage. We could estimate it as bytes read divided by file size, which needs no pre-count. I'm not sure it's accurate enough. Rows vary in length, so I'd expect it to drift on files with long notes fields. I haven't tried it.

I'd lean toward the plain counters, but I'd like your view first, since you know better what users expect from the bar. If you think the percentage matters, I'm happy to try the bytes-based estimate on a real export and see how far off it gets.
