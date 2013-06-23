---
layout: post
title: "分析支付宝客户端的插件机制"
date: 2013-06-23 12:39
comments: true
categories: iOS
---

{% img /images/alipay-plugin-1.jpg %}

## 前言

因为开了iOSDevTips的微信公共账号，老收到各种iOS开发的问题，前两天收到一个问题的内容是：

    请问像支付宝钱包那样可以在应用里安装自己的应用，是已经在应用里写了逻辑，还是可以向应用里发送代码?

我觉得这个问题挺有意思的，估计大家都感兴趣，所以今天就抽空研究了一下，将支付宝客户端的插件机制具体实现方式介绍给大家。

先介绍一下该插件机制，如上图所示，支付宝客户端在安装后，对于像“彩票”、“爱心捐赠”这类功能，需要再点击安装一次，然后才可以使用。有些时候该插件功能进行了升级，需要点击升级才可以继续使用。插件的方式有利于软件动态增加新的功能或升级功能，而不用再一次向AppStore提交审核。另外，由于用户不需要的插件可以不用安装，也缩小了应用本身的体积大小，节省了下载流量。

<!-- more -->

## 分析过程

###截取网络请求

分析第一步，截取网络请求。截取网络请求可以查看当用户点击“彩票”进行安装的时候，客户端到底做了什么事情。使用Charles的代理设置功能，启动一个http代理，然后在iPhone上设置连接此代理，则可以看到，当点击“彩票”插件时，客户端下载了一个名为 10000011.amr的文件。如下图所示：

{% img /images/alipay-plugin-2.jpg %}

###下载插件文件

尝试用wget将文件下载下来，发现其没有验证cookie，下载成功，命令如下：

``` bash
wget http://download.alipay.com/mobilecsprod/alipay.mobile/20130601021432806/xlarge/10000011.amr
```

amr本意表示是一个音频文件，明显不对，尝试将其后缀名改成zip，成功将其解压。用itools连接上支付宝的客户端，同样能看到客户端将其下载后，也是解压到document目录下的。解压后的内容与应用内新增加的内容一致，如图所示：

{% img /images/alipay-plugin-3.jpg %}

###分析文件内容

大概浏览了一下解压后的文件，主要包括html、css和js文件。可见支付宝的插件机器是通过UIWebView来展示内容的方式来实现的，那为什么要先下载安装这些内容而不通过UIWebView实时下载html呢？这主要应该是为了节省相应的流量。我看了一下，10000011.amr文件整个有将近1M大小，如果不通过插件机制预先下载，则只能依赖系统对于UIWebView的缓存来节省流量，这相对来说没有前者靠谱。

另外，使用基于UIWebView的方式来展示插件，也有利于代码的复用。因为这些逻辑都是用js来写的，可以同样应用于Android平台，在Config.js文件中，明显可以看到对于各类平台的判断逻辑。如下图所示：

{% img /images/alipay-plugin-4.jpg %}

另外，/www/demo/index-alipay-native.html 文件即该插件的首页，用浏览器打开就可以看到和手机端一样的内容。如下载图所示（左半边是手机上的应用截图，右半边是浏览器打开该html文件的截图）：

{% img /images/alipay-plugin-5.jpg %}

###插件的网络通讯

接下来感兴趣的是该插件是如何完成和支付宝后台的网络通讯的。可以想到有两种可能的方式：

 1. 直接和支付宝后台通讯
 2. 和Native端通讯，然后Native端和服务器通讯。

要验证这个需要读该插件的js源代码，整个js源码逻辑还是比较干净的，主要用了玉伯写的[seajs](http://seajs.org/docs/)做模块化加载，[backbone.js](http://backbonejs.org/)是一个前端的MVC框架，[zepto.js](http://zeptojs.com/)是一个更适合于移动端使用的"JQuery"。

大概扫了一下，感觉更可能是用的方法一：直接和支付宝后台通讯, 因为Config.js中都明确将网络通讯的地址写下来了。另一个证据是，利用下面的脚本扫描整个js源码，只能在backbone中搜到对于iframe的使用。而在iOS开发中，如果js端和native端要通讯，是需要用到iframe的，详细原理可以参见我的另一篇文章[《关于UIWebView和PhoneGap的总结》](http://blog.devtang.com/blog/2012/03/24/talk-about-uiwebview-and-phonegap/)。不过我不能完全确认，因为我还没有找到相应控制页面切换和跳转的js代码，如果你找到了，麻烦告诉我。

``` bash
find . -type f -name "*.js" | xargs grep "iframe"
```

###交易的安全

用Charles可以截取到，当有网络交易时，应用会另外启动一个https的安全链接，完成整个交易过程的加密。如下图所示：

{% img /images/alipay-plugin-6.jpg %}

##总结

支付宝的插件机制整体上就是通过html和javascript方式实现的，主要的好处是：

 1. 跨平台(可以同时用在iOS和Android客户端）
 2. 省流量（不需要的插件不用下载，插件本地缓存长期存在不会过期，自己管理插件更新逻辑）
 3. 更新方便（不用每次提交AppStore审核）

坏处如果非要说有的话，就是用javascript写iOS界面，无法提供非常炫的UI交互以及利用到iOS的所有平台特性。不过象支付宝这种工具类应用，也不需要很复杂的UI交互效果。

另外教大家一个小技巧，如果你不确定某个页面是不是UIWebView做的，直接在那个页面长按，如果弹出"拷贝，定义，学习"这种菜单，那就是确定无疑是UIWebView的界面了。如下图所示：

{% img /images/ios-menu-2.jpg %}

##相关工具

欢迎关注我的技术微博 [@唐巧_boy](http://weibo.com/tangqiaoboy) 和微信公共账号 [iOSDevTips](http://chuansong.me/account/iosDevTips) ，每天收获一些关于iOS开发的学习资料和技巧心得。

我在研究时使用了[Charles](http://www.charlesproxy.com/)来截获支付宝客户端的网络请求，用[iTools](http://itools.hk/)来查看支付宝客户端的本地内容。如果你想自行验证本文内容，请先下载上述工具。在此就不额外介绍它们的使用了。
