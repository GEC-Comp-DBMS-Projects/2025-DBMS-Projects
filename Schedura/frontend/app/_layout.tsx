import { Stack } from 'expo-router';
import "../globals.css";
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { ClerkProvider, useAuth, useUser } from '@clerk/clerk-expo';
import { tokenCache } from '@clerk/clerk-expo/token-cache';
import * as NavigationBar from 'expo-navigation-bar';
import { useEffect } from 'react';
import { AppState, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { updateUserInfo } from '@/supabase/controllers/user.controller';
import { TailwindThemeProvider } from '@/contexts/TailwindThemeContext';
import { ThemeProvider } from '@/contexts/ThemeContext';
//@ts-ignore
import { useRouter } from 'expo-router';
import { ToastProvider } from '@/components/Toast';

export default function RootLayout() {
  return (
    <ClerkProvider publishableKey={process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY!} tokenCache={tokenCache}>
        <ThemeProvider>
          <ToastProvider>
          <TailwindThemeProvider>
            <SafeAreaProvider>
              <AuthGate />
            </SafeAreaProvider>
          </TailwindThemeProvider>
          </ToastProvider>
        </ThemeProvider>
    </ClerkProvider>
  );
}

function AuthGate() {
  const { isSignedIn, isLoaded } = useAuth();
  const { user } = useUser();
  const { replace } = useRouter();

  const handleRedirect = async () => {
    if (!user) return;
    const status = await updateUserInfo(user);
    if (status === 201 || status === 409) {
      SplashScreen.hideAsync();
      replace("/(tabs)/home");
    }
    else{
      SplashScreen.hideAsync();
    }
  };

  useEffect(() => {
    const hideNav = async () => {
      await NavigationBar.setVisibilityAsync("hidden");
    };
    hideNav();
    const sub = AppState.addEventListener("change", (state) => {
      if (state === "active") hideNav();
    });
    return () => sub.remove();
  }, []);

  useEffect(() => {
    if (isSignedIn) {
      handleRedirect();
    }
  }, [isSignedIn]);

  if (!isLoaded) return null;

  return (
    <Stack screenOptions={{ headerShown: false }}>
      {isSignedIn ? (
        <>
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="space" options={{ headerShown: false }} />
        </>
      ) : (
        <Stack.Screen name="index" options={{ headerShown: false }} />
      )}
    </Stack>
  );
}
