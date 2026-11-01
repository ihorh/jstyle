# Questions

1. What went wrong? *The file is ISO-8859 (Latin-1), and splitlane decoded it
   as UTF-8.*
2. What should the user run instead? *The same command with `--encoding
   latin-1` (or `iso-8859-1`).*
3. Is the `part-0001.csv` left behind usable? *No. It is a partial chunk from
   the failed run, and should be deleted or overwritten.*
4. What does exit status 3 mean? *The input could not be decoded.*

## Unsupported If Claimed

Automatic encoding detection in splitlane, a fix release.
