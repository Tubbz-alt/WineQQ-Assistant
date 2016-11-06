WineQQ安装助手
==============

此脚本将帮助你安装WineQQ。

## 文件及说明
*  WineQQ-Assistant.sh 执行它，安装QQ6.7轻聊版。

### 可选参数

* WINETMP=/path/to/your/download/dir

该目录会储存多个下载的软件包，可用于离线或网络较差时安装使用。

* WINEQQ_PREFIX=/path/to/your/WINEPREFIX

该目录会保存Wine创建的Windows目录结构，默认安装到$HOME/.wine中。

### 举例

`WINEQQ_PREFIX=$HOME/.wineqq WINETMP=$HOME/Downloads sh WineQQ-Assistant.sh`

## 依赖项

大部分依赖项会自动解决。

**警告**： 如果你使用了Slackware64，请跟随下方的链接安装multilib实现32位兼容。

* [slacklib32](https://github.com/slackwarecn/slacklib32)
* [slackware.com](http://www.slackware.com/~alien/multilib/)

## 使用方法：

```shell
git clone https://github.com/slackwarecn-slackbuilds/WineQQ-Assistant
cd WineQQ-Assistant
WINEQQ_PREFIX=$HOME/.wineqq sh WineQQ-Assistant.sh
```

脚本完成后，如果安装顺利，可以在主菜单的“互联网”（或“网络”）分类中找到启动QQ的选项。

Enjoy it！