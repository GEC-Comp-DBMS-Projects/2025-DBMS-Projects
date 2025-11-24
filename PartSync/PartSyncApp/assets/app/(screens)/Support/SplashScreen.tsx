import { Audio } from 'expo-av';
import { useRouter } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import LottieView from 'lottie-react-native';
import React, { useEffect, useRef } from 'react';
import { Animated, Easing, Image, StyleSheet } from 'react-native';

const logo = require('../../../assets/images/splash-icon.png');
const particles = require('../../../assets/particles.json');
const soundEffect = require('../../../assets/splash.mp3');

const AnimatedSplashScreen: React.FC = () => {
  const lottieRef = useRef<LottieView>(null);
  const fadeAnim = useRef(new Animated.Value(1)).current;
  const router = useRouter();
  const animationDuration = 2200;
  const fadeDuration = 600;

  useEffect(() => {
    let sound: Audio.Sound | null = null;

    const setupSplash = async () => {
      try {
        await SplashScreen.hideAsync();

        const { sound: loadedSound } = await Audio.Sound.createAsync(soundEffect);
        sound = loadedSound;
        await sound.playAsync();

        setTimeout(() => {
          Animated.timing(fadeAnim, {
            toValue: 0,
            duration: fadeDuration,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }).start(() => {
            router.replace('/WelcomeScreen');
          });
        }, animationDuration);
      } catch (error) {
        console.warn('Splash screen error:', error);
        router.replace('/WelcomeScreen');
      }
    };

    setupSplash();

    return () => {
      if (sound) sound.unloadAsync();
    };
  }, []);

  return (
    <Animated.View style={[styles.container, { opacity: fadeAnim }]}>
      <LottieView
        ref={lottieRef}
        source={particles}
        autoPlay
        loop={false}
        style={styles.lottie}
        resizeMode="cover"
      />
      <Image
        source={logo}
        style={styles.logo}
        resizeMode="contain"
        accessible
        accessibilityLabel="App Logo"
      />
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#181825',
    justifyContent: 'center',
    alignItems: 'center',
  },
  lottie: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 1,
  },
  logo: {
    width: 200,
    height: 200,
    zIndex: 2,
  },
});

export default AnimatedSplashScreen;
