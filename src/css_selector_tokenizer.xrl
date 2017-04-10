Definitions.

NMSTART = [A-Za-z_]
NMCHAR = [-A-Za-z0-9_]
NL = \n|\r\n|\r|\f
STRING1 = \"([\t\s\!\#\$\%&\(-~]|\\{NL}\|\')*\"
STRING2 = \'([\t\s\!\#\$\%&\(-~]|\\{NL}\|\")*\'
IDENT = (\-)?{NMSTART}{NMCHAR}*
NAME = {NMCHAR}+
INT = [0-9]+
STRING = {STRING1}|{STRING2}
W = [\s\t\r\n\f]*
AB_FORMULA = {W}[\+\-]?{W}{INT}?[nN]{W}([\+\-]{W}{INT})?

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

{IDENT}\( : {token, {function, drop_last(TokenChars)}}.
{AB_FORMULA} : {token, {ab_formula, TokenChars}}.
\+{INT} : {token, {int, drop_first(TokenChars)}}.
{INT} : {token, {int, TokenChars}}.
{STRING} : {token, {string, remove_quotes(TokenChars)}}.
{IDENT} : {token, {ident, TokenChars}}.

\.{IDENT} : {token, {class, drop_first(TokenChars)}}.
#{NAME} : {token, {id, drop_first(TokenChars)}}.


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

drop_last(Chars) ->
    Len = string:len(Chars),
    string:substr(Chars, 1, Len - 1).

remove_quotes(Chars) ->
    Len = string:len(Chars),
    string:substr(Chars, 2, Len - 2).
