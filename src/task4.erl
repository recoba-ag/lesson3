%%%-------------------------------------------------------------------
%%% @author recoba_ag
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. вер 2023 14:51
%%%-------------------------------------------------------------------
-module(task4).
-author("recoba_ag").

%JSON parser
-export([parse/2]).

parse(JsonStr, map) ->
  parseToMap(JsonStr).

parseToMap(<<"{", Rest/binary>>) ->
  object_parse(Rest, #{}).

object_parse(<<>>, Acc) ->
  Acc;
object_parse(<<"}", Rest/binary>>, Acc) ->
  {Acc, Rest};
object_parse(<<"'", Rest/binary>>, Acc) ->
  {Key, Rest1}=key_parse(Rest, <<>>),
  {Value, Rest2}=value_parse(Rest1, <<>>),
  object_parse(Rest2, Acc#{Key=>Value});
object_parse(<<" '", Rest/binary>>, Acc) ->
  {Key, Rest1}=key_parse(Rest, <<>>),
  {Value, Rest2}=value_parse(Rest1, <<>>),
  object_parse(Rest2, Acc#{Key=>Value}).

key_parse(<<"':", Rest/binary>>, Acc) ->
  {Acc, Rest};
key_parse(<<Char/utf8, Rest/binary>>, Acc) ->
  key_parse(Rest, <<Acc/binary, Char/utf8>>).

value_parse(<<"}, ", Rest/binary>>, Acc) ->
  {Acc, Rest};
value_parse(<<"',", Rest/binary>>, Acc) ->
  {Acc, Rest};
value_parse(<<"'", Rest/binary>>, Acc) ->
  {Acc, Rest};
value_parse(<<" true", Rest/binary>>, _Acc) ->
  {true, Rest};
value_parse(<<" false", Rest/binary>>, _Acc) ->
  {false, Rest};
value_parse(<<" {", Rest/binary>>, _Acc) ->
  object_parse(Rest, #{});
value_parse(<<" [", Rest/binary>>, _Acc) ->
  array_parse(Rest, []);
value_parse(<<", ", Rest/binary>>, Acc) ->
  {binary_to_integer(Acc), Rest};
value_parse(<<" '", Rest/binary>>, Acc) ->
  value_parse(Rest, Acc);
value_parse(<<" ", Rest/binary>>, Acc) ->
  value_parse(Rest, Acc);
value_parse(<<Char/utf8, Rest/binary>>, Acc) ->
  value_parse(Rest, <<Acc/binary, Char/utf8>>).

array_parse(<<"]", Rest/binary>>, Acc) ->
  {Acc, Rest};
array_parse(<<"{", Rest/binary>>, _Acc) ->
  object_parse(Rest, #{});
array_parse(<<" [", Rest/binary>>, _Acc) ->
  array_parse(Rest, []);
array_parse(Bin, Acc) ->
  {Value, Rest} = value_parse(Bin, <<>>),
  {[Value|Acc], Rest}.

