#!/bin/bash
set -e

if [[ -n "$BOXLANG_MODULES" ]]; then
	for module in $(echo "$BOXLANG_MODULES" | tr "," "\n"); do
		echo "[docker-entrypoint] installing module: $module"
		box install "$module" --local

		# commandbox-boxlang installs a "boxlang-modules"-typed package into
		# the CommandBox-managed server home (.../WEB-INF/boxlang/modules/<name>),
		# not a plain project-root boxlang_modules/ — but the bare `boxlang`
		# CLI (used below to run app.bxs directly, bypassing Runwar entirely)
		# only looks in ./boxlang_modules or ~/.boxlang/modules. Relocate.
		installedPath=$(find /usr/local/lib/serverHome -maxdepth 5 -type d -name "$module" 2>/dev/null | head -1)
		if [[ -n "$installedPath" ]]; then
			mkdir -p "$APP_DIR/boxlang_modules"
			cp -r "$installedPath" "$APP_DIR/boxlang_modules/$module"
			echo "[docker-entrypoint] relocated $module -> $APP_DIR/boxlang_modules/$module"
		else
			echo "[docker-entrypoint] WARNING: could not find installed module '$module' under the server home to relocate" >&2
		fi
	done
fi

exec "$@"
