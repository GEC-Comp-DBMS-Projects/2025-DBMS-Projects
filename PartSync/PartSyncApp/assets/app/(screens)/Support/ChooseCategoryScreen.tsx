import { useRouter } from 'expo-router';
import React, { useEffect } from 'react';
import { Dimensions, Pressable, StyleSheet, Text, View } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import { useTheme } from '../../context/themeContext';

const { width } = Dimensions.get('window');

const categories = [
  { title: 'Find a GPU', route: '/(screens)/Gpu/hardwareInput' },
  { title: 'Find a Motherboard', route: '/(screens)/Motherboard/motherboardInput' },
  { title: 'Find RAM', route: '/(screens)/Ram/RamInputScreen' },
  { title: 'Find Storage', route: '/(screens)/Storage/storageInput' },
];

export default function ChooseCategoryScreen() {
  const router = useRouter();
  const { theme } = useTheme();

  const fade = useSharedValue(0);
  useEffect(() => {
    fade.value = withTiming(1, {
      duration: 600,
      easing: Easing.out(Easing.exp),
    });
  }, []);

  const fadeStyle = useAnimatedStyle(() => ({
    opacity: fade.value,
    transform: [
      {
        translateY: withTiming(fade.value ? 0 : 30, { duration: 500 }),
      },
    ],
  }));

  return (
    <Animated.View style={[styles.container, { backgroundColor: theme.background }, fadeStyle]}>
      <Text style={[styles.title, { color: theme.textPrimary }]}>
        What would you like to find?
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
            theme={theme}
          />
        ))}
      </View>
    </Animated.View>
  );
}

function AnimatedButton({
  title,
  onPress,
  theme,
}: {
  title: string;
  onPress: () => void;
  theme: any;
}) {
  const scale = useSharedValue(1);

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Pressable
      onPressIn={() => (scale.value = withTiming(0.95, { duration: 120 }))}
      onPressOut={() => (scale.value = withTiming(1, { duration: 120 }))}
      onPress={onPress}
    >
      <Animated.View style={[styles.button, animStyle, { backgroundColor: theme.accent }]}>
        <Text style={[styles.buttonText, { color: theme.textOnAccent }]}>{title}</Text>
      </Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 40,
  },
  buttonContainer: {
    width: '100%',
    alignItems: 'center',
  },
  button: {
    width: width * 0.85,
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 10,
    elevation: 5,
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 3 },
  },
  buttonText: {
    fontSize: 18,
    fontWeight: '600',
  },
});