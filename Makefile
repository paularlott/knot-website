default: help

## Generate OKF knowledge bundles into mcp/okf/ (generated; not published)
okf:
	scriptling scripts/okf.py

## Run the Knot KB MCP server (tools: knotkb_list, knotkb_get, knotkb_search, knotkb_grep)
mcp-server:
	scriptling --server :8765 --mcp-tools mcp/tools

## Pack the KB MCP server + OKF bundles into dist/knot-kb.zip (portable)
pack: okf
	@rm -f dist/knot-kb.zip
	@mkdir -p dist
	cd mcp && zip -qr ../dist/knot-kb.zip tools okf README.md

## Pack just the OKF bundles into dist/knot-okf-bundles.zip
bundle-pack: okf
	@rm -f dist/knot-okf-bundles.zip
	@mkdir -p dist
	cd mcp/okf && zip -qr ../../dist/knot-okf-bundles.zip knot-docs knot-reference

## Tag and publish a GitHub release with the KB + OKF bundles archives
release: pack bundle-pack
	@test -d ../knot || { echo "knot repo not found at ../knot"; exit 1; }
	@command -v gh >/dev/null 2>&1 || { echo "gh CLI not installed"; exit 1; }
	@V=$$(cd ../knot && go run ./scripts/getversion); \
	echo "Releasing knot-kb v$$V"; \
	if git tag -l v$$V | grep -q v$$V; then \
		echo "Tag v$$V already exists, skipping tag creation"; \
	else \
		git tag -a v$$V -m "Release $$V" && git push origin v$$V; \
	fi; \
	gh release create v$$V dist/knot-kb.zip dist/knot-okf-bundles.zip \
		-t "Release $$V" -n "Knot knowledge bundles and MCP server $$V"

.PHONY: help okf mcp-server pack bundle-pack release
## This help screen
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-20s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\n"
