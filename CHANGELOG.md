# Changelog

Versions of the jstyle plugin. A minor version changes how the agent writes or
behaves. A patch changes wording or metadata without meaning to change
behaviour. A major version would remove or rename something users rely on.

## 0.3.0 (2026-11-02)

- **Cold reads:** the agent now treats a reader's question as a sign of where
  the reader got lost, not as a request to change that passage. It looks for
  the cause, which may be a word, missing context, or an unsettled idea, and
  may sit outside the quoted passage.
- The plugin has its own README, an icon, and keywords for a directory
  listing, and its display name now says "prose style". The skill's
  frontmatter names its license.

## 0.2.0 (2026-11-01)

- **Handover** is now the moment a text is finished for you, including a part
  of a text the person accepts before the conversation moves on. Before, it
  was the moment the text reached its reader, so in co-editing an agent could
  treat every round as still a draft.

## 0.1.0 (2026-11-01)

- First release: one skill, `/jstyle:write`, with principles, facts and
  sources, sentence traps, revising, a final check, and cold reads.
