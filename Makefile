stow_args = -d "$(shell pwd)" -t "${HOME}" --no-folding --dotfiles
stow_target = "config"

install:
	stow $(stow_args) $(stow_target)
uninstall:
	stow -d $(stow_args) --delete $(stow_target)
update:
	stow -d $(stow_args) -R $(stow_target)
