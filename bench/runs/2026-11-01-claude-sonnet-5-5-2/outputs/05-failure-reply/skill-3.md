Thanks for the log. The problem is the file's encoding, not your data or the command.

**What went wrong.** splitlane reads input as UTF-8 unless you tell it otherwise. Your `file` output reports `exports/customers-2026-10.csv` as ISO-8859 text. In that encoding, byte `0xe9` is `é`, which UTF-8 doesn't accept as a single byte. At byte 4183 splitlane hit that byte, stopped, and exited with status 3, which is the code for "can't decode the input".

**What to do now.**

1. Delete the `chunks` directory. `part-0001.csv` (183 lines) is what the run wrote before it failed, and it isn't a complete chunk.
2. Run it again and name the encoding:

   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
   ```

   The CRLF line endings suggest the file came from Windows or Excel. For that kind of file, `cp1252` is the usual choice. `latin-1` also works if you'd rather use it. The two differ only for a handful of punctuation characters, such as curly quotes and the euro sign. If you know which program exported the file, use its encoding.

3. Open a chunk and check that names like `Ribeiro` and any accented cities look right. A wrong guess usually shows up as odd symbols in those places.

The chunks are always written as UTF-8, whatever the input encoding was. Anything that reads them can use UTF-8 and doesn't need `--encoding`.

If you'd rather convert the input first, `iconv -f CP1252 -t UTF-8` does it. Then you can run splitlane without `--encoding`.

If the rerun fails with a decode error at a different position, the file probably isn't `cp1252`. Post the new error and the output of `file` here.
