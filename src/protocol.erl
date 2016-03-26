%%%-------------------------------------------------------------------
%%% @author Andrew Noskov
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Март 2016 23:41
%%%-------------------------------------------------------------------
-module(protocol).
-author("Andrew Noskov").

%% API
-export([start/0, stop/0, fact/1, sum/2]).

start() ->
  spawn(fun() ->
    register(example1, self()),
    process_flag(trap_exit, true),
    Port = open_port({spawn, "../external/computing"}, [{packet, 2}]),
    loop(Port)
  end).

stop() ->
  example1 ! stop.

fact(X) -> call_port({fact, X}).
sum(X,Y) -> call_port({sum, X, Y}).

call_port(Msg) ->
  example1 ! {call, self(), Msg},
  receive
    {example1, Result} ->
      Result
  end.

loop(Port) ->
  receive
    {call, Caller, Msg} ->
      Port ! {self(), {command, encode(Msg)}},
      receive
        {Port, {data, Data}} ->
          Caller ! {example1, decode(Data)}
      end,
      loop(Port);
    stop ->
      Port ! {self(), close},
      receive
        {Port, closed} ->
          exit(normal)
      end;
    {'EXIT', Port, Reason} ->
      exit({port_terminated,Reason})
  end.

encode({fact, X}) -> [1, X];
encode({sum, X, Y}) -> [2, X, Y].

decode([Int]) -> Int.
