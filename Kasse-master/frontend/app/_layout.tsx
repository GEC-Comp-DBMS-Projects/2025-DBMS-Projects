import { Stack } from 'expo-router';
import { StripeProvider } from '@stripe/stripe-react-native';

export default function StackLayout() {
  return (
    <StripeProvider
      publishableKey="pk_test_51SKFSGPAZH6ezna7ZXnBFUxtsMz7ycftUqT4aiUbNdZJmcl631Qbya3fORPILmYkougxfPlI5hC1G59RPRbBuUmK00GK0y47D7"
      urlScheme="kasse"
    >
      <Stack screenOptions={{headerShown:false}}/>
    </StripeProvider>
  );
}
