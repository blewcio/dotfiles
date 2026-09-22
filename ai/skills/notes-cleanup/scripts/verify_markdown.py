#!/usr/bin/env python3
"""Render-test edited Markdown files to catch broken syntax before calling a
note-cleanup (or learning-notes) pass done.

Usage:
    scripts/verify_markdown.py <file> [<file> ...]

Requires markdown-it-py. If it's not importable, create a venv once and
reuse it:
    python3 -m venv /tmp/mdtest && /tmp/mdtest/bin/pip install --quiet markdown-it-py
    /tmp/mdtest/bin/python3 scripts/verify_markdown.py <file> ...
"""
import re
import sys
from pathlib import Path

try:
    from markdown_it import MarkdownIt
except ImportError:
    sys.exit(
        "markdown-it-py not installed. Run:\n"
        "  python3 -m venv /tmp/mdtest && /tmp/mdtest/bin/pip install --quiet markdown-it-py\n"
        "  /tmp/mdtest/bin/python3 " + sys.argv[0] + " <file> ..."
    )

KNOWN_TAGS = {
    "<ul>", "<li>", "<ol>", "<p>", "<strong>", "<em>", "<code>", "<a>",
    "<br>", "<hr>", "<h1>", "<h2>", "<h3>", "<h4>", "<h5>", "<h6>",
    "<blockquote>",
}


def check(path: Path) -> None:
    md = MarkdownIt("commonmark")
    text = path.read_text(encoding="utf-8")
    html = md.render(text)

    if "<pre>" in html:
        print(f"{path} -> check: accidental code block, or an intentional fenced block?")

    suspicious = [
        s for s in re.findall(r"<[a-zA-Z][a-zA-Z0-9_+-]*>(?!</)", html)
        if s.lower() not in KNOWN_TAGS
    ]
    if suspicious:
        print(f"{path} -> unescaped tag-like content: {suspicious}")

    if "\xa0" in text:
        print(f"{path} -> non-breaking spaces: {text.count(chr(0xa0))}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: verify_markdown.py <file> [<file> ...]")
    for arg in sys.argv[1:]:
        check(Path(arg))
