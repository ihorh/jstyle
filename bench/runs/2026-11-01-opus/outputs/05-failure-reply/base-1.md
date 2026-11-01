Thanks for including the full log. That made this easy to diagnose.

**What went wrong**

Your export isn't UTF-8. `file` reports it as `ISO-8859 text`, which means a Latin-1 or Windows-1252 encoding. Byte `0xe9` is `é` in those encodings, but it isn't valid UTF-8 on its own. splitlane reads input as UTF-8 unless you tell it otherwise, so it stopped at the first accented character (byte 4183) and exited with status 3, which means it couldn't decode the input.

**About `chunks/part-0001.csv`: don't use it.** splitlane writes chunks while it reads the input, and it doesn't clean up when it fails. That file is left over from the failed run. It has the header plus the 182 rows read before the error, out of the 20,000 you asked for. The rest of the file was never processed.

**What to do now**

1. Delete the partial output:
   ```bash
   rm -r chunks
   ```
2. Run again, this time giving the input encoding:
   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
   ```
   I'd try `cp1252` first. The CRLF line endings suggest the export came from a Windows tool, and cp1252 also handles characters like `€` and curly quotes correctly. If it fails with another decode error (status 3), use `--encoding latin-1`. Latin-1 accepts any byte, so it never fails to decode. The downside is that if the file is really cp1252, a few characters can come out wrong without any error.
3. Check the result. The run should end with `splitlane: wrote N chunk(s) to chunks/`, and `echo $?` should print `0`. Then search for a name you know has an accent:
   ```bash
   grep -h "é" chunks/*.csv | head
   ```
   If you see `é` and not `Ã©` or `?`, the encoding was right.

The chunks are always written as UTF-8, whatever the input encoding is, so tools that read them won't hit this problem. The CRLF line endings carry over into the chunks unchanged.

If you also get a warning that some rows were truncated, paste it here. That's a separate problem: it usually means a quote was never closed somewhere in the export.
