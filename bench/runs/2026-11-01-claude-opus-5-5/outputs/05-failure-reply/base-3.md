Thanks for including the full log, it made this quick to diagnose.

**What went wrong**

Your file isn't UTF-8. `file` reports it as `ISO-8859 text`, which means Latin-1. splitlane reads input as UTF-8 unless you tell it otherwise. In Latin-1, `é` is the single byte `0xE9`. That's valid Latin-1 but not valid UTF-8, so splitlane stopped and exited with status 3, which is our code for "couldn't decode the input."

The first rows decoded fine because they're plain ASCII (`Ana Ribeiro, Porto, ...`). The first accented character is where it failed.

**The `chunks/part-0001.csv` it left behind is incomplete. Don't use it.** splitlane had started writing the first chunk before it hit the bad byte, and it doesn't clean up after a failed run. The 183 lines in that file don't tell you where the problem is in your input. They're just how far the writer got before decoding failed.

**What to do now**

1. Delete the partial output. Any files in `chunks/` from earlier runs should go too, so old and new chunks don't get mixed:
   ```bash
   rm -rf chunks
   ```
2. Run it again and tell splitlane the file's real encoding:
   ```bash
   splitlane exports/customers-2026-10.csv --rows 20000 --out chunks --encoding latin-1
   ```
3. Check that it ends with `splitlane: wrote N chunk(s) to chunks/` and that `echo $?` prints `0`. If you also get a warning about truncated rows, some rows were longer than `--max-row-bytes` (64 KiB by default). Post that output here and we'll look at it.

**Two other things to know**

- **The chunks will be UTF-8, not Latin-1.** splitlane decodes the input with the encoding you give it but always writes UTF-8. That's usually what you want. If whatever reads the chunks expects Latin-1, accented names will look garbled there, so you'd need to tell that tool the files are UTF-8.
- **Windows line endings are kept.** Your file uses CRLF line endings, and the chunks will too, so you don't need to do anything about that.

You're right that this was harder to figure out than it should be. The error doesn't say that a partial chunk was left on disk, and splitlane doesn't remove it. I'll open a follow-up issue so a failed run either cleans up its partial output or clearly reports what it left behind.
