# Example Results

The full, unedited outputs of the two example prompts. Each prompt ran once on Opus 5.5 (`claude-opus-5-5`) without the skill
and once with it, through `bench/run.sh` with the same tools on both sides.
These are first attempts, shown as they came out.

## Water Shutoff

A note from a residents' committee to all tenants, written from
[committee-notes.md](water-shutoff/files/notes/committee-notes.md). Run
`runs/2026-11-01-claude-opus-5-5-4`. The session with the skill ran a cold
read.

The prompt:

> You are helping the residents' committee of Linden Court, a building with 36
> flats. From `notes/committee-notes.md`, write the note Jonas will email to all
> tenants and pin on the noticeboard about the water shutoff.
>
> Output only the note.

### Without the Skill

> **Water shutoff: Wednesday 18 November, from 9:00**
>
> Dear neighbours,
>
> On **Wednesday 18 November**, the water will be turned off for the whole building **from 9:00**. This includes **hot water**. Heating is on a separate circuit and will stay on.
>
> **Why:** Brightwater Plumbing is replacing the main water valve in the basement. The old valve leaked in October and flooded the basement storage, and our insurer wants it replaced before the policy is renewed in December.
>
> **When will the water be back?** We don't know for sure yet. The plumbers expect to finish by mid-afternoon, probably around 15:00, but it depends on what they find once the old valve is out. Please plan for the water to be off longer than that. I'll put a notice on the noticeboard as soon as the water is back on.
>
> **What to do beforehand**
> You don't need to do anything to your own taps or pipes. To get through the day more easily:
> - Fill a few bottles and your kettle the night before.
> - Keep a bucket of water for flushing the toilet.
> - Don't start the washing machine or dishwasher that morning.
>
> **When the water comes back**
> - The water may run brown or cloudy for a minute. Run the cold tap in the kitchen until it's clear.
> - The pipes may bang for a while because of air in them. This is normal.
>
> **Need help?**
> If you need water that day for medical reasons, or can't carry water yourself, please tell me **by Friday 13 November**. Ana from the committee can bring water up to your flat.
>
> **Basement**
> The basement storage will be locked all day. Please don't leave anything in the basement corridor.
>
> **Questions**
> Brightwater has asked tenants not to call them directly, so please send all questions to me:
> Jonas, flat 3B
> Phone: 0176 555 0142
> Email: jonas.linden3b@example.org
>
> Thank you for your patience.
>
> Jonas
> Secretary, Linden Court Residents' Committee

### With the Skill

> **Subject: Water off from 9 am on Wednesday 18 November**
>
> Dear neighbours,
>
> On Wednesday 18 November, Brightwater Plumbing will replace the main water valve in the basement. The water will go off for the whole building at 9 am. Hot water will go off too, because the boiler has to be switched off while the valve is out. The heating is on a separate circuit and will stay on.
>
> We don't know yet when the water will come back on. The foreman expects it by mid-afternoon, probably around 3 pm. It depends on what they find once the old valve is out. I'll put a notice on the noticeboard as soon as the water is back on.
>
> We're doing this now because the old valve leaked in October and flooded the basement storage. Our insurer wants it replaced before they renew the building's policy in December.
>
> You don't need to turn anything off or prepare your own taps or pipes. To get through the day:
>
> - Fill a few bottles and the kettle the night before.
> - Keep a bucket of water for flushing the toilet.
> - Don't start the washing machine or the dishwasher that morning.
>
> When the water comes back, it may run brown or cloudy for a minute. Run the cold tap in your kitchen until the water is clear. The pipes may bang for a while because of air in them.
>
> If you need water that day for medical reasons, or you can't carry water yourself, please tell me by Friday 13 November. Ana from the committee can bring water up to your flat.
>
> The basement storage will stay locked all day, so if you need anything from it, take it out before Wednesday. Please don't leave anything in the basement corridor.
>
> Please don't call Brightwater. Send all your questions to me:
>
> Jonas, flat 3B
> Phone: 0176 555 0142
> Email: jonas.linden3b@example.org
>
> Jonas
> Secretary, Linden Court residents' committee

### An Earlier Run

The first run, `runs/2026-11-01-claude-opus-5-5-3`, used a version of the
notes with the wrong weekdays: it called 18 November 2026 a Tuesday and
14 November a Friday. Both sessions, with the skill and without it, noticed
and asked Jonas to check the dates before sending. The notes were corrected
and the example run again.

## Install Pitch

One paragraph for an announcement post, written from a copy of the main
README. Run `runs/2026-11-01-claude-opus-5-5-3`. The session with the skill
ran a cold read.

The prompt:

> `README.md` in the current directory is the README of jstyle, an open-source
> project. Write one paragraph for the project's announcement post that will
> make people install the skill.
>
> Output only the paragraph.

### Without the Skill

> AI agents often write as if every word costs them. They drop small words like *that*, leave phrases without a verb, and nest clauses three deep, and the reader has to read the sentence twice to make up for the token the agent saved. jstyle is a Claude Code plugin with one skill, `/jstyle:write`, that works against this habit. Before the agent writes any prose, it lists its facts and where each one came from. It cuts sentences that carry nothing but keeps the small words that let the rest read in one pass, and it watches for patterns that make readers stop and reread, such as garden-path sentences and stacked negations. For text that gets one chance with its reader, like an email, a README, or release notes, it gives the draft to a fresh subagent for a cold read. That way the gaps the writer's own context hides get caught before your reader runs into them. You don't need to remember to call it, because the agent loads the skill on its own when it drafts text for someone outside the conversation. In the first blind benchmark, the maintainer preferred Opus 5.5's writing with the skill in 8 of 10 tasks. The project is early. It has been tested only in English with Claude models, and a session with it costs about 1.8 times as much and takes about twice as long. The full benchmark runs are in the repository so you can judge them yourself. To try it, run `/plugin install jstyle --marketplace ihorh/jstyle` in Claude Code 2.1.275 or later.

### With the Skill

> Left to themselves, AI agents often write as if every word cost them something. They drop the small words, put a colon where a verb should be, and nest one clause inside another, and the reader pays with a second pass. jstyle is a Claude Code plugin with one skill, `/jstyle:write`, that works against that habit. Before the agent writes any prose, the skill has it list its facts with their sources in its working notes, and mark the conclusions it drew itself as its own. While it writes, the agent watches for patterns that make a reader stop and reparse, such as stacked negations or garden-path sentences, where an early word suggests a reading that the rest of the sentence overturns. Before it hands over an email, a README, or release notes, it asks a subagent with none of its context to read the text cold and say where it got lost. You don't have to remember to call the skill, because the agent loads it on its own whenever it drafts text for someone outside the conversation. In the first benchmark, the maintainer compared Opus 5.5 with and without the skill, without knowing which output was which, and preferred the one with the skill in 8 of 10 writing tasks. That's one judge so far, and a session with the skill costs about 1.8 times as much and takes about twice as long. The full outputs are in `bench/runs/` in the [ihorh/jstyle](https://github.com/ihorh/jstyle) repository, so you can judge them yourself. To try it, run `/plugin install jstyle --marketplace ihorh/jstyle` in Claude Code 2.1.275 or later.
