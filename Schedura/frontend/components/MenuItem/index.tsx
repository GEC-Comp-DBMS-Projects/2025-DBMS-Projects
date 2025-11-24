import { Ionicons } from "@expo/vector-icons";
import { FC, useState, useEffect } from "react";
import { Switch, Text, TouchableOpacity, View } from "react-native";
import { useTheme } from "@/contexts/ThemeContext";


export const MenuItem: FC<{
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  subtitle?: string;
  isDestructive?: boolean;
  onPress?: () => void;
  hasToggle?: boolean;
  toggleValue?: boolean;
  onToggleChange?: (value: boolean) => void;
  disabled?: boolean;
  showBadge?: boolean;
  badgeText?: string;
}> = ({ 
  icon, 
  label, 
  subtitle,
  isDestructive, 
  onPress, 
  hasToggle, 
  toggleValue = false,
  onToggleChange,
  disabled,
  showBadge,
  badgeText
}) => {
  const { colors, isDark } = useTheme();
  const [isEnabled, setIsEnabled] = useState(toggleValue);

  // Update internal state when toggleValue prop changes
  useEffect(() => {
    setIsEnabled(toggleValue);
  }, [toggleValue]);

  const toggleSwitch = () => {
    const newValue = !isEnabled;
    setIsEnabled(newValue);
    onToggleChange?.(newValue);
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        padding: 16,
        backgroundColor: colors.card,
        borderRadius: 16,
        marginBottom: 12,
        opacity: disabled ? 0.5 : 1,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
      }}
      disabled={hasToggle || disabled}
    >
      {/* Icon Container */}
      <View style={{
        padding: 12,
        borderRadius: 12,
        backgroundColor: isDestructive 
          ? (isDark ? '#7f1d1d' : '#fef2f2')
          : (isDark ? colors.backgroundTertiary : colors.backgroundSecondary)
      }}>
        <Ionicons 
          name={icon} 
          size={22} 
          color={isDestructive ? "#ef4444" : colors.textSecondary} 
        />
      </View>

      {/* Content */}
      <View style={{ flex: 1, marginLeft: 16 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <Text style={{
            fontSize: 16,
            fontWeight: '600',
            color: isDestructive ? "#ef4444" : colors.text
          }}>
            {label}
          </Text>
          {showBadge && badgeText && (
            <View style={{
              backgroundColor: '#ef4444',
              paddingHorizontal: 8,
              paddingVertical: 4,
              borderRadius: 9999,
              marginLeft: 8
            }}>
              <Text style={{ color: '#ffffff', fontSize: 12, fontWeight: 'bold' }}>
                {badgeText}
              </Text>
            </View>
          )}
        </View>
        {subtitle && (
          <Text style={{ 
            color: colors.textSecondary, 
            fontSize: 14, 
            marginTop: 4 
          }}>
            {subtitle}
          </Text>
        )}
      </View>

      {/* Right Side */}
      {hasToggle ? (
        <Switch
          trackColor={{ false: isDark ? "#374151" : "#e5e7eb", true: "#8b5cf6" }}
          thumbColor="#ffffff"
          onValueChange={toggleSwitch}
          value={isEnabled}
        />
      ) : (
        <Ionicons name="chevron-forward-outline" size={20} color={colors.textTertiary} />
      )}
    </TouchableOpacity>
  );
};