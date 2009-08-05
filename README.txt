==========================================================
			FlashSocketServer - A socket server for serving javascript/flash clients
==========================================================

Includes:
	- generic tcp server skeleton (based on http://www.trapexit.org/Building_a_Non-blocking_TCP_server_using_OTP_principles)
		- split into a bunch of files (-> easier to grok)
	
	- two tcp servers:
		- a flash policy-file (crossdomain.xml) server
		- and an echo server
		(we could use just one server and check for "<policy-file-request/>" but that would
		 mix the policy-file handling logic and the socket serving)
	
	- a bundle of all flash sockets javascript libraries I came across snapshot-ed
	  on 2009-08-05* and adapted to connect to echo server mentioned above:
		- XMLSocket (http://www.devpro.it/xmlsocket/)
		- jssocket (http://github.com/tmm1/jsSocket)
		- jssockets (http://code.google.com/p/jssockets/)
		- HaxeSocketBridge (http://ionelmc.wordpress.com/2008/11/29/flash-socket-bridge-with-haxe/)

My preference goes to HaxeSocketBridge! :)

Unsolved issues:
	- After 20 seconds of a successful connection I'll receive a "Error #2044"
	  After some research (http://www.51ajax.net/?p=121) I reckon the preferred
	  solution is simply to ignore the error. :)

*DISCLAIMER:
	- I'm in no way affiliated with the authors of the original libraries;
	- I won't be tracking updates on those projects (simply consider these my pet forks).

==========================================================