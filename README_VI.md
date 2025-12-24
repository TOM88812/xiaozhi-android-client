<div align="center">
  <a href="./README.md">中文</a> | 
  <a href="./README_EN.md">English</a> | 
  <a href="./README_VI.md">Tiếng Việt</a>
</div>

# Xiaozhi AI Assistant Client Android / iOS
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

> Phiên bản mới đã được phát hành, mời bạn trải nghiệm! Đã thực hiện khử tiếng vang cho Flutter trên iOS và Android. ~~Hoan nghênh các PR~~.
> Nếu bạn thấy dự án hữu ích, hãy ủng hộ để tôi có thêm động lực phát triển.
> Dify hỗ trợ gửi hình ảnh tương tác. Có thể thêm nhiều agent Xiaozhi vào danh sách trò chuyện.

Xiaozhi AI Assistant được phát triển dựa trên framework Flutter, hỗ trợ triển khai đa nền tảng (iOS, Android, Web, Windows, macOS, Linux), cung cấp tính năng tương tác giọng nói thời gian thực và trò chuyện văn bản.

<table>
  <tr>
    <td align="center" valign="bottom" height="500">
      <table>
        <tr>
          <td align="center">
            <a href="https://www.bilibili.com/video/BV178EqzAEFf" target="_blank">
              <img src="1234.jpg" alt="Phiên bản mới"  width="200" height="430"/>
            </a>
          </td>
        </tr>
        <tr>
          <td align="center">
            <small>
  Phiên bản iOS, Android Client mới (Có thể tự đóng gói phiên bản Web, PC)<br>
  <a href="https://www.bilibili.com/video/BV1fgXvYqE61" style="color: red; text-decoration: none;">Nhấn vào đây để xem video demo</a>
</small>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

### Tính năng Phiên bản Thương mại V3 (Tương thích sâu với Server tự phát triển) 💼 
| Module Tính năng | Trạng thái | Mô tả |
|---------|------|------|
| **Giao diện thích ứng** | ✅ | Thích ứng giao diện sáng/tối hoặc theo thiết bị |
| **Nhà cung cấp dịch vụ AI** | ✅ | Hỗ trợ dịch vụ OpenAI, sử dụng LLM ngay trên điện thoại |
| **Chế độ suy nghĩ** | ✅ | Hỗ trợ OpenAI Thinking Mode |
| **Xem trước mã HTML** | ✅ | Mô hình viết mã HTML đơn giản để xem trước, lập trình AI trên điện thoại |
| **MCP_Client** | ✅ | Hỗ trợ gọi năng lực MCP, dữ liệu giao diện có thể tự tùy chỉnh (DIY) |
| **Tìm kiếm trực tuyến qua giao diện OpenAI** | ✅ | Hỗ trợ tìm kiếm trực tuyến qua dịch vụ giao diện OpenAI |
| **Phát video** | ✅ | Hỗ trợ phát video do mô hình trả về |
| **Kiểm tra tốc độ OpenAI** | ✅ | Kiểm tra tốc độ phản hồi giao diện OpenAI, biết ngay dịch vụ nhanh hay chậm |
| **Live2D** | ✅ | Chuyển đổi nhiều mô hình, hỗ trợ nhập nhân vật mô hình yêu thích của bạn |
| **IoT** | ✅ | Hỗ trợ gọi các chức năng điện thoại, điều hướng, nghe nhạc, v.v. |
| **Chế độ tâm trạng sáng tạo** | ✅ | Hỗ trợ chế độ ngắt lời thời gian thực |
| **MQTT-UDP** | ✅ | Hỗ trợ dịch vụ giao thức MQTT, kết nối dài (long connection) |
| **WS** | ✅ | Hỗ trợ dịch vụ giao thức WS |
| **Ngắt lời bằng giọng nói thời gian thực** | ✅ | Có thể ngắt lời bất cứ lúc nào khi Xiaozhi đang nói, nói những gì bạn muốn không ai ngăn cản |
| **Đa dịch vụ Xiaozhi** | ✅ | Thêm nhiều dịch vụ Xiaozhi, dễ dàng thực hiện mỗi người nhiều trợ lý |
| **Kết nối phần cứng** | ✅ | Có thể kết nối với phần cứng, bộ nhớ riêng biệt không lẫn lộn |
| **Tương thích sâu với Server** | ✅ | Tương thích với Server phiên bản thương mại |
| **Thông tin người dùng** | ✅ | Hiển thị thời gian hết hạn hội viên, số lượng cuộc trò chuyện, số lượng thiết bị đã liên kết, số lượng giọng nói (voiceprint), tình trạng sử dụng hạn ngạch, thiết bị hoạt động gần đây |
| **Quản lý thiết bị** | ✅ | Hỗ trợ xem tất cả các thiết bị của người dùng đang đăng nhập trên điện thoại, thêm thiết bị mới |
| **Quản lý vai trò** | ✅ | Hỗ trợ quản lý vai trò hiện tại của bạn trên điện thoại, tạo vai trò mới |
| **Quản lý giọng nói (Voiceprint)** | ✅ | Hỗ trợ ghi âm giọng nói trên điện thoại, giúp AI hiểu bạn hơn |
| **Lịch sử cuộc hội thoại** | ✅ | Hỗ trợ hiển thị lịch sử cuộc trò chuyện gần đây |
| **Quản lý bộ nhớ** | ✅ | Hỗ trợ hiển thị bộ nhớ |
| **Trang dành riêng** | ✅ | Các trang dành riêng cho sổ sách, việc cần làm, nhật ký, v.v. UI, có thể tích hợp mở rộng khả năng backend Xiaozhi, cộng tác với Xiaozhi để xây dựng trợ lý hiểu bạn |

### Tính năng Phiên bản Server Thương mại 💼 
| Module Tính năng | Trạng thái | Mô tả |
|---------|------|------|
| **Phản hồi câu đầu tiên** | ✅ | Thời gian phản hồi từ khóa đánh thức <1 giây, trải nghiệm phản hồi cực nhanh |
| **Tốc độ phản hồi trung bình** | ✅ | Thời gian phản hồi cuộc trò chuyện trung bình <2 giây (Mạng CDN công cộng) (Mạng nội bộ dưới 800ms), trải nghiệm trò chuyện mượt mà |
| **Giao thức MQTT** | ✅ | Hỗ trợ giao thức giao tiếp MQTT, kết nối dài, Server chủ động đánh thức |
| **Sao chép giọng nói** | ✅ | Hỗ trợ sao chép giọng nói Volcengine, thực hiện tùy chỉnh giọng nói cá nhân hóa |
| **Nhận dạng giọng nói** | ✅ | Hỗ trợ chức năng nhận dạng giọng nói, thực hiện trợ lý giọng nói cá nhân hóa |
| **Tương tác luồng hai chiều** | ✅ | Hỗ trợ phát trực tuyến Volcano, đầu vào giọng nói và đầu ra trả lời thời gian thực |
| **Client người dùng** | ✅ | Giao diện vận hành Client người dùng thân thiện, trang quản lý thiết bị dạng thẻ native |
| **Điểm truy cập MCP** | ✅ | Điểm truy cập công cụ MCP dựa trên vai trò, truy cập chức năng mở rộng (Đồng bộ dịch vụ Xiage) |
| **Dịch vụ MCP Hub** | ✅ | Hỗ trợ SSE/HTTP MCP Hub tích hợp thêm nhiều dịch vụ bên thứ ba |
| **Tùy chỉnh giao diện thiết bị ESP32** | ✅ | Hỗ trợ cấu hình trực tuyến chủ đề thiết bị ESP32, gói biểu cảm |
| **Function Call** | ✅ | Gọi công cụ, nâng cao trải nghiệm người dùng |
| **Bộ nhớ dài hạn** | ✅ | Trích xuất thông tin quan trọng dựa trên cuộc đối thoại của người dùng, quản lý bộ nhớ thông minh |
| **Bảng điều khiển giám sát** | ✅ | Giám sát Token theo ngày, tuần, tháng, thời lượng cuộc trò chuyện, hoạt động thiết bị, v.v. |
| **Nâng cấp firmware OTA** | ✅ | Tải lên firmware, tự động nâng cấp, quản lý thiết bị từ xa |
| **Trực quan hóa dữ liệu trò chuyện** | ✅ | Biểu đồ thống kê tần suất trò chuyện và các chức năng trực quan hóa dữ liệu khác, giám sát xu hướng dữ liệu cuộc đối thoại |
| **Hệ thống hội viên người dùng** | ✅ | Hỗ trợ thiết lập số lượng Token dựa trên cấp độ hội viên, hỗ trợ đăng ký tháng/năm, thanh toán trực tuyến (Alipay, WeChat, PayPal) |


## Thông tin liên hệ
- ## **email**
> lhht0606@163.com

- **wechat**
> Forever-Destin

# Hỗ trợ phát triển Client tùy chỉnh, vui lòng liên hệ WeChat

## Công cụ triển khai đồ họa Server
- https://space.bilibili.com/298384872
- https://znhblog.com/

## 🌟 Ủng hộ

Mỗi ngôi sao⭐ hoặc sự ủng hộ💖 của bạn là động lực để chúng tôi tiếp tục tiến lên🛸.
<div style="display: flex;">
<img src="zsm.jpg" width="260" height="280" alt="Ủng hộ" style="border-radius: 12px;" />
</div>

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/V7V71I0TE0)

# Danh sách ủng hộ
- ### ***Shanghai WoOu Culture Media Co., Ltd.***

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=TOM88812/xiaozhi-android-client&type=Date)](https://star-history.com/#TOM88812/xiaozhi-android-client&Date)
