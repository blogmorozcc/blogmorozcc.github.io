+++
title = "How to install and configure ZSH shell in Linux"
date = "2023-11-26"
tags = [
    "Linux",
    "Shell",
    "ZSH",
    "Oh My Zsh",
    "Powerlevel10k",
]
categories = [
    "Linux",
]
image = "header.jpg"
+++

## Introduction

[Zsh](https://www.zsh.org/), or Z Shell, is a powerful and feature-rich command-line shell for Unix-like operating systems, including Linux and BSD (Berkeley Software Distribution). It is an extended version of the Bourne Shell (sh) with numerous improvements and additional features. Zsh aims to provide a more interactive and user-friendly experience for shell users.

Here are some reasons why Zsh is often considered one of the best shells for Unix/Linux/BSD systems:

- **Command Line Editing**: Zsh offers advanced command-line editing capabilities, allowing users to navigate and edit commands with ease. It supports features like history expansion, spelling correction, and advanced pattern matching.

- **Customization**: Zsh is highly customizable. Users can configure various aspects of the shell's behavior, such as prompt appearance, key bindings, and completion options. The extensive configuration options make it adaptable to individual preferences and workflows.

- **Powerful Tab Completion**: Zsh provides powerful and context-aware tab completion, making it easier to navigate the file system and complete command names and arguments. It can complete not only commands but also file paths, variables, and more.

- **Plugins and Extensions**: Zsh supports plugins and extensions that enhance its functionality. Tools like Oh-My-Zsh and Prezto are popular frameworks that make it easy to manage Zsh configurations and add additional features through plugins.

- **Advanced Globbing**: Zsh supports advanced globbing patterns, which provide more flexibility and power when specifying file paths or matching patterns. This makes it easier to perform complex file operations directly from the command line.

- **Spelling Correction**: Zsh has a built-in spelling correction feature that helps users avoid typos. If you mistype a command or file path, Zsh can suggest corrections.

- **Interactive Features**: Zsh includes interactive features that improve the overall user experience, such as the ability to navigate command history easily, search through previous commands, and reuse or modify commands efficiently.

- **Compatibility with Bourne Shell**: Zsh is compatible with the Bourne Shell (sh) syntax, making it a suitable replacement for sh or Bash. Existing shell scripts are likely to work in Zsh without modification.

While Zsh offers a rich set of features, the choice of the "best" shell often depends on individual preferences and specific use cases. Other popular shells include Bash (Bourne Again SHell) and Fish (Friendly Interactive SHell), each with its own strengths and characteristics. Ultimately, the best shell is the one that aligns with your workflow and meets your specific requirements.

## Installation

### Install ZSH package

To install ZSH package in your Linux system consider using the package manager provided with your distribution. It is done differently depending on your distribution, for example:

For Arch Linux: 

{{< highlight shell "linenos=false" >}}
sudo pacman -S zsh
{{< / highlight >}}

For Fedora, Red Hat:

{{< highlight shell "linenos=false" >}}
sudo dnf install zsh
{{< / highlight >}}

For Debian, Ubuntu, Linux Mint, ElementaryOS:

{{< highlight shell "linenos=false" >}}
sudo apt install zsh
{{< / highlight >}}

In my case, I am installing it for Arch Linux, for example:

![Example of installing ZSH on Arch Linux](install.png)

### Make ZSH your default shell

To make the new installed ZSH the default for your user, type the command below, and enter your user password for confirmation:

{{< highlight shell "linenos=false" >}}
chsh -s $(which zsh)
{{< / highlight >}}

![Making ZSH the default shell](zsh-default.png)

After that it is recommended to reboot your system, on next reboot the ZSH shell will be used for your user. To reboot your Linux computer you can use command `sudo reboot` or just use GUI of your desktop environment to perform reboot.

### Perform the initial configuration

Once you open the terminal application after reboot zsh will prompt you to create the default configuration files. To apply the initial configuration press "0" on the keyboard. 

![Initial configuration of ZSH shell](zsh-initial.png)

### Install Oh My ZSH 

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) is an open-source framework and configuration manager for [Zsh](https://www.zsh.org/), the Z Shell. It was created to make it easier for users to manage their Zsh configurations and enhance their command-line experience. Oh-My-Zsh provides a collection of plugins, themes, and helper functions that can be easily integrated into Zsh, allowing users to customize and extend the functionality of their shell environment.

To install ZSH the most easy way is to use installation script from the [Oh My Zsh GitHub Repository](https://github.com/ohmyzsh/ohmyzsh). It is possible to execute the installation script by downloading it, like this:

{{< highlight shell "linenos=false" >}}
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
{{< / highlight >}}

After script finishes, you should see [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) installed like on screenshot below.

![Initial configuration of ZSH shell](oh-my-zsh-post-install.png)

### Modify Oh My ZSH theme

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) has a plenty of pre-installed themes that are located in `~/.oh-my-zsh/themes/` folder. 

![Initial configuration of ZSH shell](oh-my-zsh-default-themes.png)

You can modify your `.zshrc` file and use pre-installed theme.

{{< highlight shell "linenos=false" >}}
nano .zshrc
{{< / highlight >}}

And to change your theme to `agnoster` for example, find `ZSH_THEME` paramater and change it like this:

{{< highlight shell "linenos=false" >}}
ZSH_THEME="agnoster"
{{< / highlight >}}

### Install custom Oh My ZSH theme

Personally for me [Powerlevel10k](https://github.com/romkatv/powerlevel10k) is the most liked among the others, so in this example I will demonstrate how to install it.

#### Install compatible terminal font

In order for this custom theme to be able to correctly display some characters, your terminal should use a custom compatible fon Meslo LGS NF. To to this you can follow the [instructions from the GitHub repository](https://github.com/romkatv/powerlevel10k/blob/master/font.md).

The most simple way is download and 4 font files:

- [MesloLGS NF Regular.ttf](./MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](./MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](./MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](./MesloLGS%20NF%20Bold%20Italic.ttf)

To make them available system wide move those 4 files to `/usr/share/fonts` folder:

```bash
sudo mv "MesloLGS NF Regular.ttf" /usr/share/fonts
sudo mv "MesloLGS NF Bold.ttf" /usr/share/fonts
sudo mv "MesloLGS NF Italic.ttf" /usr/share/fonts
sudo mv "MesloLGS NF Bold Italic.ttf" /usr/share/fonts
```

Finally, to flush the font cache, execute the command:

{{< highlight shell "linenos=false" >}}
sudo fc-cache
{{< / highlight >}}

The last step is to change the font of your terminal. It can depend on the terminal you are using, but usually you can just modify it in the terminal graphical settings. In my case I set it up to use `Meslo LGS NF Regular 12`.

![Terminal font settings example](terminal-font-settings.png)

#### Install Powerlevel10k theme

First download the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme to your custom themes directory, it can be done easily just with one command:

{{< highlight shell "linenos=false" >}}
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
{{< / highlight >}}

![The process of cloning Powerlevel10k repository files](powerlevel10k-clone.png)

Then modify your `.zshrc` file:

{{< highlight shell "linenos=false" >}}
nano .zshrc
{{< / highlight >}}

and set `ZSH_THEME` parameter to be equal to `powerlevel10k/powerlevel10k`:

{{< highlight shell "linenos=false" >}}
ZSH_THEME="powerlevel10k/powerlevel10k"
{{< / highlight >}}

![Changing the theme in .zshrc](zshrc-theme.png)

After you saved the file, use the command below to apply the changes:

{{< highlight shell "linenos=false" >}}
source ~/.zshrc
{{< / highlight >}}

#### Complete Powerlevel10k configuration wizard

The first time new custom Powerlevel10k is running, the Powerlevel10k theme configuration wizard will start. You can always start this wizard again by using `p10k configure` terminal command. The wizard has several steps, just press corresponding keyboard keys to answer. I will show below how the configuration looks like in my case.

##### 1. Confirm that several font symbols are displayed correctly.

![Diamond symbol](powerlevel10k-wizard1.png)
![Lock symbol](powerlevel10k-wizard2.png)
![Up arrow symbol](powerlevel10k-wizard3.png)
![Fit between symbols](powerlevel10k-wizard4.png)

I just answered yes to those questions (by pressing "y" on keyboard), because everything in terms of symbol rendering was displayed correctly.

##### 2. Setup theme style

All the options in this section allow to modify the design of the theme according to your personal preferences. I will show what answers I typed into the wizard in case you want to replicate the exact theme behavior from this guide.

The prompt style setting will allow to setup the main look and feel, I answered `3` here.
![Prompt style](powerlevel10k-wizard5.png)

The character set is important setting, and actually Unicode allows to display more symbols, so I highly recommend answer `1` here.
![Character set](powerlevel10k-wizard6.png)

This setting allows to show or hide current time in terminal. I see no practical use in this, so I answered `n` here.
![Current time](powerlevel10k-wizard7.png)

The next settings are all about the look and feel of the theme, you can choose whatever you personally like.

![Prompt separator](powerlevel10k-wizard8.png)
![Prompt heads](powerlevel10k-wizard9.png)
![Prompt tails](powerlevel10k-wizard10.png)
![Prompt height](powerlevel10k-wizard11.png)
![Prompt connection](powerlevel10k-wizard12.png)

![Prompt frame](powerlevel10k-wizard13.png)
![Prompt spacing](powerlevel10k-wizard14.png)
![Icons](powerlevel10k-wizard15.png)
![Prompt flow](powerlevel10k-wizard16.png)
![Transient prompt](powerlevel10k-wizard17.png)


The instant prompt feature allows to reduce the loading times of the ZSH shell, so I highly recomment to enable it by answering `1` here.
![Instant prompt](powerlevel10k-wizard18.png)

The last step is to apply changes to `.zshrc`, just answer `y` here.
![Apply changes](powerlevel10k-wizard19.png)

If everything was set up right, you will see your new shell theme.

![Installed p10k theme](powerlevel10k-installed.png)

### Enable built-in Oh My ZSH plugins

Zsh supports plugins and extensions that enhance its functionality. Oh-My-Zsh makes it easy to manage Zsh configurations and add additional features through plugins.

To view a list of plugins that is bundeled with Oh My ZSH, you can type a command:

{{< highlight shell "linenos=false" >}}
ls -a ~/.oh-my-zsh/plugins/
{{< / highlight >}}

In my case I have those plugins:

![Plugins bundled with Oh My ZSH by default](oh-my-zsh-bundled-plugins.png)

Then you can modify your `.zshrc` file:

{{< highlight shell "linenos=false" >}}
nano .zshrc
{{< / highlight >}}

and set `plugins` parameter to load the plugins you need, in my case as an Android Developer I need `git` and `adb` plugins:

{{< highlight shell "linenos=false" >}}
plugins=(git adb)
{{< / highlight >}}

![Changing the plugins in .zshrc](zshrc-plugins.png)

Then apply the changes to your shell:

{{< highlight shell "linenos=false" >}}
source ~/.zshrc
{{< / highlight >}}

### Installing custom plugins

Also Oh My ZSH allows you to install and user third party plugins. For example let's install `zsh-autosuggestions` plugins to have some nice recommendations for input commands based on history.

Installing is very similar to installing a custom theme. First, clone the plugin into the custom plugins directory.

{{< highlight shell "linenos=false" >}}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
{{< / highlight >}}

![Cloning the zsh-autosuggestions plugin](zsh-autosuggestions-clone.png)

Then you can modify your `.zshrc` file the same way as I shown in the article section above, so in the result you will have:

{{< highlight shell "linenos=false" >}}
plugins=(git adb zsh-autosuggestions)
{{< / highlight >}}

Then apply the changes to your shell:

{{< highlight shell "linenos=false" >}}
source ~/.zshrc
{{< / highlight >}}

After that try to type something, and you should see some suggestion. For example I typed "neo", and the plugin suggests to use "neofetch":

![Testing the zsh-autosuggestions plugin](zsh-autosuggestions-works.png)

### Enabling auto updates

Oh-My-Zsh has a built-in update mechanism to help users keep their installation up-to-date with the latest changes, enhancements, and bug fixes contributed by the community. Also it provides a way for automatic updates, but it is disabled by default.

To configure automatic updates you should set this directive in `.zshrc` file:

{{< highlight shell "linenos=false" >}}
zstyle ':omz:update' mode auto
{{< / highlight >}}

## Conclusions

So ZSH is more feature rich shell that can make you work more efficient with extending the shell functionality with custom plugins, so it can be considered as a better alternative to bash that is the default shell in any modern Linux distribution.
