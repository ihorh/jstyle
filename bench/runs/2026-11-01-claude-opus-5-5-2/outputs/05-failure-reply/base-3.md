Thanks for including the full log. It shows what happened.

**What went wrong**

Your export isn't UTF-8. `file` reports it as `ISO-8859 text` (Latin-1), and splitlane reads input as UTF-8 unless you tell it otherwise. Byte `0xe9` is `é` in Latin-1, so the first name or city with an accent stopped the run. Exit status 3 means splitlane couldn't decode the input.

**About `chunks/part-0001.csv`**

splitlane writes rows as it reads them. It doesn't clean up when it stops early, so the file it was writing stays on disk. `part-0001.csv` has the header plus the 182 rows before the bad byte, which is fewer than the 20000 you asked for. Don't use it. That's a rough edge on our side, and we should either remove the partial output or say clearly that it's incomplete.

**What to do now**

1. Delete the partial output:
   ```bash
   rm -r chunks
   ```
   Do this before every rerun. splitlane overwrites chunk files with the same name, but it doesn't remove leftovers from an earlier run.

2. Run it again and tell splitlane the input encoding:
   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```
   The chunks are always written as UTF-8, so `é` and other accented characters come out correctly in the output.

3. Check the summary at the end. It should say `splitlane: wrote N chunk(s) to chunks/` and exit with status 0. If it also prints a warning about truncated rows, tell us here.

If the export came from Excel or another Windows tool and you see wrong characters where `€` or curly quotes should be, use `--encoding cp1252` instead. Going by your `file` output, `latin-1` is the right choice.

Your CRLF line endings are fine. splitlane keeps them as they are in the output.
