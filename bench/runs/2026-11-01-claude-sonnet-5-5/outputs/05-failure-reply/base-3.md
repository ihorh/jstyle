Your CSV isn't UTF-8, and splitlane defaults to reading UTF-8. The `file` output reports ISO-8859 text, and the failing byte `0xe9` is `é` in Latin-1/Windows-1252. About 4 KB in, splitlane hit a name or city with an accent, couldn't decode it, and stopped with exit code 3 (the documented "cannot decode input" status).

**Don't use `chunks/part-0001.csv`.** It was partly written before the error, so it has only 183 lines, not the 20,000 rows you asked for. splitlane doesn't clean up after a failed run. Delete the `chunks` directory, or at least that file, before re-running.

**Fix:** tell splitlane the real encoding:

```
rm -rf chunks
splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding cp1252
```

- Use `cp1252` if the file came from Excel or another Windows tool. Use `latin-1` if you know it's plain ISO-8859-1. They only differ for a few characters, such as curly quotes and `€`.
- `latin-1` never fails to decode, so it won't report a wrong guess. Spot-check a few accented names in the output.
- The output chunks are always written as UTF-8, whatever the input encoding. This is usually what you want, but check that whatever reads the chunks expects UTF-8.

Better still, ask whoever produces the export to switch it to UTF-8 so you don't need the flag.

If the same command with `--encoding` still fails with a decode error, send the new error message. That would mean the file has mixed encodings, and we'd need to look at it more closely.
