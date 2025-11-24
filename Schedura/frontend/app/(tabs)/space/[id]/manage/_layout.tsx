import { Image, StatusBar, Text, View } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
//@ts-ignore
import CSpace from "@/assets/images/illustrations/cspace.png"
import { Feather } from '@expo/vector-icons';
//@ts-ignore
import { Link, usePathname, useLocalSearchParams, Stack } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
import { useEffect, useState } from 'react';
import { supabase } from '@/supabase/supabase';

let navOptions = [
  { name: "Overview", suffix: "/manage", icon: "bar-chart" },
  { name: "Bookings", suffix: "/manage/bookings", icon: "calendar" },
  { name: "Requests", suffix: "/manage/requests", icon: "send" },
  { name: "Logs", suffix: "/manage/logs", icon: "credit-card" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { colors, isDark } = useTheme();
  const pathname = usePathname();
  const { id } = useLocalSearchParams(); // 👈 get space id
  const [showLogs, setShowLogs] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkIfCoworking();
  }, [id]);

  const checkIfCoworking = async () => {
    try {
      setLoading(true);
      // Get space with organisation info
      const { data: space, error: spaceErr } = await supabase
        .from('spaces')
        .select('organizationid')
        .eq('id', id as string)
        .single();

      if (spaceErr || !space?.organizationid) {
        setShowLogs(false);
        return;
      }

      // Get organisation type
      const { data: org, error: orgErr } = await supabase
        .from('organisations')
        .select('type')
        .eq('id', space.organizationid)
        .single();

      if (!orgErr && org?.type === 'CoWorking') {
        setShowLogs(true);
      } else {
        setShowLogs(false);
      }
    } catch (err) {
      console.error('Error checking coworking status:', err);
      setShowLogs(false);
    } finally {
      setLoading(false);
    }
  };

  const filteredNavOptions = showLogs ? navOptions : navOptions.filter(opt => opt.name !== 'Logs');

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />

      <View
        className="px-6 pt-6 pb-12 rounded-b-[24px]"
        style={{  backgroundColor: colors.primary }}
      >
        <Text className="text-4xl font-bold mt-6" style={{ color: colors.text }}>Dashboard</Text>
        <Text className="mt-2 text-xl" style={{ color: colors.text }}>
          Manage all your spaces with ease, {'\n'}get powerful insights
        </Text>
        <Image source={CSpace} className="absolute right-[-20px] bottom-0 hidden" />
      </View>

      <View className="p-6">
        <View
          className="flex-row items-center px-4 py-3 rounded-[16px] shadow-lg"
          style={{ backgroundColor: colors.card }}
        >
          {filteredNavOptions.map((option, index) => {
            const href = `/space/${id}${option.suffix}` as any;
            const isActive = pathname === href;

            return (
              <Link
                key={index}
                href={href}
                className="flex-1 rounded-[8px] items-center text-center"
                style={{ backgroundColor: isActive ? colors.accent : colors.card }}
              >
                <View className="flex-1 items-center justify-center p-2 px-4 rounded-[8px]">
                  <Feather
                    name={option.icon as any}
                    size={15}
                    color={isActive ? isDark ? "black" : "white" : colors.text}
                  />
                  <Text
                    className="text-xs font-semibold mt-1"
                    style={{ color: isActive ? isDark ? "black" : "white" : colors.text }}
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
