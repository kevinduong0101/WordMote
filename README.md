# WordMote

<p align="center">
  <img src="AppIcon.png" alt="WordMote Logo" width="128" height="128"><br>
  <b>Minimalist Desktop Widget & Smart Spaced Repetition Vocabulary Learning App for macOS</b><br>
  <i>Master English vocabulary effortlessly through ambient desktop immersion and smart active recall.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2013.0%2B-black?style=flat-square&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Language-Swift%205.9%2B-orange?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20AppKit-blue?style=flat-square" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
</p>

---

### 🌐 Language Selector / Chọn ngôn ngữ / 选择语言 / 言語を選択 / เลือกภาษา
<p align="center">
  <b><a href="#-english">🇬🇧 English</a></b> •
  <b><a href="#-tiếng-việt">🇻🇳 Tiếng Việt</a></b> •
  <b><a href="#-简体中文">🇨🇳 简体中文</a></b> •
  <b><a href="#-日本語">🇯🇵 日本語</a></b> •
  <b><a href="#-ภาษาไทย">🇹🇭 ภาษาไทย</a></b>
</p>

---

<a name="-english"></a>
## 🇬🇧 English

### Overview
**WordMote** is a native macOS application engineered for passive ambient learning and active retrieval practice. Rather than forcing users into high-friction study sessions, it seamlessly embeds interactive vocabulary cards onto the macOS desktop layer, schedules spaced repetition reviews, and conducts intelligent active recall quizzes that automatically respect your focus.

### ✨ Key Features
1. **Desktop Ambient Widget**
   - Sleek glassmorphic (`NSVisualEffectView`) card pinned directly to the desktop layer.
   - Non-activating panel (`NSPanel` with `acceptsFirstMouse`) that stays accessible without stealing focus.
   - High-definition GIF / WebP / Image visual cue integration via WebKit.
   - **One-Click Native Pronunciation**: Click any English word or speaker icon to trigger native US audio pronunciation powered by `AVSpeechSynthesizer`.

2. **Adaptive Spaced Repetition System (SRS)**
   - Smart scheduling algorithm that automatically calibrates review intervals based on consecutive recall streaks:
     - Streak 1 & 2: Review after 1 day.
     - Streak 3 & 4: Review after 3 days.
     - Streak 5: Review after 5 days.
     - Streak 6+: Review extended by +5 days per successful streak ($Days = (Streak - 4) \times 5$).
   - Never deletes or loses mastered words; dynamically schedules reviews when memory retention begins to fade.

3. **Active Recall Pop-up Quiz**
   - Periodic interactive challenge modal with two 50/50 randomized quiz modes:
     - **Multiple Choice**: Identify the correct definition from randomized distractors.
     - **Typing Recall**: Type the exact English word corresponding to a given definition (case-insensitive with auto-trimming).
   - Instant visual validation (green success feedback, red shake animation for errors).
   - Persistent always-on-top window with dedicated **30-minute** and **1-hour** snooze buttons for busy moments.

4. **Smart Do-Not-Disturb (Fullscreen Detection)**
   - Utilizes low-level macOS CoreGraphics Window Server APIs (`CGWindowListCopyWindowInfo`) to inspect display layers.
   - Automatically detects when you are watching movies (Netflix, YouTube), giving presentations, or playing full-screen games.
   - Silently postpones the quiz by 10 minutes without showing intrusive alerts.

5. **Menu Bar Quick Control & Library**
   - Resides neatly in the macOS Status Bar with a custom interactive popover menu.
   - Live Status Bar title updating to display the currently active word in real time.
   - Library card manager featuring duplicate word detection, instant editing, and hover-action controls.

### 📥 Download & Install (For Users)
1. Go to the [Releases](https://github.com/kevinduong0101/WordMote/releases) tab.
2. Download the latest `WordMote.dmg`.
3. Open `WordMote.dmg` and drag `WordMote.app` into your **Applications** folder.
4. *macOS Gatekeeper note*: If macOS alerts "unidentified developer", simply Right-click `WordMote.app` > **Open**, or go to **System Settings** > **Privacy & Security** > **Open Anyway**.

### 🛠️ Build & Run (For Developers)
```bash
# 1. Clone the repository
git clone https://github.com/kevinduong0101/WordMote.git
cd WordMote

# 2. Open project in Xcode
open VocabPopApp/VocabPopApp.xcodeproj
```
- In Xcode, select destination **My Mac**.
- Press `Cmd + R` to compile and launch.

---

<a name="-tiếng-việt"></a>
## 🇻🇳 Tiếng Việt

### Giới thiệu
**WordMote** là ứng dụng học từ vựng tiếng Anh chuyên sâu dành riêng cho macOS, kết hợp giữa việc "ngấm từ vựng thụ động" ngay trên màn hình nền Desktop và "truy hồi chủ động" qua các bài trắc nghiệm ngẫu nhiên, giúp bạn ghi nhớ từ vựng lâu dài mà không bị ngắt quãng dòng làm việc.

### ✨ Tính năng nổi bật
1. **Widget kính mờ dán chặt Desktop**
   - Thiết kế chuẩn Apple Glassmorphism siêu sang, nằm chìm trên màn hình nền Desktop nhưng vẫn bấm tương tác được ngay lập tức (`acceptsFirstMouse`).
   - Tích hợp ảnh GIF/ảnh minh hoạ động giúp kích thích trí nhớ hình ảnh.
   - **Phát âm chuẩn bản ngữ**: Nhấn trực tiếp vào chữ tiếng Anh bất kỳ để nghe đọc chuẩn giọng Mỹ (`AVSpeechSynthesizer`).

2. **Thuật toán lặp lại ngắt quãng thông minh (SRS)**
   - Không máy móc xóa từ khi thuộc, thuật toán tự động giãn cách thời gian ôn tập theo chuỗi ghi nhớ liên tiếp:
     - Đúng 1 - 2 lần: Ôn lại sau 1 ngày.
     - Đúng 3 - 4 lần: Giảm tần suất, ôn lại sau 3 ngày.
     - Đúng 5 lần: Ôn lại sau 5 ngày.
     - Đúng 6 lần trở lên: Ôn lại sau 10 ngày, 15 ngày, 20 ngày...

3. **Pop-up Quiz kiểm tra trí nhớ tương tác**
   - Tự động hiện câu hỏi kiểm tra sau khoảng thời gian tùy chọn với 2 chế độ ngẫu nhiên 50/50:
     - **Trắc nghiệm 4 lựa chọn (A, B, C, D)**: Lấy nghĩa ngẫu nhiên từ thư viện từ vựng.
     - **Gõ từ (Typing Mode)**: Đưa ra định nghĩa tiếng Việt, bắt buộc bạn gõ đúng chính xác từ tiếng Anh (không phân biệt hoa thường).
   - Hiệu ứng rung lắc khi chọn sai và viền xanh khi trả lời đúng.
   - Cửa sổ nổi trên cùng, có 2 nút **Snooze 30 phút** và **Snooze 1 giờ** khi bạn đang bận.

4. **Chế độ Không làm phiền khi xem phim (Fullscreen Detection)**
   - Quét ngầm hệ thống qua macOS CoreGraphics: Nếu bạn đang xem Netflix, YouTube toàn màn hình hoặc chơi game, ứng dụng sẽ **tự động hoãn câu hỏi 10 phút một cách im lặng**, tuyệt đối không làm tụt cảm xúc xem phim.

5. **Điều khiển Menu Bar & Quản lý thư viện**
   - Biểu tượng não bộ trên thanh Menu Bar hiển thị trực tiếp từ vựng đang học theo thời gian thực.
   - Thư viện quản lý từ dạng thẻ (Card), có tính năng phát hiện và cảnh báo chống thêm từ trùng lặp.

### 📥 Tải & Cài đặt file .dmg
1. Truy cập vào mục [Releases](https://github.com/kevinduong0101/WordMote/releases).
2. Tải file `WordMote.dmg` mới nhất về máy.
3. Kéo biểu tượng `WordMote` vào thư mục **Applications**.
4. *Lưu ý macOS*: Lần đầu mở app nếu có thông báo bảo mật, chỉ cần Chuột phải vào app > chọn **Open** (hoặc vào **Cài đặt máy** > **Quyền riêng tư & Bảo mật** > bấm **Open Anyway**).

---

<a name="-简体中文"></a>
## 🇨🇳 简体中文

### 概述
**WordMote** 是一款专为 macOS 设计的原生轻量级英语词汇学习工具。采用“桌面潜意识浸润 + 智能间隔重复（SRS）+ 主动召回测验”的科学记忆闭环，让您在日常电脑办公与学习过程中毫不费力地积累掌握大量高级词汇。

### ✨ 核心功能
1. **桌面毛玻璃微件（Desktop Widget）**
   - 原生 Apple Glassmorphism 设计，轻巧贴合在桌面壁纸层，随手点击即可交互（`acceptsFirstMouse` 无缝捕获鼠标）。
   - 支持高品质动图与图片辅助记忆，激活图像记忆网络。
   - **一键原声音频朗读**：轻点任何英文单词，即可通过内置 `AVSpeechSynthesizer` 聆听标准美音发音。

2. **自适应间隔重复记忆算法（SRS）**
   - 告别简单机械的“背完即删”，系统依据您的连续正确召回次数动态调整复习间距：
     - 连续答对 1 - 2 次：次日（1天后）复习。
     - 连续答对 3 - 4 次：降低出现频率，3天后复习。
     - 连续答对 5 次：5天后复习。
     - 连续答对 6 次及以上：每成功一次延长5天（10天、15天、20天...）。

3. **主动召回弹窗测验（Quiz Pop-up）**
   - 定时弹出沉浸式测验，随机采用两种 50/50 挑战形式：
     - **四选一客观题**：从词库中动态抽取混淆项，快速识别词义。
     - **拼写填空题**：根据释义拼写完整的英文单词（不区分大小写，自动滤除首尾空格）。
   - 答错微件震动报错，答对变绿并自动计入 SRS 熟练度。
   - 置顶窗口防跳过，并配备 **小憩30分钟（Snooze 30m）** 与 **小憩1小时（Snooze 1h）** 便捷控制。

4. **智能全屏防打扰（Smart Do-Not-Disturb）**
   - 底层调用 macOS CoreGraphics 窗口服务 API，精确判定前台是否有全屏应用。
   - 当您在全屏观看 Netflix、YouTube 视频或畅玩全屏游戏时，系统**静默顺延 10 分钟**，绝不突兀弹出打扰。

5. **菜单栏极简交互与词库管理**
   - 顶部状态栏图标旁实时同步显示当前正在学习的词汇。
   - 卡片式词库管理界面，具备智能查重功能，防止录入重复词条。

---

<a name="-日本語"></a>
## 🇯🇵 日本語

### 概要
**WordMote** は、macOS のために開発されたスマートな英単語学習・定着アプリケーションです。「デスクトップ環境への自然な浸透」と「アクティブリコール（想起訓練）に基づく間隔反復学習（SRS）」を融合させ、普段のPC作業の邪魔をすることなく、確実な語彙力向上を実現します。

### ✨ 主な特長
1. **デスクトップ常駐型すりガラスウィジェット**
   - macOS 純正の美しいグラスモーフィズムデザイン（`NSVisualEffectView`）。
   - 他のウィンドウのフォーカスを奪うことなく、ワンクリックで操作可能な `acceptsFirstMouse` 仕様。
   - GIF/画像の視覚的フックによる記憶定着の促進。
   - **ワンタップネイティブ音声読み上げ**：単語をクリックするだけで、Apple の音声合成エンジンによる正確なアメリカ英語の発音（TTS）が再生されます。

2. **適応型分散学習システム（SRS）**
   - 単語を忘却曲線に合わせて最適なタイミングで自動再出題：
     - 連続正解 1〜2 回：翌日（1日後）に再復習。
     - 連続正解 3〜4 回：出現頻度を抑え、3日後に復習。
     - 連続正解 5 回：5日後に復習。
     - 連続正解 6 回以上：10日、15日、20日…と正解ごとに5日間隔を延長。

3. **ポップアップ即時テスト（Pop-up Quiz）**
   - 定期的に表示されるインタラクティブな確認テスト（50/50 の確率で形式が変動）：
     - **4択選択問題**：ランダムに生成された選択肢から正しい意味を選択。
     - **スペリング入力問題**：表示された意味に対応する英単語を正確に入力（大文字・小文字は自動判別）。
   - 正解時はグリーン点灯、不正解時はシェイクアニメーションでフィードバック。
   - 集中したい時のための「**30分スヌーズ**」「**1時間スヌーズ**」ボタンを完備。

4. **全画面メディア自動検知・非通知機能（Do Not Disturb）**
   - macOS CoreGraphics API を活用し、画面がフルスクリーン状態かどうかを常時監視。
   - Netflix や YouTube の全画面視聴中、またはゲームプレイ中は、**テストの表示を自動的かつ静かに10分間延期**します。

5. **メニューバー統合＆単語管理ライブラリ**
   - メニューバー上に現在学習中の単語がリアルタイム表示されます。
   - 重複登録防止アラート、ホバー操作による編集・削除機能を備えた洗練されたカード型ライブラリ。

---

<a name="-ภาษาไทย"></a>
## 🇹🇭 ภาษาไทย

### ภาพรวม
**WordMote** คือแอปพลิเคชันสำหรับ macOS ที่ออกแบบมาเพื่อการเรียนรู้และจดจำคำศัพท์ภาษาอังกฤษอย่างมีประสิทธิภาพ ผสมผสานระหว่าง "การซึมซับคำศัพท์ผ่านหน้าจอเดสก์ท็อป" และ "การทดสอบความจำแบบเว้นระยะ (Spaced Repetition System - SRS)" ช่วยให้คุณจำคำศัพท์ได้อย่างแม่นยำและยาวนานโดยไม่รบกวนการทำงานประจำวัน

### ✨ ฟีเจอร์เด่น
1. **วิดเจ็ตเดสก์ท็อปกระจกฝ้าสุดมินิมอล**
   - ดีไซน์ Glassmorphism ที่สวยงามกลมกลืนกับระบบ macOS พร้อมโต้ตอบได้ทันทีโดยไม่แย่งโฟกัสของแอปอื่น (`acceptsFirstMouse`)
   - รองรับภาพ GIF และภาพนิ่งเพื่อช่วยกระตุ้นความจำผ่านภาพ
   - **ออกเสียงคำศัพท์ด้วยสำเนียงแท้**: เพียงคลิกที่ตัวอักษรภาษาอังกฤษ ระบบจะออกเสียงคำศัพท์สำเนียงอเมริกันทันทีด้วย `AVSpeechSynthesizer`

2. **ระบบการจำคำศัพท์แบบเว้นระยะอัจฉริยะ (SRS Algorithm)**
   - ปรับรอบเวลาการทบทวนคำศัพท์ตามความแม่นยำอย่างเป็นธรรมชาติ:
     - ตอบถูก 1 - 2 ครั้งติดกัน: ทบทวนใหม่ในอีก 1 วัน
     - ตอบถูก 3 - 4 ครั้งติดกัน: แสดงน้อยลง ทบทวนในอีก 3 วัน
     - ตอบถูก 5 ครั้งติดกัน: ทบทวนในอีก 5 วัน
     - ตอบถูก 6 ครั้งขึ้นไป: ขยายระยะเวลาเพิ่มขึ้นครั้งละ 5 วัน (10 วัน, 15 วัน, 20 วัน...)

3. **หน้าต่างควิซทดสอบความจำ (Pop-up Quiz)**
   - แจ้งเตือนทดสอบคำศัพท์เป็นรอบๆ โดยสุ่มรูปแบบคำถาม 50/50:
     - **แบบปรนัย 4 ตัวเลือก (A, B, C, D)**: ดึงความหมายจากคลังคำศัพท์มาเป็นตัวเลือก
     - **แบบพิมพ์คำศัพท์ (Typing Mode)**: แสดงความหมายภาษาไทยและให้คุณพิมพ์คำศัพท์ภาษาอังกฤษที่ถูกต้อง (ไม่แยกตัวพิมพ์เล็ก-ใหญ่)
   - หน้าต่างลอยอยู่ด้านบนสุด พร้อมปุ่ม **Snooze 30 นาที** และ **Snooze 1 ชั่วโมง** เมื่อคุณต้องการสมาธิ

4. **โหมดตรวจจับภาพยนตร์เต็มหน้าจอ (Smart Do-Not-Disturb)**
   - ระบบตรวจจับหน้าต่างอัตโนมัติผ่าน macOS CoreGraphics: หากคุณกำลังดู Netflix, YouTube เต็มจอ หรือเล่นเกม แอปจะ**เลื่อนเวลาควิซออกไป 10 นาทีโดยอัตโนมัติและเงียบสนิท** ไม่เด้งขึ้นมากวนใจ

5. **ควบคุมผ่าน Menu Bar และระบบจัดการคำศัพท์**
   - แสดงคำศัพท์ปัจจุบันบนแถบสถานะ (Menu Bar) แบบเรียลไทม์
   - ระบบคลังคำศัพท์รูปแบบการ์ด มีระบบแจ้งเตือนป้องกันการเพิ่มคำศัพท์ซ้ำอย่างชาญฉลาด

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
