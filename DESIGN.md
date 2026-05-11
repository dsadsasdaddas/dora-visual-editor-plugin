# Dora Visual Editor Plugin 下载原理

## 目标

让 Dora 2D 可视化编辑器像 Dora 社区游戏一样，通过 Dora SSR 内置 `ResourceDownloader` 被发现、预览、下载、解压、运行。

## Dora ResourceDownloader 当前协议

Dora 的下载器不需要复杂后端，只依赖 4 类 HTTP 资源：

```text
<base>/api/v1/package-list-version
<base>/api/v1/packages
<base>/assets/repos.json
<base>/assets/<package-name>/banner.jpg
```

下载流程：

```mermaid
flowchart TD
  A[ResourceDownloader 打开] --> B[GET /api/v1/package-list-version]
  B --> C{版本号变了吗}
  C -- 是 --> D[清理本地 preview cache]
  C -- 否 --> E[复用 cache]
  D --> F[GET /api/v1/packages]
  E --> F
  F --> G[GET /assets/repos.json]
  G --> H[GET /assets/name/banner.jpg]
  H --> I[显示资源卡片]
  I --> J[点击下载]
  J --> K[下载 packages[].versions[].download 指向的 zip]
  K --> L[解压到 Content.writablePath/Download/name]
  L --> M[写入 .dora/repo.json 和 .dora/banner.jpg]
  M --> N[点击运行 init.lua]
```

对应 Dora 代码：

- `Assets/Script/Tools/ResourceDownloader.ts`
- `Assets/Script/Tools/ResourceDownloader.lua`

关键字段：

```json
{
  "name": "dora-visual-editor",
  "versions": [
    {
      "file": "dora-visual-editor-0.1.0.zip",
      "size": 42631,
      "tag": "v0.1.0",
      "download": "https://github.com/.../releases/download/v0.1.0/dora-visual-editor-0.1.0.zip",
      "updatedAt": 1778328841
    }
  ]
}
```

`download` 可以指向 GitHub Release asset，所以仓库本身可以只托管静态 manifest，zip 放 Release。

## 插件包结构

zip 解压后的根目录必须可被 Dora 当项目运行：

```text
init.lua
Script/Tools/SceneImGuiEditor.lua
Script/Tools/SceneEditor/*.lua
Script/Tools/SceneEditor/*.ts
```

`init.lua` 内容：

```lua
return require("Script.Tools.SceneImGuiEditor")
```

ResourceDownloader 下载后会解压到：

```text
Content.writablePath/Download/dora-visual-editor
```

运行时实际入口等价于：

```text
Download/dora-visual-editor/init.lua
```

## 为什么要保留 TS 和 Lua

- Dora 运行时实际执行 Lua。
- TS 是源代码，方便之后继续维护和重新编译。
- TSTL 注意事项：不要用 `null`，Lua 只有 `nil`，TS 侧用 `undefined`。

## 发布步骤

```bash
cd /Users/wangyue/dora/dora-visual-editor-plugin
python3 scripts/build_package.py /Users/wangyue/dora/Dora-SSR
git add .
git commit -s -m "Release visual editor package"
git push

gh release create v0.1.1 dist/dora-visual-editor-0.1.1.zip \
  --title "Dora Visual Editor v0.1.1" \
  --notes "Update visual editor package."
```

注意：版本号目前在 `scripts/build_package.py` 的 `VERSION` 常量里。

## 当前下载源

```text
https://raw.githubusercontent.com/dsadsasdaddas/dora-visual-editor-plugin/main
```

Release 页面：

```text
https://github.com/dsadsasdaddas/dora-visual-editor-plugin/releases/tag/v0.1.0
```
