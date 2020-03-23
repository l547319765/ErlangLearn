%%%-------------------------------------------------------------------
%%% @author 10990
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%% Created : 20. 三月 2020 13:13
%%%-------------------------------------------------------------------
-module(gen_server_mysql).
-author("10990").
-behavior(gen_server).
-compile(export_all).
%% demoAPI
-export([start/1,add_task/2,get_task/0,cencel_task/0,stop/0]).
%% list管理API
-export([task_center/0,get_task_list/0,center_tasklist_init/0,add_to_list/3,pull_task/1,write_to_list/4]).
%%回调函数
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-define(SERVER,?MODULE).
%% state 保存任务的 名字，任务队列长度及任务队列.
-record(state, {
  task_id = -1,
  task_center ,      %%任务中心
  task = none,      %%当前执行任务
  length = 0,        %%任务队列长度
  task_list,         %%任务队列
  file_source        %%文件流
}).

%%        test
%%        gen_server_mysql:start(task_center).
%%        gen_server_mysql:add_task(job1,15000).
%%        gen_server_mysql:add_task(job2,15000).
%%        gen_server_mysql:add_task(job3,15000).
%%        gen_server_mysql:cencel_task().
%%        gen_server_mysql:get_task().
%%        gen_server_mysql:get_task_list().

%%----------------------------API
%%----------------------------API
%%----------------------------API
%%----------------------------API
%%------------gen_server------API
%%----------------------------API
%%----------------------------API
%%----------------------------API
%%----------------------------API

init([Name]) ->
  {Len,TaskList} =  center_tasklist_init(),
  FileSource =  file_source_init(),
  State =#state{task_center = Name,length = Len,task_list = TaskList,file_source = FileSource},
  register(Name,spawn(fun()-> task_center()end)),
  if
    Len > 0 -> Name ! {start_task,State};
    true -> void
  end,
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

handle_call(stop,_From,State)-> io:format("good bye!~n"), {stop,normal,stopped,State};

handle_call({finish_running_task},_From,State) ->
  update_task(State,3),
  State2 = State#state{task = none,task_id = -1},
  Reply = finish_task,
  Test_Center = State#state.task_center,
  Test_Center ! {start_task,State2},
  {reply, Reply, State2};

handle_call({cencel_running_task},_From,State) ->
  update_task(State,2),
  State2 = State#state{task = none,task_id = -1},
  Reply = cencel_task,
  Test_Center = State#state.task_center,
  Test_Center ! {start_task,State2},
  {reply, Reply, State2};

handle_call({running_task,Name,Id},_From,State) ->
  Len = State#state.length,
  State2 = #state{task_id = Id,task = Name,length = Len-1},
  Reply = {Name,Id},
  update_task(State2,1),
  {reply, Reply, State2};

handle_call({get_task_list},_From,State) ->
  TaskList = State#state.task_list,
  Reply = TaskList,
  {reply, Reply, State}.

%%handle_call({get_task_list},_From,State) ->
%%  TaskList = State#state.task_list,
%%  Reply = get_list_of_task(TaskList),
%%  {reply, Reply, State}.

handle_cast(_Msg,State)-> {noreply,State}.

handle_info(_Info,State)-> io:format("nothing"),{noreply,State}.

terminate(_Reason,_State)->ok.

code_change(_OldVsn,State,_Extra)->{ok,State}.

%%-----------------------------API
%%-----------------------------API
%%-----------------------------API
%%-----------------------------API
%%------------task_center------API
%%-----------------------------API
%%-----------------------------API
%%-----------------------------API
%%-----------------------------API

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
get_task_list()->
  gen_server:call(?MODULE,{get_task_list}).

%%5.查询当前任务队列
%%get_task_list()->
%%  gen_server:call(?MODULE,{get_task_list}).

%%6.停止任务管理中心
stop()->
  gen_server:call(?MODULE,stop).

%%---------------------------API
%%---------------------------API
%%---------------------------API
%%---------------------------API
%%------------task_list------API
%%---------------------------API
%%---------------------------API
%%---------------------------API
%%---------------------------API

%%初始化task_list
center_tasklist_init() ->
  crypto:start(),
  application:start(emysql),
  emysql:add_pool(task_mysql, 5, "root", "root", "127.0.0.1", 3306, "erlangLearn", latin1),
  {_,_,_,Result,_} = emysql:execute(task_mysql, <<"SELECT table_name FROM information_schema.TABLES WHERE table_name ='erlangJob1';">>),
  if
    Result =:= [] ->
      emysql:execute(task_mysql, <<"CREATE TABLE `erlangJob` (
                                    `id` int(11) NOT NULL AUTO_INCREMENT,
                                    `name` varchar(255) NOT NULL,
                                    `time` int(255) NOT NULL,
                                    `state` tinyint(11) NOT NULL COMMENT '0.unRun 1.Running  2.cencel  3.finish',
                                    PRIMARY KEY (`id`)
                                  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;">>);
    true -> void
  end,
  {_,_,_,[[Len]],_} = emysql:execute(task_mysql, <<"SELECT
                                                count( id )
                                              FROM
                                                `erlangJob`
                                              WHERE
                                                state = 0;">>),
  emysql:prepare(insert_stmt, <<"INSERT INTO erlangJob ( NAME, time, state )
                                    VALUE
                                      (?,?,?);">>),
  emysql:prepare(select_stmt, <<"SELECT
                                    *
                                  FROM
                                    erlangJob
                                  WHERE
                                    state = ?
                                  ORDER BY
                                    id ASC
                                    LIMIT 0,
                                    1;">>),
  emysql:prepare(update_stmt, <<"UPDATE erlangJob
                                  SET state = ?
                                  WHERE
                                    id = ?;">>),
  emysql:prepare(delete_stmt, <<"DELETE
                                  FROM
                                    erlangJob
                                  WHERE
                                    id = ?;">>),
  {Len,task_mysql}.

%%task_list增
add_to_list(Name,Time,State)->
  io:format("add",[]),
  Len  =  State#state.length,
  TaskList = State#state.task_list,
  emysql:execute(TaskList, insert_stmt, [Name,Time,0]),
  State#state{length = Len+1}.

%%task_list查
pull_task(State)->
  io:format("select",[]),
  TaskList = State#state.task_list,
  Len = State#state.length,
  No_task = none,
  Reply =
    case Len of
      0  ->
        {false,none,-1,State#state{task = No_task}};
      _ ->
        {_,_,_,[[Id,SqlName,SqlTime,_]],_} = emysql:execute(TaskList, select_stmt, [0]),

        {SqlTime,SqlName,Id,State#state{task_id = Id, task = SqlName, length = Len-1}}
    end,
  Reply.

%%task_list改
update_task(State,StateCode)->
  TaskList = State#state.task_list,
  Id = State#state.task_id,
  emysql:execute(TaskList, update_stmt, [StateCode,Id]),
  {ok}.

%%task_list删
delete_task(State)->
  io:format("delete",[]),
  TaskList = State#state.task_list,
  Id = State#state.task_id,
  emysql:execute(TaskList, delete_stmt, [Id]),
  {ok}.


%%通过dets获取还没使用的list
%%get_list_of_task(TaskList)->
%%  [{index,_,Job_Index}] = dets:lookup(TaskList,index),
%%  dets:traverse(TaskList,
%%    fun(
%%        {A, _, _}) ->
%%      case A of
%%        index ->void;
%%        _ ->
%%          if
%%            A >=Job_Index ->
%%              [{_,Name,Time}] = dets:lookup(TaskList,A),
%%              io:format("job = ~p name = ~p~n",[Name,Time]);
%%            true ->
%%              void
%%          end
%%      end,
%%      continue
%%    end),
%%  ok.

%%任务运行
task_center()->
  receive
    {start_task,State} ->
      {Result,Name,Id,_} = pull_task(State),
      case Result of
        false -> io:format("don't have task"),
          task_center();
        _ ->
          gen_server:call(?MODULE,{running_task,Name,Id}),
          S = State#state.file_source,
          write_to_list(S,Name,Result,start),
          receive
            {cencel_task} ->
              io:format("cencel_runing_task"),
              gen_server:call(?MODULE,{finish_running_task}),
              write_to_list(S,Name,Result,cencel),
              task_center()
          after Result ->
            io:format("finish_running~p",[Name]),
            gen_server:call(?MODULE,{cencel_running_task}),
            write_to_list(S,Name,Result,finish),
            task_center()
          end
      end
  end.

%%---------------------------API
%%---------------------------API
%%---------------------------API
%%---------------------------API
%%------------task_list------API
%%---------------------------API
%%---------------------------API
%%---------------------------API
%%---------------------------API

%%初始化文件流
file_source_init()->
  File = "./job_finish_file.txt",
  {ok,S}= file:open(File,write),
  S.

%%写入文件
write_to_list(S,Name,Time,Reason) ->
  T =  os:timestamp(),
  {{Year,Month,Day},{Hour,Minute,Second}} = calendar:now_to_local_time(T),
  io:format(S,"[~p/~p/~p ~p:~p:~p] : job ~p ~p,time is ~p .~n",[Year,Month,Day,Hour,Minute,Second,Name,Reason,Time]),
  ok.