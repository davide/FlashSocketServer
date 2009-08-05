-module(tcp_server_fsm).
-author('saleyn@gmail.com').
-author('nesrait@gmail.com').

%% API
-export([start_link/5]).

%% tcp_server callbacks
-behaviour(tcp_server).
-export([tcp_server_init/1, start_client/1, set_socket/2]).

%% supervisor callbacks
-behaviour(supervisor).
-export([init/1]).

%%----------------------------------------------------------------------
%% API
%%----------------------------------------------------------------------
start_link(ListenPort, ListenOpts, ClientSupName, HandlerModule, ExtArgs) ->
	ServerArgs = [{sup_ref,  ClientSupName}, {handler_module, HandlerModule}, {ext_args, ExtArgs}],
	tcp_server:start_link(?MODULE, ServerArgs, ListenPort, ListenOpts).

%%----------------------------------------------------------------------
%% tcp_server callbacks
%%----------------------------------------------------------------------
tcp_server_init(ServerArgs) ->
	SupRef = proplists:get_value(sup_ref, ServerArgs),
	HandlerModule = proplists:get_value(handler_module, ServerArgs),
	ExtArgs = proplists:get_value(ext_args, ServerArgs),
	ChildSupSpec =
		{
			SupRef,
			{supervisor,start_link,[{local, SupRef}, ?MODULE, [HandlerModule, ExtArgs]]},
			permanent,                               % Restart  = permanent | transient | temporary
			infinity,                                % Shutdown = brutal_kill | int() >= 0 | infinity
			supervisor,                              % Type     = worker | supervisor
			[]                                       % Modules  = [Module] | dynamic
		},
	{ok, [ChildSupSpec]}.

% A startup function for spawning new client connection handling FSM.
%% To be called by the TCP listener process.
start_client(ServerArgs) ->
	SupRef = proplists:get_value(sup_ref, ServerArgs),
    supervisor:start_child(SupRef, []).

%% A function for notifying the newly spawned client that it
%% now owns the socket and should handle the incoming messages
set_socket(Pid, Socket) when is_pid(Pid), is_port(Socket) ->
    gen_fsm:send_event(Pid, {socket_ready, Socket}).

%%----------------------------------------------------------------------
%% supervisor callbacks
%%----------------------------------------------------------------------

% Childspec for client handler instances
init([HandlerModule, ExtArgs]) ->
    {ok,
        {_SupFlags = {simple_one_for_one, 5, 60},
            [
              % TCP Client
              {   undefined,                               % Id       = internal id
                  {HandlerModule,start_link,[ExtArgs]},                  % StartFun = {M, F, A}
                  temporary,                               % Restart  = permanent | transient | temporary
                  2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  % Type     = worker | supervisor
                  []                                       % Modules  = [Module] | dynamic
              }
            ]
        }
    }.
