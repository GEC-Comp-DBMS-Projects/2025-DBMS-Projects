import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  TextInput,
  Alert,
  ActivityIndicator,
  RefreshControl,
  Modal,
  Image,
  SafeAreaView,
} from 'react-native';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { auth, db } from '../firebase';
import {
  collection,
  addDoc,
  query,
  orderBy,
  getDocs,
  doc,
  getDoc,
  updateDoc,
  arrayUnion,
  arrayRemove,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';

interface Post {
  id: string;
  userId: string;
  userName: string;
  userLocation?: string;
  content: string;
  placeName?: string;
  placeLocation?: string;
  imageUrl?: string;
  likes: string[];
  comments: Comment[];
  createdAt: any;
}

interface Comment {
  userId: string;
  userName: string;
  text: string;
  createdAt: any;
}

function SocialFeed() {
  const navigation = useNavigation<any>();
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showCommentsModal, setShowCommentsModal] = useState(false);
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);
  
  // Create post fields
  const [postContent, setPostContent] = useState('');
  const [postPlace, setPostPlace] = useState('');
  const [postLocation, setPostLocation] = useState('');
  const [posting, setPosting] = useState(false);
  
  // Comment
  const [commentText, setCommentText] = useState('');
  const [commenting, setCommenting] = useState(false);

  useEffect(() => {
    loadPosts();
  }, []);

  useFocusEffect(
    useCallback(() => {
      loadPosts();
    }, [])
  );

  const loadPosts = async () => {
    try {
      const postsRef = collection(db, 'posts');
      const q = query(postsRef, orderBy('createdAt', 'desc'));
      const querySnapshot = await getDocs(q);

      const postsData: Post[] = [];
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        postsData.push({
          id: doc.id,
          ...data,
          likes: data.likes || [],
          comments: data.comments || [],
        } as Post);
      });

      setPosts(postsData);
    } catch (error) {
      console.error('Error loading posts:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const handleCreatePost = async () => {
    if (!postContent.trim()) {
      Alert.alert('Error', 'Please write something to post');
      return;
    }

    setPosting(true);
    try {
      const user = auth.currentUser;
      if (!user) {
        Alert.alert('Error', 'You must be logged in to post');
        return;
      }

      const userDoc = await getDoc(doc(db, 'users', user.uid));
      const userData = userDoc.data();

      await addDoc(collection(db, 'posts'), {
        userId: user.uid,
        userName: userData?.name || 'Traveler',
        userLocation: userData?.location || '',
        content: postContent,
        placeName: postPlace,
        placeLocation: postLocation,
        likes: [],
        comments: [],
        createdAt: serverTimestamp(),
      });

      setPostContent('');
      setPostPlace('');
      setPostLocation('');
      setShowCreateModal(false);
      Alert.alert('Success', 'Post created successfully!');
      loadPosts();
    } catch (error) {
      console.error('Error creating post:', error);
      Alert.alert('Error', 'Failed to create post');
    } finally {
      setPosting(false);
    }
  };

  const handleLike = async (postId: string) => {
    try {
      const user = auth.currentUser;
      if (!user) return;

      const postRef = doc(db, 'posts', postId);
      const postDoc = await getDoc(postRef);
      const postData = postDoc.data();

      const likes = postData?.likes || [];
      
      if (Array.isArray(likes) && likes.includes(user.uid)) {
        // Unlike
        await updateDoc(postRef, {
          likes: arrayRemove(user.uid),
        });
      } else {
        // Like
        await updateDoc(postRef, {
          likes: arrayUnion(user.uid),
        });
      }

      loadPosts();
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  const handleComment = async () => {
    if (!commentText.trim() || !selectedPost) return;

    setCommenting(true);
    try {
      const user = auth.currentUser;
      if (!user) return;

      const userDoc = await getDoc(doc(db, 'users', user.uid));
      const userData = userDoc.data();

      const postRef = doc(db, 'posts', selectedPost.id);
      await updateDoc(postRef, {
        comments: arrayUnion({
          userId: user.uid,
          userName: userData?.name || 'Traveler',
          text: commentText,
          createdAt: Timestamp.now(),
        }),
      });

      setCommentText('');
      loadPosts();
      
      // Update selected post
      const updatedDoc = await getDoc(postRef);
      setSelectedPost({ id: selectedPost.id, ...updatedDoc.data() } as Post);
    } catch (error) {
      console.error('Error adding comment:', error);
    } finally {
      setCommenting(false);
    }
  };

  const formatTime = (timestamp: any) => {
    if (!timestamp) return 'Just now';
    
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diffInSeconds < 60) return 'Just now';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
    if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`;
    
    return date.toLocaleDateString();
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadPosts();
  };

  if (loading) {
    return (
      <SafeAreaView className="flex-1 bg-gray-50 items-center justify-center">
        <StatusBar barStyle="dark-content" backgroundColor="#f9fafb" />
        <ActivityIndicator size="large" color="#8b5cf6" />
        <Text className="text-gray-600 mt-4">Loading posts...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      {/* Header - Fixed */}
      <View className="bg-white px-5 py-4 shadow-sm">
        <View className="flex-row justify-between items-center">
          <TouchableOpacity onPress={() => navigation.navigate('Home')}>
            <Ionicons name="arrow-back" size={24} color="#000" />
          </TouchableOpacity>
          <View className="flex-1 items-center">
            <Text className="text-lg font-bold text-gray-900">Travel Feed</Text>
            <Text className="text-xs text-gray-500">Share your journey</Text>
          </View>
          <TouchableOpacity 
            onPress={() => setShowCreateModal(true)}
            className="w-10 h-10 bg-purple-500 rounded-full items-center justify-center"
          >
            <Ionicons name="add" size={24} color="#fff" />
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        className="flex-1"
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >

        {/* Posts Feed */}
        <View className="px-5 pt-5 pb-6">
          {posts.length > 0 ? (
            posts.map((post) => {
              const isLiked = post.likes && Array.isArray(post.likes) ? post.likes.includes(auth.currentUser?.uid || '') : false;
              
              return (
                <View key={post.id} className="bg-white rounded-2xl p-4 mb-4 shadow-md">
                  {/* Post Header */}
                  <View className="flex-row items-center mb-3">
                    <LinearGradient
                      colors={['#8b5cf6', '#ec4899']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={{
                        width: 48,
                        height: 48,
                        borderRadius: 24,
                        alignItems: 'center',
                        justifyContent: 'center',
                        marginRight: 12,
                      }}
                    >
                      <Text className="text-white text-lg font-bold">
                        {post.userName ? post.userName.charAt(0).toUpperCase() : 'T'}
                      </Text>
                    </LinearGradient>
                    <View className="flex-1">
                      <Text className="text-base font-bold text-gray-900">{post.userName || 'Traveler'}</Text>
                      {post.userLocation && (
                        <View className="flex-row items-center">
                          <Ionicons name="location" size={12} color="#9ca3af" />
                          <Text className="text-xs text-gray-500 ml-1">{post.userLocation}</Text>
                        </View>
                      )}
                    </View>
                    <Text className="text-xs text-gray-400">{formatTime(post.createdAt)}</Text>
                  </View>

                  {/* Post Content */}
                  <Text className="text-gray-900 text-base mb-3 leading-6">{post.content}</Text>

                  {/* Place Tag */}
                  {post.placeName && (
                    <View className="bg-blue-50 border border-blue-200 rounded-xl p-3 mb-3">
                      <View className="flex-row items-center">
                        <Ionicons name="location" size={16} color="#3b82f6" />
                        <Text className="text-blue-900 font-bold text-sm ml-2">{post.placeName}</Text>
                      </View>
                      {post.placeLocation && (
                        <Text className="text-blue-700 text-xs ml-6">{post.placeLocation}</Text>
                      )}
                    </View>
                  )}

                  {/* Actions */}
                  <View className="flex-row items-center pt-3 border-t border-gray-100">
                    <TouchableOpacity
                      onPress={() => handleLike(post.id)}
                      className="flex-row items-center mr-6"
                    >
                      <Ionicons
                        name={isLiked ? 'heart' : 'heart-outline'}
                        size={24}
                        color={isLiked ? '#ef4444' : '#9ca3af'}
                      />
                      <Text className={`ml-2 font-semibold ${isLiked ? 'text-red-500' : 'text-gray-600'}`}>
                        {post.likes?.length || 0}
                      </Text>
                    </TouchableOpacity>

                    <TouchableOpacity
                      onPress={() => {
                        setSelectedPost(post);
                        setShowCommentsModal(true);
                      }}
                      className="flex-row items-center mr-6"
                    >
                      <Ionicons name="chatbubble-outline" size={22} color="#9ca3af" />
                      <Text className="text-gray-600 ml-2 font-semibold">
                        {post.comments?.length || 0}
                      </Text>
                    </TouchableOpacity>

                    <TouchableOpacity className="flex-row items-center">
                      <Ionicons name="share-outline" size={22} color="#9ca3af" />
                    </TouchableOpacity>
                  </View>
                </View>
              );
            })
          ) : (
            <View className="items-center py-16">
              <LinearGradient
                colors={['#8b5cf6', '#ec4899']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={{
                  width: 96,
                  height: 96,
                  borderRadius: 48,
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: 16,
                }}
              >
                <Ionicons name="images-outline" size={48} color="#fff" />
              </LinearGradient>
              <Text className="text-gray-900 text-xl font-bold mb-2">No Posts Yet</Text>
              <Text className="text-gray-600 text-sm text-center mb-6 px-8">
                Be the first to share your travel experience with the community!
              </Text>
              <TouchableOpacity
                onPress={() => setShowCreateModal(true)}
                className="rounded-xl overflow-hidden"
              >
                <LinearGradient
                  colors={['#8b5cf6', '#ec4899']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{
                    paddingHorizontal: 32,
                    paddingVertical: 14,
                    alignItems: 'center',
                    flexDirection: 'row',
                  }}
                >
                  <Ionicons name="add-circle" size={20} color="#fff" style={{ marginRight: 8 }} />
                  <Text className="text-white font-bold text-base">Create Your First Post</Text>
                </LinearGradient>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </ScrollView>

      {/* Create Post Modal */}
      <Modal
        visible={showCreateModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowCreateModal(false)}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '90%' }}>
            <View className="flex-row items-center justify-between mb-6">
              <Text className="text-xl font-bold text-gray-900">Create Post</Text>
              <TouchableOpacity onPress={() => setShowCreateModal(false)}>
                <Ionicons name="close-circle" size={28} color="#9ca3af" />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-700 mb-2">What's on your mind? *</Text>
                <TextInput
                  value={postContent}
                  onChangeText={setPostContent}
                  placeholder="Share your travel experience..."
                  multiline
                  numberOfLines={6}
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  style={{ textAlignVertical: 'top' }}
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-700 mb-2">Place Name</Text>
                <TextInput
                  value={postPlace}
                  onChangeText={setPostPlace}
                  placeholder="Which place did you visit?"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-6">
                <Text className="text-sm font-semibold text-gray-700 mb-2">Location</Text>
                <TextInput
                  value={postLocation}
                  onChangeText={setPostLocation}
                  placeholder="City, Country"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <TouchableOpacity
                onPress={handleCreatePost}
                disabled={posting}
                className="rounded-xl overflow-hidden"
              >
                <LinearGradient
                  colors={posting ? ['#9ca3af', '#6b7280'] : ['#8b5cf6', '#ec4899']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ paddingVertical: 16, alignItems: 'center' }}
                >
                  {posting ? (
                    <ActivityIndicator color="#fff" />
                  ) : (
                    <Text className="text-white font-bold text-base">Post</Text>
                  )}
                </LinearGradient>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Comments Modal */}
      <Modal
        visible={showCommentsModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowCommentsModal(false)}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '80%' }}>
            <View className="flex-row items-center justify-between mb-4">
              <Text className="text-xl font-bold text-gray-900">
                Comments ({selectedPost?.comments?.length || 0})
              </Text>
              <TouchableOpacity onPress={() => setShowCommentsModal(false)}>
                <Ionicons name="close-circle" size={28} color="#9ca3af" />
              </TouchableOpacity>
            </View>

            <ScrollView className="mb-4" showsVerticalScrollIndicator={false}>
              {selectedPost?.comments && selectedPost.comments.length > 0 ? (
                selectedPost.comments.map((comment, idx) => (
                  <View key={idx} className="mb-3 p-3 bg-gray-50 rounded-xl">
                    <View className="flex-row items-center mb-2">
                      <View className="w-8 h-8 bg-purple-500 rounded-full items-center justify-center mr-2">
                        <Text className="text-white text-xs font-bold">
                          {comment.userName ? comment.userName.charAt(0).toUpperCase() : 'T'}
                        </Text>
                      </View>
                      <Text className="text-sm font-bold text-gray-900">{comment.userName || 'Traveler'}</Text>
                    </View>
                    <Text className="text-sm text-gray-700 ml-10">{comment.text}</Text>
                  </View>
                ))
              ) : (
                <Text className="text-gray-500 text-center py-8">No comments yet</Text>
              )}
            </ScrollView>

            <View className="flex-row items-center pt-4 border-t border-gray-200">
              <TextInput
                value={commentText}
                onChangeText={setCommentText}
                placeholder="Write a comment..."
                className="flex-1 bg-gray-50 rounded-xl px-4 py-3 mr-2"
              />
              <TouchableOpacity
                onPress={handleComment}
                disabled={commenting || !commentText.trim()}
                className={`w-12 h-12 rounded-xl items-center justify-center ${
                  commentText.trim() ? 'bg-purple-500' : 'bg-gray-300'
                }`}
              >
                {commenting ? (
                  <ActivityIndicator color="#fff" size="small" />
                ) : (
                  <Ionicons name="send" size={20} color="#fff" />
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

export default SocialFeed;

