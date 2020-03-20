%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 三月 2020 19:17
%%%-------------------------------------------------------------------
-module(gen_server_dets).
-author("10990").
-behavior(gen_server).
-compile(export_all).
%% demoAPI
-export([get_task_list/0,start/1,add_task/2,get_task/0,cencel_task/0,stop/0]).
%% list管理API
-export([task_center/0,get_dets/0,center_init/1,add_to_list/3,pull_task/1]).
%%回调函数API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-define(SERVER,?MODULE).
%% state 保存任务的 名字，任务队列长度及任务队列.
-record(state, {
  task_center ,      %%任务中心
  task = none,      %%当前执行任务
  length = 0,        %%任务队列长度
  task_list     %%任务队列
}).

%%        test
%%        gen_server_dets:start(task_center).
%%        gen_server_dets:add_task(job1,15000).
%%        gen_server_dets:add_task(job2,15000).
%%        gen_server_dets:add_task(job3,15000).
%%        gen_server_dets:cencel_task().
%%        gen_server_dets:get_task().
%%        gen_server_dets:get_dets().
%%        gen_server_dets:get_task_list().


%%-------------gen_server----------API
init([Name]) ->
  TaskList =  center_init(task_list),
  State =#state{task_center = Name,task_list = TaskList},
  register(Name,spawn(fun()-> task_center()end)),
  {ok,State}.

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

handle_call({name_task,Name},_From,State) ->
  Len = State#state.length,
  Reply = Name,
  {reply, Reply, State#state{task = Name,length = Len-1}};

handle_call(stop,_From,State)-> io:format("good bye!~n"), {stop,normal,stopped,State};

handle_call({get_dets},_From,State) ->
  TaskList = State#state.task_list,
  Reply = TaskList,
  {reply, Reply, State};

handle_call({get_task_list},_From,State) ->
  TaskList = State#state.task_list,
  Reply = get_list_of_task(TaskList),
  {reply, Reply, State}.

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

%%4.进程外获取dets的name
get_dets()->
  gen_server:call(?MODULE,{get_dets}).

%%4.查询当前任务队列
get_task_list()->
  gen_server:call(?MODULE,{get_task_list}).

%%5.停止任务管理中心
stop()->
  gen_server:call(?MODULE,stop).

%%------------task_list------API
%%初始化task_list
center_init(Name) ->
  %%  使用类似数据库自增主键的方式记录到了哪个数据,用另一个数据记录任务队列使用了多少
  File = "./Data.dets",
  io:format("dets opened:~p~n", [File]),
  %%  如果是文件，证明已经有过这个文件了，所以直接修复打开，否则新插入index。
  Bool = filelib:is_file(File),
  case dets:open_file(Name, [{file, File}]) of
    {ok, TaskList} ->
      case Bool of
        true  ->void;
        false ->ok = dets:insert(TaskList, {index,0,0})
      end,
      TaskList;
    {error, _Reason} ->
      io:format("cannot open dets table~n"),
      exit(eDetsOpen)
  end.

%%添加入task_list
add_to_list(Name,Time,State)->
  Len  =  State#state.length,
  TaskList = State#state.task_list,
  [{index,Data_Index,Job_Index}] = dets:lookup(TaskList,index),
  dets:insert(TaskList,[{index,Data_Index+1,Job_Index},{Data_Index,Name,Time}]),
  State#state{length = Len+1}.

%%拉取首部的任务
pull_task(State)->
  TaskList = State#state.task_list,
  Len = State#state.length,
  No_task = none,
  Reply =
    case Len of
      0  ->
        {false,none,State#state{task = No_task}};
      _ ->
        [{index,Data_Index,Job_Index}] = dets:lookup(TaskList,index),
        [{_,Name,Time}] = dets:lookup(TaskList,Job_Index),
        dets:insert(TaskList,[{index,Data_Index,Job_Index+1}]),
        {Time,Name,State#state{task = Name, length = Len-1}}
    end,
  Reply.

%%任务运行
task_center()->
  receive
    {start_task,State} ->
      {Result,Name,_} = pull_task(State),
      case Result of
        false -> io:format("don't have task"),
          task_center();
        _ ->
          gen_server:call(?MODULE,{name_task,Name}),
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

%%通过dets获取还没使用的list
get_list_of_task(TaskList)->
  [{index,_,Job_Index}] = dets:lookup(TaskList,index),
  dets:traverse(TaskList,
    fun(
      {A, _, _}) ->
        case A of
          index ->void;
          _ ->
            if
              A >=Job_Index ->
                [{_,Name,Time}] = dets:lookup(TaskList,A),
                io:format("job = ~p name = ~p~n",[Name,Time]);
              true ->
                void
            end
        end,
      continue
    end),
  ok.