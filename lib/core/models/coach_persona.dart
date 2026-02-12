import 'package:flutter/material.dart';

enum AvatarState { idle, listening, thinking, speaking, empathizing }

enum SessionEnvironment {
  cozyOffice('Cozy Office', '🏠', [Color(0xFF2D1B69), Color(0xFF11001C)]),
  zenGarden('Zen Garden', '🌿', [Color(0xFF0B3D2E), Color(0xFF071A14)]),
  gym('Training Room', '🏋️', [Color(0xFF3D1B1B), Color(0xFF1C0B0B)]),
  library('Library', '📚', [Color(0xFF1B2D3D), Color(0xFF0B1420)]),
  moonlit('Moonlit Room', '🌙', [Color(0xFF1A1040), Color(0xFF0A0820)]),
  sunrise('Sunrise Terrace', '🌅', [Color(0xFF3D2B1B), Color(0xFF1C1408)]);

  final String label;
  final String icon;
  final List<Color> gradientColors;
  const SessionEnvironment(this.label, this.icon, this.gradientColors);

  LinearGradient get gradient => LinearGradient(
    colors: gradientColors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class CoachPersona {
  final String coachId;
  final SessionEnvironment environment;
  final String avatarDescription;
  final Map<AvatarState, String> stateEmojis;

  const CoachPersona({
    required this.coachId,
    required this.environment,
    required this.avatarDescription,
    required this.stateEmojis,
  });
}

/// Maps each default coach to their persona
final Map<String, CoachPersona> coachPersonas = {
  'flow-master': const CoachPersona(
    coachId: 'flow-master',
    environment: SessionEnvironment.library,
    avatarDescription: 'Laser-focused strategist in a minimalist office',
    stateEmojis: {
      AvatarState.idle: '🎯',
      AvatarState.listening: '👂',
      AvatarState.thinking: '🤔',
      AvatarState.speaking: '🎯',
      AvatarState.empathizing: '💡',
    },
  ),
  'zen-mind': const CoachPersona(
    coachId: 'zen-mind',
    environment: SessionEnvironment.zenGarden,
    avatarDescription: 'Serene meditation master in a peaceful garden',
    stateEmojis: {
      AvatarState.idle: '🧘',
      AvatarState.listening: '🌸',
      AvatarState.thinking: '🌀',
      AvatarState.speaking: '🧘',
      AvatarState.empathizing: '🌿',
    },
  ),
  'iron-will': const CoachPersona(
    coachId: 'iron-will',
    environment: SessionEnvironment.gym,
    avatarDescription: 'Powerful coach in a premium training facility',
    stateEmojis: {
      AvatarState.idle: '💪',
      AvatarState.listening: '👊',
      AvatarState.thinking: '🧠',
      AvatarState.speaking: '🔥',
      AvatarState.empathizing: '🤝',
    },
  ),
  'career-pilot': const CoachPersona(
    coachId: 'career-pilot',
    environment: SessionEnvironment.cozyOffice,
    avatarDescription: 'Sharp strategist in a modern executive office',
    stateEmojis: {
      AvatarState.idle: '🚀',
      AvatarState.listening: '📋',
      AvatarState.thinking: '📊',
      AvatarState.speaking: '🚀',
      AvatarState.empathizing: '🤝',
    },
  ),
  'muse': const CoachPersona(
    coachId: 'muse',
    environment: SessionEnvironment.sunrise,
    avatarDescription: 'Vibrant creative spirit surrounded by colors',
    stateEmojis: {
      AvatarState.idle: '🎨',
      AvatarState.listening: '👁️',
      AvatarState.thinking: '✨',
      AvatarState.speaking: '🎨',
      AvatarState.empathizing: '💫',
    },
  ),
  'money-mind': const CoachPersona(
    coachId: 'money-mind',
    environment: SessionEnvironment.cozyOffice,
    avatarDescription: 'Composed analyst in a sleek financial office',
    stateEmojis: {
      AvatarState.idle: '💰',
      AvatarState.listening: '📈',
      AvatarState.thinking: '🧮',
      AvatarState.speaking: '💰',
      AvatarState.empathizing: '🤝',
    },
  ),
  'system-builder': const CoachPersona(
    coachId: 'system-builder',
    environment: SessionEnvironment.library,
    avatarDescription: 'Meticulous architect with blueprints and diagrams',
    stateEmojis: {
      AvatarState.idle: '⚙️',
      AvatarState.listening: '📐',
      AvatarState.thinking: '🔧',
      AvatarState.speaking: '⚙️',
      AvatarState.empathizing: '🤝',
    },
  ),
  'stoic-sage': const CoachPersona(
    coachId: 'stoic-sage',
    environment: SessionEnvironment.moonlit,
    avatarDescription: 'Ancient philosopher bathed in moonlight',
    stateEmojis: {
      AvatarState.idle: '🏛️',
      AvatarState.listening: '📜',
      AvatarState.thinking: '🤔',
      AvatarState.speaking: '🏛️',
      AvatarState.empathizing: '🕊️',
    },
  ),
  'social-spark': const CoachPersona(
    coachId: 'social-spark',
    environment: SessionEnvironment.sunrise,
    avatarDescription: 'Energetic communicator radiating confidence',
    stateEmojis: {
      AvatarState.idle: '✨',
      AvatarState.listening: '👂',
      AvatarState.thinking: '💭',
      AvatarState.speaking: '✨',
      AvatarState.empathizing: '💖',
    },
  ),
  'sleep-whisperer': const CoachPersona(
    coachId: 'sleep-whisperer',
    environment: SessionEnvironment.moonlit,
    avatarDescription: 'Gentle guardian in a starlit sanctuary',
    stateEmojis: {
      AvatarState.idle: '🌙',
      AvatarState.listening: '🌟',
      AvatarState.thinking: '💤',
      AvatarState.speaking: '🌙',
      AvatarState.empathizing: '🫂',
    },
  ),
  'dr-aura': const CoachPersona(
    coachId: 'dr-aura',
    environment: SessionEnvironment.cozyOffice,
    avatarDescription: 'Warm psychologist in a comfortable therapy room',
    stateEmojis: {
      AvatarState.idle: '🧠',
      AvatarState.listening: '💜',
      AvatarState.thinking: '🪞',
      AvatarState.speaking: '🧠',
      AvatarState.empathizing: '🫂',
    },
  ),
};

/// Get persona for a coach, with a sensible default for custom coaches
CoachPersona getPersona(String coachId) {
  return coachPersonas[coachId] ??
      const CoachPersona(
        coachId: 'custom',
        environment: SessionEnvironment.cozyOffice,
        avatarDescription: 'Your personal AI coach',
        stateEmojis: {
          AvatarState.idle: '🤖',
          AvatarState.listening: '👂',
          AvatarState.thinking: '🤔',
          AvatarState.speaking: '💬',
          AvatarState.empathizing: '🤝',
        },
      );
}
