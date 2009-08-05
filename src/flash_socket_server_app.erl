-module(flash_socket_server_app).
-author('saleyn@gmail.com').
-author('nesrait@gmail.com').

-behaviour(application).

%% API
-export([start/0]).

%% Application callbacks
-export([start/2, stop/1]).

%%----------------------------------------------------------------------
%% API
%%----------------------------------------------------------------------
start() ->
	application:start(flash_socket_server).

%%----------------------------------------------------------------------
%% Application behaviour callbacks
%%----------------------------------------------------------------------
start(_Type, _Args) ->
    {ok, PolicyServerPort} = application:get_env(policy_server_port),
	{ok, SocketServerPort} = application:get_env(socket_server_port),
    flash_socket_server:start_link(PolicyServerPort, SocketServerPort).

stop(_S) ->
    ok.
