import React, { useState, useEffect } from "react";
import { View, Text, Image, ScrollView, TouchableOpacity, SafeAreaView, StatusBar, Share, Dimensions, TextInput, Alert, ActivityIndicator, KeyboardAvoidingView, Platform, Animated } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { getSpaceById } from "@/supabase/controllers/spaces.controller";
//@ts-ignore
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
import SpaceMapView from '@/components/SpaceMapView';
import { supabase } from '@/supabase/supabase';
import { useUser } from '@clerk/clerk-expo';
import { useToast } from "@/components/Toast";

const { width } = Dimensions.get('window');

// Skeleton Loader Component
const SkeletonLoader: React.FC<{ width: number | string; height: number; style?: any }> = ({ width, height, style }) => {
  const animatedValue = new Animated.Value(0);

  React.useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(animatedValue, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(animatedValue, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, []);

  const opacity = animatedValue.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.7],
  });

  return (
    <Animated.View
      style={[
        {
          width,
          height,
          backgroundColor: '#E0E0E0',
          borderRadius: 8,
          opacity,
        },
        style,
      ]}
    />
  );
};

// Image Gallery Skeleton
const ImageGallerySkeleton: React.FC<{ isDark: boolean }> = ({ isDark }) => (
  <View style={{ position: 'relative' }}>
    <SkeletonLoader width={width} height={300} style={{ borderRadius: 0 }} />
    <View style={{ position: 'absolute', top: 48, left: 24, right: 24, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
      <View style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12, width: 48, height: 48 }} />
      <View style={{ flexDirection: 'row', gap: 12 }}>
        <View style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12, width: 48, height: 48 }} />
        <View style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12, width: 48, height: 48 }} />
      </View>
    </View>
  </View>
);

// Header Info Skeleton
const HeaderInfoSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View style={{ padding: 24, paddingBottom: 16 }}>
    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
      <View style={{ flex: 1 }}>
        <SkeletonLoader width="80%" height={36} style={{ marginBottom: 12 }} />
        <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
          <View style={{ width: 32, height: 32, backgroundColor: colors.backgroundSecondary, borderRadius: 16, marginRight: 12 }} />
          <SkeletonLoader width="60%" height={20} />
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <View style={{ width: 32, height: 32, backgroundColor: colors.backgroundSecondary, borderRadius: 16, marginRight: 12 }} />
          <SkeletonLoader width="50%" height={20} />
        </View>
      </View>
      <SkeletonLoader width={80} height={32} style={{ borderRadius: 16 }} />
    </View>
    <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 16 }}>
      <SkeletonLoader width={70} height={24} style={{ borderRadius: 20, marginRight: 12 }} />
      <SkeletonLoader width={120} height={16} />
    </View>
  </View>
);

// Action Buttons Skeleton
const ActionButtonsSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View style={{ paddingHorizontal: 24, paddingBottom: 24 }}>
    <View style={{ flexDirection: 'row', gap: 8 }}>
      <SkeletonLoader width="50%" height={48} style={{ borderRadius: 16 }} />
      <SkeletonLoader width="50%" height={48} style={{ borderRadius: 16 }} />
    </View>
  </View>
);

// Section Skeleton
const SectionSkeleton: React.FC<{ colors: any; title?: string; lines?: number }> = ({ colors, title, lines = 3 }) => (
  <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
    <SkeletonLoader width={title ? 200 : 150} height={24} style={{ marginBottom: 16 }} />
    {Array.from({ length: lines }).map((_, i) => (
      <SkeletonLoader key={i} width={i === lines - 1 ? "70%" : "100%"} height={16} style={{ marginBottom: 8 }} />
    ))}
  </View>
);

// Facilities Skeleton
const FacilitiesSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
    <SkeletonLoader width={200} height={24} style={{ marginBottom: 16 }} />
    <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
      {[1, 2, 3, 4, 5, 6].map((i) => (
        <View key={i} style={{ flexDirection: 'row', alignItems: 'center', marginRight: 24, marginBottom: 16 }}>
          <SkeletonLoader width={40} height={40} style={{ borderRadius: 12, marginRight: 12 }} />
          <SkeletonLoader width={80} height={16} />
        </View>
      ))}
    </View>
  </View>
);

// Reviews Skeleton
const ReviewsSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
      <SkeletonLoader width={120} height={24} />
      <SkeletonLoader width={80} height={20} />
    </View>
    {[1, 2, 3].map((i) => (
      <View key={i} style={{ backgroundColor: colors.backgroundSecondary, borderRadius: 16, padding: 16, marginBottom: 12 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <SkeletonLoader width={40} height={40} style={{ borderRadius: 20, marginRight: 12 }} />
            <View>
              <SkeletonLoader width={100} height={16} style={{ marginBottom: 4 }} />
              <SkeletonLoader width={80} height={12} />
            </View>
          </View>
          <SkeletonLoader width={50} height={20} style={{ borderRadius: 10 }} />
        </View>
        <SkeletonLoader width="100%" height={14} style={{ marginBottom: 6 }} />
        <SkeletonLoader width="85%" height={14} />
      </View>
    ))}
  </View>
);

export default function HallDetails() {
  const { colors, isDark } = useTheme();
  const { id } = useLocalSearchParams();
  const { user } = useUser();
  const [loading, setLoading] = useState(true);
  const [reviewsLoading, setReviewsLoading] = useState(false);
  const [submittingReview, setSubmittingReview] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [isFavorite, setIsFavorite] = useState(false);
  const [showMapView, setShowMapView] = useState(false);
  const [reviews, setReviews] = useState<any[]>([]);
  const [reviewText, setReviewText] = useState('');
  const [rating, setRating] = useState(5);
  const { back, push } = useRouter();
  const { showToast } = useToast();
  
  const facilities = [
    { name: "WiFi", icon: "wifi", available: true },
    { name: "Parking", icon: "car", available: true },
    { name: "AC", icon: "snow", available: true },
    { name: "Projector", icon: "tv", available: true },
    { name: "Catering", icon: "restaurant", available: false },
    { name: "Sound System", icon: "volume-high", available: true },
  ];

  const [space, setSpace] = useState<any>();

  const fetchSpace = async () => {
    try {
      setLoading(true);
      const { data, error } = await getSpaceById(id as string);
      if (error) {
        console.error("Error fetching spaces:", error);
      } else {
        setSpace(data);
      }
      setLoading(false);
    } catch (error) {
      console.error("Error in fetchSpaces:", error);
      setLoading(false);
    }
  };

  const fetchReviews = async () => {
    try {
      setReviewsLoading(true);
      const { data, error } = await supabase
        .from('reviews')
        .select(`
          *,
          users!userid (
            name
          )
        `)
        .eq('spaceid', id)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching reviews:', error);
      } else {
        setReviews(data || []);
      }
    } catch (error) {
      console.error('Error in fetchReviews:', error);
    } finally {
      setReviewsLoading(false);
    }
  };

  const submitReview = async () => {
    if (!user) {
      showToast({
        type: 'error',
        title: 'Sign In Required',
        description: 'Please sign in to submit a review.',
      });
      return;
    }
    if (!reviewText.trim()) {
      showToast({
        type: 'error',
        title: 'Review Required',
        description: 'Please enter your review.',
      });
      return;
    }
    try {
      setSubmittingReview(true);
      const { error } = await supabase
        .from('reviews')
        .insert({
          spaceid: id,
          userid: user.id,
          stars: rating,
          review: reviewText.trim(),
        });

      if (error) {
        console.error('Error submitting review:', error);
        showToast({
          type: 'error',
          title: 'Error',
          description: 'Failed to submit review. Please try again.',
        });
      } else {
        showToast({
          type: 'success',
          title: 'Success',
          description: 'Your review has been submitted!',
        });
        setReviewText('');
        setRating(5);
        fetchReviews();
      }
    } catch (error) {
      console.error('Error in submitReview:', error);
      showToast({
        type: 'error',
        title: 'Error',
        description: 'An error occurred. Please try again.',
      });
    } finally {
      setSubmittingReview(false);
    }
  };

  useEffect(() => {
    fetchSpace();
    fetchReviews();
  }, [id]);
  
  const handleShare = async () => {
    try {
      await Share.share({
        message: `Check out this amazing venue: ${space.name} at ${space.location}`,
      });
    } catch (error) {
      console.log('Error sharing:', error);
    }
  };

  if (loading) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.backgroundSecondary }}>
        <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />
        
        <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
          <ImageGallerySkeleton isDark={isDark} />
          
          <View style={{ backgroundColor: colors.card, borderTopLeftRadius: 24, borderTopRightRadius: 24, marginTop: -24, position: 'relative', zIndex: 10 }}>
            <HeaderInfoSkeleton colors={colors} />
            <ActionButtonsSkeleton colors={colors} />
            <SectionSkeleton colors={colors} lines={4} />
            <FacilitiesSkeleton colors={colors} />
            <SectionSkeleton colors={colors} lines={2} />
            <SectionSkeleton colors={colors} lines={1} />
            <ReviewsSkeleton colors={colors} />
            <SectionSkeleton colors={colors} lines={1} />
          </View>
        </ScrollView>

        <View style={{ backgroundColor: colors.card, borderTopWidth: 1, borderTopColor: colors.border, paddingHorizontal: 24, paddingVertical: 16 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
            <View>
              <SkeletonLoader width={100} height={28} style={{ marginBottom: 4 }} />
              <SkeletonLoader width={60} height={16} />
            </View>
            <SkeletonLoader width={120} height={48} style={{ borderRadius: 16 }} />
          </View>
        </View>
      </SafeAreaView>
    );
  }

  if (!space) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <Text style={{ color: colors.textSecondary }}>Space not found</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />
      
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
        <View style={{ position: 'relative' }}>
          <ScrollView
            horizontal
            pagingEnabled
            showsHorizontalScrollIndicator={false}
            onScroll={({ nativeEvent }) => {
              const slide = Math.ceil(nativeEvent.contentOffset.x / nativeEvent.layoutMeasurement.width);
              if (slide !== currentImageIndex) {
                setCurrentImageIndex(slide);
              }
            }}
            scrollEventThrottle={20}
          >
            {space?.images.map((image: any, index: number) => (
              <Image
                key={index}
                source={{ uri: image }}
                style={{ width, height: 300, backgroundColor: colors.backgroundSecondary }}
              />
            ))}
          </ScrollView>
          

          {space?.images.length > 1 && (
            <View style={{ position: 'absolute', bottom: 16, alignSelf: 'center', flexDirection: 'row', gap: 8 }}>
              {space.images.map((_: any, index: number) => (
                <View
                  key={index}
                  style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: index === currentImageIndex ? 'white' : 'rgba(255,255,255,0.5)' }}
                />
              ))}
            </View>
          )}
          

          <View style={{ position: 'absolute', top: 0, left: 0, right: 0, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 24, paddingTop: 48 }}>
            <TouchableOpacity 
                onPress={() => back()}
                style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12 }}>
              <Ionicons name="arrow-back" size={24} color="white" />
            </TouchableOpacity>
            <View style={{ flexDirection: 'row', gap: 12 }}>
              <TouchableOpacity 
                onPress={handleShare}
                style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12 }}
              >
                <Ionicons name="share-outline" size={24} color="white" />
              </TouchableOpacity>
              <TouchableOpacity 
                onPress={() => setIsFavorite(!isFavorite)}
                style={{ backgroundColor: 'rgba(0,0,0,0.3)', borderRadius: 24, padding: 12 }}
              >
                <Ionicons 
                  name={isFavorite ? "heart" : "heart-outline"} 
                  size={24} 
                  color={isFavorite ? "#EF4444" : "white"} 
                />
              </TouchableOpacity>
            </View>
          </View>
        </View>

        <View style={{ backgroundColor: colors.card, borderTopLeftRadius: 24, borderTopRightRadius: 24, marginTop: -24, position: 'relative', zIndex: 10 }}>

          <View style={{ padding: 24, paddingBottom: 16 }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 30, fontWeight: 'bold', color: colors.text, marginBottom: 8 }}>{space.name}</Text>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
                  <View style={{ backgroundColor: colors.backgroundSecondary, borderRadius: 20, padding: 8, marginRight: 12 }}>
                    <Ionicons name="location" size={16} color={colors.textSecondary} />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 18, flex: 1 }}>{space.location}</Text>
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View style={{ backgroundColor: colors.backgroundSecondary, borderRadius: 20, padding: 8, marginRight: 12 }}>
                    <Ionicons name="people" size={16} color={colors.textSecondary} />
                  </View>
                  <Text style={{ color: colors.textSecondary, fontSize: 18 }}>Up to {space.capacity} guests</Text>
                </View>
              </View>
              
              <View style={{ backgroundColor: colors.success + '20', borderRadius: 16, paddingHorizontal: 16, paddingVertical: 8 }}>
                <Text style={{ color: colors.success, fontWeight: '600' }}>Available</Text>
              </View>
            </View>
            

            <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 16 }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: '#FEF3C7', borderRadius: 20, paddingHorizontal: 12, paddingVertical: 4, marginRight: 12 }}>
              <Ionicons name="star" size={16} color="#F59E0B" />
              <Text style={{ color: '#92400E', fontWeight: '600', marginLeft: 4 }}>
                {reviews.length > 0
                ? (
                  reviews.reduce((sum, r) => sum + (r.stars || 0), 0) / reviews.length
                  ).toFixed(1)
                : '0.0'}
              </Text>
              </View>
              <Text style={{ color: colors.textSecondary }}>
              Based on {reviews.length} review{reviews.length === 1 ? '' : 's'}
              </Text>
            </View>
          </View>


          <View style={{ paddingHorizontal: 24, paddingBottom: 24 }}>
            <View style={{ flexDirection: 'row', gap: 8 }}>
              <TouchableOpacity onPress={()=>push(`/space/${id}/book` as any)} style={{ backgroundColor: colors.accent, borderRadius: 16, paddingHorizontal: 24, paddingVertical: 12, flex: 1 }}>
                <Text style={{ color: colors.primary, textAlign: 'center', fontWeight: '600', fontSize: 18, marginVertical: 'auto' }}>Book Now</Text>
              </TouchableOpacity>
              <TouchableOpacity style={{ borderWidth: 2, borderColor: colors.border, borderRadius: 16, paddingHorizontal: 24, paddingVertical: 12, flex: 1, backgroundColor: colors.card }}>
                <Text style={{ color: colors.text, textAlign: 'center', fontWeight: '600', fontSize: 18 }}>Check Avail</Text>
              </TouchableOpacity>
            </View>
          </View>


          <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
            <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text, marginBottom: 16 }}>About This Venue</Text>
            <Text style={{ color: colors.textSecondary, lineHeight: 24, fontSize: 16 }}>
              {space.description}
            </Text>
          </View>


          <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
            <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text, marginBottom: 16 }}>Facilities & Amenities</Text>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
              {facilities.map((facility, index) => (
                <View 
                  key={index} 
                  style={{ 
                    flexDirection: 'row', 
                    alignItems: 'center', 
                    marginRight: 24, 
                    marginBottom: 16,
                    opacity: space.amenities.includes(facility.name) ? 1 : 0.5
                  }}
                >
                  <View style={{ 
                    padding: 8, 
                    borderRadius: 12, 
                    marginRight: 12,
                    backgroundColor: space.amenities.includes(facility.name) ? colors.success + '20' : colors.backgroundSecondary
                  }}>
                    <Ionicons 
                      name={facility.icon as any} 
                      size={20} 
                      color={space.amenities.includes(facility.name) ? colors.success : colors.textSecondary} 
                    />
                  </View>
                  <Text style={{ 
                    fontWeight: '500',
                    color: space.amenities.includes(facility.name) ? colors.text : colors.textSecondary
                  }}>
                    {facility.name}
                  </Text>
                  {!space.amenities.includes(facility.name) && (
                    <Text style={{ color: colors.textSecondary, marginLeft: 4 }}>(Not Available)</Text>
                  )}
                </View>
              ))}
            </View>
          </View>


          <View className="px-6 py-6" style={{ borderTopWidth: 1, borderTopColor: colors.border }}>
            <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text, marginBottom: 16 }}>Pricing</Text>
            <View className="py-6" style={{ backgroundColor: colors.accent + '10', borderRadius: 16 }}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                <Text style={{ fontSize: 24, fontWeight: 'bold', color: colors.text }}>₹{space.pph}</Text>
                <Text style={{ color: colors.textSecondary }}>per day</Text>
              </View>
            </View>
          </View>


          {space.latitude && space.longitude && (
            <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text, marginBottom: 16 }}>Location</Text>
              <TouchableOpacity 
                onPress={() => setShowMapView(true)}
                style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: colors.border, borderRadius: 16, paddingVertical: 12 }}
              >
                <Ionicons name="map" size={20} color={colors.text} />
                <Text style={{ color: colors.text, fontWeight: '600', marginLeft: 8 }}>View on Map</Text>
              </TouchableOpacity>
            </View>
          )}


          <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border }}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text }}>Reviews</Text>
              {reviews.length > 2 && (
                <TouchableOpacity>
                  <Text style={{ color: colors.link, fontWeight: '600' }}>See All ({reviews.length})</Text>
                </TouchableOpacity>
              )}
            </View>
            
            {/* Add Review Input */}
            {user && (
              <View style={{ backgroundColor: colors.card, borderRadius: 16, padding: 16, marginBottom: 16, borderWidth: 1, borderColor: colors.border }}>
                <Text style={{ fontSize: 16, fontWeight: '600', color: colors.text, marginBottom: 12 }}>Write a Review</Text>
                
                {/* Star Rating */}
                <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 12 }}>
                  <Text style={{ color: colors.textSecondary, marginRight: 12 }}>Rating:</Text>
                  <View style={{ flexDirection: 'row', gap: 8 }}>
                    {[1, 2, 3, 4, 5].map((star) => (
                      <TouchableOpacity key={star} onPress={() => setRating(star)}>
                        <Ionicons
                          name={star <= rating ? 'star' : 'star-outline'}
                          size={24}
                          color={star <= rating ? '#F59E0B' : colors.textSecondary}
                        />
                      </TouchableOpacity>
                    ))}
                  </View>
                </View>

                {/* Review Text Input */}
                <TextInput
                  placeholder="Share your experience..."
                  placeholderTextColor={colors.textSecondary}
                  value={reviewText}
                  onChangeText={setReviewText}
                  multiline
                  numberOfLines={4}
                  style={{
                    padding: 12,
                    borderRadius: 12,
                    borderWidth: 1,
                    borderColor: colors.border,
                    backgroundColor: colors.backgroundSecondary,
                    color: colors.text,
                    minHeight: 80,
                    textAlignVertical: 'top',
                    marginBottom: 12,
                  }}
                />

                {/* Submit Button */}
                <TouchableOpacity
                  onPress={submitReview}
                  disabled={submittingReview}
                  style={{
                    backgroundColor: submittingReview ? colors.border : colors.accent,
                    borderRadius: 12,
                    paddingVertical: 12,
                    alignItems: 'center',
                    flexDirection: 'row',
                    justifyContent: 'center',
                    gap: 8,
                  }}
                >
                  {submittingReview && <ActivityIndicator size="small" color="#fff" />}
                  <Text style={{ color: colors.primary, fontWeight: '600', fontSize: 16 }}>
                    {submittingReview ? 'Submitting...' : 'Submit Review'}
                  </Text>
                </TouchableOpacity>
              </View>
            )}

            {/* Reviews List */}
            {reviewsLoading ? (
              <View style={{ paddingVertical: 24, alignItems: 'center' }}>
                <ActivityIndicator size="small" color={colors.accent} />
                <Text style={{ color: colors.textSecondary, marginTop: 8 }}>Loading reviews...</Text>
              </View>
            ) : reviews.length === 0 ? (
              <View style={{ paddingVertical: 24, alignItems: 'center' }}>
                <Text style={{ color: colors.textSecondary }}>No reviews yet. Be the first to review!</Text>
              </View>
            ) : (
              <View style={{ gap: 16 }}>
                {reviews.slice(0, 5).map((review) => (
                  <View key={review.id} style={{ backgroundColor: colors.backgroundSecondary, borderRadius: 16, padding: 16 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                        <View style={{ width: 40, height: 40, backgroundColor: colors.border, borderRadius: 20, marginRight: 12, justifyContent: 'center', alignItems: 'center' }}>
                          <Text style={{ color: colors.text, fontWeight: '600', fontSize: 16 }}>
                            {review.users?.name?.[0]?.toUpperCase() || 'U'}
                          </Text>
                        </View>
                        <View>
                          <Text style={{ fontWeight: '600', color: colors.text }}>
                            {review.users?.name || 'Anonymous'}
                          </Text>
                          <Text style={{ fontSize: 12, color: colors.textSecondary }}>
                            {new Date(review.created_at).toLocaleDateString()}
                          </Text>
                        </View>
                      </View>
                      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                        <Ionicons name="star" size={16} color="#F59E0B" />
                        <Text style={{ color: colors.textSecondary, marginLeft: 4 }}>{review.stars}.0</Text>
                      </View>
                    </View>
                    <Text style={{ color: colors.textSecondary, lineHeight: 20 }}>
                      {review.review}
                    </Text>
                  </View>
                ))}
              </View>
            )}
          </View>


          <View style={{ paddingHorizontal: 24, paddingVertical: 16, borderTopWidth: 1, borderTopColor: colors.border, marginBottom: 32 }}>
            <Text style={{ fontSize: 20, fontWeight: 'bold', color: colors.text, marginBottom: 16 }}>Contact Host</Text>
            <View style={{ flexDirection: 'row', gap: 8 }}>
              <TouchableOpacity style={{ backgroundColor: '#10B981', borderRadius: 16, paddingHorizontal: 24, paddingVertical: 12, flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}>
                <Ionicons name="call" size={20} color="white" />
                <Text style={{ color: 'white', fontWeight: '600', marginLeft: 8 }}>Call</Text>
              </TouchableOpacity>
              <TouchableOpacity style={{ backgroundColor: '#3B82F6', borderRadius: 16, paddingHorizontal: 24, paddingVertical: 12, flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}>
                <Ionicons name="chatbubble" size={20} color="white" />
                <Text style={{ color: 'white', fontWeight: '600', marginLeft: 8 }}>Message</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </ScrollView>

      <View style={{ backgroundColor: colors.card, borderTopWidth: 1, borderTopColor: colors.border, paddingHorizontal: 24, paddingVertical: 16 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View>
            <Text style={{ fontSize: 24, fontWeight: 'bold', color: colors.text }}>₹{space.pph}</Text>
            <Text style={{ color: colors.textSecondary }}>per day</Text>
          </View>
          <TouchableOpacity onPress={()=>push(`/space/${id}/book` as any)} style={{ backgroundColor: colors.accent, borderRadius: 16, paddingHorizontal: 32, paddingVertical: 12 }}>
            <Text style={{ color: colors.primary, fontWeight: '600', fontSize: 18 }}>Book Now</Text>
          </TouchableOpacity>
        </View>
      </View>
      
      {space.latitude && space.longitude && (
        <SpaceMapView
          visible={showMapView}
          onClose={() => setShowMapView(false)}
          latitude={space.latitude}
          longitude={space.longitude}
          spaceName={space.name}
          spaceAddress={space.location}
        />
      )}
    </SafeAreaView>
  );
}