Thanks for including the full log, it made this easy to diagnose.

**What went wrong**

The file isn't UTF-8, and splitlane reads input as UTF-8 unless you tell it otherwise. Your `file` output shows it: `ISO-8859 text, with CRLF line terminators`. That usually means it was exported from a Windows tool or from Excel. Byte `0xe9` is `é` in that encoding, so a name or city with an accent stopped the run. Exit status 3 means "cannot decode the input."

Ignore the "position 4183" in the message. It's counted within the block being read at that moment, not from the start of the file, so it won't lead you to the bad row.

**Don't use `chunks/part-0001.csv`.** The run stopped partway through the first chunk. That file has 183 lines (the header plus about 182 rows) instead of the 20000 rows you asked for. It's leftover output from a failed run, not a finished chunk.

**What to do now**

1. Delete the partial output:
   ```bash
   rm -r chunks
   ```
2. Run it again with the right input encoding. For a Windows or Excel export, use `cp1252`:
   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
   ```
   If that also exits with status 3, use `--encoding latin-1`. It accepts every byte, so it can't fail to decode. The trade-off is that a few characters `cp1252` handles correctly, like `€` and curly quotes, come out wrong.
3. Check that it finished. You should see `splitlane: wrote N chunk(s) to chunks/` and exit status 0. If that line is missing, the run didn't complete.

Some things that might help:

- The chunks are always written as **UTF-8**, whatever the input encoding was, so anything downstream should read them as UTF-8.
- The CRLF line endings are fine. Rows split correctly, and the chunks keep the same line endings.
- If you can change the export settings, choose "CSV UTF-8" at the source. Then you won't need `--encoding` at all.

I'll leave this open for now. If the re-run fails or the accented names look wrong in the output, post the new output here and we'll take another look.
