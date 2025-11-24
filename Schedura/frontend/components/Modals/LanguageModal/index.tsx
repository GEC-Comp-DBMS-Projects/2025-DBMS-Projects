import React, { FC } from 'react';
import { View, Text, TouchableOpacity, Modal, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/contexts/ThemeContext';

interface Language {
  code: string;
  name: string;
  nativeName: string;
  flag: string;
}

const languages: Language[] = [
  { code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸' },
  { code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸' },
  { code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷' },
  { code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪' },
  { code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹' },
  { code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹' },
  { code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺' },
  { code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳' },
  { code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵' },
  { code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷' },
  { code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦' },
  { code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳' },
];

interface LanguageModalProps {
  visible: boolean;
  setVisible: (visible: boolean) => void;
  selectedLanguage?: string;
  onSelectLanguage: (languageCode: string) => void;
}

const LanguageModal: FC<LanguageModalProps> = ({ 
  visible, 
  setVisible, 
  selectedLanguage = 'en',
  onSelectLanguage 
}) => {
  const { colors } = useTheme();
  const handleSelectLanguage = (code: string) => {
    onSelectLanguage(code);
    setVisible(false);
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={visible}
      onRequestClose={() => setVisible(false)}
    >
      <View className="flex-1 justify-end bg-black/50">
        <View className=" rounded-t-3xl" style={{ maxHeight: '80%', backgroundColor: colors.background }}>
          {/* Header */}
          <View className="flex-row items-center justify-between px-6 py-4 border-b " style={{ borderColor: colors.border }}>
            <Text style={{color: colors.text}} className="text-xl font-bold">Select Language</Text>
            <TouchableOpacity onPress={() => setVisible(false)} className="p-2">
              <Ionicons name="close" size={24} color={colors.textTertiary} />
            </TouchableOpacity>
          </View>

          {/* Language List */}
          <ScrollView className="px-6 py-4" showsVerticalScrollIndicator={false}>
            {languages.map((language) => (
              <TouchableOpacity
                key={language.code}
                onPress={() => handleSelectLanguage(language.code)}
                className="flex-row items-center py-4 border-b "
                style={{ borderColor: colors.border }}
              >
                <Text className="text-3xl mr-4">{language.flag}</Text>
                <View className="flex-1">
                  <Text style={{color: colors.text}} className="text-base font-semibold">
                    {language.name}
                  </Text>
                  <Text style={{color: colors.textTertiary}} className="text-sm mt-1">
                    {language.nativeName}
                  </Text>
                </View>
                {selectedLanguage === language.code && (
                  <Ionicons name="checkmark-circle" size={24} color="#10b981" />
                )}
              </TouchableOpacity>
            ))}
            <View className="h-6" />
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
};

export default LanguageModal;
