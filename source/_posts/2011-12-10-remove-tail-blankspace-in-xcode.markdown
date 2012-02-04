---
layout: post
title: "去掉xcode源码末尾的空格"
date: 2011-12-10 17:08
comments: true
categories: iOS xcode shell
---

在用xcode开发的时候，很容易就在行末增加一些空格了。这些空格在上传到review board上后,就会被特别的颜色显示出来。因为一种好的编程风格是说,不应该在行末增加不必要的空格。如果是用eclipse写java,那么这种时候选中写好的代码，按ctrl+shift+F即可调整源码的风格,将尾部的空格去掉。可惜在xcode中并没有提供相应的功能。

不过我们可以用命令行来达到这一效果,在工程目录下输入:

``` bash
find . -name "*.[hm]" | xargs sed -Ee 's/ +$//g' -i ""
```

这样,就可以把源码中行末多出来的空格去掉了,是不是很爽? 可以把这句加到执行post-review的脚本上，这样就可以做到自动去空格了。

顺便说一下，我打算把这些小脚本工具总结出来，放到github上，地址是 <https://github.com/tangqiaoboy/xcode_tool>，感兴趣的同学可以把它clone下来。

祝玩得开心～