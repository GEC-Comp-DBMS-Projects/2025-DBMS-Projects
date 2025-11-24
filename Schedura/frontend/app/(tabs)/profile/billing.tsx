import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StatusBar, Alert, TextInput } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
import { updateUserUpiId, getUserUpiId } from '@/supabase/controllers/user.controller';
import { useUser } from '@clerk/clerk-expo';
import { useToast } from '@/components/Toast';

const BillingPaymentsScreen = () => {
  const { colors, isDark } = useTheme();
  const router = useRouter();
  const { user } = useUser();
  const [currentPlan] = useState('Free');
  const [billingCycle] = useState('Monthly');
  const [upiId, setUpiId] = useState('');
  const [savingUpi, setSavingUpi] = useState(false);
  const [loadingUpi, setLoadingUpi] = useState(true);
  const { showToast } = useToast();

  // Fetch existing UPI ID on mount
  useEffect(() => {
    const fetchUpiId = async () => {
      if (!user?.id) return;
      try {
        setLoadingUpi(true);
        const existingUpiId = await getUserUpiId(user.id);
        if (existingUpiId) {
          setUpiId(existingUpiId);
        }
      } catch (err) {
        console.error('Error fetching UPI ID:', err);
      } finally {
        setLoadingUpi(false);
      }
    };
    fetchUpiId();
  }, [user?.id]);

  const handleSaveUpi = async () => {
    if (!upiId.trim()) {
      showToast({
        type: 'error',
        title: 'Validation',
        description: 'Please enter a valid UPI ID',
      });
      return;
    }
    setSavingUpi(true);
    try {
      await updateUserUpiId({ upiId: upiId.trim(), id: user?.id! });
      showToast({
        type: 'success',
        title: 'Success',
        description: 'UPI ID updated successfully',
      });
    } catch (err) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Failed to update UPI ID',
      });
    } finally {
      setSavingUpi(false);
    }
  };
  const plans = [
    {
      id: 'free',
      name: 'Free',
      price: '$0',
      period: 'forever',
      features: [
        'Free space listings',
        'Basic booking management',
        'Email support',
        'Standard analytics'
      ],
      current: true
    },
  ];

  const paymentMethods = [
    {
      id: '1',
      type: 'card',
      brand: 'Visa',
      last4: '4242',
      expiry: '12/25',
      isDefault: true
    },
    {
      id: '2',
      type: 'card',
      brand: 'Mastercard',
      last4: '8888',
      expiry: '08/26',
      isDefault: false
    }
  ];

  const transactions = [
    { id: '1', date: '2025-10-01', amount: '$29.00', description: 'Pro Plan - Monthly', status: 'Paid' },
    { id: '2', date: '2025-09-01', amount: '$29.00', description: 'Pro Plan - Monthly', status: 'Paid' },
    { id: '3', date: '2025-08-01', amount: '$29.00', description: 'Pro Plan - Monthly', status: 'Paid' },
  ];

  const handleUpgrade = (planId: string) => {
    Alert.alert(
      'Upgrade Plan',
      `Upgrade to ${plans.find(p => p.id === planId)?.name} plan?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Upgrade',
          onPress: () => Alert.alert('Success', 'Plan upgraded successfully!')
        }
      ]
    );
  };

  const handleAddPaymentMethod = () => {
    Alert.alert(
      'Add Payment Method',
      'This would open a payment form to add a new card or payment method',
      [{ text: 'OK' }]
    );
  };

  const handleManagePaymentMethod = (methodId: string) => {
    Alert.alert(
      'Manage Payment Method',
      'What would you like to do?',
      [
        { text: 'Set as Default', onPress: () => Alert.alert('Success', 'Default payment method updated') },
        { text: 'Remove', style: 'destructive', onPress: () => Alert.alert('Success', 'Payment method removed') },
        { text: 'Cancel', style: 'cancel' }
      ]
    );
  };

  const handleDownloadInvoice = (transactionId: string) => {
    Alert.alert('Success', 'Invoice downloaded to your device');
  };

  const PlanCard = ({ plan }: any) => (
    <View
      className={`rounded-xl p-6 mb-4 ${plan.popular ? 'border-2' : 'border-0'} shadow-lg`}
      style={{
        backgroundColor: colors.card,
        borderColor: plan.popular ? colors.link : 'transparent',
        shadowColor: colors.shadow,
        elevation: 3,
      }}
    >
      {plan.popular && (
        <View className="px-3 py-1 rounded-full self-start mb-3" style={{ backgroundColor: colors.link }}>
          <Text className="text-xs font-bold" style={{ color: 'white' }}>MOST POPULAR</Text>
        </View>
      )}

      <Text className="text-2xl font-bold" style={{ color: colors.text }}>{plan.name}</Text>
      <View className="flex-row items-baseline mt-2">
        <Text className="text-4xl font-bold" style={{ color: colors.text }}>{plan.price}</Text>
        <Text className="ml-2" style={{ color: colors.textSecondary }}>/ {plan.period}</Text>
      </View>

      <View className="mt-6 mb-6">
        {plan.features.map((feature: string, index: number) => (
          <View key={index} className="flex-row items-center mb-3">
            <Ionicons name="checkmark-circle" size={20} color={colors.success} />
            <Text className="ml-3" style={{ color: colors.textSecondary }}>{feature}</Text>
          </View>
        ))}
      </View>

      {plan.current ? (
        <View className="py-3 rounded-xl items-center" style={{ backgroundColor: colors.backgroundSecondary }}>
          <Text className="font-semibold" style={{ color: colors.textSecondary }}>Current Plan</Text>
        </View>
      ) : (
        <TouchableOpacity
          onPress={() => handleUpgrade(plan.id)}
          className="py-3 rounded-xl items-center"
          style={{ backgroundColor: plan.popular ? colors.link : colors.accent }}
        >
          <Text className="font-semibold" style={{ color: plan.popular ? 'white' : (isDark ? '#000' : 'white') }}>
            Upgrade to {plan.name}
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />

      {/* Header */}
      <View
        className="px-6 py-4 flex-row items-center border-b"
        style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}
      >
        <TouchableOpacity onPress={() => router.back()} className="p-2 mr-3">
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text className="text-xl font-bold" style={{ color: colors.text }}>Billing & Payments</Text>
      </View>

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Current Plan Overview */}
        <View className="px-6 py-4 ">
          <Text className="text-sm text-gray-700 mb-2">UPI ID</Text>
          {loadingUpi ? (
            <View className="bg-gray-50 rounded-xl px-4 py-3 mb-3 border border-gray-200 items-center justify-center" style={{ height: 48 }}>
              <Text style={{ color: colors.textSecondary }}>Loading...</Text>
            </View>
          ) : (
            <TextInput
              value={upiId}
              onChangeText={setUpiId}
              placeholder="example@upi"
              autoCapitalize="none"
              keyboardType="default"
              className="bg-gray-50 rounded-xl px-4 py-3 mb-3 border border-gray-200"
              editable={!savingUpi}
              style={{ color: colors.text }}
              placeholderTextColor={colors.textSecondary}
            />
          )}
          <TouchableOpacity
            onPress={handleSaveUpi}
            disabled={savingUpi || loadingUpi}
            className={`py-3 rounded-xl items-center ${savingUpi || loadingUpi ? 'bg-gray-300' : 'bg-primary'}`}
          >
            <Text className="text-black font-semibold">{savingUpi ? 'Saving...' : 'Save UPI'}</Text>
          </TouchableOpacity>
        </View>

        <View className="p-6 mx-6 mt-6 rounded-xl" style={{ backgroundColor: colors.link }}>
          <Text className="font-semibold text-lg" style={{ color: 'white' }}>Current Plan</Text>
          <Text className="text-3xl font-bold mt-2" style={{ color: 'white' }}>{currentPlan}</Text>
          <Text className="mt-1" style={{ color: 'rgba(255,255,255,0.8)' }}>{billingCycle} billing</Text>
        </View>

        
        <View className="px-6 py-6">
          <Text className="text-xl font-bold mb-4" style={{ color: colors.text }}>Available Plans</Text>
          {plans.map(plan => (
            <PlanCard key={plan.id} plan={plan} />
          ))}
        </View>
      {/*
        <View
          className="px-6 py-6 border-t"
          style={{ backgroundColor: colors.card, borderTopColor: colors.border }}
        >
          <View className="flex-row justify-between items-center mb-4">
            <Text className="text-xl font-bold" style={{ color: colors.text }}>Payment Methods</Text>
            <TouchableOpacity onPress={handleAddPaymentMethod}>
              <Ionicons name="add-circle" size={28} color={colors.link} />
            </TouchableOpacity>
          </View>

          {paymentMethods.map(method => (
            <TouchableOpacity
              key={method.id}
              onPress={() => handleManagePaymentMethod(method.id)}
              className="rounded-xl p-4 mb-3 flex-row items-center"
              style={{ backgroundColor: colors.backgroundSecondary }}
            >
              <View className="p-3 rounded-xl" style={{ backgroundColor: colors.card }}>
                <Ionicons name="card-outline" size={24} color={colors.textSecondary} />
              </View>
              <View className="flex-1 ml-4">
                <Text className="font-semibold" style={{ color: colors.text }}>
                  {method.brand} •••• {method.last4}
                </Text>
                <Text className="text-sm mt-1" style={{ color: colors.textSecondary }}>Expires {method.expiry}</Text>
              </View>
              {method.isDefault && (
                <View className="px-3 py-1 rounded-full" style={{ backgroundColor: isDark ? '#14532d' : '#d1fae5' }}>
                  <Text className="text-xs font-semibold" style={{ color: isDark ? '#86efac' : '#065f46' }}>Default</Text>
                </View>
              )}
            </TouchableOpacity>
          ))}
        </View>

        <View className="px-6 py-6">
          <Text className="text-xl font-bold mb-4" style={{ color: colors.text }}>Transaction History</Text>

          {transactions.map(transaction => (
            <View
              key={transaction.id}
              className="rounded-xl p-4 mb-3 flex-row items-center"
              style={{
                backgroundColor: colors.card,
                shadowColor: colors.shadow,
                elevation: 2,
              }}
            >
              <View className="p-3 rounded-xl" style={{ backgroundColor: isDark ? '#14532d' : '#d1fae5' }}>
                <Ionicons name="checkmark-circle" size={24} color={colors.success} />
              </View>
              <View className="flex-1 ml-4">
                <Text className="font-semibold" style={{ color: colors.text }}>{transaction.description}</Text>
                <Text className="text-sm mt-1" style={{ color: colors.textSecondary }}>{transaction.date}</Text>
              </View>
              <View className="items-end">
                <Text className="font-bold" style={{ color: colors.text }}>{transaction.amount}</Text>
                <TouchableOpacity
                  onPress={() => handleDownloadInvoice(transaction.id)}
                  className="mt-1"
                >
                  <Text className="text-sm" style={{ color: colors.link }}>Invoice</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))}
        </View>
        */}
        <View className="h-8" />
      </ScrollView>
    </SafeBoundingView>
  );
};

export default BillingPaymentsScreen;
