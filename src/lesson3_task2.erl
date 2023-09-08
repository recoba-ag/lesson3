%%%-------------------------------------------------------------------
%%% @author recoba_ag
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. вер 2023 14:51
%%%-------------------------------------------------------------------
-module(lesson3_task2).
-author("recoba_ag").

%% Розділити рядок на слова
-export([words/1]).

words(BinText) ->
  words(BinText, <<>>, []).

words(<<" ", Rest/binary>>, <<>>, List) ->
  words(Rest, <<>>, List);
words(<<" ", Rest/binary>>, Acc, List) ->
  words(Rest, <<>>, [Acc|List]);
words(<<Char/utf8, Rest/binary>>, Acc, List) ->
  words(Rest, <<Acc/binary, Char/utf8>>, List);
words(<<>>, Acc, List) ->
  lists:reverse([Acc|List]).