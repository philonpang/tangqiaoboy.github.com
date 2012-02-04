---
layout: post
title: "使用Github来管理xcode4中的代码片段"
date: 2012-02-04 14:32
comments: true
categories: iOS xcode
---
###代码片段介绍

xcode4引入了一个新feature: code snippets，在整个界面的右下角，可以通过快捷键：cmd + ctrl + opt + 2 调出来。code snippets是一些代码的模版，对于一些常见的编程模式，xcode都将这些代码抽象成模版放到code snippet中，使用的时候，只需要键入快捷键，就可以把模版的内容填到代码中。

<!--more-->

例如，在引入GCD(Grand Central Dispatch)后，当我们需要一个延时的操作时，只需要在xcode中键入：dispatch
, 就可以看到xcode中弹出一个上下文菜单，第一项就是相应的代码片段。如下图所示：

{% img /images/dispatch_after_snippet.jpg %}

###定义自己的代码片段

那么如何自定义code snippet呢，相当简单，当你觉得某段代码很有用，可以当作模版的时候，将其整块选中，
拖动到xcode右下角的code snippets区域中即可。xcode会自动帮你创建一个新的代码片段。
之后你可以单击该代码片段，在弹出的界面中选择edit，即可为此代码片段设置快捷键等信息。

如果有些地方你想让用户替换掉，可以用 <#被替换的内容#> 的格式。
这样在代码片段被使用后，焦点会自动移到该处，你只需要连贯的键入替换后的内容即可。如下图所示：

{% img /images/edit_code_snippet.jpg %}

关于xcode的一些代码片段，[这里](http://nearthespeedoflight.com/article/xcode_4_code_snippets)有一些用户的总结心得。

###使用Git管理代码片段
在了解了code snippet之后，我在想能不能用Git来管理它，于是就研究了一下，发现它都存放于目录 ~/Library/Developer/Xcode/UserData/CodeSnippets 中。于是，我就将这个目录设置成一个Git的版本库，然后将自己整理
的代码片段都放到Github上了。现在我有2台mac机器，一台笔记本，一台公司的iMac，我常常在2台机器间切换着工作，由于将代码片段都放在github上，所以我在任何一端有更新，另一端都可以很方便的用git pull将更新拉到本地。前两天将公司机器升级到lion，又重装了lion版的xcode，简单设置一下，所有代码片段都回来了，非常方便。

我的代码片段所在的github地址是<https://github.com/tangqiaoboy/xcode_tool>,使用它非常方便，只需要如下3步即可：

```
git clone https://github.com/tangqiaoboy/xcode_tool
cd xcode_tool
./setup_snippets.sh
```

大家也可以将我的github项目fork一份，改成自己的。这样可以方便地增加和管理自己的代码片段。

祝大家玩得开心。

