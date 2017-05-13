%%
%% DERIVATIVE WORK COPYRIGHT ------------------------------------------------
%%
%% The MIT License (MIT)
%%
%% Copyright (c) 2017 Mischov (https://github.com/mischov)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a
%% copy of this software and associated documentation files (the "Software"),
%% to deal in the Software without restriction, including without limitation
%% the rights to use, copy, modify, merge, publish, distribute, sublicense,
%% and/or sell copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
%% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
%% DEALINGS IN THE SOFTWARE.
%%
%% ORIGINAL COPYRIGHT -------------------------------------------------------
%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2003-2016. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

%% Description  : Yecc spec for XPATH grammar
%%    This version of the parser is based on the XPATH spec:
%%    http://www.w3.org/TR/1999/REC-xpath-19991116 (XPATH version 1.0)

Nonterminals
	'LocationPath'
	'AbsoluteLocationPath'
	'RelativeLocationPath'
	'Step'
%%	'AxisSpecifier'
	'NodeTest'
	'Predicate'
	'PredicateExpr'
	'AbbreviatedAbsoluteLocationPath'
	'AbbreviatedRelativeLocationPath'
	'AbbreviatedStep'
%%	'AbbreviatedAxisSpecifier'
	'Expr'
	'PrimaryExpr'
	'FunctionCall'
	'Argument'
	'UnionExpr'
	'PathExpr'
	'FilterExpr'
	'OrExpr'
	'AndExpr'
	'EqualityExpr'
	'RelationalExpr'
	'AdditiveExpr'
	'MultiplicativeExpr'
	'UnaryExpr'
%%	'Operator'
%%	'OperatorName'
	'MultiplyOperator'
	'NameTest'
	'<PredicateList>'
	'<PredicateMember>'
	'<ArgumentList>'
	'<ArgumentMember>'
	.

Terminals
	'number'
	'axis'
	'node_type'
	'literal'
	'prefix_test'
	'var_reference'
	'function_name'
	'name'
	'processing-instruction'
	'wildcard'
	'(' ')' '[' ']' '.' '..' '@' ',' '::'
	'and' 'or' 'mod' 'div'
	'/' '//' '|' '+' '-' '=' '!=' '<' '<=' '>' '>='
	'*'
	.

Rootsymbol 'Expr'.

Endsymbol '$end' .

Left 100 'or' .
Left 200 'and' .
Left 300 '=' .
Left 300 '!=' .
Left 400 '<' .
Left 400 '>=' .
Left 400 '>' .
Left 400 '<=' .
Unary 500 '-' .

Expect 2.

%%------------------------------------------------------------
%% Clauses
%%

%% [1]
'LocationPath' -> 'RelativeLocationPath' :
        path(rel, lists:flatten(['$1'])) .
'LocationPath' -> 'AbsoluteLocationPath' :
        path(abs, lists:flatten(['$1'])) .

%% [2]
'AbsoluteLocationPath' -> '/' 'RelativeLocationPath' : '$2' .
'AbsoluteLocationPath' -> '/' :
        erlang:error("Path `/` would return Document, did you mean `/*`?") .

%% [3]
'RelativeLocationPath' -> 'AbbreviatedAbsoluteLocationPath' : '$1' .
'RelativeLocationPath' -> 'Step' : '$1' .
'RelativeLocationPath' -> 'RelativeLocationPath' '/' 'Step' :
	['$1', '$3'] .
'RelativeLocationPath' -> 'AbbreviatedRelativeLocationPath' : '$1' .

%% [4]
'Step' -> 'axis' '::' 'NodeTest' '<PredicateList>'
	: step(value('$1'), '$3', '$4') .
'Step' -> 'axis' '::' 'NodeTest'
	: step(value('$1'), '$3', []) .
'Step' -> '@' 'name' '<PredicateList>'
	: step(value('$1'), '$2', '$3') .
'Step' -> '@' 'name'
	: step('attribute', '$2', []) .
'Step' -> 'NodeTest' '<PredicateList>'
	: step('child', '$1', '$2') .
'Step' -> 'NodeTest'
	: step('child', '$1', []) .
'Step' -> 'AbbreviatedStep' : unreachable("'Step' -> 'AbbreviatedStep'") .

'<PredicateList>' -> '<PredicateMember>' : lists:reverse('$1') .

'<PredicateMember>' -> '<PredicateMember>' 'Predicate'
	: ['$2'|'$1'] .
'<PredicateMember>' -> 'Predicate' : ['$1'] .

%% [5]
%% 'AxisSpecifier' -> 'axis' '::' : '$1' .
%% 'AxisSpecifier' -> 'AbbreviatedAxisSpecifier' : '$1' .

%% [7]
'NodeTest' -> 'NameTest' : '$1' .
'NodeTest' -> 'node_type' '(' ')' : node_type('$1') .
'NodeTest' -> 'processing-instruction' '(' ')' : node_type('$1') .
'NodeTest' -> 'processing-instruction' '(' 'literal' ')'
	: processing_instruction('$3') .

%% [8]
'Predicate' -> '[' 'PredicateExpr' ']' : predicate_expr('$2') .

%% [9]
'PredicateExpr' -> 'Expr' : '$1' .

%% [10]
'AbbreviatedAbsoluteLocationPath'  -> '//' 'RelativeLocationPath'
	: {'//', '$2'} .

%% [11]
'AbbreviatedRelativeLocationPath' -> 'RelativeLocationPath' '//' 'Step'
	: {'$1', '//', '$3'} .

%% [12]
'AbbreviatedStep' -> '.' : unreachable("'AbbreviatedStep' -> '.'") .
'AbbreviatedStep' -> '..' : unreachable("'AbbreviatedStep' -> '..'") .

%% [13]
%% 'AbbreviatedAxisSpecifier' ->  '$empty' : 'child' .
%% 'AbbreviatedAxisSpecifier' ->  '@' : '$1' .

%% [14]
'Expr' -> 'OrExpr' : '$1' .

%% [15]
'PrimaryExpr' -> 'var_reference' : no_varrefs() .
'PrimaryExpr' -> '(' Expr ')' : '$2' .
'PrimaryExpr' -> 'literal' : literal_expr('$1') .
'PrimaryExpr' -> 'number' : number_expr('$1') .
'PrimaryExpr' -> 'FunctionCall' : '$1' .

%% [16]
'FunctionCall' -> 'function_name' '(' ')' : function_expr('$1', []) .
'FunctionCall' -> 'function_name' '(' '<ArgumentList>' ')'
	: function_expr('$1', '$3') .

'<ArgumentList>' -> '<ArgumentMember>' : lists:reverse('$1') .

'<ArgumentMember>' -> '<ArgumentMember>' ',' 'Argument'
	: ['$3'|'$1'] .
'<ArgumentMember>' -> 'Argument' : ['$1'] .

%% [17]
'Argument' -> 'Expr' : '$1' .

%% [18]
'UnionExpr' -> 'PathExpr' : '$1' .
'UnionExpr' -> 'UnionExpr' '|' 'PathExpr' : union_expr('$1', '$3') .

%% [19]
'PathExpr' -> 'LocationPath' : '$1' .
'PathExpr' -> 'FilterExpr' : '$1' .
'PathExpr' -> 'FilterExpr' '/' 'RelativeLocationPath' :
        ['$1', '$3'] .
'PathExpr' -> 'FilterExpr' '//' 'RelativeLocationPath' :
        unreachable("'PathExpr' -> 'FilterExpr' '//' 'RelativeLocationPath'") .

%% [20]
'FilterExpr' -> 'PrimaryExpr' : '$1' .
'FilterExpr' -> 'FilterExpr' 'Predicate' : filter_expr('$1', '$2') .

%% [21]
'OrExpr' -> 'AndExpr' : '$1' .
'OrExpr' -> 'OrExpr' 'or' 'AndExpr'
	: boolean_expr('or', '$1', '$3') .

%% [22]
'AndExpr' -> 'EqualityExpr' : '$1' .
'AndExpr' -> 'AndExpr' 'and' 'EqualityExpr'
	: boolean_expr('and', '$1', '$3') .

%% [23]
'EqualityExpr' -> 'RelationalExpr' : '$1' .
'EqualityExpr' -> 'EqualityExpr' '=' 'RelationalExpr'
	: comparative_expr('=', '$1', '$3') .
'EqualityExpr' -> 'EqualityExpr' '!=' 'RelationalExpr'
	: comparative_expr('!=', '$1', '$3') .

%%[24]
'RelationalExpr' -> 'AdditiveExpr' : '$1' .
'RelationalExpr' -> 'RelationalExpr' '<' 'AdditiveExpr'
	: comparative_expr('<', '$1', '$3') .
'RelationalExpr' -> 'RelationalExpr' '>' 'AdditiveExpr'
	: comparative_expr('>', '$1', '$3') .
'RelationalExpr' -> 'RelationalExpr' '<=' 'AdditiveExpr'
	: comparative_expr('<=', '$1', '$3') .
'RelationalExpr' -> 'RelationalExpr' '>=' 'AdditiveExpr'
	: comparative_expr('>=', '$1', '$3') .

%% [25]
'AdditiveExpr' -> 'MultiplicativeExpr' : '$1' .
'AdditiveExpr' -> 'AdditiveExpr' '+' 'MultiplicativeExpr'
	: arithmetic_expr('+', '$1', '$3') .
'AdditiveExpr' -> 'AdditiveExpr' '-' 'MultiplicativeExpr'
	: arithmetic_expr('-', '$1', '$3') .

%% [26]
'MultiplicativeExpr' -> 'UnaryExpr' : '$1' .
'MultiplicativeExpr' -> 'MultiplicativeExpr' 'MultiplyOperator' 'UnaryExpr'
	: arithmetic_expr('*', '$1', '$3') .
'MultiplicativeExpr' -> 'MultiplicativeExpr' 'div' 'UnaryExpr'
	: arithmetic_expr('div', '$1', '$3') .
'MultiplicativeExpr' -> 'MultiplicativeExpr' 'mod' 'UnaryExpr'
	: arithmetic_expr('mod', '$1', '$3') .

%% [27]
'UnaryExpr' -> 'UnionExpr' : '$1' .
'UnaryExpr' -> '-' UnaryExpr : negative_expr('$2') .

%% [32]
%% 'Operator' -> 'OperatorName' : '$1' .
%% 'Operator' -> 'MultiplyOperator' : '$1' .
%% 'Operator' -> '/' : '$1' .
%% 'Operator' -> '//' : '$1' .
%% 'Operator' -> '|' : '$1' .
%% 'Operator' -> '+' : '$1' .
%% 'Operator' -> '-' : '$1' .
%% 'Operator' -> '=' : '$1' .
%% 'Operator' -> '!=' : '$1' .
%% 'Operator' -> '<' : '$1' .
%% 'Operator' -> '<=' : '$1' .
%% 'Operator' -> '>' : '$1' .
%% 'Operator' -> '>=' : '$1' .

%% [33]
%% 'OperatorName' -> 'and' : '$1' .
%% 'OperatorName' -> 'mod' : '$1' .
%% 'OperatorName' -> 'div' : '$1' .

%% [34]
'MultiplyOperator' -> '*' : '*' .

%% [37]
'NameTest' -> 'wildcard' : '$1' .
'NameTest' -> 'prefix_test' : '$1' .
'NameTest' -> 'name' : '$1' .

Erlang code.

value({Token, _Line}) ->
	Token;
value({_Token, _Line, Value}) ->
	Value.

unreachable(Hint) ->
        erlang:error("Reached unreachable: " ++ Hint).

no_varrefs() ->
        erlang:error("Variable references are not currently supported").

%% path
path(abs, [Step|Steps]) ->
        case Step of
          #{combinator := #{'__struct__' := 'Elixir.Meeseeks.Selector.Combinator.Children'}} ->
            FirstStep = maps:update(combinator, step_combinator('self'), Step),
            #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Path',
              type => abs,
              steps => [FirstStep|Steps]};
          _ ->
            #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Path',
              type => abs,
              steps => [Step|Steps]}
        end;
path(rel, Steps) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Path',
          type => rel,
          steps => Steps}.

%% step
step('attribute', Name, Predicates) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Step',
          combinator => step_combinator('attribute'),
          predicates =>  [attribute_name_test(Name) | Predicates]};
step('following', Name, Predicates) ->
        {'following', Name, Predicates};
step('namespace', Name, Predicates) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Step',
          combinator => step_combinator('namespace'),
          predicates => [namespace_name_test(Name) | Predicates]};
step('preceding', Name, Predicates) ->
        {'preceding', Name, Predicates};
step(Type, Name, Predicates) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Step',
          combinator => step_combinator(Type),
          predicates =>  [name_test(Name) | Predicates]}.

%% step_combinator
step_combinator(Type) ->
        step_combinator(Type, nil).
step_combinator('ancestor', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.Ancestors',
          selector => Selector};
step_combinator('ancestor_or_self', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.AncestorsOrSelf',
          selector => Selector};
step_combinator('attribute', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Combinator.Attributes',
          selector => Selector};
step_combinator('child', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.Children',
          selector => Selector};
step_combinator('descendant', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.Descendants',
          selector => Selector};
step_combinator('descendant_or_self', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.DescendantsOrSelf',
          selector => Selector};
step_combinator('following', Selector) ->
        {'following', Selector};
step_combinator('following_sibling', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.NextSiblings',
          selector => Selector};
step_combinator('namespace', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Combinator.Namespaces',
          selector => Selector};
step_combinator('parent', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.Parent',
          selector => Selector};
step_combinator('preceding', Selector) ->
        {'preceding', Selector};
step_combinator('preceding_sibling', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.PreviousSiblings',
          selector => Selector};
step_combinator('self', Selector) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.Combinator.Self',
          selector => Selector}.

%% node_type
node_type({_Token, _Line, Type}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NodeType',
          type => Type}.

%% processing_instruction
processing_instruction({_Token, _Line, Name}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.ProcessingInstruction',
          name => Name}.

%% union_expr
union_expr(E1, E2) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Union',
          e1 => E1,
          e2 => E2}.

%% filter_expr
filter_expr(E, Predicate) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Filter',
          e => E,
          predicate => Predicate}.

%% predicate_expr
predicate_expr(E) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Predicate',
          e => E}.

%% literal_expr
literal_expr(X) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Literal',
          value => list_to_binary(value(X))}.

%% number_expr
number_expr(X) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Number',
          value => value(X)}.

%% function_expr
function_expr(F, Args) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Function',
          f => value(F),
          args => Args}.

%% boolean_expr
boolean_expr(Op, E1, E2) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Boolean',
          op => Op,
          e1 => E1,
          e2 => E2}.

%% comparative_expr
comparative_expr(Op, E1, E2) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Comparative',
          op => Op,
          e1 => E1,
          e2 => E2}.

%% arithmetic_expr
arithmetic_expr(Op, E1, E2) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Arithmetic',
          op => Op,
          e1 => E1,
          e2 => E2}.

%% negative_expr
negative_expr(E) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.Negative',
          e => E}.

%% name_test
name_test({'wildcard', _Line, _Wildcard}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NameTest',
          namespace => nil,
          tag => list_to_binary("*")};
name_test({'prefix_test', _Line, Ns}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NameTest',
          namespace => list_to_binary(Ns),
          tag => nil};
name_test({'name', _Line, {_All, [], N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NameTest',
          namespace => nil,
          tag => list_to_binary(N)};
name_test({'name', _Line, {_All, Ns, N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NameTest',
          namespace => list_to_binary(Ns),
          tag => list_to_binary(N)};
name_test(Else) ->
        Else.

%% attribute_name_test
attribute_name_test({'wildcard', _Line, _Wildcard}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.AttributeNameTest',
          namespace => nil,
          name => list_to_binary("*")};
attribute_name_test({'prefix_test', _Line, Ns}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.AttributeNameTest',
          namespace => list_to_binary(Ns),
          name => nil};
attribute_name_test({'name', _Line, {_All, [], N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.AttributeNameTest',
          namespace => nil,
          name => list_to_binary(N)};
attribute_name_test({'name', _Line, {_All, Ns, N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.AttributeNameTest',
          namespace => list_to_binary(Ns),
          name => list_to_binary(N)}.

%% namespace_name_test
namespace_name_test({'wildcard', _Line, _Wildcard}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NamespaceNameTest',
          namespace => nil,
          name => list_to_binary("*")};
namespace_name_test({'prefix_test', _Line, Ns}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NamespaceNameTest',
          namespace => list_to_binary(Ns),
          name => nil};
namespace_name_test({'name', _Line, {_All, [], N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NamespaceNameTest',
          namespace => nil,
          name => list_to_binary(N)};
namespace_name_test({'name', _Line, {_All, Ns, N}}) ->
        #{'__struct__' => 'Elixir.Meeseeks.Selector.XPath.Expr.NamespaceNameTest',
          namespace => list_to_binary(Ns),
          name => list_to_binary(N)}.
