import { Tabs } from 'expo-router';
import React from 'react';
import { Platform, View, Text, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { SafeAreaView } from 'react-native-safe-area-context';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useTheme } from '@/contexts/ThemeContext';

interface Tab {
  name: string;
  title: string;
  icon: any;
}
const tabs: Tab[] = [
  {
    name: "home",
    title: "Home",
    icon: "home",
  },
  {
    name:"bookings",
    title:"Bookings",
    icon:"calendar",
  },
  {
    name:"spaces",
    title:"My Spaces",
    icon:"key",
  },
  {
    name: "profile",
    title: "Profile",
    icon: "user",
  },
];


const CustomTabBar: React.FC<BottomTabBarProps> = ({ state, descriptors, navigation }) => {
  const { colors, isDark } = useTheme();
  
  return (
    <View style={{ backgroundColor: colors.tertiary, width: '100%', paddingHorizontal: 20, paddingVertical: 16 }}>
      <View style={{ 
        flexDirection: 'row', 
        backgroundColor: colors.tabBarBackground, 
        borderWidth: 1,
        borderColor: colors.tabBarBorder,
        borderRadius: 24, 
        paddingVertical: 12, 
        paddingHorizontal: 8,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4
      }}>
        {state.routes.map((route, index) => {
          const { options } = descriptors[route.key];
          const label = options.tabBarLabel !== undefined
            ? options.tabBarLabel
            : options.title !== undefined
            ? options.title
            : route.name;

          const isFocused = state.index === index;
          const tab = tabs.find(t => t.name === route.name);
          const hiddenRoutes = ['add-space', 'create-space'];
          const onPress = () => {
            const event = navigation.emit({
              type: 'tabPress',
              target: route.key,
              canPreventDefault: true,
            });

            if (!isFocused && !event.defaultPrevented) {
              navigation.navigate(route.name, route.params);
            }
          };
          
          const isHidden = ['add-space', 'manage-space','edit-space', 'create-org', 'join-org', 'space/create', 'space/[id]/edit', 'space/[id]/manage', 'space/[id]/index', 'space/[id]/bookings', 'space/[id]/requests', 'space/[id]/book/index', 'organisation/create', 'organisation/join','organisation/[id]', 'profile/edit', 'profile/privacy','spaces-map', 'profile/billing', 'profile/integrations', 'space/analytics'].includes(route.name);
          
          return (
            <TouchableOpacity
              key={index}
              accessibilityRole="button"
              accessibilityState={isFocused ? { selected: true } : {}}
              accessibilityLabel={options.tabBarAccessibilityLabel}
              onPress={onPress}
              style={{ 
                flex: 1, 
                alignItems: 'center',
                display: isHidden ? 'none' : 'flex'
              }}
            >
              <View>
                <View style={{
                  width: 32,
                  height: 32,
                  marginHorizontal: 'auto',
                  alignItems: 'center',
                  justifyContent: 'center',
                  borderRadius: isFocused ? 16 : 0
                }}>
                  <Feather
                    name={tab?.icon as any}
                    size={20}
                    color={isFocused ? colors.tabIconSelected : colors.tabIconDefault}
                  />
                </View>
                <Text style={{
                  fontSize: 14,
                  fontWeight: isFocused ? '600' : '500',
                  textAlign: 'center',
                  color: isFocused ? colors.tabIconSelected : colors.tabIconDefault
                }}>
                  {typeof label === 'string' ? label : ''}
                </Text>
              </View>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

export default function TabLayout() {
  return (
    <Tabs
      tabBar={(props:any) => <CustomTabBar {...props} />}
      screenOptions={{
        headerShown: false,
        freezeOnBlur: true,
      }}
    >
      {tabs.map((tab, i) => (
        <Tabs.Screen
          key={i}
          name={tab.name}
          options={{title: tab.title}}
        />
      ))}
    </Tabs>
  );
}