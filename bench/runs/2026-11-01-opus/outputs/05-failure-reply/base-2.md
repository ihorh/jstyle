Thanks for including the full log, it made this easy to diagnose.

**What went wrong**

Your export isn't UTF-8. `file` reports it as ISO-8859 (Latin-1) text, and byte `0xe9` is how Latin-1 stores `é`. splitlane reads input as UTF-8 by default. When it hit that byte it stopped and exited with status 3, which is the "cannot decode input" error.

Before it stopped, it had already written `chunks/part-0001.csv`. That file is **incomplete**: it has the header plus 182 rows, not the 20000 you asked for. Don't use it.

**What to do now**

1. Delete the partial output. splitlane doesn't clear the output directory before a run, so starting fresh is safest:
   ```bash
   rm -r chunks
   ```
2. Run again with the file's actual encoding:
   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```
   If the export came from Excel or another Windows tool, use `--encoding cp1252` instead. It's almost the same as Latin-1 but also handles characters like `€` and curly quotes.
3. Look over the output. Latin-1 can decode any byte, so if it's the wrong encoding you won't get an error, just garbled characters. Open a chunk and check a few names that have accents. If `é` shows up as something else, try the other encoding.

Some things to know about the output:

- Chunks are always written as UTF-8, whatever the input encoding is, so they'll work with UTF-8 tools downstream.
- Your file's Windows-style (CRLF) line endings are copied into the chunks unchanged.
- At the end of the run, check the summary line on stderr. If it warns that rows were truncated, some rows were longer than `--max-row-bytes` (default 65536) and were cut short. Raise that limit and run again.

I'll leave this open as a docs improvement. The README should say that input defaults to UTF-8 and show how to choose another encoding, and the error message could suggest `--encoding` directly. If the rerun doesn't work, reply here with the new output.
