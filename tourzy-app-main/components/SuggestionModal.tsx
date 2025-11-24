import React from 'react';
import {
  View,
  Text,
  Modal,
  TouchableOpacity,
  ScrollView,
  Image,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SuggestionData } from '../services/SuggestionService';

interface Props {
  visible: boolean;
  suggestionData: SuggestionData | null;
  onClose: () => void;
  onAcceptSuggestion: (suggestion: any) => void;
}

const SuggestionModal: React.FC<Props> = ({
  visible,
  suggestionData,
  onClose,
  onAcceptSuggestion,
}) => {
  if (!suggestionData) return null;

  const getImageForType = (type: string, place: string) => {
    if (type === 'food') {
      return 'https://images.unsplash.com/photo-1533920379810-6bedac961555?w=400';
    }
    if (place.toLowerCase().includes('museum')) {
      return 'https://images.unsplash.com/photo-1564399579883-451a5d44ec08?w=400';
    }
    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400';
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View className="flex-1 bg-black/50 justify-end">
        <View className="bg-white rounded-t-3xl" style={{ maxHeight: '90%' }}>
          {/* Header */}
          <View className="p-5 border-b border-gray-200">
            <View className="flex-row items-center justify-between mb-3">
              <View className="flex-1">
                <Text className="text-xl font-bold text-gray-900">🎯 New Suggestion</Text>
                <Text className="text-xs text-gray-500 mt-1">
                  {suggestionData.decision === 'replace' ? 'Better alternatives nearby' : 'Additional options'}
                </Text>
              </View>
              <TouchableOpacity
                onPress={onClose}
                className="w-10 h-10 bg-gray-100 rounded-full items-center justify-center"
              >
                <Text className="text-xl text-gray-600">✕</Text>
              </TouchableOpacity>
            </View>

            {/* Notification Message */}
            <View className="bg-blue-50 rounded-2xl p-4">
              <Text className="text-blue-900 text-sm leading-5">
                {suggestionData.notification}
              </Text>
            </View>

            {/* Reason */}
            {suggestionData.reason && (
              <View className="mt-3">
                <Text className="text-xs text-gray-500">{suggestionData.reason}</Text>
              </View>
            )}
          </View>

          {/* Suggestions List */}
          <ScrollView className="flex-1 px-5 py-4">
            <Text className="text-base font-bold text-gray-900 mb-3">
              Suggested Places ({suggestionData.suggestions.length})
            </Text>

            {suggestionData.suggestions.map((suggestion, index) => (
              <View key={index} className="mb-4">
                <View className="bg-white rounded-2xl overflow-hidden shadow-lg border border-gray-200">
                  {/* Image */}
                  <Image
                    source={{ uri: getImageForType(suggestion.type, suggestion.place) }}
                    style={{ width: '100%', height: 140 }}
                    resizeMode="cover"
                  />

                  {/* Content */}
                  <View className="p-4">
                    {/* Title and Tags */}
                    <View className="mb-2">
                      <Text className="text-lg font-bold text-gray-900 mb-1">
                        {suggestion.place}
                      </Text>
                      <View className="flex-row flex-wrap" style={{ gap: 6 }}>
                        {suggestion.tags.slice(0, 3).map((tag, idx) => (
                          <View
                            key={idx}
                            className="bg-blue-100 rounded-full px-2 py-1"
                          >
                            <Text className="text-blue-700 text-xs font-semibold">
                              {tag}
                            </Text>
                          </View>
                        ))}
                      </View>
                    </View>

                    {/* Description */}
                    <Text className="text-sm text-gray-600 leading-5 mb-3">
                      {suggestion.description}
                    </Text>

                    {/* Reason */}
                    <View className="bg-yellow-50 rounded-lg p-3 mb-3">
                      <Text className="text-xs text-yellow-900 leading-4">
                        💡 {suggestion.reasonForSuggestion}
                      </Text>
                    </View>

                    {/* Info Pills */}
                    <View className="flex-row flex-wrap mb-3" style={{ gap: 8 }}>
                      <View className="bg-purple-50 rounded-lg px-3 py-1.5">
                        <Text className="text-xs text-purple-700 font-semibold">
                          🚗 {suggestion.distanceFromCurrent} km away
                        </Text>
                      </View>
                      <View className="bg-green-50 rounded-lg px-3 py-1.5">
                        <Text className="text-xs text-green-700 font-semibold">
                          ⏱️ {suggestion.duration}
                        </Text>
                      </View>
                      <View className="bg-orange-50 rounded-lg px-3 py-1.5">
                        <Text className="text-xs text-orange-700 font-semibold">
                          {suggestion.type === 'food' ? '🍽️ Food' : '🎯 Activity'}
                        </Text>
                      </View>
                    </View>

                    {/* Action Button */}
                    <TouchableOpacity
                      onPress={() => {
                        onAcceptSuggestion(suggestion);
                        onClose();
                      }}
                    >
                      <LinearGradient
                        colors={['#3b82f6', '#8b5cf6']}
                        start={{ x: 0, y: 0 }}
                        end={{ x: 1, y: 0 }}
                        style={{
                          borderRadius: 12,
                          paddingVertical: 12,
                          paddingHorizontal: 16,
                          alignItems: 'center',
                        }}
                      >
                        <Text className="text-white text-sm font-bold">
                          ➕ Add to Itinerary
                        </Text>
                      </LinearGradient>
                    </TouchableOpacity>
                  </View>
                </View>
              </View>
            ))}
          </ScrollView>

          {/* Footer */}
          <View className="p-5 border-t border-gray-200">
            <TouchableOpacity
              onPress={onClose}
              className="bg-gray-100 rounded-xl py-3 items-center"
            >
              <Text className="text-gray-700 text-sm font-bold">
                Maybe Later
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
};

export default SuggestionModal;

