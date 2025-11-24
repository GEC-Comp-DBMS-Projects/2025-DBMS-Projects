import { useRouter } from 'expo-router';
import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useTheme } from '../../context/themeContext';
import { darkTheme, lightTheme } from '../../theme';

export default function AboutScreen() {
  const router = useRouter();
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const translateYAnim = useRef(new Animated.Value(20)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 500,
        useNativeDriver: true,
      }),
      Animated.timing(translateYAnim, {
        toValue: 0,
        duration: 500,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const features = [
    { icon: '⚡', text: 'Instantly check component compatibility' },
    { icon: '🧠', text: 'Smart recommendations based on your PC' },
    { icon: '💾', text: 'Optimize builds for performance and budget' },
    { icon: '📊', text: 'Compare multiple configurations easily' },
  ];

  return (
    <Animated.View
      style={[
        styles.container,
        {
          backgroundColor: theme.background,
          opacity: fadeAnim,
          transform: [{ translateY: translateYAnim }],
        },
      ]}
    >
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <Text style={[styles.title, { color: theme.accent }]}>About PartSync</Text>

        <View style={[styles.card, { backgroundColor: theme.cardBackground }]}>
          <Text style={[styles.bodyText, { color: theme.textSecondary }]}>
            PartSync helps you seamlessly select and verify compatibility for GPUs, CPUs, RAM, Motherboards, and Storage.
            Analyze your existing hardware and budget to get smart, optimized recommendations for your build.
          </Text>
        </View>

        <View style={styles.featuresContainer}>
          {features.map((feat, idx) => (
            <View key={idx} style={[styles.featureCard, { backgroundColor: theme.cardBackground }]}>
              <Text style={styles.featureIcon}>{feat.icon}</Text>
              <Text style={[styles.featureText, { color: theme.textPrimary }]}>{feat.text}</Text>
            </View>
          ))}
        </View>

        <Image
          source={require('../../../assets/main.png')}
          style={[styles.icon, { tintColor: theme.icon }]}
          resizeMode="contain"
        />

        <Pressable
          onPress={() => router.replace('..')}
          style={({ pressed }) => [
            styles.button,
            {
              backgroundColor: pressed ? theme.textSecondary : theme.accent,
              transform: [{ scale: pressed ? 0.97 : 1 }],
            },
          ]}
        >
          <Text style={[styles.buttonText, { color: theme.accentText }]}>⬅️ Return to Dashboard</Text>
        </Pressable>

        <Text style={[styles.footerNote, { color: theme.textSecondary }]}>
          © PartSync – All rights reserved
        </Text>
      </ScrollView>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { padding: 24, alignItems: 'center' },
  title: { fontSize: 28, fontWeight: 'bold', marginTop: 40, marginBottom: 16, textAlign: 'center' },
  card: { padding: 20, borderRadius: 16, marginBottom: 24, width: '100%', elevation: 4 },
  bodyText: { fontSize: 16, textAlign: 'center', lineHeight: 22 },

  featuresContainer: { width: '100%', marginBottom: 24 },
  featureCard: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 12,
    marginBottom: 12,
    elevation: 2,
  },
  featureIcon: { fontSize: 22, marginRight: 12 },
  featureText: { fontSize: 16, flexShrink: 1 },

  button: { paddingVertical: 14, paddingHorizontal: 32, borderRadius: 12, marginBottom: 28, elevation: 4 },
  buttonText: { fontWeight: 'bold', fontSize: 16, textAlign: 'center' },

  icon: { width: 80, height: 80, marginBottom: 16 },
  footerNote: { fontSize: 14, marginBottom: 12, textAlign: 'center' },
});
