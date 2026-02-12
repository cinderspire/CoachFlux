# CoachFlux — RevenueCat Shipyard Submission

## Brief: Simon @BetterCreating — AI Coaching App

## Tagline
"Your AI coaching team that actually knows you."

## The Problem
Coaching is expensive ($150-500/session), inaccessible, and one-size-fits-all. Most people who need coaching can't afford it. Those who try AI chatbots get generic, forgettable responses with zero continuity.

## The Solution
CoachFlux is an AI coaching platform where users choose from 10+ specialized coaches — or build their own. Each coach has a unique personality, expertise, and communication style. The AI adapts to your mood, remembers your journey, and builds genuine "chemistry" over time.

## Key Features

### 🎭 Mood-Adaptive Coaching
Select your mood before each session. The AI adjusts its tone: empathetic when you're sad, ambitious when you're energized, calming when you're stressed. This isn't a gimmick — it's how real coaches work.

### 🧪 Chemistry Score
After 5+ messages, CoachFlux calculates a "chemistry score" based on message variety, mood improvement, and session depth. Find the coach that truly resonates with you.

### ✨ Streaming AI Responses
Character-by-character streaming with a blinking cursor — feels like your coach is thinking and typing in real-time. Not a wall of text, but a conversation.

### 📊 Mood Analytics & Insights
7-day mood sparkline, weekly reflection cards, personal growth tracking. "You tend to feel best on Tuesdays!" — data-driven self-awareness.

### 🏆 Achievement System
12+ unlockable badges: First Session, 7-Day Streak, Mood Master, Deep Diver, All Coaches, Growth Spurt. Gamification that serves the user's growth journey.

### 📔 Coaching Journal
Timeline view of all sessions with AI-generated summaries, key topics, and mood tracking. Your personal growth diary, automatically maintained.

### 🔨 Coach Builder
Create custom AI coaches with specific personalities, expertise areas, and communication styles. Your ideal coach, designed by you.

## RevenueCat Integration
- **Free Tier:** 3 coaches, 10 messages/day, basic mood tracking
- **Pro ($12.99/mo):** All coaches, unlimited messages, full analytics, journal
- **Coach ($99/mo):** Custom coach builder, priority AI, export data, API access
- Paywall with A/B testing ready
- Subscription management in settings
- Restore purchases support

## Tech Stack
- **Framework:** Flutter (iOS + Android from single codebase)
- **AI:** Google Gemini Flash 2.0 (streaming responses)
- **Monetization:** RevenueCat SDK with 3-tier subscription
- **State:** Riverpod + SharedPreferences
- **Design:** Custom design system (Night Sky theme with glassmorphism)
- **Animations:** Hero transitions, shimmer loading, streaming text, mood-reactive gradients

## Design Philosophy
- **Premium feel:** Every interaction has haptic feedback, smooth animation, purposeful motion
- **Emotionally intelligent:** The app responds to how you feel, not just what you type
- **Retention through value:** Streak system, growth garden, weekly reflections — users return because they see real progress
- **Accessibility:** 48px touch targets, semantic widgets, sufficient contrast ratios

## What Makes CoachFlux Different
1. **Multi-coach ecosystem** — Not one chatbot, but a team of specialists
2. **Emotional intelligence** — Mood tracking drives the entire experience
3. **Relationship building** — Chemistry scores make each coach relationship unique
4. **Real growth tracking** — Journal + insights prove the coaching is working
5. **Creator economy** — Coach Builder opens the door to community-created coaches

## Business Model
- Freemium with generous free tier (reduces barrier to entry)
- Pro tier targets individuals ($12.99/mo = fraction of real coaching)
- Coach tier targets practitioners/power users ($99/mo)
- Projected LTV: $45-120 per subscriber
- Natural virality: share achievements, recommend coaches

## Built With
flutter, dart, gemini-ai, revenuecat, riverpod, shared-preferences, google-fonts

## Team
cinderspire — Solo developer, built with AI-assisted development pipeline
