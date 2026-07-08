DOTFILES_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help bootstrap install stow restow completions healthcheck symlinks doctor check

help:
	@printf '%s\n' \
		'Targets:' \
		'  bootstrap    Apply stow, generate completions, then run checks' \
		'  install      Alias for bootstrap' \
		'  stow         Apply all dotfiles packages' \
		'  restow       Re-apply all dotfiles packages' \
		'  completions  Regenerate shell completions' \
		'  healthcheck  Dry-run stow validation across packages' \
		'  symlinks     Verify stowed symlinks resolve correctly' \
		'  doctor       Run repo-wide diagnostics' \
		'  check        Run the validation targets'

bootstrap: stow completions doctor

install: bootstrap

stow:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) STOW_DIR=$(DOTFILES_ROOT) ./scripts/stow-all

restow:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) STOW_DIR=$(DOTFILES_ROOT) ./scripts/stow-all

completions:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) ./scripts/gen-completions

healthcheck:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) STOW_DIR=$(DOTFILES_ROOT) ./scripts/stow-healthcheck

symlinks:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) STOW_DIR=$(DOTFILES_ROOT) ./scripts/check-symlinks

doctor:
	@DOTFILES_ROOT=$(DOTFILES_ROOT) ./scripts/dotfiles-doctor

check: healthcheck symlinks
