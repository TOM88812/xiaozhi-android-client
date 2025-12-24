<div align="center">
  <a href="./README.md">中文</a> | 
  <a href="./README_EN.md">English</a> | 
  <a href="./README_VI.md">Tiếng Việt</a>
</div>

# Xiaozhi AI Assistant Android / iOS Client
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
  <a href="https://wiki.lhht.cc">
    <img src="https://img.shields.io/badge/Docs-Wiki-yellow?logo=wikipedia">
  </a>

</p>

> The new version has been released, please experience it! Echo cancellation for Flutter iOS and Android has been implemented. ~~PRs are welcome~~.
> If you find this project useful, feel free to donate. Every donation is my motivation to move forward.
> Dify supports sending image interactions. Multiple Xiaozhi agents can be added to the chat list.

Xiaozhi AI Assistant developed based on the Flutter framework, supporting multi-platform (iOS, Android, Web, Windows, macOS, Linux) deployment, providing real-time voice interaction and text conversation functions.

<table>
  <tr>
    <td align="center" valign="bottom" height="500">
      <table>
        <tr>
          <td align="center">
            <a href="https://www.bilibili.com/video/BV178EqzAEFf" target="_blank">
              <img src="1234.jpg" alt="New Version"  width="200" height="430"/>
            </a>
          </td>
        </tr>
        <tr>
          <td align="center">
            <small>
  New Version iOS, Android Client (Web and PC versions can be built manually)<br>
  <a href="https://www.bilibili.com/video/BV1fgXvYqE61" style="color: red; text-decoration: none;">Click to watch demo video</a>
</small>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

### V3 Commercial Version Features (Deeply Adapted to Self-developed Server) 💼 
| Feature Module | Status | Description |
|---------|------|------|
| **Adaptive Theme** | ✅ | Dark/Light theme adaptation/Follows device theme |
| **AI Service Provider** | ✅ | Supports OpenAI services, using LLMs on mobile |
| **Thinking Mode** | ✅ | Supports OpenAI Thinking Mode |
| **HTML Code Preview** | ✅ | Models write simple HTML code for preview, AI programming on mobile |
| **MCP_Client** | ✅ | Supports MCP capability calls, interface data can be DIYed |
| **OpenAI Interface Online Search** | ✅ | Supports OpenAI interface service online search |
| **Video Playback** | ✅ | Supports playing videos returned by models |
| **OpenAI Speed Test** | ✅ | OpenAI interface response speed test, service speed at a glance |
| **Live2D** | ✅ | Multi-model switching, supports importing your favorite model characters |
| **IoT** | ✅ | Supports calling phone functions, navigation, music listening, etc. |
| **Innovative Mood Mode** | ✅ | Supports real-time interruption mode |
| **MQTT-UDP** | ✅ | Supports MQTT protocol service, long connection |
| **WS** | ✅ | Supports WS protocol service |
| **Real-time Voice Interruption** | ✅ | Interrupt at will while Xiaozhi is speaking, say what you want unstoppable |
| **Multiple Xiaozhi Services** | ✅ | Add multiple Xiaozhi services, easily implement multiple assistants per person |
| **Hardware Integration** | ✅ | Interconnect with hardware, separate memories |
| **Deep Adaptation to Server** | ✅ | Adapted to commercial version server |
| **User Information** | ✅ | Display membership expiration time, conversation count, bound device count, voiceprint count, quota usage, recent active devices |
| **Device Management** | ✅ | Supports mobile viewing of all devices for the current logged-in user, adding new devices |
| **Role Management** | ✅ | Supports mobile management of your current role, creating new roles |
| **Voiceprint Management** | ✅ | Supports mobile voiceprint recording, making your AI understand you better |
| **Conversation History** | ✅ | Supports displaying recent conversation records |
| **Memory Management** | ✅ | Supports displaying memories |
| **Reserved Pages** | ✅ | Reserved pages for bookkeeping, todo, diary, etc. UI, can integrate Xiaozhi backend capabilities extension, collaborate with Xiaozhi to build an assistant that understands you |

### Server Commercial Version Features 💼 
| Feature Module | Status | Description |
|---------|------|------|
| **First Sentence Response** | ✅ | Wake word response time <1s, extreme speed response experience |
| **Average Response Speed** | ✅ | Average conversation response time <2s (Public CDN network) (Local intranet limit within 800ms), smooth conversation experience |
| **MQTT Protocol** | ✅ | Supports MQTT communication protocol, long connection, server active wake-up |
| **Voice Cloning** | ✅ | Supports Volcengine voice cloning, realizing personalized voice customization |
| **Voiceprint Recognition** | ✅ | Supports voiceprint recognition function, realizing personalized voice assistant |
| **Bi-directional Streaming Interaction** | ✅ | Supports Volcano streaming playback, real-time voice input and reply output |
| **User Client** | ✅ | Friendly user client operation interface, native card-style device management page |
| **MCP Access Point** | ✅ | Role-based MCP tool access point, extension function access (Sync Xiage Service) |
| **MCP Hub Service** | ✅ | SSE/HTTP MCP Hub support for more third-party service integration |
| **ESP32 Device Theme Customization** | ✅ | Supports online configuration of ESP32 device themes and sticker packs |
| **Function Call** | ✅ | Tool calling, improving user experience |
| **Long-term Memory** | ✅ | Extract key information records based on user dialogue, intelligent memory management |
| **Monitoring Panel** | ✅ | Monitor Token, conversation duration, device activity, etc. data in day, week, month dimensions |
| **OTA Firmware Upgrade** | ✅ | Firmware upload, automatic upgrade, remote device management |
| **Chat Data Visualization** | ✅ | Chat frequency statistical charts and other data visualization functions, monitoring conversation data trends |
| **User Membership System** | ✅ | Supports setting Token count based on membership level, supports monthly/yearly subscription, online payment (Alipay, WeChat, PayPal) |


## Contact Information
- ## **email**
> lhht0606@163.com

- **wechat**
> Forever-Destin

# For customized client development support, please contact WeChat

## Server Graphical Deployment Tool
- https://space.bilibili.com/298384872
- https://znhblog.com/

## 🌟 Support

Your every star⭐ or donation💖 is our motivation to keep moving forward🛸.
<div style="display: flex;">
<img src="zsm.jpg" width="260" height="280" alt="Donate" style="border-radius: 12px;" />
</div>

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/V7V71I0TE0)

# Donation List
- ### ***Shanghai WoOu Culture Media Co., Ltd.***

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=TOM88812/xiaozhi-android-client&type=Date)](https://star-history.com/#TOM88812/xiaozhi-android-client&Date)
