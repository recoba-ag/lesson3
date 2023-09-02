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
-export([parse/1]).

parse(JsonStr) ->
  {Tokens, _Rest} = tokenize(JsonStr, []),
  {Value, _Rest2} = parse_value(Tokens, []),
  Value.

tokenize([], Acc) ->
  lists:reverse(Acc);
tokenize([<<"">> | Rest], Acc) ->
  tokenize(Rest, [string_token(<<>>) | Acc]);
tokenize([<<":">> | Rest], Acc) ->
  tokenize(Rest, [colon_token | Acc]);
tokenize([<<",">> | Rest], Acc) ->
  tokenize(Rest, [comma_token | Acc]);
tokenize([<<"{">> | Rest], Acc) ->
  tokenize(Rest, [open_brace_token | Acc]);
tokenize([<<"}">> | Rest], Acc) ->
  tokenize(Rest, [close_brace_token | Acc]);
tokenize([<<"[">> | Rest], Acc) ->
  tokenize(Rest, [open_square_token | Acc]);
tokenize([<<"]">> | Rest], Acc) ->
  tokenize(Rest, [close_square_token | Acc]);
tokenize(JsonStr, Acc) ->
  {Token, Rest} = scan_token(JsonStr),
  tokenize(Rest, [Token | Acc]).

scan_token(<<C/utf8, Rest/binary>>) when C >= $0, C =< $9 ->
  {number_token(scan_number(<<C>>, Rest)), Rest};
scan_token(<<C, Rest/binary>>) when C == $- ->
  {number_token(scan_number(<<"-">>, Rest)), Rest};
scan_token(<<C, Rest/binary>>) when C == $t ->
  {true_token, Rest};
scan_token(<<C, Rest/binary>>) when C == $f ->
  {false_token, Rest};
scan_token(<<C, Rest/binary>>) when C == $n ->
  {null_token, Rest};
scan_token(<<C, Rest/binary>>) when C == $\" ->
  {string_token(scan_string(<<>>, Rest)), Rest}.

scan_number(Acc, <<C, Rest/binary>>) when C >= $0, C =< $9 ->
  scan_number(<<Acc/binary, C>>, Rest);
scan_number(Acc, Rest) ->
  {Acc, Rest}.

scan_string(Acc, <<C, Rest/binary>>) when C /= $\" ->
  scan_string(<<Acc/binary, C>>, Rest);
scan_string(Acc, Rest) ->
  {Acc, Rest}.

number_token(Number) ->
  {number_token, Number}.

string_token(String) ->
  {string_token, String}.

parse_value([{number_token, Number} | Tokens], Rest) ->
  {{Number, Tokens, Rest}};
parse_value([{string_token, String} | Tokens], Rest) ->
  {{String, Tokens, Rest}};
parse_value([true_token | Tokens], Rest) ->
  {true, Tokens, Rest};
parse_value([false_token | Tokens], Rest) ->
  {false, Tokens, Rest};
parse_value([null_token | Tokens], Rest) ->
  {null, Tokens, Rest};
parse_value([open_brace_token | Tokens], Rest) ->
  {Object, Tokens2, Rest2} = parse_object(Tokens, Rest),
  {{Object, Tokens2, Rest2}};
parse_value([open_square_token | Tokens], Rest) ->
  {Array, Tokens2, Rest2} = parse_array(Tokens, Rest),
  {{Array, Tokens2, Rest2}}.

parse_object([close_brace_token | Tokens], Rest) ->
  {{}, Tokens, Rest};
parse_object(Tokens, Rest) ->
  {Key, Tokens2, Rest2} = parse_string(Tokens, Rest),
  [colon_token | Tokens3] = Tokens2,
  {Value, Tokens4, Rest3} = parse_value(Tokens3, Rest2),
  parse_object_pairs([{Key, Value}], Tokens4, Rest3).

parse_object_pairs(Acc, [close_brace_token | Tokens], Rest) ->
  {lists:reverse(Acc), Tokens, Rest};
parse_object_pairs(Acc, Tokens, Rest) ->
  [comma_token | Tokens2] = Tokens,
  {Key, Tokens3, Rest2} = parse_string(Tokens2, Rest),
  [colon_token | Tokens4] = Tokens3,
  {Value, Tokens5, Rest3} = parse_value(Tokens4, Rest2),
  parse_object_pairs([{Key, Value} | Acc], Tokens5, Rest3).

parse_array([close_square_token | Tokens], Rest) ->
  {[], Tokens, Rest};
parse_array(Tokens, Rest) ->
  {Value, Tokens2, Rest2} = parse_value(Tokens, Rest),
  parse_array_elements([Value], Tokens2, Rest2).

parse_array_elements(Acc, [close_square_token | Tokens], Rest) ->
  {lists:reverse(Acc), Tokens, Rest};
parse_array_elements(Acc, Tokens, Rest) ->
  [comma_token | Tokens2] = Tokens,
  {Value, Tokens3, Rest2} = parse_value(Tokens2, Rest),
  parse_array_elements([Value | Acc], Tokens3, Rest2).

parse_string([{string_token, String} | Tokens], Rest) ->
  {{String, Tokens, Rest}}.


