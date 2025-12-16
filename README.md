# 小智AI助手 Android IOS 客户端
<p align="center">
  <a href="https://github.com/TOM88812/xiaozhi-android-client/releases/latest">
    <img src="https://img.shields.io/github/v/release/TOM88812/xiaozhi-android-client?style=flat-square&logo=github&color=blue" alt="Release"/>
  </a>
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache_2.0-green.svg?style=flat-square" alt="License: Apache-2.0"/>
  </a>
  <a href="https://github.com/TOM88812/xiaozhi-android-client/stargazers">
    <img src="https://img.shields.io/github/stars/TOM88812/xiaozhi-android-client?style=flat-square&logo=github" alt="Stars"/>
  </a>
  <a href="https://github.com/TOM88812/xiaozhi-android-client/releases/latest">
    <img src="https://img.shields.io/github/downloads/TOM88812/xiaozhi-android-client/total?style=flat-square&logo=github&color=52c41a1&maxAge=86400" alt="Download"/>
  </a>
  <a href="https://wiki.lhht.cc/welcome">
    <img src="https://img.shields.io/badge/文档-Wiki-yellow?logo=wikipedia">
  </a>

</p>

> 目前已经发布新版本，敬请体验！flutter IOS与安卓回音消除已实现，~~欢迎大家PR~~。
> 觉得项目对您有用的，可以赞赏一下，您的每一次赞赏都是我前进的动力。
> Dify支持发送图片交互。可以添加多个小智智能体到聊天列表。

一个基于WebSocket的Android语音对话应用,支持实时语音交互和文字对话。
基于Flutter框架开发的小智AI助手，支持多平台（iOS、Android、Web、Windows、macOS、Linux）部署，提供实时语音交互和文字对话功能。

<table>
  <tr>
    <td align="center" valign="bottom" height="500">
      <table>
        <tr>
          <td align="center">
            <a href="https://www.bilibili.com/video/BV178EqzAEFf" target="_blank">
              <img src="1234.jpg" alt="新版"  width="200" height="430"/>
            </a>
          </td>
        </tr>
        <tr>
          <td align="center">
            <small>
  新版IOS、安卓端（可以自行打包WEB、PC版本)<br>
  <a href="https://www.bilibili.com/video/BV1fgXvYqE61" style="color: red; text-decoration: none;">观看demo视频点击跳转</a>
</small>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

### V3 版本 商业版功能（深度适配自研服务端） 💼 
| 功能模块 | 状态 | 描述 |
|---------|------|------|
| **自适应主题** | ✅ | 深色/浅色主题适配/跟随设备切换主题 |
| **AI服务提供商** | ✅ | 支持Openai服务，手机上也能用大模型 |
| **思考模式** | ✅ | 支持Openai思考模式 |
| **HTML代码预览** | ✅ | 模型写简单HTML代码进行预览，手机也能ai编程 |
| **MCP_Client** | ✅ | 支持MCP能力调用，接口数据都能DIY|
| **OpenAI接口联网搜索** | ✅ | 支持Oenai 接口服务联网搜索|
| **视频播放** | ✅ | 支持播放模型返回的视频 |
| **OpenAI 测速** | ✅ | openai接口响应测速，服务快不快一眼见|
| **Live2D** | ✅ | 多模型切换、支持导入自己心爱的模型人物 |
| **Iot** | ✅ | 支持调用手机功能、导航、听歌等 |
| **创新性心情模式** | ✅ | 支持实时打断模式 |
| **MQTT-UDP** | ✅ | 支持MQTT协议服务，长连接 |
| **WS** | ✅ | 支持ws协议服务 |
| **语音实时打断** | ✅ | 能在小智说话的期间随意打断，说您想说无人能挡 |
| **多小智服务** | ✅ | 添加多个小智服务，轻松实现每人多助手 |
| **打通硬件端** | ✅ | 可与硬件端互通，记忆不串 |
| **深度适配服务端** | ✅ | 适配商业版服务端 |
| **用户信息** | ✅ | 展示会员到期时间，对话数量、绑定设备数量、声纹数量、配额使用情况、最近活动设备|
| **设备管理** | ✅ | 支持手机端查看当前登录用户的所有设备、新增设备 |
| **角色管理** | ✅ | 支持手机端管理您当前角色、新建角色|
| **声纹管理** | ✅ | 支持手机端录制声纹，让您的AI更懂您|
| **对话记录** | ✅ | 支持展示最近的对话记录|
| **记忆管理** | ✅ | 支持展示记忆|
| **预留页面** | ✅ | 预留记账、代办、日记等页面UI，可集成小智后端能力扩展，协同小智，打造了解您的助手|

### 服务端 商业版功能 💼 
| 功能模块 | 状态 | 描述 |
|---------|------|------|
| **首句响应** | ✅ | 唤醒词响应时间 <1秒，极速响应体验 |
| **平均响应速度** | ✅ | 平均对话响应时间 <2秒，流畅对话体验 |
| **MQTT协议** | ✅ | 支持MQTT通信协议，长连接、服务端主动唤醒 |
| **音色克隆** | ✅ | 支持火山引擎与阿里云音色克隆，实现个性化声音定制 |
| **声纹识别** | ✅ | 支持声纹识别功能，实现个性化语音助手 |
| **双向流式交互** | ✅ | 支持火山流式播放，实时语音输入和回复输出 |
| **用户端** | ✅ | 友好的用户端操作界面，原生卡片方式设备管理页面 |
| **MCP接入点** | ✅ | 基于角色的MCP工具接入点，扩展功能接入（同步虾哥服务） |
| **MCP Hub服务** | ✅ | SSE/HTTP MCP Hub支持更多第三方服务集成 |
| **ESP32 设备主题自定义** | ✅ | 支持在线配置esp32设备的主题、表情包 |
| **Function Call** | ✅ | 工具调用，提升用户体验 |
| **长期记忆** | ✅ | 根据用户对话，提取关键信息记录，智能记忆管理 |
| **监控面板** | ✅ | 监控日、周、月不同维度Token，对话时长，设备活跃等数据 |
| **OTA固件升级** | ✅ | 固件上传，自动升级，远程设备管理 |
| **聊天数据可视化** | ✅ | 聊天频率统计图表等数据可视化功能，监控对话数据趋势 |
| **用户会员制** | ✅ | 支持更具会员等级设置Token数，支持包月/年，在线支付（支付宝、微信、PayPal） |


## 联系方式
- ## **email**
> lhht0606@163.com

- **wechat**
> Forever-Destin

# 支持提供定制化开发客户端可以联系WeChat

## 服务端图形化部署工具
- https://space.bilibili.com/298384872
- https://znhblog.com/

## 🌟支持

您的每一个start⭐或赞赏💖，都是我们不断前进的动力🛸。
<div style="display: flex;">
<img src="zsm.jpg" width="260" height="280" alt="赞助" style="border-radius: 12px;" />
</div>

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/V7V71I0TE0)

# 赞助榜
- ### ***上海沃欧文化传媒有限公司***

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=TOM88812/xiaozhi-android-client&type=Date)](https://star-history.com/#TOM88812/xiaozhi-android-client&Date)
