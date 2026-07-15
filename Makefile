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

.PHONY: help okf mcp-server pack
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
