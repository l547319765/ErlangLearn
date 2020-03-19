%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 三月 2020 17:41
%%%-------------------------------------------------------------------
-module(gen_server_demo).
-author("10990").
-behavior(gen_server).
-compile(export_all).
%% API
-export([start/1,add_task/2,get_task/0,cencel_task/0,task_center/0,add_to_list/3,pull_task/1]).
%%回调函数
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-define(SERVER,?MODULE).
%% state 保存任务的 名字，任务队列长度及任务队列.
-record(state, {
  task_center ,      %%任务中心
  task = none,      %%当前执行任务
  length = 0,        %%任务队列长度
  task_list = []     %%任务队列
}).

%%        test
%%        gen_server_demo:start(task_center).
%%        gen_server_demo:add_task(job1,15000).
%%        gen_server_demo:add_task(job2,15000).
%%        gen_server_demo:add_task(job3,15000).
%%        gen_server_demo:cencel_task().
%%        gen_server_demo:get_task().


%%-------------gen_server----------API
init([Name]) ->
  State = #state{},
  State2 = State#state{task_center = Name},
  register(Name,spawn(fun()-> task_center()end)),
  {ok,State2}.

handle_call({add_task,Name,Time},_From,State) ->
%%  获取当前是否在运行任务，不是的话启动任务，不然就添加到队列里。
  Task =State#state.task,
  State2 = add_to_list(Name,Time,State),
  Reply =
    case Task of
      none ->
        State#state.task_center ! {start_task,State2},
        {start_new_task};
      _ -> having_runing
    end,
  {reply, Reply, State2};

handle_call({cencel_task},_From,State) ->
  Task_center = State#state.task_center,
  Task =State#state.task,
  Reply =
    case Task of
      none->        {no_task_running};
      _ ->Task_center !{cencel_task},
        Task_center !{start_task},
        {ok}
    end,
  {reply, Reply, State};

handle_call({get_task},_From,State) ->
  Task =State#state.task,
  Reply =
    case Task of
      none->{no_task};
      _ -> Task
    end,
  {reply, Reply, State};

handle_call({unname_task},_From,State) ->
  State2 = State#state{task = none},
  Reply = none,
  Test_Center = State#state.task_center,
  Test_Center ! {start_task,State2},
  {reply, Reply, State2};

handle_call({name_task},_From,State) ->
  {Result,Name,State_new} = pull_task(State),
%%  io:format("new_running~p",[Name]),
  Name2 = State_new#state.task,
%%  io:format("new_running~p",[Name2]),
  Reply = Name2,
  {reply, Reply, State_new}.

handle_cast(_Msg,State)-> {noreply,State}.

handle_info(_Info,State)-> io:format("nothing"),{noreply,State}.

terminate(_Reason,_State)->ok.

code_change(_OldVsn,State,_Extra)->{ok,State}.

%%-------------task_center--------API

%%初始化任务管理中心
start(Name) ->
  gen_server:start_link({local,?SERVER},?MODULE,[Name],[]).

%%1.请求执行任务，任务带耗时
add_task(Name,Time)->
  gen_server:call(?MODULE,{add_task,Name,Time}).

%%2.查询当前正在执行任务
get_task()->
  gen_server:call(?MODULE,{get_task}).

%%3.取消正在执行任务
cencel_task()->
  gen_server:call(?MODULE,{cencel_task}).


%%------------task_list------API
%%初始化task_list
%%center_init(State = #state{}) -> {State}.

%%添加入task_list
add_to_list(Name,Time,State)->
  Len  =  State#state.length,
  Buff =  State#state.task_list,
  BBuff = Buff ++ [{Name,Time}],
  State#state{length = Len+1, task_list = BBuff}.

%%拉取首部的任务
pull_task(State)->
  Buff = State#state.task_list,
  Len = State#state.length,
  No_task = none,
  Reply =
    case Len of
      0  ->
        {false,none,State#state{task = No_task}};
      _ ->
        T = hd(Buff),
        BBuff = tl(Buff),
        {Name,Time}= T,
        {Time,Name,State#state{task = Name, length = Len-1, task_list = BBuff}}
    end,
  Reply.

%%任务运行
task_center()->
  receive
    {start_task,State} ->
      {Result,Name,State_new} = pull_task(State),
      case Result of
        false -> io:format("don't have task"),
          task_center();
        _ ->
          gen_server:call(?MODULE,{name_task}),
          receive
            {cencel_task} ->
              io:format("cencel_runing_task"),
              gen_server:call(?MODULE,{unname_task}),
              task_center()
          after Result ->
            io:format("finish_running~p",[Name]),
            gen_server:call(?MODULE,{unname_task}),
            task_center()
          end
      end
  end.