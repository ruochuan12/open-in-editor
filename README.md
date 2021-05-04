# 学习源码整体架构，探究「在编辑器中打开」功能实现原理

open-in-editor

## 1. 前言

>你好，我是[若川](https://lxchuan12.gitee.io)，微信搜索[「若川视野」](https://mp.weixin.qq.com/s/c3hFML3XN9KCUetDOZd-DQ)关注我，专注前端技术分享，一个愿景是帮助5年内前端开阔视野走向前列的公众号。欢迎加我微信`ruochuan12`，长期交流学习。

本文就是根据学习源码探究「在编辑器中打开」功能实现原理。

```sh
code path/to/file
```

一句话简述原理：

## 2. 环境准备工作

特意新建一个仓库[open-in-editor](https://github.com/lxchuan12/open-in-editor) `https://github.com/lxchuan12/open-in-editor`，便于大家克隆学习。

安装`vue-cli`

```sh
npm install -g @vue/cli
# OR
yarn global add @vue/cli
```

```sh
node -V
# v14.16.0
vue -V 
# @vue/cli 4.5.12
vue create vue3-project
# 这里选择的是vue3、vue2也是一样的。
# Please pick a preset: Default (Vue 3 Preview) ([Vue 3] babel, eslint)
```

## 3. 具体源码实现

### 3.1 launch-editor-middleware

### 3.2 launch-editor

## 参考链接

[yyx990803/launch-editor](https://github.com/yyx990803/launch-editor)
[umijs/launch-editor](https://github.com/umijs/launch-editor)
[vuejs/vue-devtools](https://github.com/vuejs/vue-devtools)
[vue-devtools open-in-editor.md](https://github.com/vuejs/vue-devtools/blob/dev/docs/open-in-editor.md)
["Open in editor" button doesn't work in Win 10 with VSCode if installation path contains spaces](https://github.com/vuejs/vue-devtools/issues/821)