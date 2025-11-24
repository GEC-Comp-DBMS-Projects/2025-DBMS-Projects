import { Feather, Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import React, { useEffect } from 'react';
import {
  Modal,
  Pressable,
  StyleSheet,
  Switch,
  Text,
  View
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
  accent: '#5A9AFB',
  accentText: '#fff',
  border: '#E3E3E7',
};

const darkTheme = {
  background: '#0D0D12',
  textPrimary: '#EAEAF0',
  accent: '#5A7CFA',
  accentText: '#fff',
  border: '#1F1F2A',
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

  const animatedContainer = useAnimatedStyle(() => ({
    transform: [{ scale: modalScale.value }],
    opacity: modalOpacity.value,
  }));

  const animatedGradient = useAnimatedStyle(() => ({
    backgroundColor: interpolateColor(
      themeProgress.value,
      [0, 1],
      ['#EBF0FF', '#11131A']
    ),
  }));

  const animatedText = useAnimatedStyle(() => ({
    color: interpolateColor(
      themeProgress.value,
      [0, 1],
      [lightTheme.textPrimary, darkTheme.textPrimary]
    ),
  }));

  const glow = useAnimatedStyle(() => ({
    shadowColor: interpolateColor(
      themeProgress.value,
      [0, 1],
      ['#5A9AFB', '#5A7CFA']
    ),
    shadowOpacity: interpolate(themeProgress.value, [0, 1], [0.25, 0.6]),
    shadowRadius: interpolate(themeProgress.value, [0, 1], [8, 16]),
  }));

  return (
    <Modal animationType="none" transparent visible={visible} onRequestClose={onClose}>
      <View style={styles.overlay}>
        <Animated.View style={[styles.modalContainer, animatedContainer]}>
          <Animated.View style={[styles.gradientWrapper, animatedGradient]}>

            <LinearGradient
              colors={
                isDarkMode
                  ? ['#1A1C24', '#15161C', '#101117']
                  : ['#EBF3FF', '#E8EEFF', '#DCE6FF']
              }
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={[styles.contentBox, glow]}
            >
              <Animated.Text style={[styles.title, animatedText]}>
                ⚙️ Settings
              </Animated.Text>

              {/* Theme Toggle */}
              <View style={styles.row}>
                <Ionicons
                  name={isDarkMode ? 'moon' : 'sunny'}
                  size={22}
                  color={isDarkMode ? '#CBA6F7' : '#FDB24C'}
                />
                <Animated.Text style={[styles.optionText, animatedText]}>
                  {isDarkMode ? 'Dark Mode' : 'Light Mode'}
                </Animated.Text>
                <Switch
                  value={isDarkMode}
                  onValueChange={() => {
                    Haptics.selectionAsync();
                    onToggleTheme();
                  }}
                  thumbColor={isDarkMode ? '#5A7CFA' : '#5A9AFB'}
                  trackColor={{
                    false: '#D1D5DB',
                    true: '#3E436B',
                  }}
                />
              </View>

              {/* Buttons */}
              <GradientButton
                icon="shield"
                text="Admin Login"
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
                  onTriggerAdminLogin();
                }}
                isDarkMode={isDarkMode}
              />

              <GradientButton
                icon="info"
                text="About Us"
                onPress={() => {
                  Haptics.selectionAsync();
                  onClose();
                  router.push('/(screens)/Support/aboutScreen');
                }}
                isDarkMode={isDarkMode}
              />

              <Pressable
                onPress={() => {
                  Haptics.selectionAsync();
                  onClose();
                }}
                style={styles.closeButton}
              >
                <Animated.Text style={[styles.closeText, animatedText]}>
                  Close
                </Animated.Text>
              </Pressable>
            </LinearGradient>
          </Animated.View>
        </Animated.View>
      </View>
    </Modal>
  );
};

const GradientButton = ({
  icon,
  text,
  onPress,
  isDarkMode,
}: {
  icon: any;
  text: string;
  onPress: () => void;
  isDarkMode: boolean;
}) => {
  return (
    <Pressable onPress={onPress} style={styles.button}>
      <LinearGradient
        colors={
          isDarkMode
            ? ['#5A7CFA', '#4A60E0']
            : ['#5A9AFB', '#2F72E9']
        }
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.buttonBg}
      >
        <Feather name={icon} size={18} color="#fff" />
        <Text style={styles.buttonText}>{text}</Text>
      </LinearGradient>
    </Pressable>
  );
};

export default SettingsModal;

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.65)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContainer: {
    width: '88%',
    borderRadius: 24,
    overflow: 'hidden',
  },
  gradientWrapper: {
    borderRadius: 24,
    padding: 2,
  },
  contentBox: {
    borderRadius: 24,
    padding: 24,
    alignItems: 'center',
    shadowOffset: { width: 0, height: 8 },
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    marginBottom: 24,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 26,
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
    marginBottom: 14,
    overflow: 'hidden',
  },
  buttonBg: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 14,
    borderRadius: 14,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 15,
    marginLeft: 8,
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
