import csv
import io
import os

DEFAULT_MAX_ROW_BYTES = 65536


def read_row(stream, max_row_bytes=DEFAULT_MAX_ROW_BYTES):
    buf = []
    size = 0
    in_quotes = False
    while True:
        ch = stream.read(1)
        if ch == "":
            if not buf:
                return None, False
            break
        if ch == '"':
            in_quotes = not in_quotes
        if ch == "\n" and not in_quotes:
            break
        size += len(ch.encode("utf-8"))
        if size > max_row_bytes:
            # skip to the next newline, quoted or not, or to the end of input
            while True:
                ch = stream.read(1)
                if ch == "" or ch == "\n":
                    break
            return "".join(buf), True
        buf.append(ch)
    return "".join(buf), False


def split_file(path, rows_per_chunk, out_dir, max_row_bytes=DEFAULT_MAX_ROW_BYTES,
               encoding="utf-8"):
    os.makedirs(out_dir, exist_ok=True)
    truncated = 0
    chunk_index = 0
    written = []
    with open(path, encoding=encoding, newline="") as f:
        header, _ = read_row(f, max_row_bytes)
        if header is None:
            return written, truncated
        out = None
        rows_in_chunk = rows_per_chunk
        while True:
            row, was_truncated = read_row(f, max_row_bytes)
            if row is None:
                break
            if was_truncated:
                truncated += 1
            if rows_in_chunk == rows_per_chunk:
                if out is not None:
                    out.close()
                chunk_index += 1
                name = os.path.join(out_dir, f"part-{chunk_index:04d}.csv")
                out = open(name, "w", encoding="utf-8", newline="")
                out.write(header + "\n")
                written.append(name)
                rows_in_chunk = 0
            out.write(row + "\n")
            rows_in_chunk += 1
        if out is not None:
            out.close()
    return written, truncated


def count_columns(line):
    return len(next(csv.reader(io.StringIO(line))))
