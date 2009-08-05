-module(flash_socket_light_handler).
-author('nesrait@gmail.com').

-export([start/1]).
-export([init/1]).

-define(TIMEOUT, 120000).

%%%------------------------------------------------------------------------
%%% API
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @spec (Socket) -> {ok,Pid} | ignore | {error,Error}
%% @doc To be called by the supervisor in order to start the server.
%%      If init/1 fails with Reason, the function returns {error,Reason}.
%%      If init/1 returns {stop,Reason} or ignore, the process is
%%      terminated and the function returns {error,Reason} or ignore,
%%      respectively.
%% @end
%%-------------------------------------------------------------------------
start(UserData) ->
	Pid = spawn(?MODULE, init, [UserData]),
    {ok, Pid}.

init(UserData) ->
    process_flag(trap_exit, true),
	SecurityPolicyData = proplists:get_value(security_policy_data, UserData),
	'WAIT_FOR_SOCKET'(SecurityPolicyData).

'WAIT_FOR_SOCKET'(SecurityPolicyData) ->
	receive
		{socket_ready, Socket} ->
		    % Now we own the socket
			inet:setopts(Socket, [{active, once}]),
			{ok, {IP, _Port}} = inet:peername(Socket),
%%			error_logger:info_msg("State: 'WAIT_FOR_SOCKET'. Owning socket!\n", []),
			'WAIT_FOR_DATA'(Socket, IP, SecurityPolicyData)
	after ?TIMEOUT ->
		error_logger:error_msg("Timeout in socket acceptor: ~p.\n", [self()])
	end.

'WAIT_FOR_DATA'(Socket, IP, SecurityPolicyData)->
    receive
		{tcp, Socket, Data} ->
			% Flow control: enable forwarding of next TCP message
			inet:setopts(Socket, [{active, once}]),
%%			error_logger:info_msg("State: 'WAIT_FOR_DATA'. Receiving data!\n", []),
			handle_data(Socket, IP, Data),
			'WAIT_FOR_DATA'(Socket, IP, SecurityPolicyData);
		{tcp, closed, Socket} ->
			error_logger:info_msg("~p Client ~p disconnected.\n", [self(), IP]);
		stop ->
			(catch gen_tcp:close(Socket)),
			error_logger:info_msg("State: 'WAIT_FOR_DATA'. Terminating by user request...\n", []),
			ok
    end.

handle_data(Socket, _IP, "<policy-file-request/>" ++ [0]) ->
	%% TODO: work through SecurityPolicyData to build a correct <cross-domain-policy />
	Reply = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"80,843\" /></cross-domain-policy>\0",
	gen_tcp:send(Socket, Reply);

%% Echo received data
handle_data(Socket, _IP, Data) ->
	gen_tcp:send(Socket, Data).

