# Punctuation and Case

Three conventions for punctuation and capitalization. They are my preferences,
so they apply only where no other style already decides.

## Precedence

These conventions give way to any style already in force. The aim is to fit
in: new text should look like the text around it. Look for a style in three
places. An earlier place outranks a later one.

1. **The document itself.**
2. **The project's style guide or linter config**, such as Vale or
   markdownlint.
3. **The convention of the format**, such as sentence case in a git commit
   subject.

Where nothing decides, as in chat or a new document, these conventions apply.

## Conventions

**Use the Oxford comma.** Write "layout, per-unit builds, and CI". This holds
for any prose, plain text included.

**Capitalize headings and titles in Chicago title case.** Lowercase only
articles (`a`, `an`, `the`), the coordinating conjunctions (`and`, `but`, `or`,
`nor`, `for`, `so`, `yet`), `to` in an infinitive, and prepositions at any
length. Capitalize the first and last word regardless. Write
`## What to Look For`, never `## What To Look for`.

This holds for a heading or a title in any format. A bold lead-in and a table
cell keep sentence case. A name keeps its own case: `npm`, `compinit`, and
`macOS` stay lowercase, and anything inside backticks stays as written.

**Punctuation takes the style of the text it belongs to.** This holds wherever
text carries formatting, as in markdown, chat, and rich text.

- Emphasis inside a sentence leaves the punctuation after it plain:
  `under **Memory files**.`
- A bold lead-in is a whole sentence, so its period goes inside:
  `**No section dividers.**`
