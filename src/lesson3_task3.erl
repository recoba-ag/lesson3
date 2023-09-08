%%%-------------------------------------------------------------------
%%% @author recoba_ag
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. вер 2023 14:51
%%%-------------------------------------------------------------------
-module(lesson3_task3).
-author("recoba_ag").

%% Розділити рядок на частини, з явною вказівкою роздільника
-export([split/2]).

split(BinText, Separator) ->
  BinSep=list_to_binary (Separator),
  BinSepSize=byte_size(BinSep),
  split([], BinText, BinSep, BinSepSize, <<>>).

split(List, BinText, BinSep, BinSepSize, Acc) ->
  case BinText of
    <<BinSep:BinSepSize/binary, Rest/binary>> ->
      split([Acc|List], Rest, BinSep, BinSepSize, <<>>);
    <<Char/utf8, Rest/binary>> ->
      split(List, Rest, BinSep, BinSepSize, <<Acc/binary, Char/utf8>>);
    <<>> -> lists:reverse([Acc|List])
  end.

