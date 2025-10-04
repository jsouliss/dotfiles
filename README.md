- From the source machine 

```sh
mkdir ~/dotfiles
cd ~/dotfiles
mkdir -p nvim/.config && mv ~/.config/nvim ~/dotfiles/nvim/.config/nvim
mkdir -p wezterm/.config && mv ~/.config/wezterm ~/dotfiles/wezterm/.config/wezterm
...
```

- Importing dotfiles from repo to a new machine

```sh
cd ~/
git clone git@github.com:jsouliss/dotfiles.git
cd ~/dotfiles
# Check if files already exist in .config
# Create backups if they do or delete 
# There is also a merge option will include later
stow nvim tmux wezterm ...
```


```sh
.
├── hypr
│   └── .config
│       └── hypr
│           └── hyprland.conf
├── nvim
│   └── .config
│       └── nvim
│           ├── .gitignore
│           ├── init.lua
│           ├── lazy-lock.json
│           ├── lazyvim.json
│           ├── LICENSE
│           ├── lua
│           ├── .neoconf.json
│           ├── README.md
│           └── stylua.toml
├── tmux
│   └── .config
│       └── tmux
│           └── plugins
└── wezterm
    └── .config
        └── wezterm
            └── wezterm.lua
```
