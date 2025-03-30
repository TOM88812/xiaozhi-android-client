# 小智AI助手 Android客户端

> 还在修复一些bug，晚些发布，特此声明。目前还是老版本

一个基于WebSocket的Android语音对话应用,支持实时语音交互和文字对话。
基于Flutter框架开发的小智AI助手，支持多平台（iOS、Android、Web、Windows、macOS、Linux）部署，提供实时语音交互和文字对话功能。

<table>
  <tr>
    <td align="center" valign="bottom" height="500">
      <table>
        <tr>
          <td align="center">
            <a href="https://www.bilibili.com/video/BV1fgXvYqE61" target="_blank">
              <img src="2345.jpg" alt="新版"  width="200" height="430"/>
            </a>
          </td>
        </tr>
        <tr>
          <td align="center">
            <small>
  新版IOS、安卓端（可以自行打包WEB、PC版本)<br>
  -- <a href="https://www.bilibili.com/video/BV1fgXvYqE61" style="color: red; text-decoration: none;">观看demo视频点击跳转</a>
</small>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

## 功能特点

- **跨平台支持**：使用Flutter框架，一套代码支持多平台
- **多AI模型支持**：
  - 集成小智AI服务（WebSocket实时语音对话）
  - 支持Dify
- **丰富的交互方式**：
  - 支持实时语音通话（持续对话）
  - 支持文字消息交互
  - 支持图片消息
  - 支持通话手动打断
  - 支持按住说话
- **多样化界面**：
  - 深色/浅色主题适配 （暂无适配）
  - 轻度拟物化
  - 自适应UI布局
  - 精美动画效果
- **系统功能**：
  - 多种AI服务配置管理
  - 自动重连机制
  - 语音/文字会话混合历史

## 系统要求

- **Flutter**: ^3.7.0
- **Dart**: ^3.7.0
- **iOS**: 12.0+
- **Android**: API 21+ (Android 5.0+)
- **Web**: 现代浏览器支持
- **桌面平台**: Windows 10+, macOS 10.15+, Linux (支持GTK)

## 安装与构建

1. 克隆项目:
```bash
git clone https://github.com/TOM88812/xiaozhi-android-client.git
```

2. 安装依赖:
```bash
flutter pub get
```

3. 运行应用:
```bash
flutter run
```

4. 构建发布版本:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

5. 如果没有证书:
安卓无影响。
IOS、Mac可以按照无签名的方法打包，使用第三方工具侧载。
> 👉APK签名 [获取证书](https://www.yunedit.com/xueyuan/jx/createcert)
> 👉IPA签名 [获取证书](https://www.yunedit.com/xueyuan/jx/ioscert004) 或者 [爱思助手](https://www.i4.cn/news_detail_38195.html)

## 配置说明

### 小智服务配置
- 支持配置多个小智服务地址
- WebSocket URL设置
- Token认证
- 自定义MAC

### Dify API配置
- 支持配置多个Dify服务
- API密钥管理
- 服务器URL配置


## 开发计划
- [ ] 深色/浅色主题适配
- [ ] 支持更多AI服务提供商
- [ ] 增强语音识别准确性
- [ ] 支持MQTT
- [ ] 支持Iot映射手机操作


## 🌟支持

您的每一个start⭐或赞赏💖，都是我们不断前进的动力🛸。
<div style="display: flex;">
<img src="zsm.jpg" width="260" height="280" alt="赞助" style="border-radius: 12px;" />
</div>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=TOM88812/xiaozhi-android-client&type=Date)](https://star-history.com/#TOM88812/xiaozhi-android-client&Date)
