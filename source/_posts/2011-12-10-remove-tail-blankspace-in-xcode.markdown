---
layout: post
title: "去掉xcode源码末尾的空格"
date: 2011-12-10 17:08
comments: true
categories: iOS xcode shell
---

在用xcode开发的时候，很容易就在行末增加一些空格了。这些空格在上传到review board上后,就会被特别的颜色显示出来。因为一种好的编程风格是说,不应该在行末增加不必要的空格。如果是用eclipse写java,那么这种时候选中写好的代码，按ctrl+shift+F即可调整源码的风格,将尾部的空格去掉。可惜在xcode中并没有提供相应的功能。

<!--more-->

不过我们可以用命令行来达到这一效果,在工程目录下输入:

``` bash
find . -name "*.[hm]" | xargs sed -Ee 's/ +$//g' -i ""
```

这样,就可以把源码中行末多出来的空格去掉了,是不是很爽? 可以把这句加到执行post-review的脚本上，这样就可以做到自动去空格了。

顺便说一下，我打算把这些小脚本工具总结出来，放到github上，地址是 <https://github.com/tangqiaoboy/xcode_tool>，感兴趣的同学可以把它clone下来。

祝玩得开心～

## 2013年6月22日更新

上文写于2011年末，在2012年在WWDC大会上，苹果推出了XCode4。从XCode4开始，XCode会自动去掉源码末尾的空格。所以上面提到的脚本基本没用了。不过对于工程中的html或js文件，XCode的去末尾空格功能并没有打开，所以在某些时候才能有一些小用处。

另外，每次记得敲命令来去掉空格是一件很恶心的事情，最好是由程序自动完成。考虑到现在git已经很普及了，在这里介绍另一种在git仓库中创建钩子(hook)的方法来去掉所有提交文件的末尾空格，具体做法如下：

在工程目录的 .git/hooks/目录下，创建一个名为 pre-commit的文件，输入如下内容

``` bash
#!/bin/sh
if git-rev-parse --verify HEAD >/dev/null 2>&1 ; then
   against=HEAD
else
   # Initial commit: diff against an empty tree object
   against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi
# Find files with trailing whitespace
for FILE in `exec git diff-index --check --cached $against -- | sed '/^[+-]/d' | sed -E 's/:[0-9]+:.*//' | uniq` ; do
    # Fix them!
    sed -i '' -E 's/[[:space:]]*$//' "$FILE"
    git add "$FILE"
done

```

然后用 `chmod +x pre-commit` 给该文件加上执行权限。这样，每次在git提交文件的时候，该脚本就会被自动执行并且将提交文件末尾的空格去掉。

