Your export isn't UTF-8, and splitlane reads input as UTF-8 by default. The file is almost certainly Latin-1 or Windows-1252 (the byte `0xe9` is `é` in both). `file` reports it as ISO-8859, and the sample rows you pasted have only ASCII names. The first accented character is somewhere after the first 180 or so rows.

When splitlane hit that byte, it stopped and exited with code 3, which is its encoding-error code. By then it had already written `chunks/part-0001.csv`, so that file is a partial chunk (183 lines, not 20,000 rows). It's not a usable result, so delete it.

To fix it, tell splitlane the input encoding and write to a clean directory:

```bash
rm -r chunks
splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
```

Use `cp1252` if the file came from Excel or Windows, and `latin-1` otherwise. They differ only in a few punctuation characters such as curly quotes and `€`. If a `latin-1` run fails or shows odd characters, try the other one. The chunks are always written as UTF-8, whichever encoding you read the input with.

After the run, spot-check a chunk that contains accented names, such as `Ribeiro`-style surnames or city names, to confirm they look right.

If you want, open a separate issue for the error message. It could suggest `--encoding` when decoding fails, and it could clean up the partial output.
