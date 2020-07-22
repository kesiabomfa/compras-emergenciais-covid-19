.PHONY: help build

#====================================================================
# PHONY TARGETS

help: 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Compilação datapackage.json para buid/
	Rscript --verbose scripts/build.R 2> logs/log.Rout

