(function () {
	const messagesEl = document.getElementById( "messages" );
	const statusEl = document.getElementById( "status" );
	const statusTextEl = document.getElementById( "status-text" );
	const form = document.getElementById( "chat-form" );
	const usernameInput = document.getElementById( "username" );
	const messageInput = document.getElementById( "message" );

	usernameInput.value = localStorage.getItem( "chat-username" ) || "";

	function addMessage( { user, message, time } ) {
		const isOwn = user === usernameInput.value.trim();
		const li = document.createElement( "li" );
		li.className = "msg " + ( isOwn ? "is-own" : "is-other" );

		const meta = document.createElement( "div" );
		meta.className = "meta";
		const userSpan = document.createElement( "span" );
		userSpan.className = "user";
		userSpan.textContent = user;
		const timeSpan = document.createElement( "span" );
		timeSpan.className = "time";
		timeSpan.textContent = time ? new Date( time ).toLocaleTimeString() : "";
		meta.appendChild( userSpan );
		meta.appendChild( timeSpan );

		const bubble = document.createElement( "div" );
		bubble.className = "bubble";
		bubble.textContent = message;

		li.appendChild( meta );
		li.appendChild( bubble );
		messagesEl.appendChild( li );
		messagesEl.scrollTop = messagesEl.scrollHeight;
	}

	function setStatus( state, label ) {
		statusEl.className = "chat-status is-" + state;
		statusTextEl.textContent = label;
	}

	const bp = new Pulsely( window.PULSELY_KEY, { url: "wss://pulsely.dev/ws" } );

	bp.connection.bind( "state_change", function ( { current, error } ) {
		if ( current === "connected" ) setStatus( "connected", "connected" );
		else if ( current === "unavailable" ) setStatus( "unavailable", error || "reconnecting…" );
		else if ( current === "disconnected" ) setStatus( "disconnected", "disconnected" );
		else setStatus( "connecting", current );
	} );

	bp.connect().then( function () {
		bp.subscribe( "chat" );
		bp.bind( "message", function ( data ) {
			addMessage( data );
		} );
	} );

	form.addEventListener( "submit", function ( evt ) {
		evt.preventDefault();
		const message = messageInput.value.trim();
		if ( !message ) return;

		const user = usernameInput.value.trim() || "Anonymous";
		localStorage.setItem( "chat-username", user );

		fetch( "/chat/send", {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify( { user: user, message: message } )
		} ).then( function ( res ) {
			if ( !res.ok ) {
				setStatus( "unavailable", "failed to send message" );
			}
		} );

		messageInput.value = "";
	} );
})();
