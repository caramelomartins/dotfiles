# dotfiles

This repo is a collection of my dotfiles, inspired by [GitHub ❤ ~/](https://dotfiles.github.io/) and similar resources.

## Requirements

- stow
- git

## Instructions

- Run `stow -t $HOME .`.
- Execute `brew bundle install --file $HOME/.Brewfile`.
- Install any local `homebrew` bundles from `.brew/bundles`.
- `git` - This will set global `.gitconfig` and `.gitignore` files. For privacy, email and user should be set in another file (`~/.gitconfig.local)` and will be included in the configuration.
- Execute `:PlugInstall` in `vim` & `Prefix` + `I` in `tmux` for plugins.
- `.gitconfig.local` and `.zsh/` can be added locally to add more configurations per machine.
- Install https://ohmyz.sh/.
- If necessary, copy `CLAUDE.md` from other machines.

## Resources

[dotfiles.github.com](http://dotfiles.github.com) and all the contributors referenced
in that page along with all dotfiles repos in [github.com](http://github.com) were my
main sources of inspiration and reference.

Along with stolen scripts from
[stackoverflow.com](http://stackoverflow.com) whenever necessary that are mentioned inside the scripts.

## License

[MIT](LICENSE.md)
