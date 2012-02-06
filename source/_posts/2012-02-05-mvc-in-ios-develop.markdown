---
layout: post
title: "斯坦福大学iOS开发公开课总结"
date: 2012-02-05 12:58
comments: true
categories: iOS
---

###前言
iphone开发相关的教程中最有名的，当数斯坦福大学发布的"iphone开发公开课"了。此公开课在以前叫做《iphone开发教程》，今年由于平板电脑的流行，所以也加入了ipad开发相关的课程。在[网易公开课](http://v.163.com/special/opencourse/iphonekaifa.html)上，有[该教程](http://v.163.com/special/opencourse/iphonekaifa.html)的2010年录象，并且前面15集带中文字幕文件，非常适合初学者学习。

<!--more-->

在这里顺便说一下，网易公开课上的28集其实并不需要全部看完。真正的课程只有前面12集。后面的课程都是请一些业界的名人讲他们成功的app以及学生的作品展示，可看可不看。所以大家不要被28集这么多吓到。

由于近一年来iOS5以及xcode4的发布，苹果对原有的开发环境xcode以及开发语言Objective-C都有改进，所以原有的教程中很多内容不再适用了。例如新的xcode4将Interface Builder集成到xcode中，整个IDE布局和快捷键完全大变样，又比如苹果为Objective-c引用了ARC和Storyboard，这些都使得app的编程方式大为不同。

值得高兴的是，斯坦福大学最近更新了该公开课的2011年秋季录象，免费下载地址是：<http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=480479762>，不过现在该公开课还没有翻译，只能看英文原版了。新的课程相比以前要短了许多，一共只有9课。我大概快速看了一遍，总结一些心得给大家。

###iOS的MVC模式

MVC模式算是客户端类程序使用的设计模式的标配了。iOS对于Model, View和Controller之间的相互调用有它自己的规范和约定，在公开课的[第一课](http://itunes.apple.com/itunes-u/ipad-iphone-application-development/id480479762#)中，就介绍了应该如何将MVC模式应用在iOS开发中。主要的内容就体现在如下这张图中(图片来自该公开课第一课的[配套pdf](http://itunes.apple.com/itunes-u/ipad-iphone-application-development/id480479762#)的第37页)：

{% img /images/ios_mvc.jpg %}

我下面详细介绍一下这幅图的意思。

* 首先图中绿色的箭头表示直接引用。直接引用直观来说，就是说需要包含引用类的申明头文件和类的实例变量。可以看到，只有Controller中，有对Model和View的直接引用。其中对View的直接引用体现为IBOutlet。

* 然后我们看View是怎么向Controller通讯的。对于这个，iOS中有3种常见的模式:
   1. 设置View对应的Action Target。如设置UIButton的Touch up inside的Action Target。
   1. 设置View的delegate，如UIAlertViewDelegate, UIActionSheetDelegate等。
   1. 设置View的data source, 如UITableViewDataSource。
  通过这3种模式，View达到了既能向Controller通讯，又不需要知道具体的Controller是谁是目的，这样就和Controller解耦了。

* 最后我们看Model。Model在图上有一个信号塔类似的图形，旁边写着Notification & KVO。这表明Model主要是通过Notification和KVO来和Controller通讯的。关于Notification，我写了一个模版代码片段如下:（关于代码片段的管理，推荐大家看我写的另一篇文章：[使用Github来管理xcode4中的代码片段](http://blog.devtang.com/blog/2012/02/04/use-git-to-manage-code-snippets/)

``` objc
// 监听通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(<#methodName#>) name:kLoginNotification object:nil];
// 取消监听
[[NSNotificationCenter defaultCenter] removeObserver:self];
// 发送通知
NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:200] forKey:@"code"];
[[NSNotificationCenter defaultCenter] postNotificationName:<#notification_name#> object:self userInfo:userInfo];
```

所以，对于初学者，要正确地使用MVC模式还是挺难的，回想我们以前做公司某产品iphone版的时候，就有一些Model层直接依赖了Controller层，比如Model层更新数据失败了，直接调用Controller层显示出一个失败的提示界面。这样层次划分不清，造成我们做ipad版的时候很痛苦。最后我们做了代码重构，把Model的相应改变都用Notification来完成，使得在做ipad版开发时轻松了很多。


###Convention About synthesize
“Convention over configuration"（约定高于配置）成就了Ruby On Rails，而iOS也有很多编程的约定。这些约定单独看没有什么好处，约定的最大好处就是，如果大家都遵守它，那么代码风格会趋于一致，你会很方便地读懂或修改别人的代码。

我们可以从第一课PPT的第50页看到如下的代码：

{% img /images/synthesize_convention.jpg %}

从图中可以看到，该课程推荐大家在使用synthesize关键字时，为property设置一个下划线前缀。我也看过一些iphone的开源项目，比如facebook开源的 [three20](https://github.com/facebook/three20/) ，它是遵守了这样的约定的。

其它的约定还包括：

* 以new, copy, alloc开头的方法，都应当由调用者来release，而其它方法，都返回一个autorelease对象。
* 通常iphone顶部的bar应该用UINavigation控件，而底部的bar应该用UIToolbar控件。
* 所有的UI操作都应该在主线程(UI线程)进行。这个似乎不是约定，但是好多同学不知道，也写在这儿吧。


### UIView
刚开始对界面之间的跳转很不理解，后来发现其实很简单，就是一层一层叠起来的View。从View A上点击一个按钮跳转到View B，其实就是把View B“盖”在View A上面而已。
而“盖”的方式有好多种，通常的方法有2种：

 一. 用UINavigationController把View B push进来。
``` objc
[self.navigationController pushViewController:nextView animated:YES]; 
```

 二. 用presentModalViewController方法把View B盖在上面。

``` objc
[self presentModalViewController:nextView animated:YES];
```

除此之外，其实还有一种山寨方法，即把View A和View B都用addSubView加到AppDelegate类的self.window上。然后就可以调用 bringSubviewToFront 把 View B显示出来了，如下所示：
``` objc
// AppDelegate.m类
[self.window addSubview:viewB];
[self.window addSubview:viewA];
// 在需要时调用
[self.window bringSubviewToFront:viewB];
```

上面说的是界面之间的跳转。对于一个界面内，其控件的布局其实也是一个一个叠起来的，之所以说叠，是指如果2个控件如果有重叠部分，那么处于上面的那个控件会盖住下面的。

### Nib File
Nib文件实际上内部格式是XML，而它本身并不编译成任何二进制代码。所以你如果用iFile之类的软件在iPhone上查看一些安装好的软件的目录，可以看到很多的以nib结尾的文件，这些就是该软件的界面文件。虽然这些XML经过了一些压缩转换，但是我们还是可以看到一些信息，例如它使用了哪些系统控件等。

Nib文件刚开始给我的感觉很神秘，后来发现它其实就是用于可视化的编辑View类用的。其中的 File's Owner一栏，用于表示这个View对应的Controller类。通常情况下，Controller类会有一个名为view的变量，指向这个view的实例，我们也可以建立多个IBOutlet变量，指向这个view上的控件，以便做一些界面上的控制。

在Interface Builder上还有一个好处，是可以方便的将View的事件与Controller的IBAction绑定。只需要按住Ctrl键，从控件往File's Owner一栏拖拽，即可看到可以绑定的方法列表。其实这些只是简化了我们的工作，如果完全抛开Interface Builder，我们一样可以完成这些工作。我所知道业界的一些iOS开发部门，为了多人协作更加方便，更是强制不允许使用Interface Builder，一切界面工作都在代码中完成。如果你用文本编辑器打开Nib文件看过，就能理解这样做是有道理的。因为如果2个同时编辑一个界面文件，那么冲突的可能性是100%，而且，从svn结出的冲突信息上看，你根本无法修正它。下面的代码演示了如何不用Interface Builder来添加控件以及绑定UI事件。

``` objc
// SampleViewController.m的viewDidLoad方法片段
// 添加Table View控件
UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
[self.view addSubview:tableView];
tableView.delegate = self;
[tableView release];
// 添加Button控件
self.button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)] autorelease];
[self.view addSubview:self.button];
// 绑定事件
[self.button addTarget:self action:@selector(buttonPressed) forControlEvents:(UIControlEventTouchUpInside)];
```

###总结
总体来讲，学习iOS开发还是比较容易的。我大概花了一个月时间学习iPhone开发，就可以边做边学了。

苹果的设计对于开发者来说是非常友好的，很多时候使用相应的控件就行了，都不用操心底层细节。不象Android开发，一会儿要考虑不同手机分辨率不一样了，一会儿又要考虑有些不是触摸屏了，一会儿又发现某款手机的cpu内存太弱了跑不起来，需要优化程序。另外，Objective-C相对于C++语言来说，要简单优雅得多，而且更加强大，所以做iOS的开发者很省心。

要说到不爽的地方，就是iOS开发相关的中文资料实在是太少了。要学习它，基本上需要查看苹果的官方英文文档以及WWDC大会视频，还有去[stackoverflow](http://www.stackoverflow.com)上问问题。这对于英文不太好的同学这可能是一个障碍。不过反过来，习惯之后，通过这个锻炼了自己的英文水平，倒也是一大收获。
