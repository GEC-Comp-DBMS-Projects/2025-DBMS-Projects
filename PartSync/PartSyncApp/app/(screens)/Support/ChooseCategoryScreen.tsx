import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import React, { useEffect } from 'react';
import {
  Dimensions,
  Pressable,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import { useTheme } from '../../context/themeContext';

const { width } = Dimensions.get('window');

const categories = [
  { title: 'Find a GPU ⚡', route: '/(screens)/Gpu/hardwareInput' },
  { title: 'Find a Motherboard 🧩', route: '/(screens)/Motherboard/motherboardInput' },
  { title: 'Find RAM 🧠', route: '/(screens)/Ram/RamInputScreen' },
  { title: 'Find Storage 💾', route: '/(screens)/Storage/storageInput' },
];

export default function ChooseCategoryScreen() {
  const router = useRouter();
  const { theme, isDark } = useTheme();

  const fade = useSharedValue(0);
  useEffect(() => {
    fade.value = withTiming(1, { duration: 700, easing: Easing.out(Easing.exp) });
  }, []);

  const fadeStyle = useAnimatedStyle(() => ({
    opacity: fade.value,
    transform: [
      { translateY: withTiming(fade.value ? 0 : 30, { duration: 700 }) },
    ],
  }));

  const gradientColors = isDark
    ? ['#0B0B0C', '#111318', '#1E1F24']
    : ['#0B3C8A', '#274E9B', '#5B7CE3'];

  return (
    <LinearGradient colors={gradientColors} style={styles.gradientBackground}>
      <StatusBar
        barStyle={isDark ? 'light-content' : 'dark-content'}
        translucent
        backgroundColor="transparent"
      />

      <Animated.View style={[styles.container, fadeStyle]}>
        <Text
          style={[
            styles.title,
            { color: isDark ? '#fff' : '#fff' },
          ]}
        >
          Choose Your Component
        </Text>
        <Text
          style={[
            styles.subtitle,
            { color: isDark ? '#CCCCCC' : '#E5E8FF' },
          ]}
        >
          Let’s help you find the right parts for your dream build.
        </Text>

        <View style={styles.buttonContainer}>
          {categories.map((cat, index) => (
            <AnimatedButton
              key={index}
              title={cat.title}
              onPress={() =>
                router.push({
                  pathname: cat.route,
                  params: { transition: 'fade' },
                })
              }
              isDark={isDark}
            />
          ))}
        </View>
      </Animated.View>
    </LinearGradient>
  );
}

function AnimatedButton({
  title,
  onPress,
  isDark,
}: {
  title: string;
  onPress: () => void;
  isDark: boolean;
}) {
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  const onPressIn = () => {
    scale.value = withTiming(0.96, { duration: 100 });
    opacity.value = withTiming(0.9, { duration: 100 });
  };

  const onPressOut = () => {
    scale.value = withTiming(1, { duration: 100 });
    opacity.value = withTiming(1, { duration: 100 });
  };

  const buttonColors = isDark
    ? ['#3C3F46', '#565A64']
    : ['#5A9AFB', '#3461EB'];

  return (
    <Pressable onPressIn={onPressIn} onPressOut={onPressOut} onPress={onPress}>
      <Animated.View style={[animStyle, styles.buttonShadow]}>
        <LinearGradient
          colors={buttonColors}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.button}
        >
          <Text style={styles.buttonText}>{title}</Text>
        </LinearGradient>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  gradientBackground: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    width: width * 0.9,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 40,
    paddingHorizontal: 16,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '900',
    textAlign: 'center',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 15,
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 20,
  },
  buttonContainer: {
    width: '100%',
    alignItems: 'center',
  },
  buttonShadow: {
    borderRadius: 16,
    marginVertical: 10,
    elevation: 6,
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 6,
  },
  button: {
    width: width * 0.8,
    paddingVertical: 16,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 17,
  },
});
