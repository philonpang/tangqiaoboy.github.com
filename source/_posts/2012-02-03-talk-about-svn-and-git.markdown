---
layout: post
title: "SVN和Git的使用感受"
date: 2012-02-03 21:08
comments: true
categories: shell
---

从开始工作到现在，在公司里面一直用svn来做版本管理。大约半年前听说了Git，因为Git的光辉相当耀眼，作者是Linus Torvalds，被大量的开源软件采用，如jQuery, Perl, Qt, ROR, YUI, GNOME等，所以决定学一学。
比较庆幸的是，国内有一本较好的介绍Git的书：[《Git权威指南》](http://www.amazon.cn/Git%E6%9D%83%E5%A8%81%E6%8C%87%E5%8D%97-%E8%92%8B%E9%91%AB/dp/B0058FLC40/ref=sr_1_1?ie=UTF8&qid=1328277616&sr=8-1)。
我大概花了一个月的周末时间来学习它。在这里总结一下使用Git的感受，主要是和SVN来做一些比较，以便突出Git的特点。

<!--more-->

###学习成本
首先我感觉Git的学习成本还是比较高的。svn基本上不到20个命令就可以应付日常的工作了，而Git有上百个命令。我在学习SVN的时候，基本上没有看什么书，最多就是在网上随便看了一些贴子，就基本会使用SVN了。而我花在Git的学习时间算下来，至少有1周。

因为Git的学习成本较高，所以当一个会svn的同学刚刚接触Git的时候，如果简单地把Git当SVN用，就会感觉Git相当难用。我在公司就时常听到同事抱怨它。所以我认为，要想真正用好Git，还是需要投入时间来学习它，否则是很难使用的。

###Git的内部结构
Git真正是一个面向程序员的工具，它的内部数据结构是一个有向无环图，并且，你必须理解它的内部数据结构后，才能掌握它。因为你的很多操作，都其实对应的是这个有向无环图的操作。比如:

* git commit就是增加一个结点。
* git commit --amend就是改发一个结点。
* git reset就是修改HEAD指向的结点。

另外，Git内部包括三个区域：工作区，暂存区和版本库。

* git add 是将工作区的内容保存到暂存区
* git checkout 是将暂存区的内容覆盖工作区
* git commit 是将暂存区的内容保存到版本库
* git reset 默认情况下是将版本库的内容覆盖工作区
* git diff 也有三种情况，分别是比较工作区与暂存区，工作区与版本库，暂存区与版本库之间的差别

了解了Git的内部结构，对于这些Git的命令就更加理解了。

###svn的坑

svn在平常使用上基本没什么坑，平时通过
<pre>svn pe svn:ignore . </pre>设置好忽略的文件，以免误把不应该加入版本管理的文件加进来。

我唯一遇到的一次问题是这样的：我有一个目录要加入svn的版本库，但是目录里面的一些文件不想加入。如果直接输入svn add 目录名，就会把目录下所有文件都加入到版本管理中。如果cd到那个目录里面配置svn:ignore，又会因为当前目录还不在版本管理中，设置不了。最后找到的解决办法是在svn add的时候增加 --non-recursive 参数：
```
svn add dirname --non-recursive
或者是：
$ svn add dirname --depth empty
```

还有就是对于一些不小心用svn add加入了版本管理，但实际上不应该加的目录。可以这么做：
```
svn export spool spool-tmp    (这里export可以将原目录中的.svn目录给清除掉)
svn rm spool
svn ci -m 'Removing inadvertently added directory "spool".'
mv spool-tmp spool
svn propset svn:ignore 'spool' .
svn ci -m 'Ignoring a directory called "spool".'
```

###Git的坑

 * 在windows下的文件的权限因为无法和linux上完全一致，所以用Git检出的文件权限可能显示为被更改。
另外因为windows下的换行和linux上也不一样，协作开发时也容易出问题。所以在windows上使用Git的同学需要加上以下2行配置参数：

```
git config --global core.filemode false
git config --global core.autocrlf true
第一句是忽略文件权限的改动。
第二句是将文件checkout时自动把LF转成CRLF，check in 时自动把CRLF转成LF
```

 * svn的svn revert filename 对应的其实是 git checkout -- filename, 而git revert xxx是基于xxx提交所做的改动，做一次反向提交，和svn revert 完全不一样。


###Git的一些小技巧

* 一旦推送到远程仓库后，就不要用类似git reset, git ci --amend, git rebase等破坏性提交了，否则远程仓库会因为你的新推送不是Fast Forward而拒绝提交(关于什么是Fast Forward要讲的太多了，自已看书吧)。如果实在不小心做了。在确定别人没有检出前，用git push -f 可以强制推送到远程仓库中。如下图:

{% img /images/git_push_f.jpg %}

* 在公司没有应用git前，你可以用git svn 来做管理。 git svn 相关命令：
```
     git svn clone -r REV1:HEAD svn_addr local_addr
     git svn dcommit  提交到SVN
     git svn fetch    从svn up信息
     git svn rebase   将从svn up过来的信息，rebase成git提交
     git svn rebase --continue  冲突后继续rebase信息
```

* 在用户的home目录下，有一个.gitconfig文件，里面可以配置一些别名，方便平时的git操作。
特别是那些平日使用SVN的短命令习惯了的同学，配置一下别名后，使用git就会相当顺手了。我配置的别名如下。这里特别多说一句，有些人喜欢将ci设置成commit -a，这样就不用git add来把需要提交的文件加入到暂存区了。在《Git权威指南》中，作者极力反对这样做。因为Git本身在提交前有add这步，就是为了让提交者能够审视自己的提交文件，以防止错误的提交发生。
<pre>
[alias]
    st = status -s
    ci = commit
    l = log --oneline --decorate -13
    ll = log --oneline --decorate
    co = checkout
    br = branch
    rb = rebase
    dci = dcommit
</pre>

* 如果你需要删除Git下没有加入到版本库中的文件，可以使用：
```
git clean -nd 测试删除
git clean -fd 真实删除
```

* 用git svn clone 的时候，带上 -r rev1:HEAD参数，可以省去将SVN整个提交历史抓取下来的时间。

* 搭建一个Git远程仓库相当简单，直接在一台带SSH的服务器上用git init --bare dirname即可。本地可以用git remote命令来设置多个远程分支。另外，第一次提交的时候，因为远程仓库中没有任何分支，需要用如下指令建立master分支：
```
git remote add origin yourname@yourhost.com:~/path/repository_name
git remote add add2 yourname@yourhost.com:~/path/repository_name
git push origin master
git push add2 master
如果git remote add设置地址写错了，可以用git remote set-url更改：
git remote set-url origin yourname@yourhost.com:~/path/repository_name
```

* 如何用Git将一个文件的历史提交恢复？

上次遇到一个问题，我某次提交改动了很多文件，但是其中有一个是不应该改的。所以我需要把这次提交中关于那个文件的改动撤销。直接用git checkout命令可以检出某一个文件的历史版本，然后就可以将对这个文件的改动取消了。如下：

```
git checkout CommitId fileName 
git ci -m "revert a file modification"
```

* 本地工作区还有未提交的内容时，不能pull?

可以先用 git stash 将内容暂存，然后再pull，成功后再git stash pop将修改恢复。

### 一些Git的资料

* [Git Magic](http://www-cs-students.stanford.edu/~blynn/gitmagic/intl/zh_cn/) 很通俗的一本介绍Git的书，比较短小精炼。
* [Pro Git](http://progit.org/book/zh/) 全面介绍Git的书，非常详细。
* [《Git权威指南》](http://www.amazon.cn/Git%E6%9D%83%E5%A8%81%E6%8C%87%E5%8D%97-%E8%92%8B%E9%91%AB/dp/B0058FLC40/ref=sr_1_1?ie=UTF8&qid=1328277616&sr=8-1) 中国人写的一本介绍Git的书，也非常通俗。我个人主要就是通过这本书来学习Git的。
* [Github](http://www.github.com) 基于Git的开源网站。在Github的托管的项目相当多，著名的有：rails, jquery, node, homebrew, three20, jekyll, jquery-ui, backbone, coffee-script, tornado, redis, underscore, asi-http-request, django。


