# 学习源码整体架构，探究「在编辑器中打开」功能实现原理

## 1. 前言

>你好，我是[若川](https://lxchuan12.gitee.io)，微信搜索[「若川视野」](https://mp.weixin.qq.com/s/c3hFML3XN9KCUetDOZd-DQ)关注我，专注前端技术分享，一个愿景是帮助5年内前端开阔视野走向前列的公众号。欢迎加我微信`ruochuan12`，长期交流学习。

![open-in-editor](./open-in-editor.png)

本文就是根据学习源码探究「在编辑器中打开」功能实现原理。

```sh
code path/to/file
```

一句话简述原理：利用`nodejs`中的`child_process`，执行了类似`code path/to/file`命令，于是对应编辑器就打开了相应的文件。

大概率你会报错，说不能打开这个文件。
```sh
Could not open App.vue in the editor.

To specify an editor, specify the EDITOR env variable or add "editor" field to your Vue project config.
```

![控制台不能打开编辑器的错误提示](./open-in-editor-error.png)

解决办法也简单，就是这句英文的意思。具体说明编辑器，在环境变量中说明指定编辑器。在`vue`项目的根目录下，对应本文则是：`vue3-project`，添加`.env.delelopment`文件，其内容是`EDITOR=code`。
```sh
# .env.development
EDITOR=code
```

不用指定编辑器的对应路径（`c/Users/lxchu/AppData/Local/Programs/Microsoft VS Code/bin/code`），因为会报错。为什么会报错，因为我看了源码且试过。因为会被根据空格截断，变成`c/Users/lxchu/AppData/Local/Programs/Microsoft`，当然就报错了。

本着`知其然，知其所以然`的宗旨，本文则是探究其原理，接下来我们从源码角度探究这个功能的实现原理。

## 2. vue-devtools Open component in editor 文档

探究原理之前，先来看看这个官方文档。

[vuejs/vue-devtools](https://github.com/vuejs/vue-devtools#open-component-in-editor)
文档中有一个「Open component in editor」标题
To enable this feature, follow [this guide](https://github.com/vuejs/vue-devtools/blob/dev/docs/open-in-editor.md).

```
Vue CLI 3 supports this feature out-of-the-box when running vue-cli-service serve.
```

这篇指南中写了在`Vue CLI 3`中是**开箱即用**。
也详细写了如何在`Webpack`下使用。
```sh
# 1. Import the package:
var openInEditor = require('launch-editor-middleware')
# 2. In the devServer option, register the /__open-in-editor HTTP route:
devServer: {
  before (app) {
    app.use('/__open-in-editor', openInEditor())
  }
}
# 3. The editor to launch is guessed. You can also specify the editor app with the editor option. See the supported editors list.
# 用哪个编辑器打开会自动猜测。你也可以具体指明编辑器。这里显示更多的支持编辑器列表
openInEditor('code')
# 4. You can now click on the name of the component in the Component inspector pane (if the devtools knows about its file source, a tooltip will appear).
# 如果`vue-devtools`开发者工具有提示点击的组件的显示具体路径，那么你可以在编辑器打开。
```
同时也写了如何在`Node.js`中使用等。

Node.js
You can use the [launch-editor](https://github.com/yyx990803/launch-editor#usage) package to setup an HTTP route with the `/__open-in-editor` path. It will receive file as an URL variable.

查看更多可以看[这篇指南](https://github.com/vuejs/vue-devtools/blob/dev/docs/open-in-editor.md)。

## 3. 环境准备工作

熟悉我的读者，都知道我都是**推荐调试看源码**的，正所谓：**哪里不会点哪里**。而且调试一般都写得很详细，是希望能帮助到一部分人知道如何看源码。于是我特意新建一个仓库[open-in-editor](https://github.com/lxchuan12/open-in-editor) `git clone https://github.com/lxchuan12/open-in-editor`，便于大家克隆学习。

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
npm install
# OR
yarn install
```

这里同时说明下我的vscode版本。

```sh
code -v
1.55.2
```

前文提到的`Vue CLI 3`中**开箱即用**和`Webpack`使用方法。

`vue3-project/package.json`中有一个`debug`按钮。

![debug示意图](./debug.png)

我们来搜索下`'launch-editor-middleware'`这个中间件，一般来说搜索不到`node_modules`下的文件，需要设置下。当然也有个简单做法。就是「排除的文件」右侧旁边有个设置图标「使用“排查设置”与“忽略文件”」，点击下。

其他的就不赘述了。可以看这篇知乎回答：[vscode怎么设置可以搜索包含node_modules中的文件?](https://www.zhihu.com/question/309220217/answer/586510407)

这时就搜到了`vue3-project/node_modules/@vue/cli-service/lib/commands/serve.js`中有使用这个中间件。

## 4. 具体源码实现

接着我们来看`Vue CLI 3`中**开箱即用**具体源码实现。

```js
// vue3-project/node_modules/@vue/cli-service/lib/commands/serve.js
// 46行
const launchEditorMiddleware = require('launch-editor-middleware')
// 192行
before (app, server) {
    // launch editor support.
    // this works with vue-devtools & @vue/cli-overlay
    app.use('/__open-in-editor', launchEditorMiddleware(() => console.log(
        `To specify an editor, specify the EDITOR env variable or ` +
        `add "editor" field to your Vue project config.\n`
    )))
    // 省略若干代码...
}
```

## 5 launch-editor-middleware

```js
// vue3-project/node_modules/launch-editor-middleware/index.js
const url = require('url')
const path = require('path')
const launch = require('launch-editor')

module.exports = (specifiedEditor, srcRoot, onErrorCallback) => {
  if (typeof specifiedEditor === 'function') {
    onErrorCallback = specifiedEditor
    specifiedEditor = undefined
  }

  if (typeof srcRoot === 'function') {
    onErrorCallback = srcRoot
    srcRoot = undefined
  }

  srcRoot = srcRoot || process.cwd()

  return function launchEditorMiddleware (req, res, next) {
    const { file } = url.parse(req.url, true).query || {}
    if (!file) {
      res.statusCode = 500
      res.end(`launch-editor-middleware: required query param "file" is missing.`)
    } else {
      launch(path.resolve(srcRoot, file), specifiedEditor, onErrorCallback)
      res.end()
    }
  }
}

```

## 4.2 launch-editor

```js
// vue3-project/node_modules/launch-editor/index.js
function launchEditor (file, specifiedEditor, onErrorCallback) {
  const parsed = parseFile(file)
  let { fileName } = parsed
  const { lineNumber, columnNumber } = parsed

  if (!fs.existsSync(fileName)) {
    return
  }

  if (typeof specifiedEditor === 'function') {
    onErrorCallback = specifiedEditor
    specifiedEditor = undefined
  }

  onErrorCallback = wrapErrorCallback(onErrorCallback)

  const [editor, ...args] = guessEditor(specifiedEditor)
  if (!editor) {
    onErrorCallback(fileName, null)
    return
  }
  // 省略剩余部分，后文再讲述...
}
```

### wrapErrorCallback

```js
onErrorCallback = wrapErrorCallback(onErrorCallback)
```

这段的代码，我相信读者朋友能看懂，我单独拿出来讲述，主要是因为这种包裹函数的形式在很多源码里都很常见。
这里也就是文章开头终端错误图`Could not open App.vue in the editor.`输出的代码位置。

```js
// vue3-project/node_modules/launch-editor/index.js
function wrapErrorCallback (cb) {
  return (fileName, errorMessage) => {
    console.log()
    console.log(
      chalk.red('Could not open ' + path.basename(fileName) + ' in the editor.')
    )
    if (errorMessage) {
      if (errorMessage[errorMessage.length - 1] !== '.') {
        errorMessage += '.'
      }
      console.log(
        chalk.red('The editor process exited with an error: ' + errorMessage)
      )
    }
    console.log()
    if (cb) cb(fileName, errorMessage)
  }
}
```

### guessEditor 猜测编辑器

```js
const [editor, ...args] = guessEditor(specifiedEditor)
```

```js
// vue3-project/node_modules/launch-editor/guess.js
guessEditor
```

### 4.2 launch-editor 剩余部分

```js
function launchEditor(){
  //  省略上部分...
  if (
    process.platform === 'linux' &&
    fileName.startsWith('/mnt/') &&
    /Microsoft/i.test(os.release())
  ) {
    // Assume WSL / "Bash on Ubuntu on Windows" is being used, and
    // that the file exists on the Windows file system.
    // `os.release()` is "4.4.0-43-Microsoft" in the current release
    // build of WSL, see: https://github.com/Microsoft/BashOnWindows/issues/423#issuecomment-221627364
    // When a Windows editor is specified, interop functionality can
    // handle the path translation, but only if a relative path is used.
    fileName = path.relative('', fileName)
  }

  if (lineNumber) {
    const extraArgs = getArgumentsForPosition(editor, fileName, lineNumber, columnNumber)
    args.push.apply(args, extraArgs)
  } else {
    args.push(fileName)
  }

  if (_childProcess && isTerminalEditor(editor)) {
    // There's an existing editor process already and it's attached
    // to the terminal, so go kill it. Otherwise two separate editor
    // instances attach to the stdin/stdout which gets confusing.
    _childProcess.kill('SIGKILL')
  }

  if (process.platform === 'win32') {
    // On Windows, launch the editor in a shell because spawn can only
    // launch .exe files.
    _childProcess = childProcess.spawn(
      'cmd.exe',
      ['/C', editor].concat(args),
      { stdio: 'inherit' }
    )
  } else {
    _childProcess = childProcess.spawn(editor, args, { stdio: 'inherit' })
  }
  _childProcess.on('exit', function (errorCode) {
    _childProcess = null

    if (errorCode) {
      onErrorCallback(fileName, '(code ' + errorCode + ')')
    }
  })

  _childProcess.on('error', function (error) {
    onErrorCallback(fileName, error.message)
  })
}
```


有什么作用
也可以再看看[umijs/launch-editor](https://github.com/umijs/launch-editor)原理实现。

## 6. 总结

## 参考链接

[yyx990803/launch-editor](https://github.com/yyx990803/launch-editor)<br>
[umijs/launch-editor](https://github.com/umijs/launch-editor)<br>
[vuejs/vue-devtools](https://github.com/vuejs/vue-devtools)<br>
[vue-devtools open-in-editor.md](https://github.com/vuejs/vue-devtools/blob/dev/docs/open-in-editor.md)<br>
["Open in editor" button doesn't work in Win 10 with VSCode if installation path contains spaces](https://github.com/vuejs/vue-devtools/issues/821)