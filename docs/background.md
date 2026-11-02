# **jstyle**

An opinionated prose style for AI agent.

*November 2026*

*Ihor H. and Claude (Opus 5.5) as a co-author*

## Sentences That Had to Be Read Twice

It started with a reader who kept stumbling.

- The grammar was fine, and the facts checked out.
- Some sentences still had to be read twice.
- Ihor had two theories about why
  - A measurement proved both mostly wrong.
- A few other habits did cost the reader
  - They had names long before AI.
    - Garden-path sentence
    - Telegraphic style
    - Center embedding

Here's how one reader's frustration, a number of wrong guesses, and much trial
and error became [a writing skill](https://github.com/ihorh/jstyle).

Some parts we measured, some we borrowed, and some come from Ihor's own taste
and experience.

## In Short

| Part of the skill | Where it came from | What backs it |
|---|---|---|
| Be concise, never compressed | Orwell's rule on cutting words, reversed | A README rewrite under the first rules |
| Collect Facts and Sources | A synopsis that took about ten rounds of rewording | One episode, August 2026 |
| Telegraphic style and center embedding | The readability study | A count over 50 sessions of Claude's own output |
| Clarity comes from the idea and its context, not the wording | The first rules said "the idea", and the study added "its context" | Two examples from the study |
| Garden-path sentence | Reading research that explained a cost the study found | Published reading experiments |
| Principles over rules, with worked examples | How Ihor has worked with agents through 2026 | His experience, and guidance Anthropic has published |
| Cold Read | Talking the study over | Trials on Ihor's own rule files |
| Read one level up | Research on how writers revise | Untested so far |
| Mark your own inferences | The first benchmark run | 2 of 3 email samples |

## Summer 2026: Claude's Prose Got Harder to Read

The rules began with a frustration many people shared.

- Claude Opus 5 came out on 24 July 2026.
- Its answers ran long and dense, full of stock phrases.
- Asking it to write plainly didn't help. Neither did a note in the agent's
  memory.
- Two months later, Anthropic's launch of Opus 5.5 quoted that frustration
  back.

### What People Reported

By one count on the public model arena in August, Opus 5 answers averaged 510
words, against 158 for Opus 4.5, with longer sentences and more clauses. A
Claude Code hook that translated the model's output into plain English drew
nearly 3,000 upvotes on Reddit. A blog post by Paddo collects these and other
reports. Anthropic's Opus 5.5 launch page quoted a customer: "Verbose,
hard-to-follow output has been my biggest frustration with frontier models".

## Simplified English Was in the Air

The same summer, an old answer to unclear writing came back into fashion.

- People started asking Claude to write in ASD-STE100, or Simplified
  Technical English (STE), the language of aircraft maintenance manuals.
- In late July, it inspired the first writing rules, with a script to check
  the rules a script can check.
- We looked to STE and similar standards for ideas, but none fit out of the
  box.

### ASD-STE100 That Summer

In late July, people started asking Claude to report in ASD-STE100, and within
days GitHub held skills built on it (Golubić, 2026). The timing suggests the
same frustration with Opus 5, though nobody measured that. Andrej Karpathy
recommended the standard in October, which spread it much further.

## Good Enough and Slightly Off

New models in late September made it hard to tell what the rules still did.

- Anthropic announced Opus 5.5 and Sonnet 5.5 as writing more clearly than the
  models before them.
- The prose was good enough now, but it was unclear whether the rules or the
  models deserved the credit.
- Some rules still made a visible difference, and others no longer seemed
  needed.
- What remained was slightly off, in ways that were easier to feel than to
  name.

## The Study That Proved Us Wrong

On 30 October, Claude measured its own writing to find what was still off.

- It took the 50 most recent sessions: 784 chat replies and 63 documents,
  about 7,600 sentences.
- It counted word patterns, ran a grammar parser over every sentence, and read
  samples by hand to check each count.
- Ihor went in with two guesses about what was wrong.
- [The full study](2026-10-30-readability-study.md) has the method and the
  numbers.

## Two Guesses That Didn't Hold

Neither of Ihor's guesses explained much.

- **Dropping optional words, *that* above all.** The habit is real. Where
  *that* is optional, as in "confirm (that) the files match", Claude left it
  out about 3 times in 4. But such sentences were rare, so a dropped *that*
  came up only about once in 65 sentences. Half of those came after *says*,
  as in "the log says it failed", which seldom misleads anyone.
- **Placing related words far apart,** in a way that is cheap for a model and
  hard for a person. Claude's linked words sat 2.2 to 2.4 words apart, in chat
  and in documents alike. Liu (2008) found about 2.5 for English in general.

### Dependency Distance

Linguists measure the second guess as dependency distance: the number of words
between a word and the word it grammatically depends on, such as a verb and its
subject. A text that packs related words far apart scores high.

## What the Study Found

What cost the reader sat in sentence structure, not in single words.

- **Garden paths.** A dropped *that* is rare, but where it misleads, the
  reader has to parse the sentence twice. A later slide explains why.
- **Telegraphic style,** which nobody had suspected: phrases with no verb,
  often after a colon. They turned up in 3 to 4 of every 100 replies.
- **Center embedding,** which nobody suspected either: a clause inside a
  clause inside a clause. It turned up in about 2 of every 100 sentences, and
  Claude judged 4 in 10 of those hard to read.
- **Context, not only wording.** Some verbless phrases had a clear idea but
  had dropped the context the reader needed, so no rewording could fix them.
- The first three became sentence traps in the skill, and the last changed its
  third principle.


### Two Examples

"Your other two stores split on audience: you across all projects, and one
repository" should have been "One store holds what I learn about you across
all projects, and the other holds what I learn about one repository."

Another reply asked about "a partitioned asset with an upstream that is a
single unpartitioned asset that failed", and left the reader to work out which
asset failed.

## Garden Paths

Psycholinguists call it a garden path when the start of a sentence leads the
reader to a wrong reading.

- In "I'll confirm your files match", a reader first takes *your files* as the
  thing confirmed. Then *match* sends them back to the start.
- Readers slow down on such sentences when *that* is missing (Ferreira and
  Henderson, 1990; Trueswell, Tanenhaus, and Kello, 1993).
- When the same sentence is said out loud, stress and pauses mark where the
  clause starts, so it misleads nobody.
- The rules had tested a sentence by asking whether you would say it out loud.
  A garden path passes that test, and a model can't hear anyway. The skill now
  names the failure itself: a word that sends the reader back.

### The Horse Raced Past the Barn Fell

The classic garden path, from Bever (1970), uses a different construction to
the same effect. A reader takes *raced* as the main verb, and then *fell* has
nowhere to go. The sentence means that the horse which was raced past the barn
fell.

## Sources

- Anthropic (2026). Launch pages for [Claude Opus
  5](https://www.anthropic.com/news/claude-opus-5) (24 July), [Claude Opus
  5.5](https://www.anthropic.com/claude-opus-5-5) (22 September), and [Claude
  Sonnet 5.5](https://www.anthropic.com/claude-sonnet-5-5) (28 September).
- ASD-STE100, Simplified Technical English, Issue 9.
- Bever, T. G. (1970). The cognitive basis for linguistic structures. In
  J. R. Hayes (Ed.), *Cognition and the Development of Language*. Wiley.
- Ferreira and Henderson (1990), Trueswell, Tanenhaus, and Kello (1993), and
  Liu (2008): full references in [the
  study](2026-10-30-readability-study.md#sources).
- Golubić, K. (2026, 2 October). [ASD-STE100: what it is and what it has to
  do with LLMs](https://kgolubic.com/posts/asd-ste100-and-llms/).
- Orwell, G. (1946). Politics and the English language.
- Paddo (2026, 2 September). [A dial worth turning: Claude Opus 5's
  prose](https://paddo.dev/blog/a-dial-worth-turning/).
