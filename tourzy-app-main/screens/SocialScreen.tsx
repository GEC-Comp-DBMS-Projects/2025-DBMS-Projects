import { View, Text, StyleSheet, TextInput, ScrollView, TouchableOpacity } from 'react-native';
import React, { useState } from 'react';
import { SafeAreaView } from 'react-native-safe-area-context';
import Navbar from '../components/Navbar';
import Card from '../components/Card';
import { useFocusEffect } from '@react-navigation/native';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase';

const SocialScreen = ({navigation}:any) => {

  const [posts, setPosts] = useState<any>([])
  const [initialPosts, setInitialPosts] = useState<any>([])
  useFocusEffect(
    React.useCallback(() => {
      // Reset the comment dropdown whenever the screen is focused
     
    const fetchPosts = async () => {
      try {
        
     
      const postsCollection = collection(db, 'post');
      const postsSnapshot = await getDocs(postsCollection);
      const postsList = postsSnapshot.docs.map(doc => doc.data());
      setPosts(postsList)
      setInitialPosts(postsList)
      console.log("Post: ",postsList); // You can set this to state or use it as needed
    } catch (error) {
      console.log('Error fetching data:', error);
      
    }
    };

        fetchPosts();
    }, [])
  )

  return (
    <SafeAreaView className=' px-2'>
      {/* Search Input */}
      <View className='flex-row items-center justify-center'>
        <TextInput 
          style={styles.searchInput} 
          placeholder="Search" 
          placeholderTextColor="black"
          className='w-3/4' 
          onChangeText={(text) => {
        console.log(text)
        if(text === '') {
          return setPosts(initialPosts)
        }
        const filteredPosts = initialPosts.filter((post: any) => 
          post.caption?.toLowerCase().includes(text.toLowerCase()) || 
          post.username?.toLowerCase().includes(text.toLowerCase())
        );
        console.log(filteredPosts)
        setPosts(filteredPosts);
          }}
        />
        <TouchableOpacity className='bg-blue-500 w-1/4 items-center justify-center h-10 rounded mt-5 ml-1'
          onPress={()=>{navigation.navigate("addpost")}}>
          <Text>Add Post</Text>
        </TouchableOpacity>
      </View>

    
          <View className='pb-32'>
      {/* Scrollable Card List */}
      <ScrollView className=''>
        {/* You can add multiple cards here */}
        {
          posts.map((post: any, index: number) => (
        <Card key={index} username={post.username} imageUrl={post.imgurl} likes={post.likes} caption={post.caption} />
          ))
        }
      </ScrollView>
      </View>

      
    

   
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  searchInput: {
    height: 50,
    
    backgroundColor: 'rgba(128,128,128,0.15)',
    borderRadius: 10,
    marginTop: 20,
  
   
    padding: 10,
  },
 
  navbarContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  },
});

export default SocialScreen;
