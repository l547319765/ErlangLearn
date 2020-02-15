%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 十二月 2019 12:23
%%%-------------------------------------------------------------------
-module(doc).
-author("10990").

%% API
-export([feibo_list/1,ele/1]).

%% 运行：feibo:feibo_list(5).
%% 结果示例：【1,1,2,3,5】

%% 函数element主要为了计算斐波那契数列的第N个元素
ele(1) -> 1;
ele(2) -> 1;
ele(N) -> ele(N-1) + ele(N-2).

%% 给定一个N，求出斐波那契的前N个数
feibo_list(N) -> feibo_list([], N).
feibo_list(L, 0) -> L;
feibo_list(L, N) -> feibo_list([ele(N)|L], N-1).