# Questions

1. May an agent rename output files? *Only when a maintainer asks, and then it
   updates the README and the changelog.*
2. May an agent add a dependency? *Only `pytest`, for tests, or the standard
   library.*
3. Where do messages go? *stderr, except `--version` output once it exists.*
4. When does a change need a changelog line? *When it changes behavior. Pure
   refactors and test-only changes don't.*
5. Why do these rules exist? *Agents renamed chunk files and changed the
   `--max-row-bytes` default to make a test pass.*

## Unsupported If Claimed

Rules the draft doesn't contain, such as a test coverage threshold.
