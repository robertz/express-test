# express-test

A small real-time chat demo built with [BoxLang](https://boxlang.io) and
[boxlang-express](https://github.com/ortus-boxlang/boxlang-express) (an
Express.js-style web framework for BoxLang), using
[Pulsely](https://pulsely.dev) for pub/sub messaging.

## How it works

- `app.bxs` boots a boxExpress app, serves the chat view at `/`, and
  exposes `POST /chat/send` — it sanitizes the submitted name/message with
  `bx-esapi` (OWASP ESAPI/AntiSamy), then signs and publishes the message to
  Pulsely's REST API (`POST /apps/{appId}/events`) using HMAC-SHA256.
- `views/index.bxm` renders the chat UI and connects to Pulsely's browser
  SDK with only the public app key, subscribing to the `chat` channel to
  receive messages over WebSocket.
- `public/css/chat.css` and `public/js/chat.js` hold the front-end styling
  and logic.

The Pulsely app secret lives in `app.bxs` and is only ever used server-side
to sign outgoing requests — the browser only ever sees the public app key.

> This is a demo app; credentials are inlined in `app.bxs` for convenience
> rather than pulled from the environment.

## Requirements

- [BoxLang](https://boxlang.io) CLI installed and on your `PATH`
- The `boxlang-express` and `bx-esapi` BoxLang modules (installed via
  `box install boxlang-express bx-esapi`, or already present under
  `~/.boxlang/modules`)

## Running

```bash
boxlang app.bxs
```

The server listens on port `3000` — open `http://localhost:3000` in a
browser. Multiple tabs/browsers will all see each other's messages live.

## Project structure

```
app.bxs             boxExpress app, routes, Pulsely signing/publish logic
Application.bx       BoxLang application configuration
views/index.bxm      Chat page template (.bxm view, rendered via res.render)
public/css/chat.css  Chat UI styling
public/js/chat.js    Chat client: connects to Pulsely, sends/receives messages
```
