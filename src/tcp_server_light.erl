-module(tcp_server_light).
-author('nesrait@gmail.com').

%% API
-export([start_link/4]).

%% tcp_server callbacks
-behaviour(tcp_server).
-export([tcp_server_init/1, start_client/1, set_socket/2]).

%%----------------------------------------------------------------------
%% API
%%----------------------------------------------------------------------
start_link(ListenPort, ListenOpts, HandlerModule, ExtArgs) ->
	ServerArgs = [{handler_module, HandlerModule}, {ext_args, ExtArgs}],
	tcp_server:start_link(?MODULE, ServerArgs, ListenPort, ListenOpts).

%%----------------------------------------------------------------------
%% tcp_server callbacks
%%----------------------------------------------------------------------
tcp_server_init(_ServerArgs) ->
	{ok, []}.

% A startup function for spawning new client connection handling FSM.
%% To be called by the TCP listener process.
start_client(ServerArgs) ->
	HandlerModule = proplists:get_value(handler_module, ServerArgs),
	ExtArgs = proplists:get_value(ext_args, ServerArgs),
	HandlerModule:start(ExtArgs).

%% A function for notifying the newly spawned client that it
%% now owns the socket and should handle the incoming messages
set_socket(Pid, Socket) when is_pid(Pid), is_port(Socket) ->
    Pid ! {socket_ready, Socket}.

