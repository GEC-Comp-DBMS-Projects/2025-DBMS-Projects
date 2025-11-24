import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  StatusBar,
  Modal,
  Alert,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';

interface RouteParams {
  suggestionData: any;
  currentItinerary?: any;
  onAddToItinerary?: (suggestion: any, day: number, position: number) => Promise<boolean>;
}

const SuggestionsScreen = () => {
  const navigation = useNavigation<any>();
  const route = useRoute();
  const { suggestionData, currentItinerary, onAddToItinerary } = (route.params as RouteParams) || {};
  
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedSuggestion, setSelectedSuggestion] = useState<any>(null);
  const [isAdding, setIsAdding] = useState(false);

  if (!suggestionData) {
    return (
      <View className="flex-1 bg-gray-50">
        <StatusBar barStyle="dark-content" />
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center">
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Text className="text-2xl">←</Text>
            </TouchableOpacity>
            <Text className="text-lg font-bold text-gray-900">Suggestions</Text>
            <View className="w-10" />
          </View>
        </View>
        <View className="flex-1 items-center justify-center p-5">
          <Text className="text-gray-500 text-center">No suggestions available</Text>
        </View>
      </View>
    );
  }

  const getImageForType = (type: string, place: string) => {
    if (type === 'food') {
      return 'https://images.unsplash.com/photo-1533920379810-6bedac961555?w=400';
    }
    if (place.toLowerCase().includes('museum')) {
      return 'https://images.unsplash.com/photo-1564399579883-451a5d44ec08?w=400';
    }
    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400';
  };

  const handleOpenAddModal = (suggestion: any) => {
    if (!currentItinerary || !onAddToItinerary) {
      Alert.alert('Error', 'Cannot add suggestion without an active itinerary.');
      return;
    }
    setSelectedSuggestion(suggestion);
    setShowAddModal(true);
  };

  const handleAddAtPosition = async (day: number, position: number) => {
    if (!onAddToItinerary || !selectedSuggestion) return;
    
    setIsAdding(true);
    try {
      const success = await onAddToItinerary(selectedSuggestion, day, position);
      if (success) {
        Alert.alert(
          'Success! 🎉',
          `${selectedSuggestion.place} has been added to Day ${day}!`,
          [
            {
              text: 'View Itinerary',
              onPress: () => {
                setShowAddModal(false);
                navigation.goBack();
              }
            },
            {
              text: 'Add Another',
              onPress: () => setShowAddModal(false),
              style: 'cancel'
            }
          ]
        );
      }
    } catch (err) {
      Alert.alert('Error', 'Failed to add suggestion. Please try again.');
    } finally {
      setIsAdding(false);
    }
  };

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" />
      
      {/* Header */}
      <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
        <View className="flex-row justify-between items-center mb-4">
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text className="text-2xl">←</Text>
          </TouchableOpacity>
          <Text className="text-lg font-bold text-gray-900">Smart Suggestions</Text>
          <View className="w-10" />
        </View>

        {/* Decision Badge */}
        <View className="flex-row items-center justify-between">
          <View className="flex-1">
            <Text className="text-xl font-bold text-gray-900 mb-1">🎯 New Suggestion</Text>
            <Text className="text-xs text-gray-500">
              {suggestionData.decision === 'replace' ? 'Better alternatives nearby' : 'Additional options'}
            </Text>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Notification Card */}
        <View className="px-5 pt-5 pb-3">
          <LinearGradient
            colors={['#3b82f6', '#8b5cf6']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ borderRadius: 16, padding: 16 }}
          >
            <Text className="text-white text-sm font-bold mb-1">📢 Notification</Text>
            <Text className="text-white text-base leading-6">
              {suggestionData.notification}
            </Text>
          </LinearGradient>
        </View>

        {/* Reason Section */}
        {suggestionData.reason && (
          <View className="px-5 pb-3">
            <View className="bg-yellow-50 rounded-2xl p-4 border border-yellow-200">
              <Text className="text-xs text-yellow-600 font-semibold mb-1">WHY THIS SUGGESTION?</Text>
              <Text className="text-yellow-900 text-sm leading-5">
                {suggestionData.reason}
              </Text>
            </View>
          </View>
        )}

        {/* Suggestions Header */}
        <View className="px-5 pt-2 pb-3">
          <Text className="text-lg font-bold text-gray-900">
            Suggested Places ({suggestionData.suggestions?.length || 0})
          </Text>
          <Text className="text-xs text-gray-500 mt-1">
            Tap "Add to Itinerary" to choose where to insert
          </Text>
        </View>

        {/* Suggestions List */}
        <View className="px-5 pb-5">
          {suggestionData.suggestions?.map((suggestion: any, index: number) => (
            <View key={index} className="mb-4">
              <View className="bg-white rounded-2xl overflow-hidden shadow-lg border border-gray-200">
                {/* Image */}
                <Image
                  source={{ uri: getImageForType(suggestion.type, suggestion.place) }}
                  style={{ width: '100%', height: 180 }}
                  resizeMode="cover"
                />

                {/* Content */}
                <View className="p-4">
                  {/* Title and Type Badge */}
                  <View className="flex-row items-start justify-between mb-2">
                    <View className="flex-1 pr-2">
                      <Text className="text-lg font-bold text-gray-900 mb-1">
                        {suggestion.place}
                      </Text>
                    </View>
                    <View className={`rounded-full px-3 py-1 ${
                      suggestion.type === 'food' ? 'bg-orange-100' : 'bg-blue-100'
                    }`}>
                      <Text className={`text-xs font-bold ${
                        suggestion.type === 'food' ? 'text-orange-700' : 'text-blue-700'
                      }`}>
                        {suggestion.type === 'food' ? '🍽️ Food' : '🎯 Activity'}
                      </Text>
                    </View>
                  </View>

                  {/* Tags */}
                  {suggestion.tags && suggestion.tags.length > 0 && (
                    <View className="flex-row flex-wrap mb-3" style={{ gap: 6 }}>
                      {suggestion.tags.slice(0, 4).map((tag: string, idx: number) => (
                        <View
                          key={idx}
                          className="bg-purple-50 rounded-full px-2.5 py-1 border border-purple-200"
                        >
                          <Text className="text-purple-700 text-xs font-semibold">
                            #{tag}
                          </Text>
                        </View>
                      ))}
                    </View>
                  )}

                  {/* Description */}
                  <Text className="text-sm text-gray-600 leading-5 mb-3">
                    {suggestion.description}
                  </Text>

                  {/* Reason for Suggestion */}
                  <View className="bg-blue-50 rounded-xl p-3 mb-3">
                    <Text className="text-xs text-blue-600 font-semibold mb-1">WHY THIS?</Text>
                    <Text className="text-xs text-blue-900 leading-4">
                      {suggestion.reasonForSuggestion}
                    </Text>
                  </View>

                  {/* Info Pills */}
                  <View className="flex-row flex-wrap mb-3" style={{ gap: 8 }}>
                    <View className="bg-green-50 rounded-lg px-3 py-2 flex-row items-center">
                      <Text className="text-xs text-green-700 font-bold">
                        🚗 {suggestion.distanceFromCurrent} km
                      </Text>
                    </View>
                    <View className="bg-indigo-50 rounded-lg px-3 py-2 flex-row items-center">
                      <Text className="text-xs text-indigo-700 font-bold">
                        ⏱️ {suggestion.duration}
                      </Text>
                    </View>
                    {suggestion.cost !== undefined && (
                      <View className="bg-pink-50 rounded-lg px-3 py-2 flex-row items-center">
                        <Text className="text-xs text-pink-700 font-bold">
                          💰 ₹{suggestion.cost}
                        </Text>
                      </View>
                    )}
                  </View>

                  {/* Action Buttons */}
                  <View className="flex-row" style={{ gap: 8 }}>
                    <TouchableOpacity 
                      className="flex-1"
                      onPress={() => handleOpenAddModal(suggestion)}
                      disabled={!currentItinerary}
                    >
                      <LinearGradient
                        colors={currentItinerary ? ['#3b82f6', '#8b5cf6'] : ['#9ca3af', '#6b7280']}
                        start={{ x: 0, y: 0 }}
                        end={{ x: 1, y: 0 }}
                        style={{
                          borderRadius: 12,
                          paddingVertical: 12,
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
            </View>
          ))}
        </View>

        {/* Bottom Action */}
        <View className="px-5 pb-8">
          <TouchableOpacity
            onPress={() => navigation.goBack()}
            className="bg-white border-2 border-gray-200 rounded-xl py-4 items-center"
          >
            <Text className="text-gray-700 text-base font-bold">
              Back to Itinerary
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Add to Itinerary Modal */}
      <Modal
        visible={showAddModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowAddModal(false)}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl" style={{ height: '90%' }}>
            {/* Modal Header */}
            <View className="p-5 border-b border-gray-200">
              <View className="flex-row items-center justify-between mb-2">
                <Text className="text-xl font-bold text-gray-900">Choose Location</Text>
                <TouchableOpacity
                  onPress={() => setShowAddModal(false)}
                  className="w-10 h-10 bg-gray-100 rounded-full items-center justify-center"
                >
                  <Text className="text-xl text-gray-600">✕</Text>
                </TouchableOpacity>
              </View>
              <Text className="text-sm text-gray-600">
                Select where to add "{selectedSuggestion?.place}"
              </Text>
            </View>

            {/* Days List */}
            <ScrollView className="flex-1 px-5 py-4">
              {currentItinerary?.days?.map((dayData: any) => (
                <View key={dayData.day} className="mb-6">
                  {/* Day Header */}
                  <View className="bg-blue-50 rounded-xl p-3 mb-3">
                    <Text className="text-base font-bold text-blue-900">
                      📅 Day {dayData.day}
                    </Text>
                    <Text className="text-xs text-blue-700 mt-1">
                      {dayData.activities?.length || 0} activities
                    </Text>
                  </View>

                  {/* Add at Start */}
                  <TouchableOpacity
                    onPress={() => handleAddAtPosition(dayData.day, 0)}
                    disabled={isAdding}
                    className="bg-green-50 border-2 border-green-200 rounded-xl p-3 mb-2"
                    activeOpacity={0.7}
                  >
                    <Text className="text-green-700 font-bold text-sm">
                      ➕ Add at Start of Day
                    </Text>
                    <Text className="text-green-600 text-xs mt-1">
                      Will be scheduled before first activity
                    </Text>
                  </TouchableOpacity>

                  {/* Activities with insert points */}
                  {dayData.activities?.map((activity: any, index: number) => (
                    <View key={index}>
                      {/* Activity Card */}
                      <View className="bg-gray-50 rounded-xl p-3 mb-2 ml-4">
                        <View className="flex-row items-center justify-between">
                          <View className="flex-1">
                            <Text className="text-sm font-bold text-gray-900">
                              {activity.place}
                            </Text>
                            <Text className="text-xs text-gray-600 mt-1">
                              {activity.time} • {activity.duration}
                            </Text>
                          </View>
                        </View>
                      </View>

                      {/* Insert Button After This Activity */}
                      <TouchableOpacity
                        onPress={() => handleAddAtPosition(dayData.day, index + 1)}
                        disabled={isAdding}
                        className="bg-blue-50 border-2 border-blue-200 border-dashed rounded-xl p-3 mb-2 ml-4"
                        activeOpacity={0.7}
                      >
                        <Text className="text-blue-700 font-bold text-sm text-center">
                          ➕ Add After This
                        </Text>
                        <Text className="text-blue-600 text-xs text-center mt-1">
                          Time will be calculated automatically
                        </Text>
                      </TouchableOpacity>
                    </View>
                  ))}
                </View>
              ))}

              {isAdding && (
                <View className="py-4 items-center">
                  <Text className="text-blue-600 font-bold">Adding to itinerary...</Text>
                </View>
              )}
            </ScrollView>
          </View>
        </View>
      </Modal>
    </View>
  );
};

export default SuggestionsScreen;
