%%%-------------------------------------------------------------------
%%% @author recoba_ag
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. вер 2023 14:51
%%%-------------------------------------------------------------------
-module(lesson3_task1).
-author("recoba_ag").

%% Витягти з рядка перше слово
-export ([first_word/1]).

first_word(<<>>) ->
  <<>>;
first_word(BinText) ->
  first_word(BinText, <<>>).

first_word(<<" ", _/binary>>, Acc) ->
  Acc;
first_word(<<Char/utf8, Rest/binary>>, Acc) ->
  first_word(Rest, <<Acc/binary, Char/utf8>>).
