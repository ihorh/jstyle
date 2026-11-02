# What Makes Claude's Prose Hard to Read: A Study of Its Own Output

*30 October 2026. Ihor H. raised the questions and judged the result as a
reader. Claude (Opus 5.5) measured, analyzed, and wrote.*

*Reproduced from Ihor's private notes. The only edits remove the name of the
private repository that holds his rules, and its commit IDs. The skill these
findings later fed into is described in [How jstyle Came
About](background.md).*

*The opening below overstates the stumbling. By then the prose read well
enough, and it was unclear whether the rules or the newer models deserved the
credit. What remained was slightly off, in ways that were hard to name. [How
jstyle Came About](background.md#good-enough-and-slightly-off) tells it that
way.*

Many people find AI-written text tiring to read, and struggle to say why. The
grammar is fine and the facts check out, yet some sentences have to be read
twice. Ihor is one of those readers.

Ihor maintains a set of Claude Code writing rules, kept in a private
repository. They load into every Claude Code session Ihor runs. Ihor still kept stumbling over sentences Claude wrote under
them. Claude measured its own output to find out why. This document records
what it found, and what came out of it.

## Question and Short Answer

Ihor suspected two habits:

1. Claude drops optional words, *that* above all.
2. Claude places related words far apart. Such a sentence is compact for the
   model that wrote it, and harder for a human to follow.

Neither suspicion explained much. Claude does drop *that*, about once in 65
sentences, but half the cases follow *says*, which seldom misleads. Related
words sit no farther apart than in ordinary English. The costly habits were two
that Ihor had not suspected. Claude writes phrases with no verb, and nests
clauses three deep. The study changed two lines of the rules.

## Method

The corpus held the 50 most recent Claude Code session transcripts on
Ihor's machine, spanning 16 to 30 October 2026. From them Claude took
784 chat replies and 63 Markdown files it had written, about 760,000
characters in all. It removed code blocks, and replaced inline code with a
placeholder word. Opus 5.5 wrote 86% of the text, and four other Claude models
wrote the rest.

Every session loaded the same version of the rules. It was written on
6 August 2026, and its wording did not change during the corpus window.

Two passes ran over the corpus:

- **Patterns.** Regular expressions counted word patterns over 7,597
  sentences. Claude then read a random sample of each pattern's matches and
  judged how many were real. It also read 60 random sentences of 12 words or
  more and judged each one.
- **Parser.** spaCy 3.8.2 with the `en_core_web_sm` model parsed 7,726
  sentences. The parser splits sentences differently from the patterns, so the
  totals differ. Before using a count, Claude read 10 random examples behind
  it. It discarded any count whose examples were mostly parse errors.

Words and sentences quoted as language examples appear in italics.

## Findings

| Habit | Result |
|---|---|
| Dropping *that* before a clause (*confirm the files match*) | Found about once in 65 sentences. Half the checked cases followed *says*, which seldom misleads. |
| Dropping *that* before a description of a noun (*the commit I pushed*) | Found in about a third of such descriptions. These mostly read fine, because the pronoun marks where the description starts. |
| Spreading related words far apart | Not a general habit. Linked words, such as a verb and its subject, sit 2.2 to 2.4 words apart on average, across chat and documents. Liu (2008) reported 2.5 for English. |
| A phrase with no verb, usually after a colon | Found in about 3 to 4 replies in 100. Not on the original list. |
| A clause nested inside a clause inside a clause | Found in about 2 sentences in 100, and Claude judged 4 in 10 of those hard to read. Not on the original list. |

Of the 60 longer sentences Claude read by hand, it judged 7 to cost a reader
extra work. Three placed related words far apart, and four left out a word the
reader needed. In two of those four, the missing word was a verb:

- *Your other two stores split on audience: you across all projects, and one
  repository.* The reply was about where Claude keeps notes between sessions.
  It meant that one store holds what Claude learns about the user, across all
  projects, and the other holds what it learns about one repository.
- *Any other output, a conflict above all, means stop and show me.* It meant
  that if a command prints anything else, a conflict especially, Claude
  should stop and show the output.

One hard nested sentence asked about *a partitioned asset with an upstream
that is a single unpartitioned asset that failed*. Each *that* opens a clause
inside the one before it. The reader has to work out which asset failed.
Most of the hard nested sentences stated a reason. Claude infers that a reason
which resists plain wording was unclear to the writer as well. Nothing here
tests that.

## Why a Dropped Word Costs More in Print

Psycholinguistics calls it a garden-path sentence when the opening of a
sentence steers the reader to the wrong reading. A later word then doesn't fit,
and the reader has to go back and parse the sentence again. The name comes from
the idiom "to lead someone up the garden path", meaning to mislead them. The
textbook example is *The horse raced past the barn fell*. The reader takes
*raced* as the main verb, and then *fell* has nowhere to go. The sentence
means that the horse which was raced past the barn fell.

The case in Claude's writing is milder and far more common. Some verbs can be
followed by a single thing or by a whole statement. *Confirm*, *know*, *find*,
*show*, and *mean* are among them. You can confirm *the files*, or confirm
*that the files match*. Take *I'll confirm your files match the repo copies*:

- Since *confirm* can be followed by a single thing, the reader first takes
  *your files* as what gets confirmed.
- *Match* then breaks that reading, and the reader reparses *your files
  match…* as a whole statement.
- *I'll confirm that your files match…* avoids the wrong first reading,
  because *that* signals a statement before it starts.

Readers slow down at exactly this ambiguity. Ferreira and Henderson (1990) and
Trueswell, Tanenhaus, and Kello (1993) both timed readers on such sentences,
with and without *that*. Without it, readers slowed down. The two teams
disagree on a finer point. Trueswell's team found that a verb usually followed
by a whole statement, such as *know*, softens the slowdown. Ferreira and
Henderson found no such effect.

A garden path like this is rarely a problem in speech. The speaker's stress
and pauses mark where each clause starts. Before this study, the rules tested a
sentence by asking whether you would say it out loud. A garden path passes that
test, but a reader of written text hears no intonation to lean on.

## What Changed in the Rules

The rules state intent, and leave the wording to the model's judgment. In
Ihor's experience, a rule that bans a word or a pattern backfires with a
language model. The model follows the letter of the rule, for instance by
inserting the word everywhere. It also misses the next pattern the rule didn't
name. So no edit here names *that*, colons, or any other word. Each change
names a failure the writer can recognize, whatever words caused it.

The Diagnostics table in the rules file `writing.md` lists signals that
point the writer at a rule or principle to check. The study changed two of its
rows. Before:

```markdown
| A sentence nobody would say out loud | principle 1 |
| More than two clauses in one sentence | rules 4-6 |
```

After:

```markdown
| A garden path: a word that sends the reader back to reparse | principle 1 |
| More than two clauses in one sentence, worst when nested | rules 4-6, principle 3 |
```

Principle 1 asks the writer to write to a person rather than for a record.
At the time of this study, principle 3 said prose that resists plain writing
hides an unclear idea. Rules 4 to 6 asked the writer to name the actor, say
what happens, and make every noun resolve where it is used. A later edit dropped
the noun rule and renumbered the rest, so rule 9 below is now rule 8.

The out-loud row asked the writer to hear the sentence, and a model cannot hear.
Even a human writer misses a garden path when reading their own sentence aloud.
The voice supplies the pause that written text lacks. The new row names the
failure itself, which a writer can look for in the text.

Unmarked clause starts, as after a dropped *that*, got no row of their own.
They are one common cause of a garden path, but a row naming them would narrow
the writer's search to that one cause. In Ihor's reading, one dropped
*that* sounds like speech and reads fine, but two in one sentence leave the
reader guessing at two boundaries at once. The study did not count this.

Both rows sit in `writing.md`. That file governs a document once it is handed
over to its reader. Chat follows `chatting.md`, which stays closer to speech,
because a reader in chat can ask back.

A rule to keep *that* was considered and left out. Other small words mark where
a clause starts too. *Which* and *who* open a description. *Whether* opens a
question, as in *check whether it works*. A phrase after a colon needs its
own verb to show how it connects to the sentence. A rule about *that* alone
would leave out every one of these cases. It would also push the model to insert
*that* everywhere, and the prose would read stiff.

## What It Led To

The study changed the two rows directly. Discussing it led further, to a new
rule 9, "Show the structure before the reader guesses it", and to changes in
principles 1 and 3. Ihor and Claude learned more from that discussion than from
the numbers:

- The cost sits in sentence structure, and no single word causes it.
- Print needs words where speech uses pauses. Colons and dashes often stand in
  for intonation. Removing one means bringing back the word it replaced, such
  as *because*, *so*, or a verb.
- Some lines in the rules ask for an outcome the writer cannot check. A model
  cannot hear a sentence read out loud, or experience a reader's first
  reading.
- A sentence can resist plain wording even when its idea is clear. Each of the
  two verbless examples above had a clear meaning, and stating it took a full
  sentence. The writer had compressed away context the reader needed. Every
  session in the corpus had principle 3 loaded, and its wording at the time
  named only an unclear idea as the cause. This rests on two examples, and
  nothing here measures it.
- A writer who checks a draft against the rules still has the session in
  mind: what was discussed, decided, and read. That context fills the gaps a
  reader would hit, so the draft passes the writer's own check. This holds for
  a human writer too. A second reader, given only the document and an
  instruction, would not have that context. A separate agent with a fresh
  context, which Claude Code calls a subagent, can play that reader.

These questions came up along the way, and are still open:

| Question | What an answer would improve |
|---|---|
| Which other lines in the rules state a wish rather than an action? | Rules a model can act on |
| Why do documents grow with each edit, and can a second reader catch it? | Documents that get consolidated rather than appended to |
| What should a second reader be told, when should it run, and on which model? | Faster review before a document is handed over |
| Which rules hold outside English? | Writing in Ukrainian, where the rule of one negation per sentence misfires on double negatives that mean one negation |
| When is restating context from another file worth the words? | Documents that make sense when sent on their own |

## Limits

- Claude decided which matches were real and which sentences were hard.
  Only Ihor experienced the stumbling. So the rates show how common each habit
  is, not what it costs a reader. A better test would be a human marking
  each sentence they had to read twice. That was not part of this study.
- Each hand check read 10 to 60 sentences, so ratios such as 4 in 10 are
  rough.
- One private project supplied 62% of the chat text. Its technical names trip
  the parser.
- The text is agentic coding chat, written under the rules of 6 August 2026.
  Default Claude, other rules, or other kinds of writing may differ in either
  direction.
- The findings mix chat and documents. Documents gave only 763 of the 7,726
  parsed sentences, about 10%. That is too few to report on their own, so the
  rates mostly describe chat.
- Ihor asked which other known patterns make text hard to read. Claude named
  four more, and this study did not measure them. They are unclear pronoun
  reference, two names for one thing, a phrase that could modify either of two
  words, and the order of new and known information in a sentence.

## Sources

- Ferreira, F., & Henderson, J. M. (1990). Use of verb information in
  syntactic parsing: Evidence from eye movements and word-by-word self-paced
  reading. *Journal of Experimental Psychology: Learning, Memory, and
  Cognition*, 16, 555–568.
  [PDF](https://ferreiralab.faculty.ucdavis.edu/wp-content/uploads/sites/222/2015/05/Ferreira-Henderson-1990_VerbInformationParsing_JEPLMC.pdf)
- Trueswell, J. C., Tanenhaus, M. K., & Kello, C. (1993). Verb-specific
  constraints in sentence processing: Separating effects of lexical preference
  from garden-paths. *Journal of Experimental Psychology: Learning, Memory, and
  Cognition*, 19.
- Liu, H. (2008). Dependency distance as a metric of language comprehension
  difficulty. *Journal of Cognitive Science*, 9(2), 159–191.
  [Record](https://s-space.snu.ac.kr/handle/10371/70907)
- Niu, R., & Wang, Y. (2023). The cross-linguistic variations in dependency
  distance minimization and its potential explanations. *PACLIC 37*.
  [PDF](https://aclanthology.org/2023.paclic-1.56.pdf). It quotes Hudson
  (2009), who reports Liu's mean dependency distance for English as about 2.5
  words. That is the average distance, counted in words, between a word and
  the word it grammatically depends on.

Claude read the abstracts and secondary summaries of the first three papers,
not the papers in full. It read the passage in Niu and Wang that gives the
figure for English.
