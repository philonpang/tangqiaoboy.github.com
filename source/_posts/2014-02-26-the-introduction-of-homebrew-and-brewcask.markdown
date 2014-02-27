---
layout: post
title: "使用brew cask来安装Mac应用"
date: 2014-02-26 21:38
comments: true
categories: mac
---

##简介

[`brew cask`](https://github.com/phinze/homebrew-cask)是一个用命令行管理Mac下应用的工具，它是基于[`homebrew`](http://brew.sh/)的一个增强工具。

`homebrew`可以管理Mac下的命令行工具，例如`imagemagick`, `nodejs`，如下所示：

```
brew install imagemagick
brew install node

```

而使用上`brew cask`之后，你还可以用它来管理Mac下的Gui程序，例如`qq`, `chrome`, `evernote`等，如下所示：

```
brew cask install qq
brew cask install google-chrome
brew cask install evernote

```

<!-- more -->

##安装

###安装homebrew

用以下一行命令即可安装homebrew
```
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
```

之后执行 `brew doctor` 命令可以看看`homebrew`的环境是否正常。通常第一次安装完brew之后，还需要安装苹果的`Command Line Tools`。


###安装cask

用如下命令来安装cask:

```
brew tap phinze/cask
brew install brew-cask
```

##LaunchRocket

另外再附带推荐一个工具。

[LaunchRocket](https://github.com/jimbojsb/launchrocket)是一个管理brew安装的service的工具，安装之后可以看所有的service的运行状态，如下图所示：

{% img /images/LaunchRocketUI.png %}

安装`LaunchRocket`就要用到我刚刚提的`brew cask`，用如下命令即可：

```
brew tap jimbojsb/launchrocket
brew cask install launchrocket
```

之后LauchRocket设置页面找到（如下图所示），它的启动项同时也保存在`/opt/homebrew-cask/Caskroom/launchrocket`目录中。

{% img /images/launchRocket.jpg %}

启动LauchRocket有点麻烦，需要切换设置页面去手工启动。我自己想到一个办法，方法是把 `/opt/homebrew-cask`增加到 alfred 的search目录中，然后就可以用alfred来启动了，如下所示：

 1. 设置alfred

{% img /images/launch-cask-1.jpg %}

 2. 用alfred启动LauchRocket

{% img /images/launch-cask-2.jpg %}

大家玩得开心～