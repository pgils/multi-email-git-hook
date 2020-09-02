APP              = multi-email-git-hook
XDG_DATA_HOME   ?= $(HOME)/.local/share
TEMPLATE_DIR    ?= $(XDG_DATA_HOME)/$(APP)/templates
GIT_SET_TEMPLATE = git config --global init.templateDir

all:
	@echo "Nothing to build"

install:
	@install -v -d "$(TEMPLATE_DIR)/hooks"
	@install -v -m 0755 "pre-commit.pl" "$(TEMPLATE_DIR)/hooks/pre-commit"
	@if ${GIT_SET_TEMPLATE} >/dev/null; then \
		echo "Attention: global init.templateDir already set:"; \
		${GIT_SET_TEMPLATE}; \
		echo "Unset this value first if you sure and run install again."; \
		exit 1;\
	fi
	@$(GIT_SET_TEMPLATE) $(TEMPLATE_DIR)
