Thanks for including the full log. It shows exactly what happened.

**What went wrong**

`exports/customers-2026-10.csv` isn't UTF-8. Your `file` output reports it as ISO-8859 text, which here almost certainly means ISO-8859-1, also called Latin-1. splitlane reads its input as UTF-8 unless you tell it otherwise. In Latin-1 the byte `0xe9` is `é`, but that byte isn't valid UTF-8 on its own, so splitlane stopped at the first accented character. It printed the error and exited with status 3, which means the input couldn't be decoded.

The `chunks/part-0001.csv` you found was left behind by the failed run. When splitlane stops on an error, it doesn't delete the chunk it was writing. That file has the header and the 182 rows written before the failure, so it's an incomplete chunk and you shouldn't use it.

**What to do now**

Delete the partial chunk, then run splitlane again and tell it the file's encoding:

```bash
rm chunks/part-0001.csv
splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
```

splitlane always writes chunks as UTF-8, whatever the input encoding, so anything that reads the chunks should read them as UTF-8. You don't need to do anything about the CRLF line endings, because they come through unchanged.

`--encoding` accepts any encoding name Python knows, so `iso-8859-1` works too. If future exports contain `€` or curly quotes, `file` will stop saying "ISO-8859" and say "Non-ISO extended-ASCII" instead. For those files, use `--encoding cp1252`, the usual Windows encoding. Latin-1 would turn those characters into invisible control characters without reporting an error. Your current file doesn't contain any of them, so `latin-1` is safe for it.
