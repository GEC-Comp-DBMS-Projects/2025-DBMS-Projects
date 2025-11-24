import { Feather, Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useRouter } from 'expo-router';
import React, { useEffect } from 'react';
import {
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  Switch,
  View,
} from 'react-native';
import Animated, {
  interpolate,
  interpolateColor,
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
} from 'react-native-reanimated';

const lightTheme = {
  background: '#F6F6F7',
  textPrimary: '#1C1C1E',
  accent: '#FAB387',
  accentText: '#1C1C1E',
  border: '#E3E3E7',
};

const darkTheme = {
  background: '#1E1E2A',
  textPrimary: '#F5F5F7',
  accent: '#89B4FA',
  accentText: '#F5F5F7',
  border: '#2E2E3E',
};

type Props = {
  visible: boolean;
  onClose: () => void;
  onToggleTheme: () => void;
  isDarkMode: boolean;
  onTriggerAdminLogin: () => void;
};

const SettingsModal: React.FC<Props> = ({
  visible,
  onClose,
  onToggleTheme,
  isDarkMode,
  onTriggerAdminLogin,
}) => {
  const router = useRouter();
  const themeProgress = useSharedValue(isDarkMode ? 1 : 0);
  const modalScale = useSharedValue(0.85);
  const modalOpacity = useSharedValue(0);

  useEffect(() => {
    themeProgress.value = withTiming(isDarkMode ? 1 : 0, { duration: 500 });
  }, [isDarkMode]);

  useEffect(() => {
    if (visible) {
      modalScale.value = withSpring(1, { damping: 12 });
      modalOpacity.value = withTiming(1, { duration: 350 });
    } else {
      modalScale.value = withTiming(0.85, { duration: 250 });
      modalOpacity.value = withTiming(0, { duration: 200 });
    }
  }, [visible]);

  const animatedContainerStyle = useAnimatedStyle(() => ({
    backgroundColor: interpolateColor(
      themeProgress.value,
      [0, 1],
      [lightTheme.background, darkTheme.background]
    ),
    transform: [{ scale: modalScale.value }],
    opacity: modalOpacity.value,
  }));

  const animatedTextColor = useAnimatedStyle(() => ({
    color: interpolateColor(
      themeProgress.value,
      [0, 1],
      [lightTheme.textPrimary, darkTheme.textPrimary]
    ),
  }));

  const glassCard = useAnimatedStyle(() => ({
    backgroundColor: interpolateColor(
      themeProgress.value,
      [0, 1],
      ['rgba(255,255,255,0.25)', 'rgba(30,30,30,0.4)']
    ),
    borderColor: interpolateColor(
      themeProgress.value,
      [0, 1],
      ['rgba(255,255,255,0.35)', 'rgba(255,255,255,0.1)']
    ),
  }));

  const animatedGlow = useAnimatedStyle(() => {
    const shadowColor = interpolateColor(themeProgress.value, [0, 1], ['#FAB387', '#89B4FA']);
    const shadowOpacity = interpolate(themeProgress.value, [0, 1], [0.25, 0.6]);
    const shadowRadius = interpolate(themeProgress.value, [0, 1], [6, 12]);
    const shadowHeight = interpolate(themeProgress.value, [0, 1], [4, 4]);
    const shadowWidth = interpolate(themeProgress.value, [0, 1], [0, 0]);

    return {
      shadowColor,
      shadowOpacity,
      shadowRadius,
      shadowOffset: {
        width: shadowWidth,
        height: shadowHeight,
      },
    };
  });

  return (
    <Modal
      animationType="none"
      transparent
      visible={visible}
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <Animated.View
          style={[
            styles.modalContainer,
            animatedContainerStyle,
            glassCard,
            animatedGlow,
          ]}
        >
          <Animated.Text style={[styles.title, animatedTextColor]}>
            ⚙️ Settings
          </Animated.Text>

          {/* Theme Toggle */}
          <View style={styles.row}>
            <Ionicons
              name={isDarkMode ? 'moon' : 'sunny'}
              size={22}
              color={isDarkMode ? '#CBA6F7' : '#FAB387'}
            />
            <Animated.Text style={[styles.optionText, animatedTextColor]}>
              {isDarkMode ? 'Dark Mode' : 'Light Mode'}
            </Animated.Text>
            <Switch
              value={isDarkMode}
              onValueChange={() => {
                Haptics.selectionAsync();
                onToggleTheme();
              }}
              thumbColor={isDarkMode ? darkTheme.accent : lightTheme.accent}
              trackColor={{
                false: lightTheme.border,
                true: darkTheme.border,
              }}
            />
          </View>

          <Pressable
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              onTriggerAdminLogin();
            }}
            style={styles.button}
          >
            <Animated.View style={[styles.buttonBackground, animatedGlow]} />
            <Feather
              name="shield"
              size={18}
              color={isDarkMode ? darkTheme.accentText : lightTheme.accentText}
            />
            <Animated.Text style={[styles.buttonText, animatedTextColor]}>
              Admin Login
            </Animated.Text>
          </Pressable>

          <Pressable
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
              onClose();
              router.push('/(screens)/Support/aboutScreen');
            }}
            style={styles.button}
          >
            <Animated.View style={[styles.buttonBackground, animatedGlow]} />
            <Feather
              name="info"
              size={18}
              color={isDarkMode ? darkTheme.accentText : lightTheme.accentText}
            />
            <Animated.Text style={[styles.buttonText, animatedTextColor]}>
              About Us
            </Animated.Text>
          </Pressable>

          <Pressable
            onPress={() => {
              Haptics.selectionAsync();
              onClose();
            }}
            style={styles.closeButton}
          >
            <Animated.Text style={[styles.closeText, animatedTextColor]}>
              Close
            </Animated.Text>
          </Pressable>
        </Animated.View>
      </View>
    </Modal>
  );
};

export default SettingsModal;

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.55)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContainer: {
    padding: 26,
    borderRadius: 24,
    width: '85%',
    borderWidth: 1,
    overflow: 'hidden',
    alignItems: 'center',
    ...Platform.select({
      ios: { backdropFilter: 'blur(15px)' },
    }),
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    marginBottom: 20,
    letterSpacing: 0.5,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
    width: '100%',
  },
  optionText: {
    fontSize: 16,
    marginLeft: 12,
    flex: 1,
    fontWeight: '600',
  },
  button: {
    width: '100%',
    borderRadius: 14,
    paddingVertical: 12,
    paddingHorizontal: 16,
    marginBottom: 16,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
  },
  buttonBackground: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 14,
  },
  buttonText: {
    marginLeft: 8,
    fontWeight: '700',
    fontSize: 15,
  },
  closeButton: {
    marginTop: 10,
    paddingVertical: 8,
    paddingHorizontal: 20,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
  },
  closeText: {
    fontSize: 16,
    fontWeight: '600',
  },
});
