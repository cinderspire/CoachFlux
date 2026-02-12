<div align="center">

# 🧠 CoachFlux

### **11 Coaches. One You. Zero Excuses.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Gemini](https://img.shields.io/badge/Gemini_Flash_2.0-AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![RevenueCat](https://img.shields.io/badge/RevenueCat-Subscriptions-F25A5A?style=for-the-badge)](https://revenuecat.com)
[![License](https://img.shields.io/badge/License-Proprietary-333?style=for-the-badge)](#license)

<br/>

**11 specialized AI coaches · 19 evidence-based techniques · One app that transforms how 8 billion people access personal growth — for less than a cup of coffee.**

*The average life coaching session costs $300. CoachFlux delivers expert-level coaching for $0.03/month in AI costs.*

<br/>

[Features](#-features) · [Tech Stack](#-tech-stack) · [Architecture](#-architecture) · [RevenueCat](#-revenuecat-integration) · [Build & Run](#-build--run) · [License](#-license)

</div>

---

## 🔥 The Problem

The coaching industry generates **$20B/year**, yet **96% of the world** is priced out. Therapy waitlists stretch 6–12 weeks. Wellness apps give you a meditation timer and call it a day.

**CoachFlux** makes world-class coaching universally accessible by combining clinically-informed AI with Gemini Flash 2.0's breakthrough economics: **$0.10 per million tokens**.

---

## 🎯 Features

### 🧠 11 Specialized AI Coaches

Each coach has **2,000+ words** of carefully engineered system architecture — distinct worldview, communication style, and intervention strategies.

| Coach | Specialty | Methodology |
|:------|:----------|:------------|
| 🩺 **Dr. Aura** | AI Psychologist | CBT, DBT, ACT, IFS, Schema Therapy |
| 🏛️ **Marcus** | Stoic Mentor | Ancient philosophy × modern resilience |
| 🚀 **Nova** | Career Strategist | Goal-setting, negotiation, leadership |
| 🧘 **Sage** | Mindfulness Guide | Meditation, breathwork, awareness |
| 💪 **Atlas** | Fitness & Wellness | Habit science, movement, nutrition |
| 🎨 **Luna** | Creative Catalyst | Flow states, unblocking, artistic growth |
| 🔥 **Phoenix** | Transformation Coach | Life transitions, reinvention, grief |
| 💕 **Ember** | Relationship Expert | Attachment theory, boundaries |
| ⚡ **Zen** | Productivity Master | Deep work, systems thinking |
| 💰 **Aria** | Financial Wellness | Money mindset, wealth building |
| 🛠️ **Custom** | Coach Builder | Design your own AI coach from scratch |

### 🌟 Core Capabilities

- **🎭 Mood-Adaptive Conversations** — Real-time emotional signal analysis shifts tone and intervention strategy dynamically
- **🧬 Chemistry Score** — Proprietary algorithm that surfaces your ideal coach match and improves over time
- **📈 Transformation Journey** — Psychological phase tracking (Awareness → Exploration → Commitment → Integration → Mastery)
- **🌱 Growth Garden** — Living visual metaphor for progress. Duolingo's streak mechanic meets a Zen garden
- **🏆 Achievements & XP** — 12+ milestone badges, leveling system that makes growth feel like a game
- **📓 Coaching Journal** — AI-generated session summaries with insights, action items, and emotional arc tracking
- **📊 Insights Dashboard** — Mood trends, session frequency, growth velocity, weekly AI reflections
- **💎 Wisdom Collection** — Shareable cards of your most powerful coaching moments
- **🎨 Mood-Reactive UI** — Color palette subtly shifts based on detected emotional state

### 🔬 19 Evidence-Based Techniques

Pomodoro Timer · Box Breathing · SMART Goals · Budget Calculator · Gratitude Journaling · Cognitive Reframing · Values Clarification · Progressive Muscle Relaxation · and 11 more — all **woven directly into coaching conversations**.

### 📊 70 Daily Micro-Actions

10 goal categories × 7 rotating actions = **10 weeks** of unique daily content across Health, Career, Relationships, Finance, Creativity, Mindfulness, Learning, Social, Self-Care, and Purpose.

<details>
<summary>📸 <b>Screenshots</b></summary>
<br/>
<i>See the <code>/assets/screenshots/</code> directory for app screenshots and demo materials.</i>
</details>

---

## 🏆 How We Compare

| Feature | Wysa | Woebot | BetterHelp | **CoachFlux** |
|:--------|:----:|:------:|:----------:|:-------------:|
| AI coaches with distinct personalities | ❌ | ❌ | ❌ | ✅ **11** |
| Real-time streaming responses | ❌ | ❌ | N/A | ✅ |
| Chemistry/matching algorithm | ❌ | ❌ | Basic | ✅ |
| Evidence-based technique library | ~5 | ~8 | Varies | ✅ **19** |
| Mood-adaptive tone shifting | Basic | Basic | N/A | ✅ |
| Gamified growth system | ❌ | ❌ | ❌ | ✅ |
| Custom coach creation | ❌ | ❌ | ❌ | ✅ |
| Price | $99/yr | Free* | $300/mo | **Free → $12.99/mo** |

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|:------|:-----------|:----|
| **Framework** | Flutter 3.x | Single codebase for iOS & Android |
| **Language** | Dart 3.x | Type-safe, async-first |
| **AI Engine** | Google Gemini Flash 2.0 | Sub-200ms TTFT, $0.10/1M tokens |
| **State** | Riverpod | Reactive, compile-time safe |
| **Monetization** | RevenueCat SDK ^8.6.0 | Subscription lifecycle & paywalls |
| **Streaming** | Server-Sent Events (SSE) | Character-by-character AI responses |
| **Storage** | SharedPreferences | Local-first, zero-server privacy |
| **Design** | Material Design 3 | Modern adaptive UI system |

---

## 🏗️ Architecture

```
                         ┌──────────────────────────────────┐
                         │          CoachFlux App            │
                         │          (Flutter/Dart)           │
                         └──────────┬───────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
           ┌──────────────┐ ┌─────────────┐ ┌─────────────┐
           │   Riverpod   │ │  RevenueCat │ │   Local     │
           │    State     │ │  SDK ^8.6.0 │ │   Storage   │
           │  Management  │ │             │ │  (On-Device) │
           └──────┬───────┘ └──────┬──────┘ └─────────────┘
                  │                │
                  ▼                ▼
           ┌─────────────┐ ┌─────────────────┐
           │ Gemini 2.0  │ │  App Store /    │
           │ Flash API   │ │  Play Store     │
           └──────┬──────┘ └─────────────────┘
                  │
                  ▼
           ┌─────────────────┐
           │  SSE Streaming  │
           │  Response Layer │
           │  (Real-time)    │
           └─────────────────┘

    ┌─────────────────────────────────────────────┐
    │  🔒 PRIVACY: Zero-server architecture.      │
    │     No user data ever leaves the device.     │
    └─────────────────────────────────────────────┘
```

---

## 💰 RevenueCat Integration

RevenueCat is **architecturally central** to CoachFlux — not a bolt-on.

### Monetization Tiers

| Tier | Price | Includes |
|:-----|:------|:---------|
| **Free** | $0 | 50 msgs/day, 3 coaches, core techniques |
| **Pro** | $12.99/mo | Unlimited msgs, all 11 coaches, Coach Builder, full technique library, advanced insights |
| **Coach** | $99/mo | Everything in Pro + priority AI, extended context memory, exclusive programs |

### Integration Depth

| Capability | Implementation |
|:-----------|:---------------|
| **Entitlement-Gated Features** | Real-time entitlement checks on every premium feature — no stale states |
| **Paywall Orchestration** | Context-aware paywalls at **7 strategic conversion points** in the user journey |
| **Offering Management** | 3-tier structure managed via dashboard — A/B test pricing without app updates |
| **Subscription Lifecycle** | Full handling: purchases, restores, grace periods, billing retries, cross-platform sync |
| **Customer Attributes** | Coaching metadata (favorite coach, session count, growth phase) synced for cohort analysis |
| **Promo Offers** | Introductory pricing & promotional offers for acquisition campaigns |

---

## 🚀 Build & Run

### Prerequisites

- Flutter 3.x+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.x+
- A [Google AI Studio](https://aistudio.google.com/) API key (Gemini)
- A [RevenueCat](https://www.revenuecat.com/) account & API keys

### Setup

```bash
# Clone the repository
git clone https://github.com/cinderspire/coachflux.git
cd coachflux

# Install dependencies
flutter pub get

# Configure API keys (create a .env or update your config file)
# GEMINI_API_KEY=your_key_here
# REVENUECAT_API_KEY=your_key_here

# Run on device/simulator
flutter run
```

### Build for Production

```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release
```

---

## 🗺️ Roadmap

| Feature | Status |
|:--------|:------:|
| 🎙️ Voice Coaching (Gemini multimodal) | Planned |
| 👥 Group Coaching Rooms | Planned |
| 🏪 Coach Marketplace | Planned |
| ⌚ Wearable Integration (Apple Watch HRV) | Planned |
| 🌍 10+ Languages | Planned |
| 🧪 Clinical Validation Studies | Planned |
| 📊 RevenueCat Experiments (A/B pricing) | Planned |
| 🤖 Multi-Model Routing | Planned |

---

## 📄 License

**Proprietary** — © 2026 [Mustafa Bilgiç](https://github.com/cinderspire) / cinderspire. All rights reserved.

**Bundle ID:** `com.cinderspire.coachflux`
**Privacy Policy:** [playtools.top/privacy-policy.html](https://playtools.top/privacy-policy.html)

---

<div align="center">

*CoachFlux — Because everyone deserves a coach in their corner.*
*Not just those who can afford one.*

<br/>

**Built with ❤️ by [Mustafa Bilgiç / cinderspire](https://github.com/cinderspire)**

**🏗️ RevenueCat Shipyard 2026**

</div>
