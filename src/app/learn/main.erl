%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 二月 2020 19:00
%%%-------------------------------------------------------------------
-module(main).
-author("10990").

%% APIs
-export([start_one/1]).

%% for spawns
-export([loop/1]).

%% 定义进程的 state。
%% 我们一般说，一个服务、或 “对象” 会维护自己内部的 '状态'
%% 状态可能是一个字符串缓存，可能是某个资源的引用，这个跟业务相关。
%% 状态存在于内存中，跟外界隔离，通过 API 接口与外界交互。
%% 面向对象语言里用 类和对象来存储状态，Erlang 里我们用 process。
%% 所以我们又说 Erlang 是 “面向Process 编程的”
-record(state, {
  name,      %% 消息栈的名字
  length = 0,  %% 消息栈长度
  buff = []   %% 消息栈的存储列表
}).

loop(State = #state{name = Name, length = Len, buff = Buff}) ->
  receive
    {get_name, From}->
      From ! {ok, Name},
      loop(State);
    {get_length, From}->
      From ! {ok, Len},
      loop(State);
    {set_name, NewName, From} ->
      From ! ok,
      loop(State#state{name = NewName});
    {push, Msg, From} ->
      From ! ok,
      loop(State#state{buff = [Msg | Buff], length = Len + 1});
    {pop, [], From} ->
      From ! {error, empty},
      loop(State);
    {pop, [TopMsg | Msgs], From} ->
      From ! {ok, TopMsg},
      loop(State#state{buff = Msgs, length = Len - 1});
    _Unsupported ->
      erlang:error(io_libs:format("unsupported msg: ", [_Unsupported]) )
  end.

start_one(BuffName) ->
  %% 启动一个消息栈，并返回其 PID
  Pid = spawn(main, loop, [#state{name=BuffName}]),
  io:format("Buff ~s created! Pid = ~p~n", [BuffName, Pid]),
  Pid.