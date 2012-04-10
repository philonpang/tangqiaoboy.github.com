---
layout: post
title: "关于UIWebView和PhoneGap的总结"
date: 2012-03-24 20:19
comments: true
categories: iOS javascript
---

## 前言
今天参加了Adobe和CSDN组织的一个关于[PhoneGap的开发讲座](http://hui.csdn.net/MeetingInfo.aspx?mid=99) ，而PhoneGap在iOS设备上的实现就是通过UIWebView控件来展示html内容，并且与native代码进行交互的。

正好我们在做有道云笔记的iPad版，因为我们也是使用UIWebView来展示笔记内容，所以也需要做js与native代码相互调用的事情。所以在这儿顺便总结一下UIWebView在使用上的细节，以及谈谈我对PhoneGap的看法。

<!-- more -->

## 机制
首先我们需要让UIWebView加载本地HTML。使用如下代码完成：

``` objc
    NSString * path = [[NSBundle mainBundle] bundlePath];
    NSURL * baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString * htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:(NSUTF8StringEncoding) error:nil];
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
```

接着，我们需要让js能够调用native端。iOS SDK并没有原生提供js调用native代码的API。但是UIWebView的一个delegate方法使我们可以做到让js需要调用时，通知native。在native执行完相应调用后，可以用stringByEvaluatingJavaScriptFromString方法，将执行结果返回给js。这样，就实现了js与native代码的相互调用。

以下是PhoneGap相关调用的示例代码：

``` objc
// Objective-C语言
- (BOOL)webView:(UIWebView *)webView 
    shouldStartLoadWithRequest:(NSURLRequest *)request 
    navigationType:(UIWebViewNavigationType)navigationType {
       NSURL * url = [request URL];
       if ([[url scheme] isEqualToString:@"gap"]) {
            // 在这里做js调native的事情
            // ....
            // 做完之后用如下方法调回js
            [webView stringByEvaluatingJavaScriptFromString:@"alert('done')"];
            return NO;
        }       
        return YES;
}
```

具体让js通知native的方法是让js发起一次特殊的网络请求。这里，我们和PhoneGap都是使用加载一个隐藏的iframe来实现的，通过将iframe的src指定为一个特殊的URL，实现在delegate方法中截获这次请求。

以下是PhoneGap相关调用的示例代码：

```
// Javascript语言
// 通知iPhone UIWebView 加载url对应的资源
// url的格式为: gap:something
function loadURL(url) {
    var iFrame;
    iFrame = document.createElement("iframe");
    iFrame.setAttribute("src", url);
    iFrame.setAttribute("style", "display:none;");
    iFrame.setAttribute("height", "0px");
    iFrame.setAttribute("width", "0px");
    iFrame.setAttribute("frameborder", "0");
    document.body.appendChild(iFrame);
    // 发起请求后这个iFrame就没用了，所以把它从dom上移除掉
    iFrame.parentNode.removeChild(iFrame);
    iFrame = null;
}
```

在这里，可能有些人说，通过改document.location也可以达到相同的效果。关于这个，我和zyc专门试过，一般情况下，改document.location是可以，但是改document.location有一个很严重的问题，就是如果我们连续2个js调native，连续2次改document.location的话，在native的delegate方法中，只能截获后面那次请求，前一次请求由于很快被替换掉，所以被忽略掉了。

我也专门去Github上查找相关的开源代码，它们都是用过iframe来实现调用的，例如这个：<https://github.com/marcuswestin/WebViewJavascriptBridge>

关于这个，我也做了一个Demo来简单示例，地址如下：<https://github.com/tangqiaoboy/UIWebViewSample>


## 参数的传递
以上的示例代码为了讲清楚机制，所以只是示例了最简单的相互调用。但实际上js和native相互调用时，常常需要传递参数。

例如，有道云笔记iPad版用UIWebView显示笔记的内容，当用户点击了笔记中的附件，这个时候，js需要通知native到后台下载这个笔记附件，同时通知js当前的下载进度。对于这个需求，js层获得用户点击事件后，就需要把当前点击的附件的ID传递给native，这样native才能知道下载哪个附件。

参数传递最简单的方式是将参数作为url的一部分，放到iFrame的src里面。这样UIWebView通过截取分析url后面的内容即可获得参数。但是这样的问题是，该方法只能传递简单的参数信息，如果参数是一个很复杂的对象，那么这个url的编解码将会很复杂。对此，我们的有道云笔记和PhoneGap采用了不同的技术方案。

 * 我们的技术方案是将参数以JSON的形式传递，但是因为要附加在url之后，所以我们将JSON进行了Base64编码，以保证url中不会出现一些非法的字符。
 * PhoneGap的技术方案是，也是用JSON传递参数，但是将JSON放在UIWebView中的一个全局数组中，UIWebView当需要读取参数时，通过读取这个全局数组来获得相应的参数。

相比之下，应该说PhoneGap的方案更加全面，适用于多种场景。而我们的方案简洁高效，满足了我们自己产品的需求。


## 同步和异步
因为iOS SDK没有天生支持js和native相互调用，大家的技术方案都是自己实现的一套调用机制，所以这里面有同步异步的问题。细心的同学就能发现，js调用native是通过插入一个iframe，这个iframe插入完了就完了，执行的结果需要native另外用stringByEvaluatingJavaScriptFromString方法通知js，所以这是一个异步的调用。

而stringByEvaluatingJavaScriptFromString方法本身会直接返回一个NSString类型的执行结果，所以这显然是一个同步调用。

所以js call native是异步，native call js是异步。在处理一些逻辑的时候，不可避免需要考虑这个特点。

这里顺便说一个android，其实在android开发中，js调native是同步的，但是PhoneGap为了将自己做成一个跨平台的框架，所以在android的js call native的native端，用 new Thread新建了一个执行线程，这样把android的js call native也变成了异步调用。

## UIWebView的问题

### 线程阻塞问题
我们在开发中发现，当在native层调用stringByEvaluatingJavaScriptFromString方法时，可能由于javascript是单线程的原因，会阻塞原有js代码的执行。这里我们的解决办法是在js端用defer将iframe的插入延后执行。

### 主线程的问题
UIWebView的stringByEvaluatingJavaScriptFromString方法必须是主线程中执行，而主线程的执行时间过长就会block UI的更新。所以我们应该尽量让stringByEvaluatingJavaScriptFromString方法执行的时间短。

有道云笔记在保存的时候，需要调用js获得笔记的完整html内容，这个时候如果笔记内容很复杂，就会执行很长一段时间，而因为这个操作必须是主线程执行，所以我们显示“正在保存”的UIAlertView完全无法正常显示，整个UI界面完全卡住了。在新的编辑器里，我们更新了获得html内容的代码，才将这个问题解决。

### 键盘控制
做iOS开发的都知道，当我们需要键盘显示在某个控件上时，可以调用[obj becomeFirstResponder]方法来让键盘出来，并且光标输入焦点出现在该控件上。

但是这个方法对于UIWebView并不可用。也就是说，我们无法通过程序控制让光标输入焦点出现在UIWebView上。
关于这个问题，我在stackoverflow上专门[问了一下](http://stackoverflow.com/questions/9835956/show-keyboard-in-contenteditable-uiwebview-programmatically)，还是没有得到很好的解决办法。

### CommonJS规范
commonJS是一个模块块加载的规范。而AMD是该规范的一个草案，CommonJS AMD规范描述了模块化的定义，依赖关系，引用关系以及加载机制，其规范原文在[这里](http://wiki.commonjs.org/wiki/Modules/AsynchronousDefinition) 。它被requireJS，NodeJs，Dojo，jQuery等开源框架广泛使用。[这里](http://blog.csdn.net/dojotoolkit/article/details/6076668)还有一篇不错的中文介绍文章。

AMD规范需要用目录层级当作包层次，这一点就象java一样。之前我以为iOS打包后的ipa资源文件中不能有资源目录层级关系，今天在会上问了一下，原来是我自己弄错了。如果需要将目录层级带入ipa资源文件中，只需要将该目录拖入工程中，然后选择“Create groups for any added folders”。如下图所示，这样目录层级能够打包到ipa文件中。

{% img /images/uiwebview-commonjs-folder.jpg %}

## 调试
在iOS设备中调试javascript是一件相当苦逼的事情，拿pw的话来说：“一下子回到了ie6时代”。当然，业界也有一些调试工具可以用的。

我们在开发时主要采用的是[weinre](http://phonegap.github.com/weinre/)这个框架。用这个框架，可以做一些基本的调试工作，但是它现在功能还没有象pc上的js调试器那么强大，例如它不能下断点，另外如果有js执行错误，它也无法正确的将错误信息报出。它还有一些bug，例如在mac机下，如果你同时连接了有线网和无线网，那么weinre将无法正确地连接到调试页面。

但终究，它是现在业界现存的唯一相对可用的调试工具了。本次的PhoneGap讲座的第一位演讲者董龙飞有一篇博客很好地介绍了weinre的使用，地址是[这里](http://www.donglongfei.com/2012/03/debug-phonegap-app-using-weinre/)，推荐感兴趣的同学看看。即使不用PhoneGap，weinre也能给你在移动设备上设计网页带来方便。

## 我对PhoneGap的看法
今天的大会上，2位演讲者把PhoneGap吹得相当牛。但是其实真正用过的人才能知道，PhoneGap还是有相当多的问题的。至少我知道在网易就有一个使用PhoneGap而失败的项目，所以我认为PhoneGap还是有它相当大的局限性的。

我认为PhoneGap有以下3大问题：

 1. 首先，PhoneGap的编程语言其实是javascript，这对于非前端工作者来说，其实学习起来和学习原生的objective-C或Java编程语言难度差不多，而且由于历史原因，javascript语言本身的问题比其它语言都多。要想精通javascript，相当不易。

 2. 然后，PhoneGap的目标是方便地创建跨平台的应用。但是其实苹果和google都发布了自己的人机交互指南。有些情况下，苹果的程序和android程序有着不同的交互原则的。象有道云笔记的[iPhone版](http://itunes.apple.com/us/app/id450748070?ls=1&mt=8)和[android版](http://m.note.youdao.com/noteproxy/download?todo=download&platform=android&keyfrom=note.web)，就有着完全不同的界面和交互。使用PhoneGap就意味着你的程序在UI和交互上，既不象原生的iphone程序，又不象原生的android程序。

 3. 最后，性能问题。Javascript终究无法和原生的程序比运行效率，这一点在当你要做一些动画效果的时候，就能显现得很明显。

当然，PhoneGap的优势也很明显，如果你是做图书类，查询类，小工具类应用的话，这些应用UI交互不复杂，也不占用很高的cpu资源，PhoneGap将很好地发挥出它的优势。对于这类应用：

 1. 你只需要编写一次，则可以同时完成iOS, android, windows phone等版本的开发。

 2. 如果改动不大，只是内容升级，那它升级时只需要更新相应的js文件，而不需要提交审核，而一般正常提交苹果的app store审核的话，常常需要一周时间。

所以PhoneGap不是万能的，但也不是没有用，它有它擅长的领域，一切都看你是否合理地使用它。

最后，推荐[PhoneGap中国网站](http://www.phonegap.cn/) ，在这里，你可以找到为数不多的中文资料。也推荐本次PhoneGap的演讲者[董龙飞的微博](http://weibo.com/donglongfei)， 它是Adobe中国平台技术经理，应该能为你解答不少关于PhoneGap的问题。

## 对js的感想
现在前端工程师相当牛逼啊。前端工程师不但可以写前端网页，还可以用Flex写桌面端程序，可以用nodejs写server端程序，可以用PhoneGap写移动端程序，这一切，都是基于javascript语言的，还有最新出的windows 8，原生支持用js来写Metro程序，世界已经无法阻止前端工程师了。



