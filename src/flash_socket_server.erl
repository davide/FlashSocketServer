-module(flash_socket_server).
-author('nesrait@gmail.com').

-export([start_link/2]).

start_link(PolicyServerPort, SocketServerPort) ->
	ListenOpts = [{reuseaddr, true}, {keepalive, false}, {backlog, 30}, {active, false}],
	PolicyServerArgs = [{security_policy_data, nada_por_agora}],
	tcp_server_fsm:start_link(PolicyServerPort, ListenOpts, flash_policy_handler_sup, flash_policy_fsm_handler, PolicyServerArgs),
	SocketServerArgs = [],
	tcp_server_fsm:start_link(SocketServerPort, ListenOpts, flash_socket_handler_sup, flash_socket_fsm_handler, SocketServerArgs).
	%tcp_server_light:start_link(PolicyServerPort, ListenOpts, flash_socket_light_handler, ServerArgs).

