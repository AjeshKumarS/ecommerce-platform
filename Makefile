.DEFAULT_GOAL := help

.PHONY: help tree check-tools

help: ## Show available commands
	@awk -F ': ## ' '/^[[:alnum:]_-]+: ## / {printf "  make %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

tree: ## Show the repository directory structure
	@find . -type d -not -path './.git*' -not -path '*/target*' | sort

check-tools: ## Show Java and Maven versions when installed
	@command -v java >/dev/null 2>&1 && java -version || echo "java not found (Java 21+ is planned)"
	@command -v mvn >/dev/null 2>&1 && mvn -version || echo "mvn not found (Maven setup is planned)"