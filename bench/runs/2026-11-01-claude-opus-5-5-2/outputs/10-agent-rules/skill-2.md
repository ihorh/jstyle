# Rules for coding agents in splitlane

These rules exist because agents have broken things here before. One agent renamed the chunk files during a "cleanup" PR, and that broke a user's pipeline. Another changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass. Users rely on the CLI's names, defaults, and output streams, so treat all of them as public interface.

## Output file names

Don't change the names of the files splitlane writes. Right now these are `part-0001.csv`, `part-0002.csv`, and so on, inside the `--out` directory. They are set in `split_file()` in `src/splitlane/split.py`.

A maintainer may ask you to rename them, as happened with the zero-padded scheme in 0.4.0. If so, update the example in `README.md` and add a line to `CHANGELOG.md` in the same change.

## CLI option defaults

Don't change the default value of any CLI option. The defaults are defined in `src/splitlane/cli.py` and listed in `README.md`. There are two exceptions:

- You may change the `--rows` default, but only after a maintainer agrees to it.
- A bug fix may change a default. A failing test doesn't make a default a bug. In that case, fix the code or the test.

If you do change a default, update `README.md` and the changelog.

## Dependencies

Don't add third-party dependencies. You can always use the Python standard library. You can use `pytest` in tests, but don't import it from the code under `src/`.

## Changelog

Every change gets a line in the `Unreleased` section of `CHANGELOG.md`. Bug fixes start with `Fix:`. There are two exceptions:

- An internal refactor that leaves behavior unchanged needs no line. A refactor that changes behavior does need one.
- A change that touches only tests needs no line.

## stdout and stderr

Don't print anything to stdout. All messages go to stderr and start with `splitlane: `, as the messages in `src/splitlane/cli.py` already do.

The one planned exception is a `--version` option. It doesn't exist yet. When someone adds it, it will print the version to stdout.

## Performance of `read_row()`

`read_row()` in `src/splitlane/split.py` reads its input one character at a time. Don't make it any slower than it is now. Every row of every input goes through this function, so even a small cost per character adds up on large files.
