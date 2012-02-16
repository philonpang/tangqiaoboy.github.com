---
layout: post
title: "给iOS工程增加Daily Build"
date: 2012-02-16 19:27
comments: true
categories: iOS
published: true
---

##前言
Daily Build是一件非常有意义的事情，也是敏捷开发中关于“持续集成”的一个实践。Daily Build对于开发来说有如下好处：

 * 保证了每次check in的代码可用，不会造成整个工程编译失败。
 * 进度跟进。产品经理可以每天看到最新的开发进度，并且试用产品，调整一些细节。很多时候，一个新功能，你真正用了一下才能有体会好或不好，所以daily build也给产品经理更多时间来调理他的设计。
 * 需求确认。产品经理可以确认开发的功能细节是他的预期。因为我们的开发比较紧凑，所以都没有传统的需求说明文档，所以daily build也给产品经理用于尽早确认开发的功能细节是他的预期，我就遇到一次产品经理发现开发出的一个功能细节和他的预期不一致，但是因为有daily build，使得我可以尽早做修改，把修改的代价减小了。
 * 测试跟进。如果功能点是独立的话，测试同事完全可以根据daily build来进行一些早期的测试。越早的Bug反馈可以使得修改bug所需的时间越短。

<!--more-->

##步骤

###xcodebuild命令
如何做daily build呢？其实Xcode就提供了命令行build的命令，这个命令是xcodebuild，用xcodebuild -usage
可以查看到所有的可用参数，如下所示：

``` bash
[tangqiao ~]$xcodebuild -usage
Usage: xcodebuild [-project <projectname>] [[-target <targetname>]...|-alltargets] [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild [-project <projectname>] -scheme <schemeName> [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild -workspace <workspacename> -scheme <schemeName> [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild -version [-sdk [<sdkfullpath>|<sdkname>] [<infoitem>] ]
       xcodebuild -list [[-project <projectname>]|[-workspace <workspacename>]]
       xcodebuild -showsdks

```

一般情况下的命令使用如下:

``` bash
xcodebuild -configuration Release -target "YourProduct"
```

但在daily build中，用Release用为configuration其实不是特别好。因为Release的证书可能会被经常修改。我们可以基于Release的Configuation，建一个专门用于daily build的configuration。方法是：在工程详细页面中，选择Info一栏，在Configurations一栏的下方点击“+”号，然后选择"Duplicate Release Configuration", 新建名为"DailyBuild"的Configuration, 如下图所示：

{% img /images/daily_build_1.png %}

之后就可以用如下命令来做daily build了

``` bash
xcodebuild -configuration DailyBuild -target "YourProduct"
```

执行完命令后，会在当前工程下的 build/DailyBuild-iphoneos/目录下生成一个名为： YourProduct.app的文件。这个就是我们Build成功之后的程序文件。

###生成ipa文件
接下来我们需要生成ipa文件，在生成ipa文件这件事情上，xcode似乎没有提供什么工具，不过这个没什么影响，因为ipa文件实际上就是一个zip文件，我们使用系统的zip命令来生成ipa文件即可。需要注意的是，ipa文件并不是简单地将编辑好的app文件打成zip文件，它需要将app文件放在一个名为Payload的文件夹下，然后将整个Payload目录打包成为.ipa文件，命令如下：

``` bash
cd $BUILD_PATH
mkdir -p ipa/Payload
cp -r ./DailyBuild-iphoneos/$PRODUCT_NAME ./ipa/Payload/
cd ipa
zip -r $FILE_NAME *
```

###生成安装文件
苹果允许用itms-services协议来直接在iphone/ipad上安装应用程序，我们可以直接生成该协议需要的相关文件，这样产品经理和测试同学都可以直接在设备上安装新版的应用了。相关的参考资料可以见：[这里](http://blog.encomiabile.it/2010/12/21/ios4-and-wireless-application-deploy/)和 [这里](http://blog.s135.com/itms-services/)

具体来说，就是需要生成一个带 itms-services 协议的链接的html文件，以及一个 plist 文件。

生成html的示例代码如下：

``` bash
cat << EOF > install.html
<!DOCTYPE HTML>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>安装此软件</title>
  </head>
  <body>
    <ul>
      <li>安装此软件:<a href="itms-services://?action=download-manifest&url=http%3A%2F%2Fwww.yourdomain.com%2Fynote.plist">$FILE_NAME</a></li>
    </ul>
    </div>
  </body>
</html>
EOF
```

生成plist文件的代码如下，注意，需要将下面的涉及 www.yourdomain.com的地方换成你线上服务器的地址，将ProductName换成你的app安装后的名字。

``` bash
cat << EOF > ynote.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>items</key>
   <array>
       <dict>
           <key>assets</key>
           <array>
               <dict>
                   <key>kind</key>
                   <string>software-package</string>
                   <key>url</key>
                   <string>http://www.yourdomain.com/$FILE_NAME</string>
               </dict>
               <dict>
                   <key>kind</key>
                   <string>display-image</string>
                   <key>needs-shine</key>
                   <true/>
                   <key>url</key>
                   <string>http://www.yourdomain.com/icon.png</string>
               </dict>
           <dict>
                   <key>kind</key>
                   <string>full-size-image</string>
                   <key>needs-shine</key>
                   <true/>
                   <key>url</key>
                   <string>http://www.yourdomain.com/icon.png</string>
               </dict>
           </array><key>metadata</key>
           <dict>
               <key>bundle-identifier</key>
               <string>com.yourdomain.productname</string>
               <key>bundle-version</key>
               <string>1.0.0</string>
               <key>kind</key>
               <string>software</string>
               <key>subtitle</key>
               <string>ProductName</string>
               <key>title</key>
               <string>ProductName</string>
           </dict>
       </dict>
   </array>
</dict>
</plist>


EOF

```

###定时运行
这一点非常简单，使用crontab -e命令即可。大家可以随意google一下crontab命令，可以找到很多相关文档。假如我们要每周1-5的早上9点钟执行daily build，则crontab的配置如下：

```
0 9 * * * 1-5 /Users/tangqiao/dailybuild.sh >> /Users/tangqiao/dailybuild.log 2>&1
```

###失败报警
在daily build脚本运行失败时，最好能发报警邮件或者短信，以便能够尽早发现。发邮件可以用python的smtplib来写，示例如下：

``` python
import smtplib

sender = 'sender@devtang.com'
receivers = ['receiver@devtang.com']

message = """From: Alert <sender@devtang.com>
To: Some one <receiver@devtang.com>
Subject: SMTP email sample

Hope you can get it.
"""

try:
    obj = smtplib.SMTP('server.mail.devtang.com')
    obj.sendmail(sender, receivers, message)
    print 'OK: send mail succeed'
except Exception:
    print 'Error: unable to send mail'

```

###上传
daily build编译出来如果需要单独上传到另外一台web机器上，可以用ftp或者scp协议。如果web机器悲剧的是windows机器的话，可以在windows机器上开一个共享，然后用 mount -t smbfs来将这个共享mount到本地，相关的示例代码如下：
``` bash
mkdir upload
mount -t smbfs //$SMB_USERNAME:$SMB_PASSWORD@$SMB_TARGET ./upload
if [ "$?" -ne 0 ]; then
    echo "Failed to mount smb directory"
    exit 1
fi
mkdir ./upload/$FOLDER
cp $FILE_NAME ./upload/$FOLDER/
if [ "$?" -eq 0 ]; then
    echo "[OK] $FILE_NAME is uploaded to $SMB_TARGET" 
else
    echo "[ERROR] $FILE_NAME is FAILED to  uploaded to $SMB_TARGET" 
fi
umount ./upload
```


##总结
将以上各点结合起来，就可以用bash写出一个daily build脚本了。每天这一切都会自动完成，心情相当好。
