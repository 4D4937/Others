---
description: >-
  9月18日上午，pixiv.net遭遇DNS投毒，域名被劫持到随机IP，之前的修改host进行访问的方法也不再可用，但仍然有一些可以恢复的方法，下面列出几个，供参考
---

# Pixiv 恢复访问的几种方法

{% hint style="warning" %}
pixiv客户端暂时没有完美的~~**免费**~~解决方法，推荐SS/SSR
{% endhint %}

| / | 镜像站 | 蓝灯 | SS/SSR |
| :---: | :---: | :---: | :---: |
| 速度 | 较快 | 较慢 | 快 |
| 是否支持登录 | 不支持 | 支持 | 支持 |
| 支持站点 | 网页端 | 网页端/客户端 | 网页端/客户端 |



## 方法一 【推荐】

#### 我们搭建了pixiv镜像站，直接访问下面[域名](https://pixiv.online)即可使用

{% code-tabs %}
{% code-tabs-item title="镜像站由 LIBER+ 赞助支持" %}
```
pixiv.online
```
{% endcode-tabs-item %}
{% endcode-tabs %}

{% hint style="info" %}
pixiv镜像暂不支持登录/注册
{% endhint %}

镜像站无法进行登录/注册好像是某些站点没有反代完全.. 有了解的同学欢迎[联系](https://t.me/btcnode)我

## 方法二

#### 使用lantern等v.p.n绕过大陆DNS

蓝灯是免费的使用起来比较方便，但可能会有速度慢的问题

```
getlantern.org
```

## 方法三   \[已失效】

{% hint style="danger" %}
9.18 该方法已失效
{% endhint %}

#### ~~修改 hosts~~

* ~~host文件路径：C:\Windows\System32\drivers\etc~~
* ~~找到文件名为host的文件，使用文本编辑器打开（个人推荐Sublime、Notepad++），添加以下host后保存即可上P站。~~

```text
#Pixiv Start
210.129.120.45 pixiv.net
210.129.120.45 www.pixiv.net
210.129.120.45 accounts.pixiv.net
210.129.120.45 touch.pixiv.net
210.129.120.47 www.pixiv.net
210.129.120.47 accounts.pixiv.net
210.129.120.47 touch.pixiv.net
210.129.120.46 www.pixiv.net
210.129.120.46 accounts.pixiv.net
210.129.120.46 touch.pixiv.net
210.140.131.147 source.pixiv.net
210.140.131.147 imgaz.pixiv.net
210.129.120.46 app-api.pixiv.net
210.129.120.48 oauth.secure.pixiv.net
210.129.120.45 dic.pixiv.net
210.140.131.153 comic.pixiv.net
210.129.120.47 factory.pixiv.net
74.120.148.207 g-client-proxy.pixiv.net
210.140.170.179 sketch.pixiv.net
210.129.120.47 payment.pixiv.net
210.129.120.45 sensei.pixiv.net
210.140.131.144 novel.pixiv.net
210.129.120.46 en-dic.pixiv.net
210.140.131.145 i1.pixiv.net
210.140.131.145 i2.pixiv.net
210.140.131.145 i3.pixiv.net
210.140.131.145 i4.pixiv.net
210.140.131.159 d.pixiv.org
210.140.92.135 pixiv.pximg.net
210.140.92.136 i.pximg.net
#Pixiv End
```

## 方法四

#### SS/SSR 代理绕过gfw访问

ss/ssr使用需要付费购买服务，提供的商家也有很多，这里推荐 [**LIBER+**](https://liberplus.us) 是否购买自行决定

{% hint style="info" %}
该方法适用于网页端与客户端
{% endhint %}





