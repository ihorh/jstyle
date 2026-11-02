# **jstyle**

An opinionated prose style for your AI agent.

[github.com/ihorh/jstyle](https://github.com/ihorh/jstyle)

*November 2026*

*Ihor H. and Claude (Opus 5.5) as a co-author*

How one reader's frustration, a few wrong guesses, and much trial and error
became a writing skill. Some parts we measured, some we borrowed, and some
come from Ihor's own taste and experience.

## What the Skill Watches For

Small slips that leave prose good enough but slightly off. Several had names
long before AI.

- Background before the point
- Garden-path sentences
- Center embedding
- Telegraphic style
- Missing context that no rewording fixes
- Inferences passed off as facts
- The curse of knowledge
- Documents that only grow

## Summer 2026: Claude's Prose Got Harder to Read

The rules began with a frustration many people shared.

- Claude Opus 5 came out on 24 July 2026, and its answers ran long and dense,
  full of stock phrases.
- Many people turned to an existing standard, Simplified Technical English
  (STE), the language of aircraft maintenance manuals.
- Ihor answered with writing rules of his own, and a script to check the
  mechanical ones.
- In late September, Anthropic's launch of Opus 5.5 quoted that frustration
  back.

### What People Reported

By one count on the public model arena in August, Opus 5 answers averaged 510
words, against 158 for Opus 4.5, with longer sentences and more clauses. A
Claude Code hook that translated the model's output into plain English drew
nearly 3,000 upvotes on Reddit. A blog post by Paddo collects both, along with
other reports. Anthropic's Opus 5.5 launch page quoted a customer: "Verbose,
hard-to-follow output has been my biggest frustration with frontier models".

### STE That Summer

In late July, people started asking Claude to write in STE, formally
ASD-STE100, and within days GitHub held skills built on it (Golubić, 2026).
In October, Andrej Karpathy recommended the standard, which spread it much
further.

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

- It took the 50 most recent sessions, mostly written by Opus 5.5: 784 chat
  replies and 63 documents, about 7,600 sentences.
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
  hard for a person. Claude's mean dependency distance was 2.2 to 2.4, in chat
  and in documents alike. Liu (2008) found about 2.5 for English in general.

## What the Study Found

What cost the reader sat in sentence structure, not in single words.

- **Garden paths.** A dropped *that* is rare, but each one that misleads
  makes the reader parse the sentence twice. A later slide explains why.
- **Telegraphic style,** which nobody had suspected: phrases with no verb,
  often after a colon. They turned up in 3 to 4 of every 100 replies.
- **Deep nesting,** which nobody suspected either: a clause inside a clause
  inside a clause. It turned up in about 2 of every 100 sentences. Its
  hardest kind is center embedding.
- **Context, not only wording.** Some verbless phrases had a clear idea but
  had dropped the context the reader needed, so no rewording could fix them.

### Two Examples

"Your other two stores split on audience: you across all projects, and one
repository" should have been "One store holds what I learn about you across
all projects, and the other holds what I learn about one repository."

Another reply asked about "a partitioned asset with an upstream that is a
single unpartitioned asset that failed", and left the reader to work out which
asset failed.

### Center Embedding

A clause sits in the middle of another clause, so the reader holds the outer
one open until the inner one ends.

- **One level reads fine:** "The report the team wrote was late."
- **Two levels break down:** "The rat the cat the dog chased killed ate the
  malt." Three subjects wait for three verbs, which arrive in reverse order.
- **Nesting to one side stays easy:** "the dog that chased the cat that killed
  the rat" is just as deep, but each clause closes before the next one opens.

Miller and Chomsky (1963) traced the difficulty to the clauses held open, not
to the depth.

## Garden Paths

Psycholinguists call it a garden path when the start of a sentence leads the
reader to a wrong reading.

- In "I'll confirm your files match", a reader first takes *your files* as the
  thing confirmed. Then *match* sends them back to the start.
- Readers slow down on such sentences when *that* is missing (Ferreira and
  Henderson, 1990; Trueswell, Tanenhaus, and Kello, 1993).
- When the same sentence is said out loud, stress and pauses mark where the
  clause starts, so it rarely misleads.

### The Horse Raced Past the Barn Fell

The classic garden path, from Bever (1970), uses a different construction to
the same effect. A reader takes *raced* as the main verb, and then *fell* has
nowhere to go. The sentence means that the horse which was raced past the barn
fell.

## Why the Skill Bans No Words

The obvious fix was a rule to always keep *that*. We didn't write one.

- Other small words mark where a clause starts too, such as *which*, *who*, and
  *whether*.
- A rule about one word would teach the model to sprinkle it everywhere, and to
  miss the next case.
- So the skill bans no word or pattern anywhere. Each sentence trap names a
  failure the writer can recognize, whatever words caused it.

## Principles Over Rules

That choice follows a very specific way of working with agents.

- Treat agents more like colleagues than like programs to configure.
- Give them the principles and the intent behind a task, not a long list of
  rules. Rules make an agent worse rather than safer: it hunts for loopholes,
  or applies a rule to the letter where its point doesn't hold. Ihor has seen
  this with Claude and with other agents and models.
- Keep hard bans for what can't be undone, such as deleting files or
  force-pushing.
- Write for the most capable model you can afford. Weaker models may need
  more rules.

Anthropic's [constitution](https://www.anthropic.com/constitution) and
[prompting
guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
point the same way. The guide warns that recent models overreact to
instructions like "CRITICAL: You MUST use this tool".

## The Writer Can't See Its Own Gaps

Talking the study over turned up a problem no rule could fix.

- A writer checking a draft still has the whole session in mind: what was
  discussed, decided, and read.
- That context fills every gap a stranger would fall into, so the draft passes
  its writer's check.
- Economists named this the curse of knowledge in 1989 (Camerer, Loewenstein,
  and Weber), and Steven Pinker brought it to writers in *The Sense of Style*
  (2014). We ran into it first, and found the name afterwards.

## Cold Reads

The fix is a second reader who knows nothing about the session.

- The skill calls it a cold read. The reader gets only the text and one line on
  who it's for, and is asked for questions rather than rewrites.
- On a draft of about 1,000 words, the writer judged about half the reader's
  flags worth fixing. Two of those were garden paths the writer had read
  straight past.
- Since jstyle 0.4.0, the cold reader runs on a model a tier below the
  writer's, such as Sonnet when Opus writes. Our reasoning: a smaller model
  shares fewer of the writer's guesses, so it stalls where a hurried person
  would, and it costs less.

## Documents That Grow

The last piece came from reading rather than measuring.

- An agent editing a document adds the new text and moves on, without asking
  what it displaced, so documents slowly grow.
- Sommers (1980) found that experienced writers treat each addition or deletion
  as "a reordering of the whole", while students mostly swap words. An agent
  adds freely, as experienced writers do, but skips the rework that should
  follow.
- The opposite fails too: a model that rewrites a whole text unprompted tends to
  lose detail. The Agentic Context Engineering paper (Zhang and others, 2025)
  calls this "context collapse".
- So after an edit the skill rereads one level up, the paragraph and then the
  section. It rewrites only where the point has shifted, and asks before a
  rewrite outgrows a paragraph.

## Clarity on Every Level

Taken together, these findings put clarity on several levels at once, and
work on one level can't make up for a gap on another.

- **The idea and its context:** what the text means to say, and what the
  reader needs to follow it.
- **The whole text:** what comes first, and whether each addition still fits.
- **The paragraph:** where its point lands.
- **The sentence:** traps that make the reader parse twice.
- **The word:** the small words that carry the logic.

## Where the Skill Parts Ways With Popular Advice

Simplified Technical English and Orwell's rules serve their own readers well.
For the style the skill aims at, most of their rules work against the reader.

- **Word limits.** STE caps a sentence at 20 words in a procedure and 25 in a
  description. A cap splits sentences at arbitrary points, and the pieces
  often read worse than one longer sentence with a clear structure. In the
  skill, length is a hint to look closer, and no word count decides.
- **Cutting small words.** Orwell's rule "if it is possible to cut a word out,
  always cut it out" leads to compressed prose. The skill cuts whole sentences
  that carry nothing, and keeps the small words that carry the logic.
- **A plain vocabulary.** STE limits the writer to a dictionary of approved
  words. The skill leaves technical terms and names as they are.
- **Active voice by rule.** The skill flags a passive only when it hides an
  actor the writer knows.
- **Strict rules in general.** In Ihor's experience, a model follows them to
  the letter, and the prose comes out predictable and flat.

### What the Skill Kept

STE warns that dropping words to shorten a sentence creates ambiguity rather
than clarity. The skill agrees, and goes further: its telegraphic-style trap
asks the writer to put back the small words a colon or a dash replaced.

## Building jstyle

jstyle was built fresh, as a public plugin, on 1 November 2026. It drew on
writing rules Ihor had used and refined in private for three months.

- Before writing the skill, we ran its benchmark with no skill loaded: 10
  writing tasks, such as an email, a README, and release notes.
- That way the skill spends words only on failures current models still make.
- One surprise: asked to draft an email from a set of notes, Opus had the sender
  report a finding the notes never contained, in 2 of 3 samples. That became the
  skill's instruction to mark your own inferences as yours.
- The reports are in [bench/reports/](../bench/reports/).

## What Is Still Untested

Some parts of the skill rest on less than a measurement.

- **Reading cost.** The study counted how often each habit occurs. No one has
  timed or marked a human reading Claude's text.
- **Read one level up.** It rests on research about human writers, and no trial
  has tested whether it helps.
- **The approach itself.** That fewer rules make a better agent is Ihor's
  experience across many sessions and models, not a measured result.
- **The best cold-read model.** The default rests on our reasoning, and on one
  side-by-side run of Opus and Sonnet on Ihor's rule files.
- **The benchmark and the trials.** Ten tasks, three samples each, and the
  maintainer making blind picks between outputs with and without the skill. That
  is enough to steer an opinionated skill with one maintainer, but it is not a
  controlled study.

## Sources

- Anthropic (2026). Launch pages for [Claude Opus
  5](https://www.anthropic.com/news/claude-opus-5) (24 July), [Claude Opus
  5.5](https://www.anthropic.com/claude-opus-5-5) (22 September), and [Claude
  Sonnet 5.5](https://www.anthropic.com/claude-sonnet-5-5) (28 September).
- Anthropic (2026). [Claude's
  constitution](https://www.anthropic.com/constitution), and [Prompting best
  practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices).
- ASD-STE100, Simplified Technical English, Issue 9.
- Bever, T. G. (1970). The cognitive basis for linguistic structures. In
  J. R. Hayes (Ed.), *Cognition and the Development of Language*. Wiley.
- Camerer, C., Loewenstein, G., & Weber, M. (1989). The curse of knowledge in
  economic settings. *Journal of Political Economy*, 97(5), 1232–1254.
- Ferreira and Henderson (1990), Trueswell, Tanenhaus, and Kello (1993), and
  Liu (2008): full references in [the
  study](2026-10-30-readability-study.md#sources).
- Golubić, K. (2026, 2 October). [ASD-STE100: what it is and what it has to
  do with LLMs](https://kgolubic.com/posts/asd-ste100-and-llms/).
- Miller, G. A., & Chomsky, N. (1963). Finitary models of language users. In
  R. D. Luce, R. R. Bush, & E. Galanter (Eds.), *Handbook of Mathematical
  Psychology*, Vol. 2. Wiley.
- Orwell, G. (1946). Politics and the English language.
- Paddo (2026, 2 September). [A dial worth turning: Claude Opus 5's
  prose](https://paddo.dev/blog/a-dial-worth-turning/).
- Pinker, S. (2014). *The Sense of Style*. Viking.
- Sommers, N. (1980). Revision strategies of student writers and experienced
  adult writers. *College Composition and Communication*, 31(4), 378–388.
- Zhang, Q., and others (2025). Agentic context engineering.
  [arXiv:2510.04618](https://arxiv.org/abs/2510.04618).
