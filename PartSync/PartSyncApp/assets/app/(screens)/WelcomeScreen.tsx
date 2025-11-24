import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import {
  Dimensions,
  Image,
  Pressable,
  StyleSheet,
  Text
} from 'react-native';
import Animated, {
  Easing,
  interpolateColor,
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withSequence,
  withTiming
} from 'react-native-reanimated';
import Icon from 'react-native-vector-icons/Feather';
import AdminLoginModal from '../(modals)/AdminLoginModal';
import SettingsModal from '../(modals)/settingsModal';
import { useTheme } from "../context/themeContext";
import { darkTheme, lightTheme } from '../theme';

const { width } = Dimensions.get('window');

export default function WelcomeScreen() {
  const router = useRouter();
  const { isDark, toggleTheme } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const [settingsVisible, setSettingsVisible] = useState(false);
  const [adminVisible, setAdminVisible] = useState(false);
  const [adminToken, setAdminToken] = useState<string | null>(null);

  const fadeIn = useSharedValue(0);
  const scaleAnim = useSharedValue(1);
  const iconScale = useSharedValue(1);
  const floatingIcon = useSharedValue(0);
  const progress = useSharedValue(isDark ? 1 : 0);

  useEffect(() => {
    fadeIn.value = withTiming(1, { duration: 800, easing: Easing.out(Easing.exp) });

    progress.value = withTiming(isDark ? 1 : 0, {
      duration: 500,
      easing: Easing.out(Easing.exp),
    });

    floatingIcon.value = withRepeat(
      withSequence(
        withTiming(-8, { duration: 2000, easing: Easing.inOut(Easing.sin) }),
        withTiming(0, { duration: 2000, easing: Easing.inOut(Easing.sin) })
      ),
      -1,
      true
    );
  }, [isDark]);

  const bgAnim = useAnimatedStyle(() => ({
    backgroundColor: interpolateColor(
      progress.value,
      [0, 1],
      [lightTheme.background, darkTheme.background]
    ),
  }));

  const iconAnimStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: withTiming(iconScale.value, { duration: 150 }) },
      { translateY: floatingIcon.value },
      { rotate: withTiming(progress.value ? '0deg' : '180deg', { duration: 500, easing: Easing.out(Easing.exp) }) },
    ],
  }));

  const fadeStyle = useAnimatedStyle(() => ({
    opacity: fadeIn.value,
  }));

  const buttonBgAnim = useAnimatedStyle(() => ({
    backgroundColor: interpolateColor(
      progress.value,
      [0, 1],
      [lightTheme.accent, darkTheme.accent]
    ),
  }));

  const handleToggleTheme = () => {
    iconScale.value = 1.3;
    setTimeout(() => { iconScale.value = 1 }, 150);
    toggleTheme();
  };

  return (
    <Animated.View style={[styles.container, bgAnim]}>
      <Animated.Image
        source={require("../../assets/main.png")}
        style={[styles.icon, { tintColor: theme.icon }, fadeStyle]}
        resizeMode="contain"
      />

      <Animated.Text style={[styles.title, fadeStyle, { color: theme.textPrimary }]}>
        Welcome to PartSync
      </Animated.Text>
      <Animated.Text style={[styles.subText, fadeStyle, { color: theme.textSecondary }]}>
        Get personalized hardware recommendations and check compatibility for GPU, RAM, Motherboards, and Storage.
      </Animated.Text>

      <Pressable
        onPress={() => router.push('../(screens)/Support/ChooseCategoryScreen')}
        onPressIn={() => scaleAnim.value = withTiming(0.96, { duration: 100 })}
        onPressOut={() => scaleAnim.value = withTiming(1, { duration: 100 })}
        android_ripple={{ color: theme.textSecondary + '33' }}
      >
        <Animated.View style={[styles.button, buttonBgAnim, { transform: [{ scale: scaleAnim.value }] }]}>
          <Text style={[styles.buttonText, { color: theme.accentText }]}>Get Started</Text>
        </Animated.View>
      </Pressable>

      <Pressable
        onPress={() => router.push('/(screens)/AIBuildScreen')}
        style={{ marginTop: 20 }}
      >
        <Text style={{ color: '#CBA6F7', fontWeight: 'bold', textShadowColor: '#0002', textShadowRadius: 1 }}>
          Try AI Build Assistant
        </Text>
      </Pressable>

      <Pressable onPress={handleToggleTheme} style={styles.themeButton}>
        <Animated.View style={iconAnimStyle}>
          <Icon name={isDark ? "moon" : "sun"} size={28} color={theme.icon} />
        </Animated.View>
      </Pressable>

      <Pressable onPress={() => setSettingsVisible(true)} style={styles.settingsButton}>
        <Image source={require('../../assets/gear.png')} style={{ width: 24, height: 24, tintColor: theme.icon }} />
      </Pressable>

      <SettingsModal
        visible={settingsVisible}
        onClose={() => setSettingsVisible(false)}
        onToggleTheme={toggleTheme}
        isDarkMode={isDark}
        onTriggerAdminLogin={() => {
          setSettingsVisible(false);
          setAdminVisible(true);
        }}
      />

      <AdminLoginModal
        visible={adminVisible}
        onClose={() => setAdminVisible(false)}
        onSuccess={(token: string) => setAdminToken(token)}
      />
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 24 },
  icon: { width: 150, height: 150, marginBottom: 30 },
  title: { fontSize: 32, fontWeight: 'bold', textAlign: 'center', marginBottom: 16 },
  subText: { fontSize: 16, textAlign: 'center', marginBottom: 40 },
  button: {
    paddingVertical: 16,
    paddingHorizontal: 40,
    borderRadius: 14,
    elevation: 6,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 6,
    marginBottom: 20,
  },
  buttonText: { fontWeight: 'bold', fontSize: 16, textAlign: 'center' },
  themeButton: { position: 'absolute', top: 50, right: 70, padding: 10 },
  settingsButton: { position: 'absolute', top: 50, right: 24, padding: 10 },
});
