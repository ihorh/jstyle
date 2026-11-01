Thanks for including the full log. It shows what happened.

**What went wrong**

The file isn't UTF-8. splitlane reads input as UTF-8 unless you pass `--encoding`. `file` reports the export as `ISO-8859 text`, which is Latin-1. Byte `0xe9` is `é` in Latin-1, probably in a name or city like "José" or "Évora". In UTF-8 that byte has to be followed by specific continuation bytes, so decoding stopped there. splitlane then exited with status 3, which is the exit code for "cannot decode input".

The `chunks/part-0001.csv` left behind is a partial file from before the error. It has the header plus 182 rows and is missing everything after the bad byte. Don't use it. Exit status 3 means the run failed, even though a file was written.

**What to do now**

1. Delete the partial output so it can't get mixed up with a good run:

   ```bash
   rm -r chunks
   ```

2. Run again and tell splitlane the input encoding:

   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```

   On success it prints `wrote N chunk(s) to chunks/` and exits with 0.

3. Spot-check one of the rows with an accented name in the output. If the export came from Excel or another Windows tool and you see odd characters where `€` or curly quotes should be, run it again with `--encoding cp1252`. For a file that `file` reports as plain ISO-8859, the two encodings should give the same result.

**Two things to know about the output**

- splitlane always writes chunks as UTF-8, whatever the input encoding is. If whatever reads the chunks expects Latin-1, tell it they're UTF-8 now.
- The CRLF line endings from your export are kept in the chunks.

If it still fails with `--encoding latin-1`, please post the new output and we'll look again.
