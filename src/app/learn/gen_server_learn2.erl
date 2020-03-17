%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 三月 2020 14:10
%%%-------------------------------------------------------------------
-module(gen_server_learn2).
-author("10990").

%% API
-export([]).

%% @author Rolong<rolong@vip.qq.com>
-compile(export_all).

%% 假设我开了3个银行账户：
%%
%%
%% bank_server2:create_account(name1, 100).
%% bank_server2:create_account(name2, 100).
%% bank_server2:create_account(name3, 100).
%%
%% 练习1：如何获取name1对应的pid?
%%
%% 解答1：Pid1 = whereis(name1).
%%
%%
%% 练习2：实现一个函数，计算以上3个账户余额的总和。
%%
%% bank_sum(name1, name2, name3) -> Result.
%%
%% Result 为账号name1, name2, name3三个账户余额的总和。

%% 练习2解答思路:

%% 1、先实现获取一个账户余额的API

%% 1.1、用receive原语实现
bank_check(Name) ->
  Pid = whereis(Name),
  Pid ! {self(), check},
  receive
    {Pid, Money} -> Money
  end.


%% 1.2、用gen_server:call/2实现
bank_check2(Name) ->
  gen_server:call(Name, check).


%% 2、实现bank_sum函数

%% 2.1、普通实现
bank_sum(N1, N2, N3) ->
  M1 = bank_check2(N1),
  M2 = bank_check2(N2),
  M3 = bank_check2(N3),
  M1 + M2 + M3.

%% 2.2、递归实现
bank_sum2(Names) ->
  bank_sum2(Names, 0).

bank_sum2([Name | T], Sum) ->
  Sum1 = Sum + bank_check2(Name),
  bank_sum2(T, Sum1);
bank_sum2([], Sum) ->
  Sum.