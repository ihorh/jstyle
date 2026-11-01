import argparse
import sys

from splitlane.split import DEFAULT_MAX_ROW_BYTES, split_file

EXIT_OK = 0
EXIT_USAGE = 2
EXIT_ENCODING = 3


def main(argv=None):
    p = argparse.ArgumentParser(prog="splitlane")
    p.add_argument("input")
    p.add_argument("--rows", type=int, default=100000)
    p.add_argument("--out", default="out")
    p.add_argument("--max-row-bytes", type=int, default=DEFAULT_MAX_ROW_BYTES)
    p.add_argument("--encoding", default="utf-8")
    args = p.parse_args(argv)

    if args.rows < 1:
        print("splitlane: --rows must be at least 1", file=sys.stderr)
        return EXIT_USAGE

    print(f"splitlane: processing {args.input}", file=sys.stderr)
    try:
        written, truncated = split_file(args.input, args.rows, args.out,
                                        args.max_row_bytes, args.encoding)
    except UnicodeDecodeError as e:
        print(f"splitlane: cannot decode {args.input} as {args.encoding}: {e}",
              file=sys.stderr)
        return EXIT_ENCODING

    print(f"splitlane: wrote {len(written)} chunk(s) to {args.out}/", file=sys.stderr)
    if truncated:
        print(f"splitlane: warning: {truncated} row(s) longer than "
              f"{args.max_row_bytes} bytes were truncated", file=sys.stderr)
    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
