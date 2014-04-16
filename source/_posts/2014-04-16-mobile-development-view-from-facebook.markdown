---
layout: post
title: "从Facebook看移动开发的发展"
date: 2014-04-16 20:37:59 +0800
comments: true
categories: iOS summary
---

{% img /images/facebook-logo.jpg %}

##从Facebook谈起

Facebook最近绝对是互联网界的新闻明星。它首先是进行了大手笔的收购：2014年2月，Facebook 以 160 亿美元现金加股票，以及30 亿美元受限制股票福利的方式[收购移动 IM 应用 WhatsApp](http://tech.ifeng.com/internet/special/fb-whatsapp/content-1/detail_2014_02/21/34032969_0.shtml)，总收购成本 190 亿美元。然后是继续发布了新产品：2014年2月，Facebook发布了一个新的移动端新闻阅读应用[Paper](https://www.facebook.com/paper)。最后，Facebook最近还将自己使用的大量工具开源，包括开源了Paper的加载效果[Shimmer](https://github.com/facebook/Shimmer)，LLDB的增强工具[chisel](https://github.com/facebook/chisel)，以及Key-Value Observing工具[KVOController](https://github.com/facebook/KVOController)，如果说这些开源工具让程序员如获至宝的话，那么Facebook将Paper的交互设计工具[Origami](http://facebook.github.io/origami/)免费开放，则是对广大设计师的福音，极大地方便了移动交互设计工作的开展。

2014年对于Facebook来说也是一个值得纪念的日子。因为从2004年2月4日Facebook产品上线到现在，Facebook刚刚走过10个年头。10年前，Facebook的创始人扎克伯格才19岁，是哈佛大学的一名学生。转眼间10年后，Facebook已经成长为全球最大的社交网络，月活跃用户达到12亿，市值约1200亿美元。

业界内大多讨论的话题都围绕在Facebook收购WhatsApp这件事情上，而作为一个移动开发者，我更加看重Facebook 发布Paper这件事情。因为Paper并不是一个简单的应用，它有着非常优秀的交互效果，并且在产品设计和技术上都使用了许多前沿的技术，那就让我们看看，Paper的开发到底有何不同之处？

##交互设计

我们首先从产品设计上看Paper的不同之处。Paper虽然只是一个新闻客户端，但从大家对Paper的评价上，我们发现优秀的交互再一次成为大家关注的焦点。回想那些成功的应用，大多都有着令人心动的交互效果，例如：Tweetie的下拉刷新，现在基本上成为iPhone上内容刷新的标准。Path跳出来的红心让人心动，很多朋友甚至会没事点那个红心，欣赏那流畅的按钮散开效果。还有Mailbox，用流畅的手势操作，将邮件管理与任务管理完美结合起来。

国外成功的优秀应用也在影响着国内。交互设计不同于平面设计，不能简单地用Photoshop展现，而交互设计对于移动应用的成功又异常关键，所以需要花费不少时间来设计，因此产品经理很难兼顾地做交互设计。所以，在国内的一线互联网公司里，交互设计师这个职位慢慢成了移动应用的标配。但是在大部分的非一线互联网公司里面，移动开发的设计仍然停留在由产品经理简单潦草的完成阶段。所以，Facebook这次Paper的成功发布，再一次给移动开发的从业者指出了交互设计的重要性。

回顾中国互联网产业的发展我们可以发现，产品经理（Product Manager）这个职位也是最近五、六年才成为互联网公司的标配的，想必在不远的将来，除着交互设计越来越重要，移动交互设计师也会成为每一个互联网公司重要的必备职位。

另一方面，由于工具的欠缺，大量的交互设计师的工作效率非常低下，他们为了做出一个新颖的效果常常需要花费大量精力。这次Facebook免费开放出基于苹果Quartz Composer的增强工具集[Origami](http://facebook.github.io/origami/)，使得交互设计工作得到更好的辅助。而且在Facebook的带动下，[jQC 1.0](http://qcdesigners.com/index.php/forums/topic/100/it-s-finally-here-j-qc-1-0-a-u/)也出现了。jQC是一个与Facebook之前开源的Origami兼容的工具，提供了15个新的Patch来提高Quartz Composer的功能。

不过另一方面，该工具仍然需要设计师具备一定的基础编码能力，所以对于广大设计师来说，交互设计工具Origami对设计师带来的既是机会，同时也是挑战。

## 移动开发技术

随着iOS依赖管理工具Cocoapods和大量第三方开源库成熟起来，业界积累了大量的优秀开源项目。这次Facebook开发Paper使用了[将近100个第三方开源库](http://blog.rpplusplus.me/blog/2014/02/11/facebook-paper-used-3rd/)，极大地减化了自己的应用开发任务。相信随着移动开发的发展，移动开发的生态圈会越来越成熟，基础的开源组件也将将越来越丰富，广大开发者都将从中受益。

另一方面，Facebook的工程师在[Quora上反馈](http://www.quora.com/What-exactly-did-Jason-Prado-mean-when-he-said-Xcode-cannot-handle-our-scale/answer/Scott-Goodson-1)说Paper在Xcode下打开需要40多秒钟，编译一次需要30分钟。这反映出大量的开源库的使用也给iOS集成编译环境Xcode提出了新的挑战，相信苹果会花大力气解决Xcode的性能问题。

##总结

Facebook发布的Paper让我看到了移动开发领域的快速发展，大量新的工具和开源技术给了设计师和程序员机会和挑战，相信在移动互联网快速发展的浪潮中，会涌现出越来越多优秀的移动应用。谁会是未来移动互联网的霸主？让我们拭目以待。


## 版权说明

本文已发表在《程序员》杂志2014年4月刊上，链接为：<http://www.csdn.net/article/2014-04-16/2819341>
