**What went wrong**

`customers-2026-10.csv` isn't UTF-8. `file` reports it as ISO-8859 text with CRLF line endings, which usually means it was exported from Excel or a Windows tool. The byte `0xe9` is `é` in Latin-1/Windows-1252, and it isn't valid UTF-8. splitlane reads input as UTF-8 by default, so it stopped at the first accented character (byte 4183) and exited with status 3, the "cannot decode" code.

The file itself is fine. The first rows you pasted decode without problems, so the failure starts at the first non-ASCII name or city.

**What to do now**

1. Delete the `chunks/` directory, or at least `chunks/part-0001.csv`. That file is a partial result from the failed run. It has only 183 lines, not 20,000 rows, and it stops where decoding failed. Don't use it.
2. Re-run with the input encoding specified:

   ```
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
   ```

   If the file came from Excel on Windows, `cp1252` is the best guess. `--encoding latin-1` also works if you're not sure. The two differ only for a few characters, such as curly quotes and `€`. If you see odd characters in the output, try the other one.
3. The output chunks are always written as UTF-8, whatever the input encoding. This is the current behavior, and it means the result is converted rather than copied byte for byte. Check that downstream tools expect UTF-8.
4. Spot-check a name with an accent, such as `José` or `Zoë`, in the new `part-*.csv` files to confirm it came through correctly.

Re-exporting the CSV as UTF-8 from the source system would also work.

**Follow-up on our side**

A failed run leaves partial output in the output directory with only the exit code to warn you. That is easy to miss, so I'll track making that clearer (cleaning up or clearly flagging partial chunks), and mentioning `--encoding` in the decode error message.
