-module(ps).
-export([start/0]).

start()->
    {ok, Listen} = gen_tcp:listen(843, [list, {reuseaddr, true}, {active, true}]),
    spawn(fun() -> par_connect(Listen) end).

par_connect(Listen)-> 
    {ok, Socket} = gen_tcp:accept(Listen), 
    spawn(fun() -> par_connect(Listen) end), 
    loop(Socket). 

loop(Socket)->
    receive
	{tcp, Socket, L} ->
	    io:format(L),
	    Reply = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"5222\" /></cross-domain-policy>\0",
	    gen_tcp:send(Socket, Reply),
	    loop(Socket);
	{tcp, closed, Socket} ->
	    io:format("server closed socket")
    end.
