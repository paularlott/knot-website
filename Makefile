default: help

## Generate OKF 0.2 knowledge bundles into okf/ (committed: Cloudflare runs Hugo, not scripts;
## mounted into the site at /okf/ via hugo.toml)
okf:
	scriptling scripts/okf.py

## Run the Knot KB MCP server (tools: knotkb_list, knotkb_get, knotkb_search, knotkb_grep)
mcp-server:
	scriptling --server :8765 --mcp-tools mcp/tools

## Pack the KB MCP server + OKF bundles into dist/knot-kb.zip (portable)
pack: okf
	@rm -rf dist/knot-kb dist/knot-kb.zip
	@mkdir -p dist/knot-kb/okf dist
	cp -R mcp/tools dist/knot-kb/tools
	cp -R okf/knot-docs okf/knot-reference dist/knot-kb/okf/
	cp mcp/README.md dist/knot-kb/
	cd dist/knot-kb && zip -qr ../knot-kb.zip .
	@echo "Built dist/knot-kb.zip"

## Pack just the OKF bundles into dist/knot-okf-bundles.zip
bundle-pack: okf
	@rm -f dist/knot-okf-bundles.zip
	@mkdir -p dist
	cd okf && zip -qr ../dist/knot-okf-bundles.zip knot-docs knot-reference
	@echo "Built dist/knot-okf-bundles.zip"

## Regenerate OKF bundles; commit them if anything changed (no push)
okf-sync: okf
	@if ! git diff --quiet -- okf/; then \
		echo "OKF bundles changed; committing"; \
		git add okf/ && git commit -m "Regenerate OKF bundles"; \
	else \
		echo "OKF bundles up to date"; \
	fi

## Tag and publish a GitHub release with the KB + OKF bundles archives.
## Ordering matters: regenerate + commit the bundles, then push — the push
## either no-ops or pushes the code and triggers the Cloudflare site build —
## and only then pack the zips, upload, and tag, so the hosted bundles and
## the release archive can never diverge from the committed docs.
release:
	@$(MAKE) okf-sync
	@test -d ../knot || { echo "knot repo not found at ../knot"; exit 1; }
	@command -v gh >/dev/null 2>&1 || { echo "gh CLI not installed"; exit 1; }
	@git push
	@$(MAKE) pack bundle-pack
	@V=$$(cd ../knot && go run ./scripts/getversion); \
	echo "Releasing knot-kb v$$V"; \
	if git tag -l v$$V | grep -q v$$V; then \
		echo "Tag v$$V already exists, skipping tag creation"; \
	else \
		git tag -a v$$V -m "Release $$V" && git push origin v$$V; \
	fi; \
	gh release create v$$V dist/knot-kb.zip dist/knot-okf-bundles.zip \
		-t "Release $$V" -n "Knot knowledge bundles and MCP server $$V"

## Sync the OpenAPI spec from the pro repo into static/api-reference/ (committed;
## the site builds on Cloudflare, which cannot read sibling repos)
api-spec:
	cp ../knot-pro-src/internal/api/spec/knot-openapi.yaml static/api-reference/knot-openapi.yaml

.PHONY: help okf mcp-server pack bundle-pack okf-sync release api-spec
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
