# Xcode Cloud 内测配置说明

这个仓库是 SponsorBlock 的 Safari Web Extension Xcode 壳工程。Xcode Cloud 可以直接识别：

- Xcode 工程：`SponsorBlock for YouTube - Skip Sponsorships/SponsorBlock.xcodeproj`
- iOS Scheme：`SponsorBlock (iOS)`
- 构建脚本：`SponsorBlock for YouTube - Skip Sponsorships/ci_scripts/ci_post_clone.sh`

`ci_post_clone.sh` 会在 Xcode Cloud 克隆仓库后执行，负责初始化子模块、安装缺失的 Node.js、生成 `SponsorBlock/config.json`，并运行 `npm run build:safari` 生成 Safari 扩展资源。

## 准备仓库

1. 使用自己的 GitHub fork，不建议直接基于上游仓库配置 Xcode Cloud。
2. 保持仓库公开更省心，因为 SponsorBlock 使用 GPL-3.0，并带有允许 App Store/TestFlight 分发的附加说明。即使只给朋友测，也要保留源码和许可证文本。
3. 如果 Xcode Cloud 首次连接 GitHub，按 Xcode 或 App Store Connect 的提示授权访问这个 fork。

## 配置签名

打开：

`SponsorBlock for YouTube - Skip Sponsorships/SponsorBlock.xcodeproj`

选择 Scheme：

`SponsorBlock (iOS)`

在 Xcode 里逐个检查下面两个 iOS target：

- `SponsorBlock (iOS)`
- `SponsorBlock Extension (iOS)`

在 `Signing & Capabilities` 中设置：

- Team：选择你的 Apple Developer Program 团队
- Automatically manage signing：开启
- Bundle Identifier：换成你自己名下的唯一标识

推荐命名：

- 主 App：`com.ericterminal.sponsorblock`
- 扩展：`com.ericterminal.sponsorblock.extension`

如果这个 bundle id 已经被占用，改成你自己的域名前缀即可。主 App 和扩展必须是两个不同的 bundle id。

完成后，用 Xcode 或 Git 提交 `.xcodeproj` 的签名配置改动并推送到 GitHub。

## 配置 App Store Connect

1. 在 App Store Connect 创建 App 记录。
2. 平台选择 iOS。
3. Bundle ID 选择主 App 的 bundle id，例如 `com.ericterminal.sponsorblock`。
4. App 名称需要全站唯一，可以使用带个人构建标识的名字，例如 `SponsorBlock Eric Build`。
5. SKU 随便填一个稳定值，例如 `sponsorblock-eric-ios`。

## 配置 Xcode Cloud

在 Xcode 中打开工程后配置 Xcode Cloud：

1. 选择你的 fork 仓库。
2. 选择 Scheme：`SponsorBlock (iOS)`。
3. 添加 `Archive` action。
4. Platform 选择 iOS。
5. Deployment Preparation：
   - 发给普通朋友测试：选择 `TestFlight and App Store`。
   - 只给 App Store Connect 团队成员测试：可以选择 `TestFlight Internal Only`。
6. Start Condition 可以先设为手动触发，确认成功后再改为推送到 `master` 时自动触发。

Xcode Cloud 会自动运行仓库里的 `ci_post_clone.sh`。如果构建失败，优先看 Xcode Cloud 日志中 `ci_post_clone.sh` 的输出，确认 `npm ci` 和 `npm run build:safari` 是否成功。

## 发给朋友测试

如果朋友只是普通 Apple ID，不是你 App Store Connect 团队成员，需要走外部 TestFlight：

1. 在 App Store Connect 的 TestFlight 页面创建 External Testing 组。
2. 把 Xcode Cloud 生成的 build 加到这个组。
3. 填写测试说明并提交 Beta App Review。
4. 审核通过后，用邮箱邀请朋友，或者开启公开邀请链接。

如果你把朋友加成 App Store Connect 用户，可以走 Internal Testing，但这会给对方团队访问权限，通常不建议只为了一个朋友测试而这样做。

注意：Apple 当前文档说明，Xcode Cloud 生成的 build 通常需要在 App Store Connect 里手动加入测试组。

## 常见问题

如果 Xcode Cloud 报找不到 Safari 扩展资源，检查 `ci_post_clone.sh` 是否运行成功，尤其是 `SponsorBlock/dist/manifest.json` 是否在构建前生成。

如果 Xcode Cloud 报签名或 provisioning profile 错误，通常是主 App 或扩展 target 没有改成你的 Team 和唯一 bundle id，或者没有开启自动签名。

如果本机手动构建时出现 iOS 链接到 macOS SDK 的错误，先清掉环境变量再构建：

```sh
env -u SDKROOT -u LIBRARY_PATH -u CPATH -u C_INCLUDE_PATH -u CPLUS_INCLUDE_PATH -u OBJC_INCLUDE_PATH xcodebuild -project 'SponsorBlock for YouTube - Skip Sponsorships/SponsorBlock.xcodeproj' -scheme 'SponsorBlock (iOS)' -destination 'generic/platform=iOS' build
```

这里只作为本机排查命令。正常发内测时，优先使用 Xcode Cloud。

## 参考

- Apple：Writing custom build scripts
  https://developer.apple.com/documentation/xcode/writing-custom-build-scripts
- Apple：Configuring your Xcode Cloud workflow's actions
  https://developer.apple.com/documentation/xcode/configuring-your-xcode-cloud-workflow-s-actions
- Apple：Creating a Safari web extension
  https://developer.apple.com/documentation/safariservices/creating-a-safari-web-extension
- Apple：Invite external testers
  https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers
