<p align="center">
  <h1 align="center">🧠 CoachFlux</h1>
  <p align="center"><strong>Your AI coaching team that actually knows you.</strong></p>
  <p align="center">11 specialized AI coaches · 19 evidence-based techniques · Mood-adaptive intelligence</p>
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Gemini_Flash_2.0-AI-4285F4?logo=google" alt="Gemini">
    <img src="https://img.shields.io/badge/RevenueCat-8.6.0-FF6B6B?logo=revenuecat" alt="RevenueCat">
    <img src="https://img.shields.io/badge/License-Proprietary-lightgrey" alt="License">
  </p>
</p>

---

## The Problem

Personal coaching costs $150–500/session. Therapy waitlists are 6–12 weeks. Generic AI chatbots give surface-level advice. **96% of the world is priced out of personal growth support.**

## The Solution

CoachFlux puts a team of 11 specialized AI coaches in your pocket — each with distinct expertise, personality, and therapeutic methodology. Powered by Gemini Flash 2.0 ($0.10/1M tokens), we deliver expert-level coaching at a fraction of the cost, with real-time mood adaptation and streaming conversations that feel genuinely human.

---

## ✨ Features

### 🎭 11 AI Coaches
Each coach has a 2,000+ word system architecture defining their worldview, communication style, and intervention strategies. Not 11 skins on one prompt — 11 genuinely different coaching experiences.

| Coach | Domain | Approach |
|-------|--------|----------|
| **Dr. Aura** 🧠 | AI Psychologist | CBT, DBT, ACT, IFS, Schema Therapy |
| **Marcus** 🏛️ | Stoic Mentor | Ancient philosophy + modern resilience |
| **Nova** 🚀 | Career Strategist | Goals, negotiation, leadership |
| **Sage** 🧘 | Mindfulness Guide | Meditation, breathwork, presence |
| **Atlas** 💪 | Fitness & Wellness | Habit science, movement, nutrition |
| **Luna** 🎨 | Creative Catalyst | Flow states, artistic unblocking |
| **Phoenix** 🔥 | Transformation | Life transitions, reinvention |
| **Ember** ❤️ | Relationships | Attachment theory, boundaries |
| **Zen** ⚡ | Productivity | Deep work, systems thinking |
| **Aria** 💎 | Financial Wellness | Money mindset, wealth building |
| **Custom** 🔨 | Coach Builder | Design your own AI coach |

### 🧪 Chemistry Score
Proprietary matching algorithm that evaluates interaction depth, topic resonance, and engagement patterns to surface your ideal coach. Gets smarter with every conversation.

### 🌊 Mood-Adaptive Intelligence
Every message is analyzed for emotional signals in real-time. Coaches dynamically adjust tone, pacing, and intervention strategy — no mood buttons required.

### ⚡ Streaming AI Responses
Character-by-character streaming with sub-200ms latency. Conversations feel alive, not like waiting for a loading spinner.

### 🎯 19 Evidence-Based Techniques
Integrated directly into coaching conversations:
- 🍅 Pomodoro Timer · 🫁 Box Breathing · 🎯 SMART Goals · 💰 Budget Calculator
- Gratitude Journaling · Cognitive Reframing · Values Clarification · Progressive Muscle Relaxation
- And 11 more...

### 🌱 Growth Garden
A living visual metaphor for your personal development. Complete sessions, hit milestones, watch your garden bloom. Each plant represents a growth area.

### 🔄 Transformation Journey
Psychological phase system tracking your growth arc: **Awareness → Exploration → Commitment → Integration → Mastery**

### 📊 10 Goals × 7 Daily Micro-Actions
70 unique rotating micro-actions across Health, Career, Relationships, Finance, Creativity, Mindfulness, Learning, Social, Self-Care, and Purpose. No two weeks are alike.

### 🏆 Achievements & XP
Level progression, milestone badges, and experience points that make personal growth feel like a game you want to play.

### 📔 Journal & Wisdom Collection
AI-generated session summaries, mood trend tracking, and shareable Wisdom Cards capturing your most powerful insights.

---

## 💰 Pricing

| Tier | Price | Includes |
|------|-------|----------|
| **Free** | $0 | 50 msgs/day, 3 coaches, core techniques |
| **Pro** | $12.99/mo | Unlimited everything, all 11 coaches, Coach Builder |
| **Coach** | $99/mo | Priority AI, extended memory, exclusive programs |

Powered by **RevenueCat** (`purchases_flutter ^8.6.0`) with entitlement-gated features, strategic paywall presentation, and full subscription lifecycle management.

---

## 🏗️ Architecture

```
Flutter (Riverpod) → Gemini Flash 2.0 (SSE Streaming) → Mood-Adaptive Response
        ↓                                                         ↓
   RevenueCat SDK                                        Local-First Storage
  (Entitlements,                                       (SharedPreferences,
   Paywalls,                                            Zero-Server Privacy)
   Offerings)
```

### Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Frontend** | Flutter + Dart | Single codebase, native performance |
| **State** | Riverpod | Compile-time safe, reactive |
| **AI** | Gemini Flash 2.0 | $0.10/1M tokens, streaming, quality |
| **Monetization** | RevenueCat ^8.6.0 | Industry-standard subscription infra |
| **Storage** | SharedPreferences | Privacy-first, on-device only |
| **Streaming** | SSE (Server-Sent Events) | Real-time token delivery |
| **Design** | Material Design 3 | Modern, adaptive theming |

### Privacy

**Zero-server architecture.** All conversations, journal entries, mood data, and personal insights stay on-device. No user data ever leaves your phone.

---

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build for release
flutter build ios --no-codesign --release
flutter build apk --release
```

### Environment Setup

1. Add your Gemini API key to the app configuration
2. Configure RevenueCat with your API keys and offerings
3. Set up your Free/Pro/Coach entitlements in the RevenueCat dashboard

---

## 📁 Project Structure

```
lib/
├── coaches/          # 11 AI coach definitions & system prompts
├── models/           # Data models (sessions, mood, achievements)
├── providers/        # Riverpod providers (state management)
├── screens/          # UI screens (chat, dashboard, garden, journal)
├── services/         # Gemini API, RevenueCat, mood detection
├── widgets/          # Reusable components (chemistry, wisdom cards)
└── utils/            # Techniques, micro-actions, helpers
```

---

## 🗺️ Roadmap

- [ ] 🎙️ Voice coaching (Gemini multimodal)
- [ ] 👥 Group coaching rooms
- [ ] 🏪 Coach marketplace
- [ ] ⌚ Apple Watch / wearable integration
- [ ] 🌍 10+ language support
- [ ] 🧪 Clinical validation studies
- [ ] 📊 RevenueCat A/B experiments

---

## 📄 Info

- **Bundle ID:** `com.cinderspire.coachflux`
- **Developer:** MUSTAFA BILGIC
- **Privacy Policy:** [playtools.top/privacy-policy.html](https://playtools.top/privacy-policy.html)
- **Built for:** [RevenueCat Shipyard 2026](https://shipyard.revenuecat.com)

---

<p align="center"><em>Because everyone deserves a coach in their corner.</em></p>
