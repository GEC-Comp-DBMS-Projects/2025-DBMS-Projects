import { Image, StatusBar, Text, View } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
//@ts-ignore
import CSpace from "@/assets/images/illustrations/cspace.png"
import { Feather } from '@expo/vector-icons';
//@ts-ignore
import { Link, usePathname, useLocalSearchParams, Stack } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';

let navOptions = [
  { name: "Bookings", suffix: "/bookings", icon: "calendar" },
  { name: "Requests", suffix: "/bookings/requests", icon: "send" },
];

export default function MyBookingsPage({ children }: { children: React.ReactNode }) {
  const { colors, isDark } = useTheme();
  const pathname = usePathname();
  const { id } = useLocalSearchParams(); // 👈 get space id

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.tertiary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.primary} />
      <View className="p-6 pb-12 rounded-b-[24px]" style={{ backgroundColor: colors.primary }}>
        <Text className="text-4xl font-bold mt-6" style={{ color: colors.accent }}>My Bookings</Text>
        <Text className="mt-2 text-lg" style={{ color: colors.textSecondary }}>
          Manage all your bookings and requests with ease, get powerful insights
        </Text>
        <Image source={CSpace} className="absolute -right-5 bottom-0 hidden" />
      </View>

      <View className="p-6">
        <View
          className="flex-row items-center gap-2 rounded-2xl px-4 py-3"
          style={{
            backgroundColor: colors.card,
            shadowColor: colors.shadow,
            
            borderWidth: 1,
            borderColor: colors.border
          }}
        >
          {navOptions.map((option, index) => {
            const href = `${option.suffix}`;
            const isActive = pathname === href;
            return (
              <Link
                key={index}
                href={href as any}
                className="flex-1 rounded-xl items-center text-center"
                style={{ backgroundColor: isActive ? colors.accent : colors.card }}
              >
                <View className="flex-1 items-center justify-center p-2 px-4 rounded-md">
                  <Feather
                    name={option.icon as any}
                    size={15}
                    color={isActive ? (isDark ? '#000' : 'white') : colors.text}
                  />
                  <Text
                    className="text-xs font-semibold mt-1"
                    style={{ color: isActive ? (isDark ? '#000' : 'white') : colors.text }}
                  >
                    {option.name}
                  </Text>
                </View>
              </Link>
            );
          })}
        </View>
      </View>
      <Stack screenOptions={{headerShown:false}}/>
    </SafeBoundingView>
  );
}
