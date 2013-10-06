---
layout: post
title: "StoryBoard--看上去很美"
date: 2012-12-15 10:21
comments: true
categories: iOS
---

## 介绍
StoryBoard是苹果在2011年的WWDC Session 309《Introducing Interface Builder Storyboarding》中介绍的Interface Builder的新功能。其基本想法是将原本的xib进行升级，引入一个容器用于管理多个xib文件，并且这个容器可以通过拖拽设置xib之间的界面跳转。而这个容器就是被苹果称做的StoryBoard。下图是一个Storyboard的截图。

{% img /images/enbrace-ios5-1.png %}

<!-- more -->

##优点

总体上来说，Storyboard有以下好处：

 1. 你可以从storyboard中很方便地梳理出所有View Controller的界面间的调用关系。这一点对于新加入项目组的开发同事来说，比较友好。
 2. 使用Storyboard可以使用Table View Controller的Static Cell功能。对于开发一些Cell不多，但每个Cell都不一样的列表类设置界面会比较方便。
 3. 通过实现 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 方法，每个View Controller的跳转逻辑都聚集在一处，这方便我们统一管理界面跳转和传递数据。
 4. Storyboard可以方便将一些常用功能模块化和复用。例如WWDC2011年介绍Storyboard的视频就将微博分享功能模块化成一个单独的Storyboard。我在开发App时，也将例如通过第三方注册登录模块做成一个单独的Storyboard，便于以后复用。

##缺点

我在新项目使用Storyboard时，却发现它只是看上去很美，真正用起来，却有很多问题，我发现的问题有：

 1. 首先它和xib一样，对版本管理是灾难。因为是它实际上的多个xib的集合，所以更容易让多人编辑产生冲突。苹果对storyboard的设计也不好，基本上你只要打开，什么都不做，这个文件就会被更改，所以冲突几乎是不可避免的---除非你不打开，实在不小心打开看了，需要在提交前回退成服务器上的版本。
 2. Storyboard提供的 Static cell特性只适合于UITableViewController的子类。我很多时候的用法是一个TableView嵌套在另一个UIView中，static cell就不能用了。
 3. segue的概念对于开发来说并不省事，如果是用程序内部trigger一个segue，那么需要在另一个回调的地方设置dest view controller的参数信息。

##总结

我仔细比较权衡了一下优缺点，最主要的问题是我的版本管理在多人协作开发时将陷入灾难，而这是完全不能接受的。而最主要的好处就是，你可以在一个类似白板的地方“一揽众山小“一样了解所有界面之间的切换关系，但这个有那么重要吗？我自已其实很清楚跳转逻辑，这个只是对新同事了解项目代码时有帮助，那我花一点时间直接给他讲讲画画不就搞定的吗？为了这点好处而让版本管理无法使用，是完全不能接受的。

所以最终我决定放弃使用StoryBoard了，这个“看上去很美”的功能有着不可接受的缺陷。现在看来，它仅适用于做一些Demo的开发。苹果一直没有处理好这类可视化界面设计功能的版本管理，象xib文件，虽然是xml格式的，但如果多人编辑了，合并起来也会很麻烦。所以业界好多同行都不用xib,直接用纯代码来写界面，虽然稍慢一点儿，但是工程很干净，也基本没有了多人协作的版本冲突问题。

##2013-10-6更新

苹果在WWDC2013之后发布了Xcode5，storyboard和xib的内部实现进行了大量修改，使得其格式更加简单和易读，最终的效果是在版本冲突时，合并冲突变得可能。所以，现在我对于storyboard和xib不再象以前那么排斥了。








