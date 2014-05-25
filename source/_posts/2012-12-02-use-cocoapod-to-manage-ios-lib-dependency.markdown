---
layout: post
title: "用CocoaPods做iOS程序的依赖管理"
date: 2014-05-25 14:09
comments: true
categories: iOS
---

{% img /images/cocoapods-logo.png %}

## 文档更新说明

 * 2012-12-02 v1.0 初稿
 * 2014-01-08 v1.1 增加设置ruby淘宝源相关内容
 * 2014-05-25 v2.0 增加国内spec镜像、使用私有pod、podfile.lock、创建spec文件等内容

## CocoaPods简介

每种语言发展到一个阶段，就会出现相应的依赖管理工具，例如Java语言的Maven，nodejs的npm。随着iOS开发者的增多，业界也出现了为iOS程序提供依赖管理的工具，它的名字叫做：[CocoaPods](http://cocoapods.org/)。

CocoaPods[项目的源码](https://github.com/CocoaPods/CocoaPods)在Github上管理。该项目开始于2011年8月12日，经过多年发展，现在已经成为iOS开发事实上的依赖管理标准工具。开发iOS项目不可避免地要使用第三方开源库，CocoaPods的出现使得我们可以节省设置和更新第三方开源库的时间。

在我开发猿题库客户端时，其使用了24个第三方开源库。在没有使用CocoaPods以前，我需要:

 1. 把这些第三方开源库的源代码文件复制到项目中，或者设置成git的submodule。
 1. 对于这些开源库通常需要依赖系统的一些framework，我需要手工地将这些framework一一增加到项目依赖中，比如通常情况下，一个网络库就需要增加以下framework: CFNetwork, SystemConfiguration, MobileCoreServices, CoreGraphics, zlib。
 1. 对于某些开源库，我还需要设置`-licucore`或者 `-fno-objc-arc`等编译参数
 1. 管理这些依赖包的更新。
 
这些体力活虽然简单，但毫无技术含量并且浪费时间。在使用CocoaPods之后，我只需要将用到的第三方开源库放到一个名为Podfile的文件中，然后执行`pod install`。CocoaPods就会自动将这些第三方开源库的源码下载下来，并且为我的工程设置好相应的系统依赖和编译参数。

## CocoaPods的安装和使用介绍

###安装

安装方式异常简单, Mac下都自带ruby，使用ruby的gem命令即可下载安装：

``` bash
$ sudo gem install cocoapods
$ pod setup
```

如果你的gem太老，可能也会有问题，可以尝试用如下命令升级gem:

``` bash
sudo gem update --system
```

另外，ruby的软件源rubygems.org因为使用的亚马逊的云服务，所以被墙了，需要更新一下ruby的源，如下代码将官方的ruby源替换成国内淘宝的源：

```
gem sources --remove https://rubygems.org/
gem sources -a http://ruby.taobao.org/
gem sources -l
```

还有一点需要注意，`pod setup`在执行时，会输出`Setting up CocoaPods master repo`，但是会等待比较久的时间。这步其实是Cocoapods在将它的信息下载到 `~/.cocoapods`目录下，如果你等太久，可以试着cd到那个目录，用`du -sh *`来查看下载进度。你也可以参考本文接下来的`使用cocoapods的镜像索引`一节的内容来提高下载速度。

### 使用CocoaPods的镜像索引

所有的项目的Podspec文件都托管在`https://github.com/CocoaPods/Specs`。第一次执行`pod setup`时，CocoaPods会将这些`podspec`索引文件更新到本地的 `~/.cocoapods/`目录下，这个索引文件比较大，有80M左右。所以第一次更新时非常慢，笔者就更新了将近1个小时才完成。

一个叫[akinliu](http://akinliu.github.io/2014/05/03/cocoapods-specs-/)的朋友在[gitcafe](http://gitcafe.com/)和[occhina](http://www.oschina.net/)上建立了CocoaPods索引库的镜像，因为gitcafe和occhina都是国内的服务器，所以在执行索引更新操作时，会快很多。如下操作可以将CocoaPods设置成使用gitcafe镜像：

``` bash

pod repo remove master
pod repo add master https://gitcafe.com/akuandev/Specs.git
pod repo update

```

将以上代码中的 `https://gitcafe.com/akuandev/Specs.git` 替换成 `http://git.oschina.net/akuandev/Specs.git` 即可使用occhina上的镜像。

###使用CocoaPods

使用时需要新建一个名为Podfile的文件，以如下格式，将依赖的库名字依次列在文件中即可

```
platform :ios
pod 'JSONKit',       '~> 1.4'
pod 'Reachability',  '~> 3.0.0'
pod 'ASIHTTPRequest'
pod 'RegexKitLite'
```

然后你将编辑好的Podfile文件放到你的项目根目录中，执行如下命令即可：

``` bash
cd "your project home"
pod install
```

现在，你的所有第三方库都已经下载完成并且设置好了编译参数和依赖，你只需要记住如下2点即可：

 1. 使用CocoaPods生成的 *.xcworkspace 文件来打开工程，而不是以前的 *.xcodeproj 文件。
 2. 每次更改了Podfile文件，你需要重新执行一次`pod update`命令。

###查找第三方库

你如果不知道cocoaPods管理的库中，是否有你想要的库，那么你可以通过pod search命令进行查找，以下是我用pod search json查找到的所有可用的库：

``` bash
$ pod search json

-> AnyJSON (0.0.1)
   Encode / Decode JSON by any means possible.
   - Homepage: https://github.com/mattt/AnyJSON
   - Source:   https://github.com/mattt/AnyJSON.git
   - Versions: 0.0.1 [master repo]


-> JSONKit (1.5pre)
   A Very High Performance Objective-C JSON Library.
   - Homepage: https://github.com/johnezang/JSONKit
   - Source:   git://github.com/johnezang/JSONKit.git
   - Versions: 1.5pre, 1.4 [master repo]

// ...以下省略若干行

```

###关于.gitignore

当你执行`pod install`之后，除了Podfile外，CocoaPods还会生成一个名为`Podfile.lock`的文件，你不应该把这个文件加入到`.gitignore`中。因为`Podfile.lock`会锁定当前各依赖库的版本，之后如果多次执行`pod install` 不会更改版本，要`pod update`才会改`Podfile.lock`了。这样多人协作的时候，可以防止第三方库升级时造成大家各自的第三方库版本不一致。

CocoaPods的这篇[官方文档](http://guides.cocoapods.org/using/using-cocoapods.html#should-i-ignore-the-pods-directory-in-source-control)也在`What is a Podfile.lock`一节中介绍了`Podfile.lock`的作用，并且指出：

{% blockquote %}

This file should always be kept under version control.

{% endblockquote %}

##为自己的项目创建podspec文件

我们可以为自己的开源项目创建`podspec`文件，首先通过如下命令初始化一个`podspec`文件：

```
pod spec create your_pod_spec_name
```

该命令执行之后，CocoaPods会生成一个名为`your_pod_spec_name.podspec`的文件，然后我们修改其中的相关内容即可。

具体步骤可以参考这两篇博文中的相关内容：[《如何编写一个CocoaPods的spec文件》](http://ishalou.com/blog/2012/10/16/how-to-create-a-cocoapods-spec-file/) 和[《Cocoapods 入门》](http://studentdeng.github.io/blog/2013/09/13/cocoapods-tutorial/)。

##使用私有的pods

我们可以直接指定某一个依赖的`podspec`，这样就可以使用公司内部的私有库。该方案有利于使企业内部的公共项目支持CocoaPods。如下是一个示例：

``` bash
pod 'MyCommon', :podspec => 'https://yuantiku.com/common/myCommon.podspec'
```

## 不更新podspec

CocoaPods在执行`pod install`和`pod update`时，会默认先更新一次`podspec`索引。使用`--no-repo-update`参数可以禁止其做索引更新操作。如下所示：

```
pod install --no-repo-update
pod update --no-repo-update
```

###生成第三方库的帮助文档

如果你想让CococaPods帮你生成第三方库的帮助文档，并集成到Xcode中，那么用brew安装appledoc即可：

``` bash
brew install appledoc
```

关于appledoc，我在另一篇博客[《使用Objective-C的文档生成工具:appledoc》](http://blog.devtang.com/blog/2012/02/01/use-appledoc-to-generate-xcode-doc/)中有专门介绍。它最大的优点是可以将帮助文档集成到Xcode中，这样你在敲代码的时候，按住opt键单击类名或方法名，就可以显示出相应的帮助文档。

##原理

大概研究了一下CocoaPods的原理，它是将所有的依赖库都放到另一个名为Pods项目中，然后让主项目依赖Pods项目，这样，源码管理工作都从主项目移到了Pods项目中。发现的一些技术细节有：

 1. Pods项目最终会编译成一个名为libPods.a的文件，主项目只需要依赖这个.a文件即可。
 2. 对于资源文件，CocoaPods提供了一个名为Pods-resources.sh的bash脚本，该脚本在每次项目编译的时候都会执行，将第三方库的各种资源文件复制到目标目录中。
 3. CocoaPods通过一个名为Pods.xcconfig的文件来在编译时设置所有的依赖和参数。

愿大家玩得开心～
