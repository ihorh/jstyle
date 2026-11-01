Thanks for the log. It shows two things: the cause of the failure, and a partial output file you should clear out.

**What went wrong**

splitlane reads input as UTF-8 unless you tell it otherwise. Your file isn't UTF-8. `file` reports it as ISO-8859 text, and the byte `0xe9` at position 4183 is `é` in Latin-1. That's probably a name or city with an accent. splitlane hit that byte, couldn't decode it, and stopped with exit status 3, which is the code for an undecodable input.

The run didn't finish before it failed. `chunks/part-0001.csv` has only 183 lines. It holds the rows read before the bad byte, not a full 20,000-row chunk. Don't use it.

**What to do**

1. Delete the partial output:

   ```bash
   rm -r chunks
   ```

2. Re-run with the file's real encoding:

   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
   ```

   I chose `cp1252` because the CRLF line endings suggest the file came from Windows or Excel. If that fails or the accents look wrong, try `--encoding latin-1`. The two differ only for a few punctuation characters, such as curly quotes and the euro sign.

The chunks are always written as UTF-8, whatever the input encoding was. Anything that reads them should treat them as UTF-8.

To check the result, open a chunk and look at a row with an accented character. If it reads correctly, the encoding was right. If you see `Ã©` or `?`, the encoding was wrong, so delete `chunks` and try the other one.

I'll make the error message mention `--encoding`, so the fix is in the output next time.
