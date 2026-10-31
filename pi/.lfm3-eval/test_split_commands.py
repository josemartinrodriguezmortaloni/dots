import pytest
from split_commands import split_commands


def test_basic_split():
    assert split_commands("ls -la") == ["ls -la"]


def test_semicolon_split():
    assert split_commands("a; b") == ["a", "b"]


def test_and_split():
    assert split_commands("a && b") == ["a", "b"]


def test_or_split():
    assert split_commands("a || b") == ["a", "b"]


def test_pipe_split():
    assert split_commands("a | b") == ["a", "b"]


def test_nested_quotes_semicolon_not_split():
    # Inside single quotes, a semicolon is literal.
    assert split_commands("it's; fine") == ["it's; fine"]


def test_double_quote_escape():
    # Double quotes delimit literal content including semicolons.
    assert split_commands("a \"b; c\"") == ["a \"b; c\""]


def test_empty_string():
    assert split_commands("") == []


def test_spaces_in_quotes():
    # Spaces inside single/double quotes are preserved as one token.
    assert split_commands("hello 'world'") == ["hello 'world'"]


def test_mixed_separators():
    assert split_commands("a; b && c || d | e") == ["a", "b", "c", "d", "e"]


def test_escaped_pipe():
    # Backslash before pipe should be treated as escape of the next char,
    # so no split at that position.
    assert split_commands("a \\| b") == ["a \\| b"]

