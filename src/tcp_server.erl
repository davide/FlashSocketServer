-module(tcp_server).

-export([start_link/4]).

-behaviour(supervisor).
-export([init/1]).

-export([behaviour_info/1]).
behaviour_info(callbacks) ->
    [{tcp_server_init,1},{start_client,1},{set_socket,2}];
behaviour_info(_Other) ->
    undefined.

%%--------------------------------------------------------------------
%% @spec (Port::integer(), ListenOpts::list(), ChildModule::atom()) -> {ok, Pid} | {error, Reason}
%
%% @doc Called by a supervisor to start the listening process.
%% @end
%%----------------------------------------------------------------------
start_link(ServerModule, ServerArgs, Port, ListenOpts) ->
	error_logger:info_msg("Starting TCP Server (~p) on port ~p.\n", [ServerModule, Port]),
	{ok, ChildSpecs} = ServerModule:tcp_server_init(ServerArgs),
	ok = supervisor:check_childspecs(ChildSpecs),
	supervisor:start_link(?MODULE, [[ServerModule, ServerArgs, Port, ListenOpts], ChildSpecs]).

%%----------------------------------------------------------------------
%% Supervisor behaviour callbacks
%%----------------------------------------------------------------------
init([TcpListenerArgs, ChildSpecs]) ->
	SupFlags = {one_for_one, 5, 60},
	TcpListenerSpec =
		{	tcp_listener,                          % Id       = internal id
			{tcp_listener,start_link,TcpListenerArgs}, % StartFun = {M, F, A}
			permanent,                               % Restart  = permanent | transient | temporary
			2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
			worker,                                  % Type     = worker | supervisor
			[tcp_listener]                           % Modules  = [Module] | dynamic
		},
    {ok, {SupFlags, [TcpListenerSpec|ChildSpecs]}}.

