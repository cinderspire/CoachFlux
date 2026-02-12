# CoachFlux — RevenueCat Shipyard 2026 Submission

## Project Title

**CoachFlux — Your AI Coaching Team That Actually Knows You**

## Tagline

11 specialized AI coaches. 19 evidence-based techniques. One app that transforms how 8 billion people access personal growth — for less than a cup of coffee.

---

## Inspiration

Here's a number that should make you angry: **$300**.

That's the average cost of a single session with a life coach. The coaching industry generates $20B/year, yet 96% of the world's population is priced out entirely. Meanwhile, therapy waitlists stretch 6–12 weeks. And "wellness apps"? They give you a meditation timer and call it a day.

We asked a different question: **What if the world's best coaching methodologies — CBT, DBT, ACT, IFS, Schema Therapy, Motivational Interviewing — were available to anyone, anytime, for free?**

Not a chatbot that says "tell me more." Not a scripted decision tree. A genuinely adaptive AI coaching *team* that reads your emotional state, remembers your journey across sessions, and deploys clinically-informed techniques in real time.

That's CoachFlux. And we built it in a way that's economically sustainable at scale — because Gemini Flash 2.0 costs **$0.10 per million tokens**, meaning we can serve a user's entire monthly coaching for less than a penny.

**The math changes everything.** When coaching costs nothing to deliver, the only question is: how good can we make it?

---

## What It Does

CoachFlux is a premium AI coaching platform with **11 specialized AI coaches** — each with a distinct personality, expertise domain, and therapeutic methodology. This isn't 11 skins on one prompt. Each coach has 2,000+ words of carefully engineered system architecture defining their worldview, communication style, and intervention strategies.

### 🧠 The Coaches

| Coach | Specialty | Methodology |
|-------|-----------|-------------|
| **Dr. Aura** | AI Psychologist | Expert-level CBT, DBT, ACT, IFS, Schema Therapy |
| **Marcus** | Stoic Mentor | Ancient philosophy meets modern resilience |
| **Nova** | Career Strategist | Goal-setting frameworks, negotiation, leadership |
| **Sage** | Mindfulness Guide | Meditation, breathwork, present-moment awareness |
| **Atlas** | Fitness & Wellness | Habit science, movement psychology, nutrition |
| **Luna** | Creative Catalyst | Unblocking creativity, flow states, artistic growth |
| **Phoenix** | Transformation Coach | Life transitions, reinvention, grief processing |
| **Ember** | Relationship Expert | Attachment theory, communication, boundaries |
| **Zen** | Productivity Master | Deep work, time management, systems thinking |
| **Aria** | Financial Wellness | Money mindset, budgeting psychology, wealth building |
| **Custom** | Coach Builder | Users design their own AI coach from scratch |

### 🎯 What Sets Us Apart from Wysa, Woebot & BetterHelp

| Feature | Wysa | Woebot | BetterHelp | **CoachFlux** |
|---------|------|--------|------------|---------------|
| AI coaches with distinct personalities | ❌ | ❌ | ❌ (human only) | ✅ **11 coaches** |
| Real-time streaming responses | ❌ | ❌ | N/A | ✅ **Character-by-character** |
| Chemistry/matching algorithm | ❌ | ❌ | Basic questionnaire | ✅ **Dynamic scoring** |
| Evidence-based technique library | ~5 | ~8 | Therapist-dependent | ✅ **19 techniques** |
| Mood-adaptive tone shifting | Basic | Basic | N/A | ✅ **Real-time emotional calibration** |
| Gamified growth system | ❌ | ❌ | ❌ | ✅ **XP, Achievements, Growth Garden** |
| Custom coach creation | ❌ | ❌ | ❌ | ✅ **Coach Builder** |
| Cost | $99/yr | Free (limited) | $300/mo | **Free → $12.99/mo** |

### 🌟 Core Features

- **Mood-Adaptive Conversations** — Every message is analyzed for emotional signals. The AI dynamically shifts tone, pacing, and intervention strategy without the user ever clicking a "mood" button.

- **Chemistry Score** — A proprietary algorithm that evaluates interaction depth, topic resonance, response engagement, and session consistency to surface each user's ideal coach match. It gets smarter over time.

- **Transformation Journey** — A psychological phase system that tracks where users are in their growth arc (Awareness → Exploration → Commitment → Integration → Mastery) and adapts coaching intensity accordingly.

- **19 Evidence-Based Techniques** — Not just listed, but *integrated into coaching conversations*:
  - 🍅 Pomodoro Timer — Focus sessions with coach encouragement
  - 🫁 Box Breathing — Guided 4-4-4-4 breathwork for anxiety
  - 🎯 SMART Goal Tracker — Structured goal decomposition
  - 💰 Budget Calculator — Financial wellness tools
  - 📝 Gratitude journaling, cognitive reframing, values clarification, progressive muscle relaxation, and 11 more

- **10 Goal Categories × 7 Rotating Daily Micro-Actions** — 70 unique micro-actions that rotate daily across Health, Career, Relationships, Finance, Creativity, Mindfulness, Learning, Social, Self-Care, and Purpose. Users never see the same day twice for 10 weeks.

- **Growth Garden** 🌱 — A living visual metaphor for personal development. Complete sessions, hit milestones, and watch your garden bloom. Each plant represents a different growth area. It's Duolingo's streak mechanic meets a Zen garden.

- **Achievements & XP System** — 12+ milestone badges, experience points for every interaction, and level progression that makes personal growth feel like leveling up in a game you actually want to play.

- **Coaching Journal** — AI-generated session summaries with key insights, action items, and emotional arc tracking. Your personal growth diary, written for you.

- **Insights Dashboard** — Mood trends over time, session frequency analysis, growth velocity metrics, and weekly AI-generated reflections.

- **Wisdom Collection** — Beautiful, shareable cards capturing the most powerful insights from your coaching sessions. Save, revisit, and share the moments that changed your perspective.

### 💰 Monetization (RevenueCat-Powered)

| Tier | Price | What You Get |
|------|-------|-------------|
| **Free** | $0 | 50 messages/day, 3 coaches, core techniques |
| **Pro** | $12.99/mo | Unlimited messages, all 11 coaches, Coach Builder, full technique library, advanced insights |
| **Coach** | $99/mo | Everything in Pro + priority AI, extended context memory, exclusive coaching programs |

---

## How We Built It

### Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Flutter    │────▶│  Gemini 2.0  │────▶│  Streaming SSE  │
│  (Riverpod)  │◀────│  Flash API   │◀────│  Response Layer  │
└──────┬───────┘     └──────────────┘     └─────────────────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│  RevenueCat  │     │ Local Storage │
│  SDK ^8.6.0  │     │ (On-Device)   │
└──────────────┘     └──────────────┘
```

- **Flutter + Dart** — Single codebase for iOS and Android
- **Riverpod** — Reactive state management with compile-time safety
- **Google Gemini Flash 2.0** — Our AI backbone. Chosen for three reasons:
  1. **Speed**: Sub-200ms time-to-first-token for streaming
  2. **Quality**: Competitive with GPT-4-class models on coaching tasks
  3. **Cost**: $0.10/1M tokens means we can offer a generous free tier *and* be profitable
- **RevenueCat SDK (purchases_flutter ^8.6.0)** — The backbone of our monetization

### Deep RevenueCat Integration

RevenueCat isn't a bolt-on — it's architecturally central to CoachFlux:

1. **Entitlement-Gated Features** — Every premium feature (Coach Builder, unlimited messaging, advanced coaches) checks RevenueCat entitlements in real-time. No stale states, no race conditions.

2. **Paywall Orchestration** — Context-aware paywall presentation: when a free user tries to access a locked coach, they see a beautifully designed upgrade flow powered by RevenueCat's paywall infrastructure. We trigger paywalls at 7 strategic conversion points in the user journey.

3. **Offering Management** — Three-tier offering structure (Free/Pro/Coach) managed entirely through RevenueCat's dashboard, enabling us to A/B test pricing without app updates.

4. **Subscription Lifecycle** — Full handling of purchases, restores, grace periods, billing retries, and cross-platform entitlement sync. RevenueCat abstracts the App Store/Play Store complexity so we can focus on coaching.

5. **Customer Attributes** — We sync coaching metadata (favorite coach, session count, growth phase) to RevenueCat customer attributes for cohort analysis and targeted re-engagement.

6. **Promo Offers** — Introductory pricing and promotional offers configured through RevenueCat for user acquisition campaigns.

### Key Technical Decisions

- **Streaming-First AI**: Custom SSE (Server-Sent Events) implementation for character-by-character rendering. We built custom Flutter animation controllers that handle text insertion without jank, even on mid-range devices.

- **Prompt Engineering at Scale**: Each of the 11 coaches has a 2,000+ word system prompt engineered over 30+ iterations. Dr. Aura alone references CBT cognitive distortion categories, DBT's four modules, ACT hexaflex principles, IFS parts work terminology, and Schema Therapy's 18 early maladaptive schemas.

- **Local-First Privacy**: All journal entries, mood data, session history, and personal insights are stored on-device. No user conversation data ever hits our servers. This is a privacy-first architecture by design.

- **Mood Detection Pipeline**: Real-time emotional signal analysis runs on every user message before it reaches the AI, injecting mood context into the prompt without requiring any explicit user input.

---

## Challenges We Ran Into

### 1. Making 11 Coaches Feel Genuinely Different
The hardest problem wasn't technical — it was psychological. How do you make Dr. Aura (clinical, warm, methodical) feel fundamentally different from Phoenix (bold, transformative, confrontational) when they're both powered by the same LLM? Answer: **2,000+ word system architectures per coach**, covering worldview, communication patterns, intervention triggers, forbidden phrases, and even humor styles. 30+ prompt iterations per coach.

### 2. Streaming UX in Flutter
Flutter's text rendering isn't designed for character-by-character streaming. We built custom `AnimationController` pipelines and a specialized text buffer that batches incoming tokens into smooth visual updates. The result: butter-smooth streaming even on 3-year-old Android devices.

### 3. The Chemistry Score Cold Start Problem
How do you score chemistry when a user has only sent 3 messages? We solved this with a hybrid approach: initial matching based on stated goals and personality preferences, transitioning to behavioral scoring (response depth, session return rate, topic diversity) after 10+ interactions.

### 4. Balancing Free vs. Pro
50 free messages/day is generous — intentionally so. We wanted free users to genuinely benefit, not just get a taste. The conversion to Pro happens naturally when users form bonds with locked coaches or want Coach Builder access. RevenueCat's analytics helped us validate this.

### 5. Transformation Journey Phase Detection
Building a system that accurately detects whether someone is in the "Awareness" vs. "Commitment" phase of their growth journey required mapping psychological change models (Prochaska's Transtheoretical Model) into quantifiable behavioral signals.

---

## Accomplishments We're Proud Of

- 🏆 **11 AI coaches** with genuinely distinct personalities, methodologies, and therapeutic approaches — including Dr. Aura, an AI psychologist with expert-level knowledge across 5 major therapeutic frameworks
- ⚡ **Sub-200ms streaming latency** — conversations feel indistinguishable from chatting with a real person
- 🧬 **Chemistry Score** that meaningfully improves coach-user pairing and gets smarter over time
- 🌱 **Growth Garden** — a gamification system that makes personal development genuinely engaging without being manipulative
- 💰 **Unit economics that work**: At $0.10/1M tokens, our AI cost per active user is ~$0.03/month. Combined with RevenueCat's subscription infrastructure, we have a path to profitability from day one
- 🔬 **19 evidence-based techniques** woven directly into coaching conversations, not bolted on as separate features
- 🎨 **Mood-reactive UI theming** — the entire app subtly shifts its color palette based on detected emotional state
- 🔒 **Zero-server privacy architecture** — no user data leaves the device. Ever.
- 📱 **Full RevenueCat integration** with 3-tier monetization, 7 strategic paywall touchpoints, entitlement-gated features, and subscription lifecycle management

---

## What We Learned

1. **Prompt engineering is the new UX design.** The difference between a good AI coach and a great one isn't the model — it's the 2,000 words of system architecture that define how it thinks, speaks, and intervenes.

2. **RevenueCat eliminates an entire class of problems.** We spent zero time debugging receipt validation, platform-specific purchase flows, or subscription state management. That time went straight into coaching quality.

3. **Gemini Flash 2.0 is a game-changer for AI-first apps.** At $0.10/1M tokens with GPT-4-class quality, the economics of AI coaching fundamentally change. You can offer a generous free tier and still build a business.

4. **Gamification in wellness works when it's not predatory.** Growth Garden succeeds because it visualizes genuine progress, not artificial streaks designed to create anxiety.

5. **Chemistry matters more than capability.** Users don't want the "best" coach — they want *their* coach. The Chemistry Score increased session return rates by making that match feel personal.

---

## What's Next

- 🎙️ **Voice Coaching** — Real-time voice conversations with AI coaches using Gemini's multimodal capabilities
- 👥 **Group Coaching Rooms** — Shared coaching spaces for couples, teams, and accountability groups
- 🏪 **Coach Marketplace** — Publish and share custom-built coaches with the community
- ⌚ **Wearable Integration** — Apple Watch heart rate + HRV data for physiological mood detection
- 🌍 **10+ Languages** — Starting with Spanish, Portuguese, Turkish, Hindi, and Mandarin
- 🧪 **Clinical Validation** — Partner with universities to study CoachFlux's impact on well-being outcomes
- 📊 **RevenueCat Experiments** — A/B test pricing, paywall designs, and trial lengths to optimize conversion
- 🤖 **Multi-Model Architecture** — Route complex therapeutic conversations to larger models while keeping casual coaching on Flash for cost efficiency

---

## Built With

- **Flutter** — Cross-platform UI framework
- **Dart** — Application language
- **Google Gemini Flash 2.0** — AI backbone ($0.10/1M tokens)
- **RevenueCat (purchases_flutter ^8.6.0)** — Subscription management & monetization
- **Riverpod** — Reactive state management
- **SharedPreferences** — Local-first data persistence
- **Server-Sent Events (SSE)** — Real-time AI streaming
- **Material Design 3** — Modern, adaptive UI system

---

## Try It

- **Bundle ID:** `com.cinderspire.coachflux`
- **Privacy Policy:** https://playtools.top/privacy-policy.html
- **Developer:** MUSTAFA BILGIC

---

*CoachFlux: Because everyone deserves a coach in their corner. Not just those who can afford one.*
