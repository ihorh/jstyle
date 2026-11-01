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

It applies at handover, the moment the text reaches its reader. A draft you
hand to someone to send or publish counts, because for you it is the finished
text. Working notes are exempt: thinking on paper, exploration, and a draft
labeled as a working draft.

A project's own conventions decide the structure: which sections exist, their
order, their headings, and the line width. This skill decides what goes inside
them. A section the convention requires stays, even when one sentence fills it.

## Principles

These call for judgment. A text can pass every rule below and still read like
paperwork.

1. **Write to a person, not for a record.** Say what you mean plainly, as you
   would to a colleague who asked, even when it isn't what they expect. A
   softened point leaves the reader to decode it. Being direct doesn't mean
   being casual.
2. **Write what the reader needs and can't work out alone.** A paragraph that
   restates what the reader already knows spends their attention and returns
   nothing.
3. **Clarity comes from the idea, not the wording.** A sentence reads plainly
   when its idea is clear to you, and when the reader has the context to follow
   it. Getting there may take more words.
4. **Bring a refresher with every reference.** When you point at a term, a
   concept, or another document, put enough beside it for a reader who knows it
   to recall it: a synonym, a phrase, or a sentence. The refresher only jogs
   the memory of a reader who already knows the thing. A reader who doesn't
   will open the source anyway. Quote at length only when the quote is the
   point.
5. **Be concise, never compressed.** Cut a whole sentence that carries nothing.
   Keep the words inside a sentence that let it read in one pass: articles,
   verbs, and connectives such as "that", "because", and "so". A shorter
   sentence that needs a second reading costs more than a longer one that
   doesn't.

   > **Before.** "Truncation: silent, flag only; caller must check."
   >
   > **After.** "When a row is too long, the function cuts it and returns a
   > flag. Nothing else reports the cut, so the caller has to check the flag."

## Rules

These are cheap. Each costs you a clause and saves the reader a question.

1. **Prefer the active voice when you know the actor.** Write "the encoder
   writes the bytes" rather than "the bytes are written". Keep the passive for
   an actor you don't know.
2. **Say what happens.** Write "`copy()` truncates the string and returns
   `true`" rather than "truncation is not an error".
3. **One negation per sentence.** Each negation makes the reader flip the
   meaning, and two in a short phrase stop them. "Nothing else needs a
   non-default standard" becomes "only this unit needs a non-default standard".
   A negation repeated across a list counts once, so "no prefix and no suffix"
   is fine.
4. **Finish the thought.** Saying an operation can truncate is half an answer.
   Say how the reader tells that it did. Otherwise they leave the text to find
   out.
5. **Show the structure before the reader guesses it.** Speech marks structure
   with pauses and stress, and text has only words and punctuation. Where a
   sentence could be read two ways, mark the one you mean with a word, a comma,
   or a different order. Write "while the agent edited, the file grew" rather
   than "while the agent edited the file grew". When you replace a colon, a
   semicolon, or a dash with a full stop, write out the link it stood for,
   such as "because" or "so".

Never simplify a technical word. These rules govern sentences, never
vocabulary.

## Facts Before Prose

Before writing any prose, list the facts the text will rest on, and give each
one its source:

- a file and line
- a URL
- a command you ran, with what it printed
- something the person told you

A claim about the project, its people, or its numbers needs one of these.
General technical knowledge, such as how a standard library behaves, does not.
A claim about the project that you can't source is one you invented. Check
before you write, not after: an invented sentence reads as smoothly as a
checked one, so rereading the draft won't flag it. Keep the facts that serve
the reader, and drop the rest even when they're true. The list itself stays
out of the text.

## Keep Your Inferences Your Own

Often you'll work something out that no source states: a consequence of the
code, a risk, a likely cause. Say it, because it's often the most useful part
of the text. But mark it as your reasoning, and keep it apart from what the
sources say.

That matters most when you write in someone else's voice, as in an email
drafted for a person. Your inference is not their finding. Put it beside the
draft as a note for them to confirm, rather than in their mouth.

> **Before.** The notes call a bug Windows-only. In an email drafted for the
> bug's owner to send to Priya, who decides the release: "Since then I've
> found it's wider than that. Any run that stops
> partway leaves the same mix of files, on any computer."
>
> **After.** The email describes the bug as the notes do. Beside the draft:
> "From the code, I think any run that stops partway leaves the same mix, on
> any system, not only Windows. I haven't tested it. Confirm it before you
> mention it to Priya."

## Revising

An edit follows the same order as a draft: facts first. A sentence's structure
was built for the facts it carried. If it still makes its point with the new
fact, a patch is enough. If the point shifts, list the facts again and write
the sentence fresh.

Then read one level up. An added sentence can repeat, contradict, or bury
something the paragraph already said. If the paragraph's point has shifted,
rewrite the paragraph, then check the section the same way. Keep climbing while
the point keeps shifting. An addition needs this check more than a substitution
does. When a new fact makes an old sentence wrong, fix the old sentence rather
than adding a correction after it.

## Before Handing Over

Reread the text as its reader, and look twice wherever one of these turns up.
Each one marks a place to look, never a verdict:

- a hedge on something you know
- a paragraph you could delete with nothing lost
- a reference with no refresher beside it, or to something the text never
  introduced
- a fact you can't point at a source for
- a word that sends the reader back to reparse the sentence
- more than two clauses in one sentence, worst when nested
- more than one negation in one sentence

Splitting a sentence follows from clarity, never the other way round.

Your own reread has a blind spot: your context fills every gap the reader will
fall into. So when the reader won't share your context and the text gets one
shot, ask a fresh reader too. That covers an email, a README, release notes, or
an instruction file. A fresh reader is a subagent, or any new session, that
gets only the text and asks what it couldn't resolve. It never sees this
conversation. A draft the person will read with you in chat, or a small local
edit, usually needs only your own reread. If you can't start a fresh reader,
say so when you hand the text over, so the person knows the check was
skipped.

## Other Languages

The principles, Facts Before Prose, and Revising hold in any language. Rule 3
and the examples are written for English. In another language, keep their
intent and let that language's grammar decide the details.
