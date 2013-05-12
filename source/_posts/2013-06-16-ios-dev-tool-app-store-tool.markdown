---
layout: post
title: "iOS开发工具篇-AppStore统计工具"
date: 2013-06-16 12:26
comments: true
categories: iOS iOSDevTool
---

本文首发于InfoQ，本文版权归InfoQ所有，转载请保留[原文链接](http://www.infoq.com/cn/articles/appstore-statistical-tool)。

## 前言

随着iOS开发的流行，针对iOS开发涉及的方方面面，早有一些公司提供了专门的解决方案或工具。这些解决方案或工具包括：用户行为统计工具（友盟，Flurry，Google Analytics等),  App Store销售分析工具（例如App annie)， App crash收集工具（例如Crashlytics)，App测试发布工具（Test Flight）, App Push服务等。

这些解决方案或工具节省了iOS开发者大量的开发时间，但是由于相关介绍文章的缺乏，许多开发者都在重复着自己一次又一次重新造轮子。所以我希望，将我自己使用和调研的相关的第三方服务使用经验，整理成一系列文章，以便广大开发者能够省去大量的重复性工作。

今天介绍AppStore统计工具：App Annie和苹果的命令行统计工具。

<!-- more -->

## App Annie介绍

{% img /images/app-annie-homepage.jpg %}

苹果官方的iTunes Connect提供的销售数据统计功能比较弱，例如只能保存最近30天的详细销售数据，界面丑陋，
无法查看App的排名历史变化情况等。

[AppAnnie](http://www.appannie.com/)是一个专门为开发者提供的，针对AppStore相关数据的统计分析工具。
该工具可以统计App在AppStore的下载量，排名变化，销售收入情况以及用户评价等信息。

### 原理
AppAnnie实现的原理是：通过你配置的管理账号，向itunes connect请求获得你的App的相关数据，包括每日下载量，用户的评分数据，以及销售数据。

### 注册Sales类型的账号

使用AppAnnie，首先需要在苹果官方的itunes connect中配置一个Sales类型的账号。
因为默认的开发者账号是Admin级的权限，该权限是非常高的，可以修改App的价格或者直接下架商品。
如果将这个账号直接配置在AppAnnie中，虽然不影响其获得相关数据，但是有一定的账号安全风险。

配置该账号的详细步骤如下：

1、登录itunes connect，选择Manager Users

{% img /images/itunes-connect-add-user-1.jpg %}

2、选择iTunes Connect User

{% img /images/itunes-connect-add-user-2.jpg %}

3、点击Add new User

{% img /images/itunes-connect-add-user-3.jpg %}

4、填写新用户的相关信息

{% img /images/itunes-connect-add-user-4.jpg %}

5、勾选用户类型为Sales

{% img /images/itunes-connect-add-user-5.jpg %}

6、选择Notifications为All Notifications。点击图中所指的位置即可全选。

{% img /images/itunes-connect-add-user-6.jpg %}

7、之后，邮箱中会收到iTunes Connect发来的激活邮件。
点击邮件中的激活链接，即可进入到账号注册界面，之后注册账号即可激活。如果该邮箱已经注册过Apple Id，则会进入到登录界面，登录后即可激活。

{% img /images/itunes-connect-add-user-7.jpg %}


## 注册 App Annie账号及配置

打开App Annie的官方网站:<http://www.appannie.com/>，
注册步骤和一般网站的步骤一样，我就不介绍了，注册完成之后的配置步骤如下：

1、在设置页面中增加iTunes Connect账号

{% img /images/app-annie-1.jpg %}

2、填写你的之前在iTunes Connect中增加的Sales类型的账号及密码

{% img /images/app-annie-2.jpg %}

3、在User Setting中勾选上接收每日Report

{% img /images/app-annie-3.jpg %}

4、这样，每天就可以收到AppAnnie发来的相关统计邮件了。如下是一封粉笔网的销售报告邮件截图：

{% img /images/app-annie-4.jpg %}


## 官方的命令行工具

如果你觉得将自己的销售数据交给第三方统计服务商，有一些不太安全。可以考虑使用苹果官方提供的Autoingestion.class工具来获得每天的销售数据，然后存到本地的数据库中。

该工具的下载地址是[这里](http://www.apple.com/itunesnews/docs/Autoingestion.class.zip)，
苹果对于该用户的帮助文档在[这里](http://www.apple.com/itunesnews/docs/AppStoreReportingInstructions.pdf)。

下面介绍一下这个工具的使用，将Autoingestion.class下载下来后，切换到class文件所在目录，执行如下命令，即可获得对应的统计数据：

```
java Autoingestion <帐号名> <密码> <vendorId> <报告类型> <时间类型> <报告子类型> <时间>
```

其中vendor Id在iTunes Connect的如下图所示位置获得，是一个数字8开头的序列。

{% img /images/itunes-connect-vendor-id.jpg %}

<报告类型>可选的值是：Sales 或 Newsstand

<时间类型>可选的值是：Daily, Weekly, Monthly 或 Yearly

<报告子类型>可选的值是：Summary, Detailed 或 Opt-In

<时间>以如下的格式给出：YYYYMMDD

以下是一个示例，它将获得2013年5月8日的日销售摘要数据。

```
java Autoingestion username@fenbi.com password 85587619 Sales Daily Summary 20130508
```

我试用了一下该工具，觉得还是太糙了一些，仅仅能够将销售数据备份下来，如果要做AppAnnie那样的统计报表，还需要写不少代码。而且，该工具并不象App Annie那样，还提供应用在App Store的排名变化情况。虽然可以自己再做抓取，但也是需要工作量的。

## 其它类似App Annie的服务

类似App Annie这样的服务还有：[AppFigures](http://appfigures.com)。我试用过之后，发现它不如App Annie功能强大。不过作为一个替代方案，也一并介绍给大家。

在Github上也有一些开源的[统计工具](https://github.com/alexvollmer/itunes-connect)，感兴趣的朋友也可以尝试一下。这些工具基本上也就是对苹果的命令行工具的增强，例如增加了将数据导入到数据库中等功能。

## 功能对比

App Annie和苹果本身提供的命令行工具虽然都能统计App Store的数据，但是二者功能相差悬殊。苹果的命令行工具仅仅能提供销售数据的按日、周、月、年等方式的统计和备份。而App Annie除了以更加良好的界面和交互提供这些功能外，还能跟踪App的排名变化，以及App在苹果的各种榜单中所处位置的情况。

建议大家都可以尝试使用App Annie或AppFigures这类统计工具，帮助你方便地查看App的销售和排名情况。






