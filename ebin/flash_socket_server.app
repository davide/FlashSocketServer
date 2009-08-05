{application, flash_socket_server,
 [
  {description, "Flash Socket Server"},
  {vsn, "1.0"},
  {id, "flash_socket_server"},
  {modules,      [tcp_server,
						tcp_listener,
						tcp_server_fsm,
						tcp_server_light,
						flash_socket_server,
						flash_socket_handler,
						flash_socket_server_app
					  ]},
  {registered,   [tcp_server, tcp_listener]},
  {applications, [kernel, stdlib]},
  %%
  %% mod: Specify the module name to start the application, plus args
  %%
  {mod, {flash_socket_server_app, []}},
  {env, [{policy_server_port, 843}, {socket_server_port, 5222}]}
 ]
}.
