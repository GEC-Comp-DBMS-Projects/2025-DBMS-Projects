import type { UserProfile } from "@/types/database.type";
import type { FC } from "react";
import { ActivityIndicator, Image, Text, View } from "react-native";
import { useTheme } from "@/contexts/ThemeContext";


export const ProfileHeader: FC<{ 
  profile: UserProfile | null; 
  loading: boolean; 
  onRefresh: () => void;
}> = ({ profile, loading, onRefresh }) => {
  const { colors, isDark } = useTheme();
  
  return (
    <View style={{ 
      position: 'relative', 
      overflow: 'hidden', 
      backgroundColor: colors.primary 
    }}>
      <View style={{ 
        alignItems: 'center', 
        paddingTop: 64, 
        paddingBottom: 32, 
        paddingHorizontal: 24,
        position: 'relative',
        zIndex: 10
      }}>
        <View style={{ position: 'relative', marginBottom: 24 }}>
          {loading ? (
            <View style={{
              width: 112,
              height: 112,
              borderRadius: 56,
              borderWidth: 4,
              borderColor: isDark ? 'rgba(255, 255, 255, 0.2)' : 'rgba(0, 0, 0, 0.2)',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.1)'
            }}>
              <ActivityIndicator color={colors.accent} size="large" />
            </View>
          ) : (
            <>
              <Image
                source={{
                  uri: profile?.avatar_url 
                }}
                style={{
                  width: 112,
                  height: 112,
                  borderRadius: 56,
                  borderWidth: 4,
                  borderColor: isDark ? 'rgba(255, 255, 255, 0.2)' : 'rgba(0, 0, 0, 0.2)'
                }}
              />
              <View style={{
                position: 'absolute',
                bottom: 8,
                right: 8,
                width: 24,
                height: 24,
                backgroundColor: '#10b981',
                borderRadius: 12,
                borderWidth: 2,
                borderColor: colors.primary
              }} />
            </>
          )}
        </View>
        <View style={{ alignItems: 'center' }}>
          <Text style={{ 
            color: colors.accent, 
            fontSize: 24, 
            fontWeight: 'bold', 
            marginBottom: 4 
          }}>
            {loading ? 'Loading...' : profile?.name }
          </Text>
          <Text style={{ 
            color: isDark ? 'rgba(255, 255, 255, 0.7)' : 'rgba(0, 0, 0, 0.7)', 
            fontSize: 16, 
            marginBottom: 12 
          }}>
            {loading ? '' : profile?.email }
          </Text>

          {/* Stats Row */}
          <View style={{ 
            flexDirection: 'row', 
            gap: 24, 
            marginTop: 8 
          }}>
            {/*
            <View style={{ alignItems: 'center' }}>
              <Text style={{ 
                color: colors.accent, 
                fontSize: 20, 
                fontWeight: 'bold' 
              }}>12</Text>
              <Text style={{ 
                color: isDark ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.6)', 
                fontSize: 12 
              }}>Events</Text>
            </View>
            <View style={{ alignItems: 'center' }}>
              <Text style={{ 
                color: colors.accent, 
                fontSize: 20, 
                fontWeight: 'bold' 
              }}>5</Text>
              <Text style={{ 
                color: isDark ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.6)', 
                fontSize: 12 
              }}>Upcoming</Text>
            </View>
            <View style={{ alignItems: 'center' }}>
              <Text style={{ 
                color: colors.accent, 
                fontSize: 20, 
                fontWeight: 'bold' 
              }}>7</Text>
              <Text style={{ 
                color: isDark ? 'rgba(255, 255, 255, 0.6)' : 'rgba(0, 0, 0, 0.6)', 
                fontSize: 12 
              }}>Completed</Text>
            </View>*/}
          </View>
        </View>
      </View>
    </View>
  );
};
