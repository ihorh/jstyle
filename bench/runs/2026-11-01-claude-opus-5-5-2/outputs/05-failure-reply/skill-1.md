Your export isn't UTF-8, and splitlane reads its input as UTF-8 unless you tell it otherwise. `file` says the CSV is ISO-8859 text. That's a family of encodings, but the most likely member is Latin-1 (ISO-8859-1). In Latin-1 the byte in the error, 0xe9, is `é`, so a name or city in the file has an accent. Exit status 3 is splitlane's code for "couldn't decode the input."

Clear the output directory and run again with the encoding set:

```bash
rm -rf chunks
splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
```

Splitlane creates `chunks/` again if it's missing. The `chunks/part-0001.csv` left over from the failed run holds only the rows splitlane got through before the error, so don't use it. The new run would overwrite that file anyway. Clearing the directory first just means every file in it comes from the run that worked.

A successful run ends with `splitlane: wrote N chunk(s) to chunks/` and exits with status 0. Splitlane always writes chunks as UTF-8, whatever the input encoding, and it has no option to change that. If the tool that reads the chunks next expects Latin-1, set it to read UTF-8 instead.

It's worth spending a minute on one check. Latin-1 maps every possible byte to some character. If the file is really in another encoding, the run won't fail. It will finish and quietly write some characters wrong. Open a chunk in a text editor that reads UTF-8 (not Excel, which can make correct UTF-8 look broken) and find a row with an accented name.

- If `é` and other accented letters look right, and nothing else looks strange, you're done.
- If accented letters look right but curly quotes, dashes or `€` show up as other symbols, the export is probably Windows-1252. Excel and many Windows tools write that encoding, and the CRLF line endings that `file` reported point to a Windows origin. In that case, clear `chunks` again and run with `--encoding cp1252`.

`--encoding` accepts any encoding name Python understands, so `latin1`, `iso-8859-1` and `windows-1252` work too.
