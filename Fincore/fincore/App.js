import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from "expo-status-bar";

import LoginPage from './screens/login';
import SignupScreen from './screens/signup';
import OTPVerificationScreen from './screens/OTPVerificationScreen';
import ExplorePage from './screens/explorepage';
import ConsentScreen from './screens/consentscreen';
import FinancialDashboard from './screens/financialdashboard';
import TransactionsScreen from './screens/transactions';
import AccountsScreen from './screens/accountsscreen';
import WelcomeScreen from './screens/WelcomeScreen';
import { StocksScreen, AdvisorConnectScreen, TaxCenterScreen } from './screens/placeholderscreens';
import AppOpen from "./screens/appopen";
import CandleCloseChart from "./screens/Stocks/CandleCloseChart";
import DashboardScreen from "./screens/dashboard/DashboardScreen";
import FinancialAdvisorScreen from "./screens/dashboard/FinancialAdvisorScreen";
import StocksScreenDashboard from "./screens/dashboard/StocksScreen";
import TaxFilingScreen from "./screens/dashboard/TaxFilingScreen";
import MainTabNavigator from "./screens/MainTabNavigator";
import StockHome from "./screens/Stocks/stockhome";
import RegistrationScreen from "./screens/Stocks/registrationscreen";
import LoginScreen from "./screens/Stocks/loginscreen";
import InsightsScreen from './screens/insightsscreen';
import AdvisorScreen from './screens/advisor';
import AdvisorChatScreen from './screens/advisorchat';
import DocumentsUploadScreen from './screens/DocumentsUploadScreen';
import TaxCalculationScreen from './screens/TaxCalculationScreen';
import ITRGenerationScreen from './screens/ITRGenerationScreen';
import FilingAssistantScreen from './screens/FilingAssistantScreen';
import AcknowledgmentScreen from './screens/AcknowledgmentScreen';
import TaxDashboard from './screens/TaxDashboard';

import DataReviewScreen from './screens/DataReviewScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Login"
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
      >
        {}
        <Stack.Screen name="LoginScreen" component={LoginScreen} />
        <Stack.Screen name="RegistrationScreen" component={RegistrationScreen} />
        <Stack.Screen name="Login" component={LoginPage} />
        <Stack.Screen name="Signup" component={SignupScreen} />
        <Stack.Screen 
          name="OTPVerification" 
          component={OTPVerificationScreen}
          options={{
            headerShown: true,
            title: 'Verify OTP',
          }}
        />

        {}
        <Stack.Screen name="AppOpen" component={AppOpen} />
        <Stack.Screen name="CandleCloseChart" component={CandleCloseChart} />

        {}
        <Stack.Screen name="MainApp" component={MainTabNavigator} />

        {}
        <Stack.Screen name="StockHome" component={StockHome} />
        <Stack.Screen name="Explore" component={ExplorePage} />
        
        {}
        <Stack.Screen 
          name="Consent" 
          component={ConsentScreen}
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />

        {}
        <Stack.Screen name="Dashboard" component={FinancialDashboard} />
        <Stack.Screen name="Transactions" component={TransactionsScreen} />
        <Stack.Screen name="Accounts" component={AccountsScreen} />
        <Stack.Screen 
          name="Stocks" 
          component={StocksScreen} 
          options={{ headerShown: true, title: 'Stocks' }} 
        />
        <Stack.Screen 
          name="AdvisorConnect" 
          component={AdvisorConnectScreen} 
          options={{ headerShown: true, title: 'Advisor Connect' }} 
        />
        <Stack.Screen 
          name="TaxCenter" 
          component={TaxCenterScreen} 
          options={{ headerShown: true, title: 'Tax Center' }} 
        />
        
        {}
        <Stack.Screen name="Insights" component={InsightsScreen} />
        <Stack.Screen name="Advisor" component={AdvisorScreen} />
        <Stack.Screen name="AdvisorChat" component={AdvisorChatScreen} />
        
        {}
        <Stack.Screen 
          name="Welcome" 
          component={WelcomeScreen}
          options={{
            headerShown: false
          }}
        />
        
        {}
        <Stack.Screen 
          name="DocumentsUploadScreen" 
          component={DocumentsUploadScreen}
          options={{
            headerShown: false
          }}
        />

        {}
        <Stack.Screen 
          name="DataReviewScreen" 
          component={DataReviewScreen}
          options={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        />
        {}
        <Stack.Screen 
          name="TaxCalculation" 
          component={TaxCalculationScreen}
          options={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        />
        <Stack.Screen 
          name="ITRGeneration" 
          component={ITRGenerationScreen}
          options={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        />
        <Stack.Screen 
          name="FilingAssistant" 
          component={FilingAssistantScreen}
          options={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        />
        <Stack.Screen 
          name="Acknowledgment" 
          component={AcknowledgmentScreen}
          options={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        />
        <Stack.Screen name="TaxDashboard" component={TaxDashboard} options={{ headerShown: false, animation: 'slide_from_right' }} />
      </Stack.Navigator>

      <StatusBar style="auto" />
    </NavigationContainer>
  );
}