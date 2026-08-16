FROM ortussolutions/commandbox:boxlang

ENV APP_DIR=/app
WORKDIR $APP_DIR

# This image only has CommandBox's own `box` CLI (for running apps under its
# Runwar server) — no standalone `boxlang` binary. express-test needs the
# bare CLI, since boxlang-express runs its own com.sun.net.httpserver.HttpServer
# via app.listen() rather than running under Runwar/CommandBox's server model.
# Install it the same way the official ortussolutions/boxlang:cli image does.
ENV BOXLANG_VERSION=1.16.0
RUN curl -fsSL https://install.boxlang.io | bash -s -- ${BOXLANG_VERSION} --without-commandbox

# commandbox-boxlang teaches `box install` how to resolve a "boxlang-modules"
# typed ForgeBox package whose downloadURL is a GitHub-shorthand string
# (e.g. boxlang-express's "robertz/boxlang-express#v0.1.14") — without it,
# `box install boxlang-express` reports success but silently installs nothing.
RUN box install commandbox-boxlang --system

# The base image bakes a sample CommandBox site into /app (403.html,
# index.cfm, webroot/, etc.) — clear it so nothing shadows express-test's
# own files or confuses BoxLang's config/module resolution.
RUN rm -rf /app/* /app/.[!.]*

COPY app.bxs .
COPY views/ views/
COPY public/ public/
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV BOXLANG_MODULES=boxlang-express

EXPOSE 3003

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["boxlang", "app.bxs"]
