%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 十二月 2019 12:23
%%%-------------------------------------------------------------------
-module(fibonacci).
-author("10990").

%% API
-export([fibonacci_list/1,ele/1,test/0]).

%%测试
test()->
  fibonacci_list(7),
  fibonacci_list(6).

%% 函数element主要为了计算斐波那契数列的第N个元素
ele(1) -> 1;
ele(2) -> 1;
ele(N) -> ele(N-1) + ele(N-2).

%% 给定一个N，求出斐波那契的前N个数
fibonacci_list(N) -> fibonacci_list([], N).
fibonacci_list(L, 0) -> L;
fibonacci_list(L, N) -> fibonacci_list([ele(N)|L], N-1).