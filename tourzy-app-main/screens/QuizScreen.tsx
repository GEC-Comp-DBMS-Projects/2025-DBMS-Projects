import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, TouchableOpacity, Image, ScrollView, ImageBackground } from 'react-native';
import { styled } from 'nativewind';
import quizData1 from '../JSON-files/quiz.json';
import { SafeAreaView } from 'react-native-safe-area-context';
import { updateUser } from '../utils/updateUser';
import { fetchDoc } from '../utils/getUser';
import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';
import { useFocusEffect } from '@react-navigation/native';

const quizData = quizData1.states_and_union_territories;

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledTouchableOpacity = styled(TouchableOpacity);
const StyledImage = styled(Image);
const StyledScrollView = styled(ScrollView);

interface QuizQuestion {
    question: string;
    options: string[];
    answer: string;
}



const QuizScreen: React.FC = ({navigation}:any) => {
    const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
    const [selectedOption, setSelectedOption] = useState<string | null>(null);
    const [isAnswered, setIsAnswered] = useState(false);
    const [score, setScore] = useState(0);
    const [over, setOver] = useState(false);
    const [showSubmit, setShowSubmit] = useState(false);
    const [points, setPoints] = useState(0);
    const [initializing, setInitializing] = useState(true);
    const [noInternet, setnointernet] = useState(false);
 
    
  
 

    const [currentState, setCurrentState] = useState(quizData[0]);
    const currentQuestion = currentState.quiz[currentQuestionIndex];

    useEffect(() => {
        const determineState = async () => {
            try {
                const state = await AsyncStorage.getItem('state');
                if (state != null) {
                 
                    const userState = state;
                    const stateIndex = quizData.findIndex(state => state.state === userState);
                    console.log("State Index: ", stateIndex);
                    if (stateIndex !== -1) {
                        setCurrentState(quizData[stateIndex]);
                    }
                }
            } catch (e) {
                console.log('Error determining state:', e);
            }
        };

        determineState();
    }, []);

    

    const fetchOnline = async()=>{
        try {
    
    
          const user:any = await fetchDoc();
          console.log("User: ", user);
          if(user){
              setInitializing(false);
              
          }
          if(user?.quiz?.answered){
              console.log("User has answered the quiz");
              setScore(user.quiz?.score);
              setPoints(user?.points);
              setOver(true);
              setInitializing(false);
          }
         
          
          console.log('My User:', user);
        } catch (error) {
         
          console.log('Error fetching user:', error);
        }
      }
      
      const fetchOffline = async() => {
    
        try {
          const jsonValue:any = await AsyncStorage.getItem('user');
       
            console.log("User: ", JSON.parse(jsonValue));
            if(jsonValue != null){
                setInitializing(false);
            }
            if(JSON.parse(jsonValue)?.quiz?.answered){
                console.log("User has answered the quiz");
                setScore(JSON.parse(jsonValue).quiz.score);
                setPoints(JSON.parse(jsonValue)?.points);
                setOver(true);
                setInitializing(false);
            }
          
        } catch (e) {
          console.log('Error fetching user:', e);
        }
    
      }
    
      const fetch = async () => {
    
        NetInfo.fetch().then(state => {
          if (!state.isConnected) {
            console.log("No internet connection");
            fetchOffline()
            setnointernet(true);
          } else {
            console.log("Internet connection available");
            
            fetchOnline()
           
          }
        });
       
       
    
      };

      const updateAsync = async(points:any, score:any)=>{
        console.log("Updating async...")
        try {
            const jsonValue = await AsyncStorage.getItem('user');
            let data = jsonValue != null ? JSON.parse(jsonValue) : {};
            
            // Update a specific field, for example, 'name'
            data.points = data.points+ points;
            data.quiz.score = data.quiz.score + score;
            data.quiz.answered = true;
            
        
            // Save the updated data

            await AsyncStorage.setItem('user', JSON.stringify(data));
            console.log()
          } catch (error) {
            console.error('Error updating field:', error);
          }

      }

      
    
    
      useEffect(() => {
        console.log("Navigation UseEffect");
        fetch();
    
       
    
      }, [navigation]);

      console.log("No Internet: ",noInternet)
    useFocusEffect(
    useCallback(() => {
      // Code to run when the screen is focused (e.g., page is loaded by back button)
      console.log('Screen is focused');
      fetch();

      return () => {
        // Optional: cleanup when the screen is unfocused
        console.log('Screen is unfocused');
      };
    }, [])
  );

    console.log(over)
    useEffect(() => {
        fetch()
    }, []);

    
  
const handleOptionSelect = (option: string) => {
    if (isAnswered) return;
    setSelectedOption(option);
    setIsAnswered(true);
    if (option === currentQuestion.answer) {
        console.log("score: ", score);
        const newScore = score + 1;
        setScore(newScore);
        
        const newPoints = newScore === 5 ? 250 : (newScore === 1 || newScore === 2) ? newScore * 50 : points;
        setPoints(newPoints);
    } else if (score === 0) {
        setPoints(0);
    }
};

const handleSubmit = async () => {
    if (currentQuestionIndex === currentState.quiz.length - 1) {
        setOver(true);
    }

    await updateAsync(points, score);  // Always update async storage first
    if (!noInternet) {
        await updateUser(points, score);  // Update Firestore if online
    }
};



    const handleNextQuestion = () => {
        if (currentQuestionIndex < currentState.quiz.length - 1) {
            console.log("currentQuestionIndex: ", currentQuestionIndex);
            setCurrentQuestionIndex(currentQuestionIndex + 1);
            setSelectedOption(null);
            setIsAnswered(false);
            if (currentQuestionIndex === currentState.quiz.length - 2) {
                setShowSubmit(true);
            }
        }
    };

    const getOptionColor = (option: string) => {
        if (!isAnswered) return 'bg-gray-200';
        if (option === currentQuestion.answer) return 'bg-green-500';
        if (option === selectedOption) return 'bg-red-500';
        return 'bg-gray-200';
    };

    if (initializing) {
        return (
          <View style = {{flex:1, justifyContent: 'center', alignItems:'center'}}>
            <Image
                source={require('../assets/splash.png')}
                style={{ width:340, height:340, opacity: 1 }}
            />
          </View>
        ) // or a loading component
      }


    if (over) {
        return (
            <StyledView className="flex-1 justify-center items-center bg-gray-100">
                <StyledText className="text-2xl font-bold mb-4">Quiz Completed!</StyledText>
                <StyledText className="text-xl">
                    Your score: {score} out of {currentState.quiz.length}
                </StyledText>
                <StyledText className="text-xl">
                    Points: {points}
                </StyledText>

                <StyledTouchableOpacity
                    className="bg-blue-500 p-3 rounded-lg mt-4"
                    onPress={() => navigation.navigate('Home')}
                >
                    <StyledText className="text-center text-white">
                        Go back
                    </StyledText>
                </StyledTouchableOpacity>
            </StyledView>
        );
    }

    return (
        <SafeAreaView className="flex-1 w-full h-screen">
            <ImageBackground
                source={require('../assets/mountainBack.jpg')}
                style={{ flex: 1 }}
            >
                <StyledView className="justify-start mt-28 flex-1 p-4">
                    <StyledView className="bg-black/50 rounded-lg p-4 mb-4">
                        <StyledText className="text-white text-lg font-bold mb-2">
                            Discover {currentState.state}
                        </StyledText>
                        <StyledView
                            className="bg-green-500 h-2 rounded-full"
                            style={{ width: `${((currentQuestionIndex + 1) / currentState.quiz.length) * 100}%` }}
                        />
                        <StyledText className="text-white text-right mt-1">
                            {currentQuestionIndex + 1}/{currentState.quiz.length}
                        </StyledText>
                    </StyledView>

                    <StyledView className="bg-white rounded-lg p-4 mb-4">
                        <StyledText className="text-black text-lg font-semibold mb-4">
                            {currentQuestion.question}
                        </StyledText>
                        {currentQuestion.options.map((option, index) => (
                            <StyledTouchableOpacity
                                key={index}
                                className={`p-3 rounded-lg mb-2 ${getOptionColor(option)}`}
                                onPress={() => handleOptionSelect(option)}
                            >
                                <StyledText className="text-center text-black">
                                    {option}
                                </StyledText>
                            </StyledTouchableOpacity>
                        ))}
                    </StyledView>

                    {isAnswered && (showSubmit ? (
                        <StyledTouchableOpacity
                            className="bg-blue-500 p-3 rounded-lg"
                            onPress={handleSubmit}
                        >
                            <StyledText className="text-center text-white">
                                Submit
                            </StyledText>
                        </StyledTouchableOpacity>
                    ) : (
                        <StyledTouchableOpacity
                            className="bg-blue-500 p-3 rounded-lg"
                            onPress={handleNextQuestion}
                        >
                            <StyledText className="text-center text-white">
                                Next Question
                            </StyledText>
                        </StyledTouchableOpacity>
                    ))}

                    <StyledTouchableOpacity className="bg-gray-300 p-3 rounded-lg mt-2">
                        <StyledText className="text-center text-gray-600">
                            Report Question
                        </StyledText>
                    </StyledTouchableOpacity>
                </StyledView>
            </ImageBackground>
        </SafeAreaView>
    );
};

export default QuizScreen;
