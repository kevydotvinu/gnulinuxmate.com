---
title: VIM Tricks
layout: post
subtitle: Tricks which apart from usual-googled-results
image: /images/vim.jpg
tags: [Terminal, Commands]
---

Vim is a greatly improved version of the good old UNIX editor Vi. As we all need and core reason behind the choice of Linux OS is the customization. Isn't it? So is Vim. You may find common Vim tricks just by typing some keywords in the Google. Excluding that, here, I do have handful of some other.  

**vim-tmux-runner**  
This is one of our favorite. As the name suggests, tmux has something to do with this. It is simple as this, whatever we type in the one pane of tmux can be thrown away to the next and execute right away. GIF image shown here will demonstrate the idea. No doubt, this will blissful for script writers. The complete instruction of installation can be found in the creator's Github [repository](https://github.com/christoomey/vim-tmux-runner).   

![vim_tmux_runner](/images/vim_tmux_runner.gif)

**vim-clipboard-copy**  
We all are familiar with `y` for copy and `p` for paste, but this features limited inside the Vim. Simply install `vim-gtk` package to get this feature out of the Vim. After the installation, press `"+y` to copy contents to clipboard directly. If in case you do not know just open a new terminal window and run these two commands, entering your password when prompted:

```bash
sudo apt-get update
sudo apt-get install vim-gtk
```

**vim-color-scheme**  
Specific color pattern is very significant for script writers. It gives quick idea of content in the first glimpse. Although bunch of color schemes are readly available in Github repository, It is hard to go not mentioning [this](https://github.com/jacoborus/tender.vim) one.
