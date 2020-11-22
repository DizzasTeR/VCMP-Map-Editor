__events <- {};

function validateEvent(event) {
	if(!__events.rawin(event)) {
		__events.rawset(event, []);
	}
}

function bindEvent(event, handler) {
	validateEvent(event);
	__events.rawget(event).push(handler);
}

function invokeEvent(event, ...) {
	validateEvent(event);
	
	local args = [this];
	foreach(_, param in vargv) {
		args.push(param);
	}
	
	foreach(_, handler in __events.rawget(event)) {
		handler.acall(args);
	}	
}

bindEvent("onServerData", function(stream)
{
	local data = stream.ReadString();
	// Convert: fromJSON.decode
});