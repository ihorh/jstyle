**What went wrong:** your file isn't UTF-8, and splitlane reads input as UTF-8 unless you tell it otherwise.

`file` reports `exports/customers-2026-10.csv` as `ISO-8859 text`, which means Latin-1. In Latin-1, byte `0xe9` is `é`, so a name or city with an accent (José, Valéria, Liège…) is spelled differently than UTF-8 expects. splitlane decodes the file as it goes, so it got through the first 182 rows, wrote them out, then stopped at the first `é` with exit status 3. Exit status 3 means "couldn't decode the input."

**What to do now:**

1. **Delete the partial output.** `chunks/part-0001.csv` holds only the header and 182 rows, cut off where the error hit. Don't use it. Clear the directory so nothing from this run gets mixed into the next one:

   ```bash
   rm -r chunks
   ```

2. **Run it again and give the encoding:**

   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```

   It should end with `splitlane: wrote N chunk(s) to chunks/` and exit 0.

A few notes:

- **Output is always UTF-8.** `--encoding` only controls how splitlane reads the input. The chunks are written as UTF-8 no matter what, so `é` comes out correctly in the chunks. If whatever reads the chunks expects Latin-1, it will need to read them as UTF-8 instead.
- **If the file came from Excel on Windows,** `--encoding cp1252` also works. It decodes the same accented letters and also handles curly quotes and `€`. Because `file` said ISO-8859 and not "Non-ISO extended-ASCII," `latin-1` should be fine here.
- **Line endings:** the CRLF line endings are fine. splitlane keeps them, so the chunks will also use CRLF.

On our side, splitlane shouldn't leave a half-written chunk behind when a run fails, and the error should say which file is incomplete. That's the same problem as #57, and the planned fix (write to a temp directory and move the files into place at the end) will cover this case too. Until then, if you get a non-zero exit status, treat whatever is in the output directory as unusable.
