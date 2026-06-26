# Makefile — HelioBus800
.PHONY: setup run watch tree test lint pr help

setup:
	bash heliobus800-bootstrap.sh

run:
	bash heliobus800-automation.sh run

watch:
	bash heliobus800-automation.sh watch

tree:
	bash heliobus800-init-tree.sh .

test:
	python3 -m pytest tests/ -v

lint:
	shellcheck heliobus800-automation.sh heliobus800-bootstrap.sh \
	           heliobus800-gitsetup.sh heliobus800-init-tree.sh || true

pr:
	git add -A && git commit -m "manual: update $$(date '+%Y-%m-%d %H:%M')" && gh pr create --fill

help:
	@echo "setup   instala dependências (1x)"
	@echo "run     ciclo único build/test/PR"
	@echo "watch   loop contínuo daemon"
	@echo "tree    recria árvore de docs"
	@echo "test    roda pytest"
	@echo "lint    shellcheck nos scripts"
	@echo "pr      PR manual"
