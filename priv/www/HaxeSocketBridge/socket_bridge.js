window.onload = function() {
	var newdiv = document.createElement('div');
	newdiv.setAttribute("id", "socket_bridge");
	document.body.appendChild(newdiv);
	swfobject.embedSWF("socket_bridge.swf", "socket_bridge", "300", "120", "8.0.0");
	//swfobject.embedSWF("socket_bridge.swf?onloadcallback=onFlashSocketReady", "socket_bridge", "300", "120", "8.0.0");
}

// This code was extracted from the swf while I was figuring out what was 
// failing with IE. While we could argue for a clear separation between the
// swf and js, the fact is that it's better to have only one file.
BootJavascript = (function(){
	if (window.FlashSocket) return;
	var Class = function(properties){
		var klass = function(event_handlers){
			for (var p in event_handlers) {
				if (event_handlers.hasOwnProperty(p)) {
					this[p] = event_handlers[p];
				}
			}
			return this.init.apply(this);
		};
		klass.prototype = properties;
		klass.constructor = arguments.callee;
		return klass;
	};
			
	window.FlashSocket = new Class({
		init: function(){
			this._instance = window.FlashSocket._instances.length;
			window.FlashSocket._instances.push(this);
		},
		close: function(){
			window.FlashSocket._instances[this._instance] = null;
			window.FlashSocket._bridge.close(this._instance);
		},
		write: function(data){
			window.FlashSocket._bridge.write(this._instance, data);
		},
		connect: function(host, port) {
			window.FlashSocket._bridge.connect(this._instance, host, port);
		}
	});
	window.FlashSocket._instances = [];
	var f = function(tag){
		var elems = document.getElementsByTagName(tag);
		for (var i=0; i<elems.length; i++)
			if (elems[i].CAN_I_HAS_SOCKET) return elems[i];
	};
	window.FlashSocket._bridge = f('embed') || f('object');
	window.FlashSocket.loadPolicyFile = function(path) { window.FlashSocket._bridge.loadPolicyFile(path) };
	if (window.onFlashSocketReady)
		window.onFlashSocketReady();
});