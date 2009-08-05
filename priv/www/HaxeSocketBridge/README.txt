==========================================================
									Changes in HaxeSocketBridge
==========================================================
The Security.loadPolicyFile(path) function is global to the swf object so there is no point
in only being able to access that function from within specific socket objects.

I removed the wrapper function from the FlashSocket object constructor:

            "window.FlashSocket = new Class({",
                "init: function(){",
                    "this._instance = ''+window.FlashSocket._instances.length;",
                    "window.FlashSocket._instances.push(this);",
                "},",
                ...
->                "loadPolicyFile: function(path) {",
->                    "window.FlashSocket._bridge.loadPolicyFile(path);",
->                "}",
            "});",

and defined it globally to the FlashSocket object:
		"window.FlashSocket._bridge = f('embed') || f('object');",
		"window.FlashSocket.loadPolicyFile = function(path) { window.FlashSocket._bridge.loadPolicyFile(path) };",

==========================================================

BUG NO INTERNET EXPLORER
	- A vírgula abaixo assinalada origina um erro:

            "window.FlashSocket = new Class({",
                "init: function(){",
                    "this._instance = ''+window.FlashSocket._instances.length;",
                    "window.FlashSocket._instances.push(this);",
                "},",
                ...
                "loadPolicyFile: function(path) {",
                    "window.FlashSocket._bridge.loadPolicyFile(path);",
->                "}",
            "});",

==========================================================

E ainda...
	- Adição de alguns espaços a seguir às várias funções do FlashSocket para
	  eliminar um erro no Firefox e IE acerca de um "}" em falta.
	  
	- Adição de um callback "onFlashSocketReady" por omissão:
		if (flash.Lib.current.loaderInfo.parameters.onloadcallback != null)
			ExternalInterface.call(flash.Lib.current.loaderInfo.parameters.onloadcallback);
		else
			ExternalInterface.call("function(){if (window.onFlashSocketReady) window.onFlashSocketReady();}");

==========================================================