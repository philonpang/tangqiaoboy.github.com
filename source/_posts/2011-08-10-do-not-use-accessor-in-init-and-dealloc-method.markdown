---
layout: post
title: "不要在init和dealloc函数中使用accessor"
date: 2011-08-10 17:32
comments: true
categories: iOS
---

Objective-C 2.0 增加了dot syntax，用于简单地调用成员变量的accessor。相当于java的getter和setter。
因为正常情况下，写一个accessor对于初学者来说，还是挺容易犯错的。比如有一个NSString * 的成员变量叫name。一个错误的写法是：
``` objc
-(void) setName:(NSString *)newName {
     name = newName;
}
```

<!--more-->

Java同学肯定想不通上面的代码有什么错吧？原因是Objective-C需要自己负责内存的释放。
所以需要在改变reference之前，将原对象release，对新的对象，也需要retain一下，代码就改成这样：
``` objc
-(void) setName:(NSString *)newName {
     [name release];
     name = [newName retain];
}
```

初学者可能以为这样就对了，其实还是有错，如果newName和name的指向的是同一个对象，并且这个对象retain count只有1的话。
那么name release之后，这个对象就被回收掉了。所以应该改成：

``` objc
-(void) setName:(NSString *)newName {
     if (name != newName) {
          [name release];
          name = [newName retain];
     }
}
```


这样才算是一个正确的set函数，Java同学肯定被吓到了，虽然知道这么写，但这比Java麻烦多了。于是，Objective-C允许程序员使用 @property + @synthesize 关键字来自动生成这些代码。于是Objective-C的程序员幸福了。大部分时候根本就不用写getter和setter。

但是需要小心，Objective-C的accessor不能在init和dealloc函数中使用！如果你在dealloc中这么写，就有问题：
``` objc
-(void)dealloc {
     self.name = nil;
     [super dealloc]
}
```

苹果在它的developer文档库中有一个专门讲cocoa的内存管理的文章：
<http://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/MemoryMgmt.pdf>

文章的第16页有一节题目是：Don’t Use Accessor Methods in Initializer Methods and dealloc

文章说：你唯一不应该用Accessor的地方是init函数和delloc函数。在init函数中，对于一个_count成员变量应该像下面这样赋值：

``` objc
-(void) init { 
     self = [super init]; 
     if (self) {
          _count = [[NSNumber alloc] initWithInteger:0]; 
     }
     return self;
}
```

对于一个带参数的init函数，你应该实现成下面这样：
``` objc
- (void) initWithCount:(NSNumber *)startingCount { 
     self = [super init]; 
     if (self) {
          _count = [startingCount copy];
     }
     return self;
}
```

对于在dealloc中，对应的写法应该是调release:
``` objc
- (void)dealloc { 
     [_count release]; 
     [super dealloc];
}
```

但是比较郁闷的是，文章最后没有说为什么不能！去stackoverflow上搜了一下，比较不靠谱的说法是这样少一次函数调用，更快。比较靠谱的说法是：在init和dealloc中，对象的存在与否还不确定，所以给对象发消息可能不会成功。

顺便说一下, 当发现这个文章的时候，我们的代码中已经有了很多这样错误用法。虽然程序没有出现严重的内存问题，但是为了保险，还是打算一行一行改掉，后来我想，这个能不能用vim搞定呢？
于是我进vim，用qa启动宏录制，然后输入 
<pre>
:%s/self./[/g  再输入：%s/= nil/release]/g 
</pre>
再输入q, 这样就可以用@a来启动刚刚录制的宏来做替换了。相当方便。


