---
layout: post
title: "First Post"
date: 2011-12-25 14:17
comments: true
categories: [xcode, tool]
---

大家好。这是一篇测试的文章。

c代码高亮效果：
``` c
int main() {
    char * s = "hello world";
    printf("%s\n", s);
    return 0;
}
```

objc代码高亮效果：
``` objc
NSString * a = @"abc";
NSLog(@"%@", a);
```

objc的高亮效果:
{% codeblock lang:objc %}
+ (ImageCache *) sharedInstance {
    if (instance == nil) {
        @synchronized(self) {
            if (instance == nil) {
                instance = [[ImageCache alloc] init];
            }
        }
    }
    return instance;
}
{% endcodeblock %}

<!--more-->

objc高亮：
``` objc
+ (ImageCache *) sharedInstance {
    if (instance == nil) {
        @synchronized(self) {
            if (instance == nil) {
                instance = [[ImageCache alloc] init];
            }
        }
    }
    return instance;
}
```

Javascript语法高亮:
{% codeblock lang:javascript %}
function loadURL(url) {
    var iFrame;
    iFrame= document.createElement("iframe");
    iFrame.setAttribute("src", url);
    document.body.appendChild(iFrame); 
    iFrame.parentNode.removeChild(iFrame);
    iFrame = null;
}
{% endcodeblock %}

gist 语法高亮：
{% gist 1519172 %}


图片测试：
{% img /images/mm.png %}

引用测试：
{% blockquote %}
这是一段引用的文字。
第二行。
{% endblockquote %}


