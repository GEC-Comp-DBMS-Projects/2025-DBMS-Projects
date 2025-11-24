import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StatusBar, Alert, Switch } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';

const PrivacySecurityScreen = () => {
  const { colors, isDark } = useTheme();
  const router = useRouter();
  
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [biometricEnabled, setBiometricEnabled] = useState(false);
  const [activityStatus, setActivityStatus] = useState(true);
  const [readReceipts, setReadReceipts] = useState(true);

  const handleChangePassword = () => {
    Alert.alert(
      'Change Password',
      'You will receive an email with instructions to reset your password.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Send Email', 
          onPress: () => Alert.alert('Success', 'Password reset email sent!')
        }
      ]
    );
  };

  const handleManageSessions = () => {
    Alert.alert(
      'Active Sessions',
      'You have 3 active sessions:\n\n• iPhone 14 Pro (Current)\n• MacBook Pro\n• iPad Air',
      [
        { text: 'OK' }
      ]
    );
  };

  const handleDataDownload = () => {
    Alert.alert(
      'Download Your Data',
      'We will prepare a copy of your data and send you a download link via email. This may take up to 24 hours.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Request Download', 
          onPress: () => Alert.alert('Success', 'Data download request submitted!')
        }
      ]
    );
  };

  const handleDeleteAccount = () => {
    Alert.alert(
      'Delete Account',
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: () => {
            Alert.alert(
              'Final Confirmation',
              'Type "DELETE" to confirm account deletion',
              [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Confirm Delete', style: 'destructive' }
              ]
            );
          }
        }
      ]
    );
  };

  const SettingItem = ({ 
    icon, 
    title, 
    subtitle, 
    onPress, 
    hasToggle, 
    toggleValue, 
    onToggleChange,
    isDestructive 
  }: any) => (
    <TouchableOpacity
      onPress={onPress}
      disabled={hasToggle}
      className="flex-row items-center p-4 rounded-xl mb-3"
      style={{
        backgroundColor: colors.card,
        shadowColor: colors.shadow,
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      <View
        className="p-3 rounded-lg"
        style={{
          backgroundColor: isDestructive
            ? (isDark ? '#7f1d1d' : '#fef2f2')
            : (isDark ? colors.backgroundTertiary : colors.backgroundSecondary)
        }}
      >
        <Ionicons 
          name={icon} 
          size={22} 
          color={isDestructive ? '#ef4444' : colors.textSecondary} 
        />
      </View>

      <View className="flex-1 ml-4">
        <Text
          className="text-base font-semibold"
          style={{ color: isDestructive ? '#ef4444' : colors.text }}
        >
          {title}
        </Text>
        {subtitle && (
          <Text className="text-sm mt-1" style={{ color: colors.textSecondary }}>
            {subtitle}
          </Text>
        )}
      </View>

      {hasToggle ? (
        <Switch
          trackColor={{ false: isDark ? "#374151" : "#e5e7eb", true: "#8b5cf6" }}
          thumbColor="#ffffff"
          onValueChange={onToggleChange}
          value={toggleValue}
        />
      ) : (
        <Ionicons name="chevron-forward-outline" size={20} color={colors.textTertiary} />
      )}
    </TouchableOpacity>
  );

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      
      {/* Header */}
      <View
        className="flex-row items-center px-6 py-4 border-b"
        style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}
      >
        <TouchableOpacity onPress={() => router.back()} className="p-2 mr-3">
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text className="text-xl font-bold" style={{ color: colors.text }}>Privacy & Security</Text>
      </View>

      <ScrollView className="flex-1 px-6 py-6" showsVerticalScrollIndicator={false}>
        {/* Security */}
        <View className="mb-6">
          <Text
            className="text-sm font-bold mb-4 uppercase tracking-wide"
            style={{ color: colors.textSecondary }}
          >
            Security
          </Text>
          
          <SettingItem
            icon="lock-closed-outline"
            title="Change Password"
            subtitle="Update your password regularly"
            onPress={handleChangePassword}
          />
          
          <SettingItem
            icon="shield-checkmark-outline"
            title="Two-Factor Authentication"
            subtitle="Add an extra layer of security"
            hasToggle
            toggleValue={twoFactorEnabled}
            onToggleChange={(value: boolean) => {
              setTwoFactorEnabled(value);
              Alert.alert(
                value ? 'Enabled' : 'Disabled',
                `Two-factor authentication ${value ? 'enabled' : 'disabled'}`
              );
            }}
          />
          
          <SettingItem
            icon="finger-print-outline"
            title="Biometric Login"
            subtitle="Use Face ID or fingerprint"
            hasToggle
            toggleValue={biometricEnabled}
            onToggleChange={(value: boolean) => {
              setBiometricEnabled(value);
              Alert.alert(
                value ? 'Enabled' : 'Disabled',
                `Biometric login ${value ? 'enabled' : 'disabled'}`
              );
            }}
          />
          
          <SettingItem
            icon="phone-portrait-outline"
            title="Manage Sessions"
            subtitle="View and manage active devices"
            onPress={handleManageSessions}
          />
        </View>

        {/* Privacy */}
        <View className="mb-6">
          <Text
            className="text-sm font-bold mb-4 uppercase tracking-wide"
            style={{ color: colors.textSecondary }}
          >
            Privacy
          </Text>
          
          <SettingItem
            icon="eye-outline"
            title="Activity Status"
            subtitle="Show when you're active"
            hasToggle
            toggleValue={activityStatus}
            onToggleChange={setActivityStatus}
          />
          
          <SettingItem
            icon="checkmark-done-outline"
            title="Read Receipts"
            subtitle="Let others know you've seen messages"
            hasToggle
            toggleValue={readReceipts}
            onToggleChange={setReadReceipts}
          />
          
          <SettingItem
            icon="shield-outline"
            title="Blocked Users"
            subtitle="Manage blocked accounts"
            onPress={() => Alert.alert('Blocked Users', 'No blocked users')}
          />
        </View>

        {/* Data & Privacy */}
        <View className="mb-6">
          <Text
            className="text-sm font-bold mb-4 uppercase tracking-wide"
            style={{ color: colors.textSecondary }}
          >
            Data & Privacy
          </Text>
          
          <SettingItem
            icon="download-outline"
            title="Download Your Data"
            subtitle="Get a copy of your information"
            onPress={handleDataDownload}
          />
          
          <SettingItem
            icon="trash-outline"
            title="Delete Account"
            subtitle="Permanently delete your account"
            onPress={handleDeleteAccount}
            isDestructive
          />
        </View>

        <View className="h-8" />
      </ScrollView>
    </SafeBoundingView>
  );
};

export default PrivacySecurityScreen;
