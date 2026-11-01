---
name: write
description: Load before drafting text for a reader outside this conversation, such as a README, documentation, a docstring, release notes, a pitch, an email, or a draft shaped in chat. An opinionated house style that puts correct facts and clear ideas ahead of brevity.
---

# Write

This skill shapes text an agent writes for a person. Most writing advice fights
wordiness. This skill fights compression instead: the dropped words, verbless
fragments, and packed clauses that save the writer a token and cost the reader
a second pass.

It was written for Claude and other recent models. It states intent more than
procedure, and it relies on your judgment to apply it.

## When It Applies

The skill applies at handover, and the project's own conventions come first.

- **Handover** is the moment the text reaches its reader. A draft you hand to
  someone to send or publish counts, because for you it is the finished text.
- **Working notes are exempt:** thinking on paper, exploration, and a draft
  labeled as a working draft.
- **The project decides structure.** Its conventions set which sections exist,
  their order, their headings, and the line width. This skill writes what goes
  inside them. A section the convention requires stays, even when one sentence
  fills it.
- **A requested tone wins.** When the person asks for a level of formality,
  write to it.
- **Other languages** keep the principles and the facts. The sentence rules and
  examples are written for English, so let the language's own grammar decide
  their details.

## Principles

These call for judgment. A text can pass every rule below and still read like
paperwork.

1. **Write to a person, not for a record.** Say what you mean plainly, as you
   would to a colleague who asked, in a tone that is neither stiff nor chummy.
2. **Spend the reader's attention on what's new to them.** Leave out what they
   already know, and keep what they would otherwise have to work out.
3. **Clarity comes from the idea and its context, not from the wording
   alone.** When a sentence stays unclear after a few rewordings, work out the
   idea, or the context the reader is missing, before writing it again.
4. **Give a reference a refresher when the reader may need one.** A synonym, a
   phrase, or a sentence beside a term or a link often spares the reader a
   detour.
5. **Be concise, never compressed.** Cut whole sentences that carry nothing,
   and keep every word that lets the rest read in one pass.

## Facts and Sources

An invented sentence reads as smoothly as a checked one, so rereading a draft
won't catch it. That is why the facts come first.

- **List the facts before any prose,** each with its source: a file and line,
  a URL, a command you ran with what it printed, or something the person told
  you.
- **Source every claim specific to the subject,** such as its people, its
  numbers, or its history. General knowledge, such as how a standard library
  behaves, needs none.
- **Keep the facts that serve the reader,** and drop the rest even when they're
  true. The list itself stays out of the text.
- **Mark your own inferences as yours.** A consequence you worked out from the
  sources is often the most useful part of the text, and the reader needs to
  know it came from you.
- **In someone else's voice, put your inference beside the draft,** as a note
  for them to confirm, never in their mouth.

  > **Before.** The venue's confirmation says the hall seats 80. In the
  > invitation drafted for Marta to send to the club's members: "We've since
  > confirmed room for up to 120, so bring a friend."
  >
  > **After.** The invitation says the hall seats 80. Beside the draft: "From
  > the floor plan, I think the hall could take 120 without the tables. I
  > haven't checked with the venue. Confirm it before you promise it."

## Sentence Rules

These rules are cheap: each costs you a clause and saves the reader a question.
They govern sentences, never vocabulary, so a technical term stays as it is.

1. **Prefer the active voice when you know the actor.** Write "the script
   deletes the old logs" rather than "the old logs are deleted".
2. **Say what happens.** Write "the upload stops and shows an error" rather
   than "the upload is not completed".
3. **Keep one negation per sentence.** Two negations in a short phrase make the
   reader flip the meaning twice. "It's not unusual for the train not to stop
   here" becomes "the train often skips this station".
4. **Finish the thought.** When a refund can take up to two weeks, say how the
   customer checks where it is.
5. **Make a sentence's grammar visible.** Where a sentence could be read two
   ways, mark the one you mean with a word, a comma, or a different order.
   Write "while Anna dressed, the baby played in the crib" rather than "while
   Anna dressed the baby played in the crib".
6. **Keep the small words that carry the logic:** articles, verbs, and
   connectives such as "that", "because", and "so". When you replace a colon, a
   semicolon, or a dash with a full stop, write out the link it stood for.

   > **Before.** "Meeting moved: Thursday. Room TBC, bring slides."
   >
   > **After.** "The meeting has moved to Thursday. The room isn't booked yet,
   > so I'll send it once it is. Please bring your slides."

7. **Let the idea set the length.** Split a long sentence when its parts read
   better apart, and keep it whole when splitting would sound unnatural. No
   word count decides it.

## Revising

An edit follows the same order as a draft, starting from the facts. A
sentence's structure was built for the facts it carried, so a new fact can
outgrow it.

- **Patch or rewrite.** If the sentence still makes its point with the new
  fact, patch it. If the point shifts, list the facts again and write the
  sentence fresh.
- **Read one level up.** An added sentence can repeat, contradict, or bury
  something the paragraph already said. If the paragraph's point has shifted,
  rewrite the paragraph, then check the section the same way.
- **Stop climbing** at the first level whose point still holds.
- **Fix the old sentence** when a new fact makes it wrong, rather than adding a
  correction after it.
- **Ask before a large rewrite.** When a small edit would mean rewriting more
  than a paragraph, say what you'd change and confirm with the person first.

## Final Check

Your own context fills every gap the reader will fall into, so your reread
needs help.

- **Reread as the reader,** and look twice wherever one of these turns up. Each
  marks a place to look, never a verdict:
  - a hedge on something you know
  - a paragraph you could delete with nothing lost
  - a reference the reader can't place, or one the text never introduced
  - a fact you can't point at a source for
  - a word that sends the reader back to reparse the sentence
  - several clauses in one sentence, worst when nested
  - more than one negation in one sentence
- **Ask a fresh reader** when the reader won't share your context and the text
  gets one shot, as with an email, a README, release notes, or an instruction
  file. A fresh reader is a subagent or a new session that gets only the text,
  never this conversation, and reports what it couldn't resolve.
- **Skip the fresh reader** for a draft the person will read with you in chat,
  or a small local edit.
- **Say when you skipped it.** If you can't start a fresh reader, tell the
  person when you hand the text over.

