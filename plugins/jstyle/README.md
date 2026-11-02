# jstyle

An opinionated prose style for your AI agent, so more of what you write gets
read.

The plugin has one skill, `/jstyle:write`. Your agent loads it when it writes
for a person outside the conversation, such as documentation, a README, a code
comment, release notes, or an email, and leaves it off for chat replies. To
load it yourself, run `/jstyle:write`.

The skill asks the agent to:

- start from facts and their sources before writing prose,
- work out what a sentence means to say when rewording doesn't make it clear,
- fit each edit into the paragraph around it, so the text still reads as a
  whole,
- avoid sentence patterns that make a reader stop and reparse, and
- be concise, but never so compressed that the meaning gets lost.

The skill also brings cold reads. The agent may give its text to a subagent
that gets only the text and one line on who it's for. The subagent lists what
it had to reread or couldn't follow. A cold read may cost extra tokens and
time. To have the agent ask you first, add a line such as "Ask before starting
a subagent." to your instructions file (`CLAUDE.md` in Claude Code).

The skill has been tested only in English, with Claude models.

The [project README](https://github.com/ihorh/jstyle#readme) has an example
with and without the skill, how to install and use it, and the benchmark
behind it.

## Disclaimer

jstyle shapes how an agent writes. It doesn't check facts, and it doesn't make
text fit for legal, regulatory, medical, or safety-critical use. Review what an
agent writes before you send or publish it. The software comes with no
warranty, as the [MIT License](https://github.com/ihorh/jstyle/blob/main/LICENSE)
states.

## License

Copyright © 2026 Ihor H.

- **MIT** ([LICENSE](https://github.com/ihorh/jstyle/blob/main/LICENSE))
  covers the plugin and its skill.
- **CC BY 4.0** ([LICENSE-DOCS](https://github.com/ihorh/jstyle/blob/main/LICENSE-DOCS))
  covers this README.
