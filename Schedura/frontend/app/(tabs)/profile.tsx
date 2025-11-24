import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, StatusBar, Alert, Linking } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useUser } from '@clerk/clerk-expo';
import { getUserInfo } from '@/supabase/controllers/user.controller';
import { MenuItem } from '@/components/MenuItem';
import { ProfileHeader } from '@/components/ProfileHeader';
import SignOutModal from '@/components/Modals/SignOutModal';
import LanguageModal from '@/components/Modals/LanguageModal';
import type { UserProfile } from '@/types/database.type';
import { useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
import { useToast } from '@/components/Toast';


const ProfileScreen = () => {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [signOutModalVisible, setSignOutModalVisible] = useState(false);
  const [languageModalVisible, setLanguageModalVisible] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState('en');
  const router = useRouter();
  const { theme, colors, isDark, toggleTheme } = useTheme();
  const { showToast } = useToast();
  const MenuSection = ({ title, children }: { title: string; children: React.ReactNode }) => (
    <View className="mb-6">
      <Text style={{ color: colors.textSecondary }} className="text-sm font-bold mb-4 uppercase tracking-wide">
        {title}
      </Text>
      <View style={{ backgroundColor: colors.card }} className="rounded-3xl">
        {children}
      </View>
    </View>
  );

  const { user: authUser } = useUser();

  const fetchProfile = async () => {
    setLoading(true);
    const data = await getUserInfo(authUser?.id!);
    setProfile({ ...data, avatar_url: authUser?.imageUrl });
    setLoading(false);
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  const handleEditProfile = () => {
    router.push('/profile/edit');
  };

  const handlePrivacySecurity = () => {
    router.push('/profile/privacy');
  };

  const handleBilling = () => {
    router.push('/profile/billing');
  };
  const handleIntegrations = () => {
    router.push('/profile/integrations');
  }

  const handleNotificationsChange = (value: boolean) => {
    setNotificationsEnabled(value);
    showToast({
      type: 'info',
      title: `Notifications ${value ? 'Enabled' : 'Disabled'}`,
      description: `You have ${value ? 'enabled' : 'disabled'} notifications.`,
      duration: 3000,
    })
  };

  const handleDarkModeChange = (value: boolean) => {
    toggleTheme();
  };

  const handleLanguage = () => {
    setLanguageModalVisible(true);
  };

  const handleSelectLanguage = (languageCode: string) => {
    setSelectedLanguage(languageCode);
    const languageNames: Record<string, string> = {
      en: 'English (US)',
      es: 'Español',
      fr: 'Français',
      de: 'Deutsch',
      it: 'Italiano',
      pt: 'Português',
      ru: 'Русский',
      zh: '中文',
      ja: '日本語',
      ko: '한국어',
      ar: 'العربية',
      hi: 'हिन्दी'
    };
    showToast({
      type: 'info',
      title: `Language Changed`,
      description: `You have changed the language to ${languageNames[languageCode]}.`,
    });
  };

  const getLanguageName = (code: string) => {
    const languageNames: Record<string, string> = {
      en: 'English (US)',
      es: 'Español',
      fr: 'Français',
      de: 'Deutsch',
      it: 'Italiano',
      pt: 'Português',
      ru: 'Русский',
      zh: '中文',
      ja: '日本語',
      ko: '한국어',
      ar: 'العربية',
      hi: 'हिन्दी'
    };
    return languageNames[code] || 'English (US)';
  };

  const handleHelpCenter = () => {
    Alert.alert('Help Center', 'Opening help center...', [
      { 
        text: 'Open Documentation',
        onPress: () => Linking.openURL('https://docs.schedura.com')
      },
      {
        text: 'Watch Tutorials',
        onPress: () => Linking.openURL('https://youtube.com/@schedura')
      },
      { text: 'Cancel', style: 'cancel' }
    ]);
  };

  const handleContactSupport = () => {
    Alert.alert('Contact Support', 'How would you like to contact us?', [
      { 
        text: 'Email',
        onPress: () => Linking.openURL('mailto:support@schedura.com')
      },
      { 
        text: 'Phone',
        onPress: () => Linking.openURL('tel:+1234567890')
      },
      { text: 'Cancel', style: 'cancel' }
    ]);
  };

  const handleRateApp = () => {
    Alert.alert(
      'Rate Schedura',
      'Enjoying Schedura? Please rate us on the app store!',
      [
        { 
          text: 'Rate on App Store',
          onPress: () => {
            // iOS App Store link
            Linking.openURL('https://apps.apple.com/app/schedura');
          }
        },
        {
          text: 'Rate on Play Store',
          onPress: () => {
            // Android Play Store link
            Linking.openURL('https://play.google.com/store/apps/details?id=com.schedura');
          }
        },
        { text: 'Maybe Later', style: 'cancel' }
      ]
    );
  };

  const handleAbout = () => {
    Alert.alert(
      'About Schedura',
      'Schedura v1.0.0\n\nYour premier space booking and management platform.\n\n© 2025 Schedura. All rights reserved.',
      [{ text: 'OK' }]
    );
  };

  const handleTerms = () => {
    Alert.alert('Terms of Service', 'Opening terms of service...', [
      { 
        text: 'Open in Browser',
        onPress: () => Linking.openURL('https://schedura.com/terms')
      },
      { text: 'Cancel', style: 'cancel' }
    ]);
  };

  const handlePrivacyPolicy = () => {
    Alert.alert('Privacy Policy', 'Opening privacy policy...', [
      { 
        text: 'Open in Browser',
        onPress: () => Linking.openURL('https://schedura.com/privacy')
      },
      { text: 'Cancel', style: 'cancel' }
    ]);
  };

  return (
    <SafeBoundingView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor="transparent" translucent />
      <ScrollView showsVerticalScrollIndicator={false}>
        <ProfileHeader profile={profile} loading={loading} onRefresh={fetchProfile} />

        <View className="px-6 py-6">
          <MenuSection title="Account">
            <MenuItem
              icon="person-outline"
              label="Edit Profile"
              subtitle="Update your personal information"
              onPress={handleEditProfile}
              disabled={loading}
            />
            <MenuItem
              icon="lock-closed-outline"
              label="Privacy & Security"
              subtitle="Manage your account security"
              onPress={handlePrivacySecurity}
              disabled={loading}
            />
            <MenuItem
              icon="card-outline"
              label="Billing & Payments"
              subtitle="Manage subscription and payments"
              onPress={handleBilling}
              disabled={loading}
            />
            <MenuItem
              icon="cube-outline"
              label="Integrations"
              subtitle="Manage third-party integrations"
              onPress={handleIntegrations}
              disabled={loading}
            />
          </MenuSection>

          <MenuSection title="Preferences">
            <MenuItem
              icon="notifications-outline"
              label="Notifications"
              subtitle="Push notifications and alerts"
              hasToggle
              toggleValue={notificationsEnabled}
              onToggleChange={handleNotificationsChange}
            />
            <MenuItem
              icon="moon-outline"
              label="Dark Mode"
              subtitle="Switch to dark theme"
              hasToggle
              toggleValue={isDark}
              onToggleChange={handleDarkModeChange}
            />
            <MenuItem
              icon="language-outline"
              label="Language"
              subtitle={getLanguageName(selectedLanguage)}
              onPress={handleLanguage}
              disabled={loading}
            />
          </MenuSection>

          <MenuSection title="Support">
            <MenuItem
              icon="help-circle-outline"
              label="Help Center"
              subtitle="FAQs and support articles"
              onPress={handleHelpCenter}
              disabled={loading}
            />
            <MenuItem
              icon="chatbubble-outline"
              label="Contact Support"
              subtitle="Get help from our team"
              onPress={handleContactSupport}
              disabled={loading}
            />
            <MenuItem
              icon="star-outline"
              label="Rate App"
              subtitle="Share your feedback"
              onPress={handleRateApp}
              disabled={loading}
            />
          </MenuSection>

          <MenuSection title="About">
            <MenuItem
              icon="information-circle-outline"
              label="About Schedura"
              subtitle="Version 1.0.0"
              onPress={handleAbout}
              disabled={loading}
            />
            <MenuItem
              icon="document-text-outline"
              label="Terms of Service"
              onPress={handleTerms}
              disabled={loading}
            />
            <MenuItem
              icon="shield-checkmark-outline"
              label="Privacy Policy"
              onPress={handlePrivacyPolicy}
              disabled={loading}
            />
          </MenuSection>

          {profile && (
            <View className="mt-4">
              <MenuItem
                icon="log-out-outline"
                label="Sign Out"
                subtitle="Sign out of your account"
                isDestructive
                onPress={() => setSignOutModalVisible(true)}
                disabled={loading}
              />
            </View>
          )}

          <View className="h-8" />
        </View>
      </ScrollView>

      <SignOutModal visible={signOutModalVisible} setVisible={setSignOutModalVisible} />
      <LanguageModal 
        visible={languageModalVisible} 
        setVisible={setLanguageModalVisible}
        selectedLanguage={selectedLanguage}
        onSelectLanguage={handleSelectLanguage}
      />
    </SafeBoundingView>
  );
};

export default ProfileScreen;
