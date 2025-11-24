import React, { useState } from 'react';
import { View, Text, Image, StyleSheet, TouchableOpacity, Linking, Alert, TextInput, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

const { width: screenWidth } = Dimensions.get('window');

interface SocialMediaCardProps {
  username: string;
  imageUrl: string;
  likes: number;
  caption: string;
}

const SocialMediaCard: React.FC<SocialMediaCardProps> = ({ username, imageUrl, likes, caption }) => {
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(likes || 0);
  const [isCommentDropdownVisible, setIsCommentDropdownVisible] = useState(false);
  const [comment, setComment] = useState('');
  const [comments, setComments] = useState<string[]>([]);

  const handleLikePress = () => {
    setIsLiked(!isLiked);
    setLikeCount(prevCount => (isLiked ? prevCount - 1 : prevCount + 1));
  };

  const handlePostComment = () => {
    if (comment.trim()) {
      setComments(prevComments => [...prevComments, comment]);
      setComment(''); // Clear the input field after posting
    }
  };

  const openInstagram = async () => {
    const instagramURL = 'instagram://app';
    const webURL = 'https://www.instagram.com';

    try {
      const supported = await Linking.canOpenURL(instagramURL);
      if (supported) {
        await Linking.openURL(instagramURL);
      } else {
        await Linking.openURL(webURL);
      }
    } catch (error) {
      Alert.alert('Unable to open Instagram');
    }
  };

  return (
    <View style={styles.card}>
      <View style={styles.header}>
        <Image
          source={{ uri: 'https://via.placeholder.com/40' }} // Temporary avatar
          style={styles.avatar}
        />
        <Text style={styles.username}>{username}</Text>
      </View>

      <Image 
        source={{ uri: imageUrl }} 
        style={styles.mainImage}
      />

      <View style={styles.footer}>
        <TouchableOpacity style={styles.likeButton} onPress={handleLikePress}>
          <Ionicons
            name={isLiked ? "heart" : "heart-outline"}
            size={24}
            color={isLiked ? "red" : "black"}
          />
          <Text style={styles.likeCount}>{likeCount}</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.commentButton} onPress={() => setIsCommentDropdownVisible(!isCommentDropdownVisible)}>
          <Ionicons name="chatbubble-outline" size={24} color="black" />
        </TouchableOpacity>

        <TouchableOpacity style={styles.shareButton} onPress={openInstagram}>
          <Ionicons name="paper-plane-outline" size={24} color="black" />
        </TouchableOpacity>
      </View>

      <Text style={styles.caption}>{caption}</Text>
      <TouchableOpacity>
        <Text style={styles.readMore}>Read more</Text>
      </TouchableOpacity>

      {/* Comment Dropdown */}
      {isCommentDropdownVisible && (
        <View style={styles.commentDropdown}>
          <Text style={styles.commentDropdownTitle}>Comments</Text>

          {comments.length > 0 ? (
            comments.map((c, index) => (
              <Text key={index} style={styles.commentText}>• {c}</Text>
            ))
          ) : (
            <Text style={styles.noComments}>No comments yet. Be the first!</Text>
          )}

          <View style={styles.commentInputWrapper}>
            <TextInput
              style={styles.commentInput}
              placeholder="Write a comment..."
              value={comment}
              onChangeText={setComment}
            />
            <TouchableOpacity style={styles.postButton} onPress={handlePostComment}>
              <Text style={styles.postButtonText}>Post</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    borderRadius: 10,
    margin: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    padding: 10,
    width: screenWidth * 0.9,  // 90% of the screen width for responsiveness
    alignSelf: 'center',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 10,
  },
  username: {
    fontWeight: 'bold',
    fontSize: 16,  // Larger for readability
  },
  mainImage: {
    width: '100%',
    height: screenWidth * 0.6,  // Height is 60% of the screen width
    borderRadius: 10,
    marginVertical: 10,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 10,
  },
  likeButton: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  commentButton: {
    alignItems: 'center',
  },
  shareButton: {
    alignItems: 'center',
  },
  likeCount: {
    marginLeft: 5,
  },
  caption: {
    fontSize: 14,
    marginVertical: 10,
  },
  readMore: {
    color: 'gray',
    fontSize: 12,
    marginTop: 5,
  },
  commentDropdown: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
  },
  commentDropdownTitle: {
    fontWeight: 'bold',
    marginBottom: 5,
  },
  commentText: {
    marginBottom: 5,
  },
  noComments: {
    color: '#777',
  },
  commentInputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 10,
  },
  commentInput: {
    flex: 1,
    borderColor: '#ccc',
    borderWidth: 1,
    borderRadius: 5,
    padding: 5,
  },
  postButton: {
    marginLeft: 10,
    backgroundColor: '#0084ff',
    borderRadius: 5,
    paddingVertical: 10,
    paddingHorizontal: 15,
  },
  postButtonText: {
    color: 'white',
    fontWeight: 'bold',
  },
});

export default SocialMediaCard;
  