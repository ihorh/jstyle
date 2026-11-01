# #42: Rows with newlines inside quotes get split in two

**maya (opened, 2026-09-14)**

Our CRM export has a `notes` column, and some notes contain line breaks. The
CSV quotes those fields correctly, as RFC 4180 says. splitlane treats the line
break as the end of the row, so one customer becomes two broken rows, and the
second one has the wrong number of columns. Downstream, our importer rejects
the whole chunk.

Example:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

Expected two data rows. splitlane writes three.

**devi (2026-09-15)**

Confirmed. `read_row()` stops at the first `\n` it sees and ignores quotes
entirely. That was deliberate in 0.1, because tracking quotes means one
malformed quote can make the reader think the rest of the file is a single
field. I chose "never swallow the file" over "handle quoted newlines".

**tomasz (2026-09-15)**

How common is a malformed quote compared to a legit multi-line field? I'd guess
the legit case is far more common in real exports, but I have no data.

**maya (2026-09-16)**

We have two teams blocked on this: billing and support analytics. Both get CRM
exports with notes. Neither has ever seen a malformed quote, as far as I know.

**devi (2026-09-18)**

Fair. Proposal: track quotes in `read_row()`, so a newline inside quotes stays
in the field. That's what RFC 4180 says and what every spreadsheet does.

**tomasz (2026-09-18)**

+1. Let's do it.

**maya (2026-09-19)**

Great, thanks. Can this go in the next release?

**devi (2026-09-22)**

Implemented on a branch. While testing, I fed it a file with one stray `"` in
row 12 of 400k rows. It read everything after row 12 as one field and wrote a
chunk with a header and one enormous row. That's exactly the failure I was
worried about in 0.1. So I don't want to ship quote tracking as-is.

**tomasz (2026-09-23)**

Could we detect the stray quote? E.g. if a quoted field runs past N lines,
assume it's broken.

**devi (2026-09-24)**

Counting lines doesn't work, since a notes field can legitimately have many.
But we already have `--max-row-bytes`. If a row grows past that limit, we stop,
treat the row as truncated, and skip to the next newline. A legit multi-line
note stays far below the limit. A stray quote hits the limit, damages one row,
and the reader recovers on the next line.

**tomasz (2026-09-24)**

So we keep the quote tracking, but bound it. One damaged row instead of a
swallowed file. I like it.

**maya (2026-09-25)**

Does "truncated" mean we lose data silently? Our importer won't notice a
shortened row.

**devi (2026-09-26)**

Not silently. I'll make the CLI print how many rows were truncated at the end of
a run. Callers using the library get a flag from `read_row()`.

**maya (2026-09-26)**

The CLI message works for us. We'll check for it in our scripts.

**devi (2026-10-02)**

Merged. Quoted newlines stay in the row, and a row that passes
`--max-row-bytes` is cut there and counted. Closing. It ships in 0.4.0.

**tomasz (2026-10-03)**

One follow-up for later: the skip after truncation goes to the next newline
even if that newline is inside quotes. So in a bad case, the reader might
resync in the middle of a real multi-line field. Probably rare. Not blocking.
