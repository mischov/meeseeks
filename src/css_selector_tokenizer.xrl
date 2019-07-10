Definitions.

NONASCII = [^\x00-\x7F]
ESCAPE = \\[^\r\n\f]
NMSTART = ([_A-Za-z]|{NONASCII}|{ESCAPE})
NMCHAR = ([_A-Za-z0-9-]|{NONASCII}|{ESCAPE})
NL = \n|\r\n|\r|\f
STRING1 = \"([^\n\r\f\\"]|\\{NL}|{ESCAPE})*\"
STRING2 = \'([^\n\r\f\\']|\\{NL}|{ESCAPE})*\'
IDENT = (\-)?{NMSTART}{NMCHAR}*
NAME = {NMCHAR}+
INT = [0-9]+
STRING = {STRING1}|{STRING2}
S = [\s\t\r\n\f]+
W = {S}?
AB_FORMULA = ([\+\-]{W})?{INT}?[nN]({W}[\+\-]{W}{INT})?

Rules.

\[{W} : {token, "["}.
{W}\] : {token, "]"}.
{W}\) : {token, ")"}.

~= : {token, value_includes}.
\|= : {token, value_dash}.
\$= : {token, value_suffix}.
\^= : {token, value_prefix}.
\*= : {token, value_contains}.
= : {token, value}.

{IDENT}\({W} : {token, {function, without_escapes(trim_and_drop_last(TokenChars))}}.
{AB_FORMULA} : {token, {ab_formula, TokenChars}}.
\+{INT} : {token, {int, drop_first(TokenChars)}}.
{INT} : {token, {int, TokenChars}}.
{STRING} : {token, {string, without_escapes(remove_quotes(TokenChars))}}.
{IDENT} : {token, {ident, without_escapes(TokenChars)}}.

\.{IDENT} : {token, {class, without_escapes(drop_first(TokenChars))}}.
#{NAME} : {token, {id, without_escapes(drop_first(TokenChars))}}.


\:{W} : {token, ":"}.
\*{W} : {token, "*"}.

{W}\^{W} : {token, "^"}.
{W}\|{W} : {token, "|"}.
{W}\,{W} : {token, ","}.

{W}>{W} : {token, ">"}.
{W}~{W} : {token, "~"}.
{W}\+{W} : {token, "+"}.
[\s\f]+ : {token, space}.

Erlang code.

drop_first([_|Rest]) ->
    Rest.

trim_and_drop_last(Chars) ->
    Trimmed = string:strip(Chars),
    Len = string:len(Trimmed),
    string:substr(Trimmed, 1, Len - 1).

remove_quotes(Chars) ->
    Len = string:len(Chars),
    string:substr(Chars, 2, Len - 2).

without_escapes(Chars) ->
    re:replace(Chars, "\\\\", "", [unicode, global, {return, list}]).
