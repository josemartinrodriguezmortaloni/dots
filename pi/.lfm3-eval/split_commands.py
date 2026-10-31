def split_commands(cmd: str) -> list[str]:
    """Split a shell line into subcommands by ;, &&, || and |.

    Respects single quotes (literal), double quotes (escape sequences),
    and backslash escapes. Returns the tokens as a list of strings.
    """
    tokens = []
    current = []
    in_single = False
    in_double = False
    i = 0
    n = len(cmd)
    while i < n:
        ch = cmd[i]
        if not in_single and not in_double:
            # Quote toggles first.
            if ch == "'":
                in_single = not in_single
                current.append(ch)
                i += 1
                continue
            elif ch == '"':
                in_double = not in_double
                current.append(ch)
                i += 1
                continue
            # Multi-character separators.
            if cmd.startswith("&&", i):
                tokens.append("".join(current).strip())
                current = []
                i += 2
                continue
            elif cmd.startswith("||", i):
                tokens.append("".join(current).strip())
                current = []
                i += 2
                continue
            # Single-character separators.
            if ch == ";" or ch == "|":
                tokens.append("".join(current).strip())
                current = []
                i += 1
                continue
            elif ch == "\\":
                # Backslash escapes the next character: keep both as literal.
                if i + 1 < n:
                    current.append(ch)
                    current.append(cmd[i+1])
                else:
                    current.append(ch)
                i += 2
                continue
            else:
                current.append(ch)
                i += 1
        else:
            # Inside a quoted region: copy character verbatim.
            current.append(ch)
            i += 1
    if current:
        tokens.append("".join(current).strip())
    return tokens
