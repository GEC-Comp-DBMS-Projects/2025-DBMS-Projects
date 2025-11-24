import { Stack } from "expo-router";
import { ThemeProvider } from "./context/themeContext";

export default function Layout() {
  return (
    <ThemeProvider>
      <Stack>
        <Stack.Screen name="./index" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Support/SplashScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/WelcomeScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Support/ChooseCategoryScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Support/aboutScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/Gpu/hardwareInput" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Gpu/RecommendationScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Gpu/LoadingScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/Ram/RamInputScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Ram/RamLoadingScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Ram/RamRecommendationScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/Motherboard/motherboardInput" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Motherboard/MotherboardLoadingScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Motherboard/MotherboardRecommendationScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/Storage/storageInput" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Storage/StorageLoadingScreen" options={{ headerShown: false }} />
        <Stack.Screen name="(screens)/Storage/StorageRecommendationScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/Admin/AdministrationScreen" options={{ headerShown: false }} />

        <Stack.Screen name="(screens)/AIBuildScreen" options={{ headerShown: false }} />
        
        <Stack.Screen
          name="(modals)/settingsModal"
          options={{ presentation: "modal", headerShown: false }}
        />
        <Stack.Screen
          name="(modals)/AdminLoginModal"
          options={{ presentation: "modal", headerShown: false }}
        />
      </Stack>
    </ThemeProvider>
  );
}
