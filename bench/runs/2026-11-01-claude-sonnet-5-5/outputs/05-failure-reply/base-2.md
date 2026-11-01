**What went wrong**

`splitlane` reads input as UTF-8 unless you tell it otherwise. Your export is not UTF-8. `file` reports it as ISO-8859 (Latin-1 style). Byte `0xe9` is `é` in that encoding, and it isn't valid UTF-8. The decode failed at byte 4183, so `splitlane` stopped and exited with status 3. That is the exit code for "input cannot be decoded".

The run did not fail cleanly. It wrote `chunks/part-0001.csv` before it hit the bad byte, and that file holds only 183 lines. You asked for 20000 rows per chunk, so it is incomplete.

**What to do**

1. Delete the leftover partial output so it can't be mixed in with the real chunks:
   ```
   rm -r chunks
   ```
2. Re-run with the input encoding specified:
   ```
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```
   If the export came from Excel on Windows, use `--encoding cp1252` instead. It is nearly identical to Latin-1, but it also covers characters like `€` and curly quotes. If one of them gives you odd characters in names, try the other.

The chunks are always written as UTF-8, whatever the input encoding. So `Ribeiro`-style accented names will come out correctly encoded in the output, and anything reading the chunks downstream can treat them as UTF-8.

If you re-export from the source system, choose "CSV UTF-8" if it offers that. You won't need the flag then.
