#!/bin/bash
#
# Copyright(C) 2014-2016 startmenu
# Homepage: https://github.com/startmenu/WineQQ-Assistant
#
# GPL v2.1 许可证：GNU 通用公共许可证 v2.1
# 这是自由软件，你可以自由更改并重新分发它。
# 在法律所允许的范围内,不附带任何担保条款。
#
# 原作者 startmenu, 主页：https://github.com/startmenu
#
# Copyright(C) 2016 weak_ptr
#
# GPL v2.1 许可证：GNU 通用公共许可证 v2.1
# 这是自由软件，你可以自由更改并重新分发它。
# 在法律所允许的范围内,不附带任何担保条款。
# 
# 作者 weak_ptr <weak_ptr@163.com>，修改再分发
# Last change: 2016-10-21
#
# 基于startmenu的WineQQ-Assistant脚本制作的Slackware WineQQ解决方案。
#

set -e

echo "==================== Wine QQ 安装脚本 ===================="
echo "* 原作者startmenu (homepage: https://github.com/startmenu/)"
echo "* 感谢原作者startmenu编写的脚本。"
echo "* weak_ptr <weak_ptr@163.com> 改写了脚本的部分内容，以实现更自动"
echo "* 化的安装过程。"
echo "* 以GPL v2.1之名，GNU在上，weak_ptr在此修改后再分发此脚本。"
echo "* "
echo -e "* \033[0;31m警告：\033[0m"
echo -e "* \033[0;31m如果你使用的是Slackware64，你必须先安装multilib。\033[0m"
echo -e "* \033[0;31m参阅下方的链接。\033[0m"
echo "* https://www.slackware.com/~alien/multilib/ "
echo "* https://github.com/slackwarecn/slacklib32/ "
echo "* 如果有更多疑问，请在github提出issue。"
echo "========================================================="
echo "初始化安装环境..."
TZ="Asia/Shanghai"
LANG=zh_CN.UTF-8
WINETMP=${WINETMP:-$HOME/WineQQ-temp}
WINEQQ_PREFIX=${WINEQQ_PREFIX:-$HOME/.wine}
WINE=/usr/bin/wine
WINE_PATH=/usr/bin
ICONS_DIR=$HOME/.local/share/icons/hicolor/256x256/apps

function write_note()
{
	echo -e "\033[0;34mNote:\t\033[0m$1"
}

function write_warning()
{
	echo -e "\033[0;33mWarn:\t\033[0m$1"
}

function write_error()
{
	echo -e "\033[0;31mErr :\t\033[0m$1"
}

function initialize_tmp()
{
    if [ -d $WINETMP ]; then
        true
    else
        mkdir $WINETMP
    fi
}

function initialize_icon_dir()
{
    if [ -d $ICONS_DIR ]; then
        true
    else
        mkdir -p $ICONS_DIR
    fi
}

function initialize_wine()
{
    if [ -x /usr/bin/wine ]; then
        write_note "发现已安装的Wine程序。"
        idx=0
        for VER_NUM in $(/usr/bin/wine --version | sed -e "s/wine-//" -e "s/\./ /g"); do
            VERSION[$idx]=$VER_NUM
            idx=$(expr $idx + 1)
        done
        # echo ${VERSION[*]}
        if ! [[ ${VERSION[0]} > 1 || ${VERSION[1]} > 7 || ${VERSION[2]} > 49 ]]; then
        # if [ ${VERSION[0]} -gt 1 -o ！ ${VERSION[1]} -gt 7 -o ！ ${VERSION[2]} -gt 49 ]; then
            write_warning "Wine程序版本较旧，正在安装wine 1.7.49..."
            wine_staging
        fi
    else
        write_note "正在下载并安装wine 1.7.49..."
        wine_staging
    fi
}

function wine_staging()
{
    write_note "正在获取Play on Linux编译好的Wine 1.7.49"
    write_note "下载地址：http://wine.playonlinux.com/binaries/linux-x86/PlayOnLinux-wine-1.7.49-linux-x86.pol"

    if [ ! -f $WINETMP/PlayOnLinux-wine-1.7.49-linux-x86.pol ]; then
        if wget http://wine.playonlinux.com/binaries/linux-x86/PlayOnLinux-wine-1.7.49-linux-x86.pol -P $WINETMP -c; then
            true
        else
            write_error "下载失败，请检查网络连接。"
            exit 1
        fi
    fi

    write_note "安装Wine 1.7.49到$HOME/.winevers ..."
    if [ ! -d $HOME/.winevers ]; then   
        mkdir -p $HOME/.winevers
    fi

    if [ -d $HOME/.winevers/1.7.49 ]; then
        write_warning "发现已存在的 Wine1.7.49 安装，重新安装..." 
        rm -r $HOME/.winevers/1.7.49
    fi

    tar xf $WINETMP/PlayOnLinux-wine-1.7.49-linux-x86.pol -C $HOME/.winevers
    mv $HOME/.winevers/wineversion/1.7.49 $HOME/.winevers/1.7.49
    rm -r $HOME/.winevers/wineversion $HOME/.winevers/files $HOME/.winevers/playonlinux
    WINE=$HOME/.winevers/1.7.49/bin/wine
    WINE_PATH=$HOME/.winevers/1.7.49/bin
}

function check_p7zip()
{
    if [ -f /usr/bin/7z ]; then 
        true
    else 
        write_error "没有找到p7zip，停止。"
        exit 2
    fi
}

function check_iconv()
{
    if `which iconv >> /dev/null 2>&1`; then
        true
    else
        write_error "没有找到iconv，停止。"
        exit 2
    fi
}

function initialize_wine_prefix_dir()
{
    if [ -d $WINEQQ_PREFIX ]; then
        write_warning "检测到已存在的WineQQ安装，重新安装..."
        rm -r $WINEQQ_PREFIX
    fi
    write_note "初始化Wine容器..."
    WINEPREFIX=$WINEQQ_PREFIX $WINE wineboot >/dev/null 2>&1
}

function initialize_fonts()
{
    if [ ! -f /usr/share/fonts/TTF/wqy-microhei.ttc -a ! -f $HOME/.fonts/wqy-microhei.ttc -a ! -f $HOME/.fonts/TTF/wqy-microhei.ttc ]; then
        write_note "正在安装文泉驿微米黑字体..."
        write_note "下载地址：http://jaist.dl.sourceforge.net/project/wqy/wqy-microhei/0.2.0-beta/wqy-microhei-0.2.0-beta.tar.gz"
        if [ ! -f $WINETMP/wqy-microhei-0.2.0-beta.tar.gz ]; then
            if wget http://jaist.dl.sourceforge.net/project/wqy/wqy-microhei/0.2.0-beta/wqy-microhei-0.2.0-beta.tar.gz -P $WINETMP -c; then
                if [ ! $(sha1sum $WINETMP/wqy-microhei-0.2.0-beta.tar.gz) = "28023041b22b6368bcfae076de68109b81e77976" ]; then
                    write_error "sha1sum 校验错误，请重新下载。"
                    rm $WINETMP/wqy-microhei-0.2.0-beta.tar.gz
                    exit 1
                fi
            else
                write_error "下载失败，请检查网络连接。"
                exit 1
            fi
        fi

        if [ ! -d $HOME/.fonts ]; then
            mkdir -p $HOME/.fonts
        fi

        tar xf $WINETMP/wqy-microhei-0.2.0-beta.tar.gz -C $WINETMP
        cp $WINETMP/wqy-microhei/wqy-microhei.ttc $HOME/.fonts
    fi

    write_note "正在注册文泉驿字体..."
    cat > $WINETMP/fonts.reg<<EOF
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"Arial Unicode MS"="文泉驿微米黑"
"Batang"="文泉驿微米黑"
"Dotum"="文泉驿微米黑"
"Gulim"="文泉驿微米黑"
"Lucida Console"="文泉驿微米黑"
"Microsoft Sans Serif"="文泉驿微米黑"
"Microsoft YaHei"="文泉驿微米黑"
"MingLiU"="文泉驿微米黑"
"MS Gothic"="文泉驿微米黑"
"MS Mincho"="文泉驿微米黑"
"MS PGothic"="文泉驿微米黑"
"MS PMincho"="文泉驿微米黑"
"MS UI Gothic"="文泉驿微米黑"
"NSimSun"="文泉驿微米黑"
"PMingLiU"="文泉驿微米黑"
"SimFang"="文泉驿微米黑"
"SimHei"="文泉驿微米黑"
"SimKai"="文泉驿微米黑"
"SimSun"="文泉驿微米黑"
"Tahoma"="文泉驿微米黑"
"YaHei"="文泉驿微米黑"
"Yahei UI"="文泉驿微米黑"
"宋体"="文泉驿微米黑"
"新細明體"="文泉驿微米黑"
"ＭＳＰゴシック"="文泉驿微米黑"
EOF
    iconv -f utf8 -t gbk  $WINETMP/fonts.reg -o $WINETMP/fonts_reg.reg
    rm $WINETMP/fonts.reg -f
    WINEPREFIX=$WINEQQ_PREFIX $WINE regedit $WINETMP/fonts_reg.reg >/dev/null 2>&1
    WINEPREFIX=$WINEQQ_PREFIX $WINE_PATH/wineserver -k

    if [ $WINE_PATH = /usr/bin ]; then
        if [ ! -d /usr/share/wine/font.disable ]; then
            write_note "正在删除Wine的Tahoma字体，以解决一处乱码死角，请输入管理员密码。"
            sudo mkdir -p /usr/share/wine/font.disable
            sudo mv /usr/share/wine/fonts/tahoma* /usr/share/wine/font.disable
        fi
    else
        mkdir $WINE_PATH/../share/wine/font.disable
        mv $WINE_PATH/../share/wine/fonts/tahoma* $WINE_PATH/../share/wine/font.disable
    fi
}

function install_qq()
{
    if [ ! -f $WINETMP/QQ6.7Light.exe ]; then
        write_note "正在下载并安装QQ 6.7..."
        write_note "下载地址：http://dldir1.qq.com/qqfile/qq/QQ6.7Light/13466/QQ6.7Light.exe"

        if use_proxy=off wget http://dldir1.qq.com/qqfile/qq/QQ6.7Light/13466/QQ6.7Light.exe -P $WINETMP -c; then
            if [ ! $(sha1sum $WINETMP/QQ6.7Light.exe) = "e1e1ff2bf6461c08047d0a01927a43c5a0746bdf" ]; then
                write_error "sha1sum校验码错误，请重试。"
                exit 1
            fi
        else
            write_error "下载失败，请检查网络连接。"
            exit 1
        fi
    fi

    write_note "即将安装WineQQ。安装完毕后如果自动打开QQ登录窗口，请先关闭，因为安装后还需要一些处理才能正常使用，切记！"
    
    cat >$WINETMP/iehack.reg << EOF
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer]
"Version"="8.0"
EOF
    WINEPREFIX=$WINEQQ_PREFIX $WINE regedit $WINETMP/iehack.reg >/dev/null 2>&1
    WINEPREFIX=$WINEQQ_PREFIX $WINE $WINETMP/QQ6.7Light.exe >/dev/null 2>&1
    WINEPREFIX=$WINEQQ_PREFIX $WINE_PATH/wineserver -k

    write_note "注意，如果你没有看到安装界面，或没有进入最后一步点击完成安装，你的QQ可能没有安装完成。"
    write_note "如果QQ的登录界面已经打开，请先关闭它。"

    write_note "正在注册组件..."
    cat >$WINETMP/txhack.reg <<EOF
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"*riched20"="native,builtin"
"riched20.dll"="native,builtin"
"txplatform.exe"=""
"txupd.exe"=""
EOF
    WINEPREFIX=$WINEQQ_PREFIX $WINE regedit $WINETMP/txhack.reg >/dev/null 2>&1

    write_note "正在从QQ可执行程序中提取图标..."
    7z -y e $WINEQQ_PREFIX/drive_c/Program\ Files/Tencent/QQ/Bin/QQ.exe -o$WINETMP/qqicon >/dev/null
    cp $WINETMP/qqicon/4  $ICONS_DIR/WineQQ.png

    write_note "正在创建启动脚本..."
cat > $WINEQQ_PREFIX/qq_launcher.sh <<EOF
#!/bin/sh
export TZ="Asia/Shanghai" 
export LC_ALL=zh_CN.UTF-8 
export WINEPREFIX=$WINEQQ_PREFIX
export WINE=$WINE
export WINE_PATH=$WINE_PATH
runqq()
{
\$WINE "C:\Program Files\Tencent\QQ\Bin\QQ.exe" >/dev/null 2>&1
}

wineqq_verbose()
{
\$WINE "C:\Program Files\Tencent\QQ\Bin\QQ.exe"
}

runhelp()
{
echo 
echo "记住，只有选项能用："
echo "-h 或 --help :  就是你正在看的这些东西"
echo "-v 或 --verbose : 把QQ运行时那些又臭又长的东西显示出来 "
echo "-r 或 --regedit : 呼叫注册表编辑器，胆小者勿入"
echo "-c 或 --winecfg : 召唤winecfg来帮你设置酒瓶"
echo "-t 或 --taskmgr : 开启用来杀进程的任务管理器"
echo "-e 或 --explorer : 打开Wine的文件管理器，然而这并没有什么用"
echo "-k 或 --kill : 关掉把酒瓶里运行的程序都关掉，但不会打碎这个酒瓶"
echo "-u 或 --uninstall ：把酒瓶里的东西全部倒掉（卸载）"
echo
}

case \$1 in
  "-h"|"--help")
  runhelp
  ;;
  "-v"|"--verbose")
  wineqq_verbose
  ;;
  "-r"|"--regedit")
  $WINE regedit
  ;;
  "-c"|"--winecfg")
  $WINE winecfg
  ;;
  "-t"|"--taskmgr")
  $WINE taskmgr
  ;;
  "-e"|"--explorer")
  $WINE explorer
  ;;
  "-k"|"--kill")
  $WINE_PATH/wineserver -k
  ;;
  "-u"|"-uninstall")
  rm -rf \$WINEPREFIX
  rm -rf \$HOME\.winevers
  rm \$HOME/.local/share/applications/wineqq.desktop
  rm \$HOME/.local/share/icons/hicolor/256x256/apps/WineQQ.png
  ;;
*)
  if [ -z \$1 ];
  then 
    runqq
  else 
    echo "谁告诉你 \$1 这个选项的？"
    runhelp
  fi  
  ;;
 esac
 
EOF

    chmod +x $WINEQQ_PREFIX/qq_launcher.sh
    write_note "正在创建菜单项..."
    cat >$WINETMP/QQ.desktop <<EOF
[Desktop Entry]
Name=QQ 6.7 Lite
Comment=Tencent QQ 6.7 Lite
Categories=Network;
Exec=$WINEQQ_PREFIX/qq_launcher.sh
Icon=WineQQ
Type=Application
EOF

    cp $WINETMP/QQ.desktop $HOME/.local/share/applications/wineqq.desktop
    WINEPREFIX=$WINEQQ_PREFIX $WINE_PATH/wineserver -k
    write_note "安装完成！在主菜单中找到QQ的菜单项启动。"
    write_note "你现在可以手工删除 $WINETMP 目录。"
    exit 0
}

initialize_tmp
initialize_icon_dir
initialize_wine
initialize_wine_prefix_dir
initialize_fonts
check_p7zip
check_p7zip
install_qq
