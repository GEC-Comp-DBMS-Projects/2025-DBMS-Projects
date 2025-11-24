import React, { useState, useEffect } from "react";
import { View, Text, ScrollView, TouchableOpacity, StatusBar, ActivityIndicator, Image, SafeAreaView } from "react-native";
import { Ionicons } from "@expo/vector-icons";
//@ts-ignore
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useUser } from "@clerk/clerk-expo";
import SafeBoundingView from "@/components/SafeBoundingView";
import { useTheme } from "@/contexts/ThemeContext";
import dayjs from "dayjs";
import { supabase } from "@/supabase/supabase";
import RazorpayCheckout from 'react-native-razorpay';
import { useToast } from '@/components/Toast';
import { acceptBooking } from "@/supabase/controllers/booking.controller";

interface Booking {
  id: string;
  space_id: string;
  user_id: string;
  start: string;
  end: string;
  payment_status: string;
  total_amount: number;
  reason?: string;
  created_at: string;
  spaces?: {
    name: string;
    location: string;
    pph: number;
    capacity: number;
    ownerid: string;
    'spaces-images'?: Array<{ link: string }>;
  };
  users?: {
    name: string;
    email: string;
  };
  ownerInfo?: {
    name: string;
    email: string;
    upiId: string;
  };
}

export default function BookingDetailsScreen() {
  const { showToast } = useToast();
  const { id } = useLocalSearchParams();
  const { back, navigate } = useRouter();
  const { user } = useUser();
  const { colors, isDark } = useTheme();
  
  const [booking, setBooking] = useState<Booking | null>(null);
  const [loading, setLoading] = useState(true);
  const [payLoading, setPayLoading] = useState(false);

  useEffect(() => {
    fetchBookingDetails();
  }, [id]);

  const fetchBookingDetails = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('bookings')
        .select(`
          *,
          spaces (
            name,
            ownerid,
            location,
            pph,
            capacity,
            spaces-images (link)
          ),
          users (
            name,
            email
          )
        `)
        .eq('id', id)
        .single();
    
      if (error) {
        console.error("Error fetching booking:", error);
      } else {
        const ownerInfo = await supabase
          .from('users')
          .select('name, email, upiId')
          .eq('id', data.spaces.ownerid)
          .single();
        
        if (ownerInfo) {
          setBooking({...data, ownerInfo: ownerInfo.data});
        }
      }
    } catch (error) {
      console.error("Error in fetchBookingDetails:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleProceedToPayment = async () => {
    if (!booking || !booking.spaces?.ownerid) {
      showToast({ type: 'error', title: 'Payment', description: 'Booking or owner missing.' });
      return;
    }

    try {
      setPayLoading(true);
      const totalAmount = booking.total_amount || ((booking.spaces?.pph || 0) * days);
      // Ask backend to create an order tied to the owner so backend can route funds/transfer
      const createRes = await fetch('https://schedura.onrender.com/payments/create-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          bookingId: booking.id,
          ownerId: booking.spaces.ownerid,
          amount: Number(totalAmount),
        }),
      });
      const orderData = await createRes.json();
      if (!createRes.ok || !orderData?.order_id || !orderData?.key_id) {
        throw new Error(orderData?.error || 'Failed to create order');
      }

      const options: any = {
        key: orderData.key_id,
        amount: Math.round(Number(orderData.amount) * 100), // paise
        currency: 'INR',
        name: booking.spaces?.name || 'Schedura',
        description: `Booking ${booking.id}`,
        order_id: orderData.order_id,
        prefill: {
          name: booking.users?.name || '',
          email: booking.users?.email || '',
        },
        theme: { color: colors.accent || '#3399cc' },
      };

      RazorpayCheckout.open(options)
        .then(async (paymentResult: any) => {
          // Send paymentResult to backend for verification & transfer
          try {
            const verifyRes = await fetch('https://schedura.onrender.com/payments/verify', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                bookingId: booking.id,
                order_id: paymentResult.razorpay_order_id,
                payment_id: paymentResult.razorpay_payment_id,
                signature: paymentResult.razorpay_signature,
              }),
            });
            const verifyJson = await verifyRes.json();
            if (!verifyRes.ok || !verifyJson.success) {
              showToast({ type: 'error', title: 'Payment', description: 'Verification failed.' });
              onFailure(verifyJson);
              return;
            }
            onSuccess(paymentResult);
          } catch (err) {
            console.error('Verification error', err);
            showToast({ type: 'error', title: 'Payment', description: 'Verification failed.' });
            onFailure(err);
          }
        })
        .catch((error: any) => {
          showToast({ type: 'error', title: 'Payment', description: error?.message || 'Payment failed' });
          onFailure(error);
        });
    } catch (err: any) {
      console.error('Order creation error', err);
      showToast({ type: 'error', title: 'Payment', description: err?.message || 'Failed to start payment' });
    } finally {
      setPayLoading(false);
    }
  };

    const onSuccess = async (success:any) => {
      if(!booking) return;
      await acceptBooking(booking.id, );
      // check if connected to google calendar and add event
      const res = await fetch(`https://schedura.onrender.com/integrations/status?userid=${booking.spaces?.ownerid}`);
      const connected = await res.json();
      if(connected){
        try {
          await fetch("https://schedura.onrender.com/calendar/add", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              title: "Hall Booking: " + booking.spaces?.name,
              description: "Customer: " + booking.users?.name + ", Email: " + booking.users?.email,
              startTime: booking.start,
              endTime: booking.end,
              userid: booking.spaces?.ownerid,
            }),
          });
        } catch (error) {
          console.error("Error adding event to Google Calendar:", error);
        }
      }
      navigate('/(info)/payment/successful');
    }
    const onFailure = (error:any) => {
      navigate('/(info)/payment/unsuccessful');
    }

  const calculateDays = () => {
    if (!booking) return 0;
    const start = dayjs(booking.start);
    const end = dayjs(booking.end);
    return end.diff(start, 'day') + 1;
  };

  const getStatusColor = (status: string) => {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return 'bg-green-500';
      case 'pending':
        return 'bg-yellow-500';
      case 'cancelled':
        return 'bg-red-500';
      case 'completed':
        return 'bg-blue-500';
      default:
        return 'bg-gray-500';
    }
  };

  if (loading) {
    return (
      <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} />
        <View className="flex-1 justify-center items-center">
          <ActivityIndicator size="large" color={colors.accent} />
          <Text className="text-lg mt-4" style={{ color: colors.text }}>Loading booking details...</Text>
        </View>
      </SafeBoundingView>
    );
  }

  if (!booking) {
    return (
      <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} />
        <View className="flex-1 justify-center items-center px-6">
          <Ionicons name="alert-circle-outline" size={64} color={colors.textSecondary} />
          <Text className="text-xl font-semibold mt-4 text-center" style={{ color: colors.text }}>
            Booking Not Found
          </Text>
          <Text className="text-base mt-2 text-center" style={{ color: colors.textSecondary }}>
            The booking you're looking for doesn't exist or has been removed.
          </Text>
          <TouchableOpacity onPress={back} className="mt-6 px-6 py-3 rounded-xl" style={{ backgroundColor: colors.accent }}>
            <Text className="font-semibold" style={{ color: isDark ? '#000' : '#fff' }}>Go Back</Text>
          </TouchableOpacity>
        </View>
      </SafeBoundingView>
    );
  }

  const days = calculateDays();

  return (
    <SafeAreaView className="flex-1 h-full" style={{ backgroundColor: colors.tertiary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} />
     

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
      

        <View className="px-6 py-6">
          {/* Space Name & Status */}
          <View className="flex-row justify-between items-start mb-4">
            <View className="flex-1">
              <Text className="text-2xl font-bold mb-2" style={{ color: colors.text }}>
                {booking.spaces?.name || 'Unknown Space'}
              </Text>
              <View className="flex-row items-center">
                <Ionicons name="location" size={16} color={colors.textSecondary} />
                <Text className="ml-1" style={{ color: colors.textSecondary }}>
                  {booking.spaces?.location || 'Location not available'}
                </Text>
              </View>
            </View>
            
          </View>

          {/* Booking Info Card */}
          <View className="rounded-xl p-5 mb-4 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <Text className="text-lg font-semibold mb-4" style={{ color: colors.text }}>Booking Information</Text>
            
            <View className="gap-3">
              <View className="flex-row justify-between items-center py-2">
                <View className="flex-row items-center">
                  <Ionicons name="calendar-outline" size={20} color={colors.textSecondary} />
                  <Text className="ml-2" style={{ color: colors.textSecondary }}>Check-in</Text>
                </View>
                <Text className="font-semibold" style={{ color: colors.text }}>
                  {dayjs(booking.start).format('MMM DD, YYYY')}
                </Text>
              </View>

              <View className="flex-row justify-between items-center py-2">
                <View className="flex-row items-center">
                  <Ionicons name="calendar-outline" size={20} color={colors.textSecondary} />
                  <Text className="ml-2" style={{ color: colors.textSecondary }}>Check-out</Text>
                </View>
                <Text className="font-semibold" style={{ color: colors.text }}>
                  {dayjs(booking.end).format('MMM DD, YYYY')}
                </Text>
              </View>

              <View className="flex-row justify-between items-center py-2">
                <View className="flex-row items-center">
                  <Ionicons name="time-outline" size={20} color={colors.textSecondary} />
                  <Text className="ml-2" style={{ color: colors.textSecondary }}>Duration</Text>
                </View>
                <Text className="font-semibold" style={{ color: colors.text }}>
                  {days} {days === 1 ? 'Day' : 'Days'}
                </Text>
              </View>

              <View className="flex-row justify-between items-center py-2">
                <View className="flex-row items-center">
                  <Ionicons name="people-outline" size={20} color={colors.textSecondary} />
                  <Text className="ml-2" style={{ color: colors.textSecondary }}>Capacity</Text>
                </View>
                <Text className="font-semibold" style={{ color: colors.text }}>
                  Up to {booking.spaces?.capacity || 0} guests
                </Text>
              </View>
            </View>
          </View>

          {/* Reason */}
          {booking.reason && (
            <View className="rounded-xl p-5 mb-4 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <Text className="text-lg font-semibold mb-2" style={{ color: colors.text }}>Booking Reason</Text>
              <Text className="text-base leading-6" style={{ color: colors.textSecondary }}>{booking.reason}</Text>
            </View>
          )}

          {/* User Details */}
          <View className="rounded-xl p-5 mb-4 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <Text className="text-lg font-semibold mb-4" style={{ color: colors.text }}>Contact Information</Text>
            
            <View className="gap-3">
              <View className="flex-row items-center">
                <Ionicons name="person-outline" size={20} color={colors.textSecondary} />
                <Text className="ml-3" style={{ color: colors.text }}>
                  {booking.users?.name}
                </Text>
              </View>

              <View className="flex-row items-center">
                <Ionicons name="mail-outline" size={20} color={colors.textSecondary} />
                <Text className="ml-3" style={{ color: colors.text }}>
                  {booking.users?.email || 'No email provided'}
                </Text>
              </View>
            </View>
          </View>

          {/* Price Breakdown */}
          <View className="rounded-xl p-5 mb-4 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <Text className="text-lg font-semibold mb-4" style={{ color: colors.text }}>Price Breakdown</Text>
            
            <View className="gap-3">
              <View className="flex-row justify-between items-center">
                <Text className="text-base" style={{ color: colors.textSecondary }}>₹{booking.spaces?.pph || 0} × {days} days</Text>
                <Text className="text-base" style={{ color: colors.text }}>₹{(booking.spaces?.pph || 0) * days}</Text>
              </View>

              <View className="border-t pt-3 mt-2" style={{ borderTopColor: colors.border }}>
                <View className="flex-row justify-between items-center">
                  <Text className="text-lg font-bold" style={{ color: colors.text }}>Total Amount</Text>
                  <Text className="text-2xl font-bold" style={{ color: colors.text }}>
                    ₹{booking.total_amount || (booking.spaces?.pph || 0) * days}
                  </Text>
                </View>
              </View>
            </View>
          </View>

          {/* Booking Metadata */}
          <View className="rounded-xl p-5 mb-6 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <Text className="text-xs mb-1" style={{ color: colors.textSecondary }}>Booking ID: {booking.id}</Text>
            <Text className="text-xs" style={{ color: colors.textSecondary }}>
              Created: {dayjs(booking.created_at).format('MMM DD, YYYY HH:mm')}
            </Text>
          </View>
          <TouchableOpacity className="p-5" onPress={onSuccess}>
            <Text className="text-xs" style={{ color: colors.textSecondary }}>
              Bypass Payment (For Testing Purposes)
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* Payment Button */}
      {booking.payment_status === 'pending' && (
        <View className="border-t px-6 py-4" style={{ backgroundColor: colors.card, borderTopColor: colors.border }}>
          <TouchableOpacity
            onPress={handleProceedToPayment}
            className="rounded-xl py-4 flex-row items-center justify-center bg-primary"
            disabled={payLoading}
          >
            <Ionicons name="card-outline" size={24} color="#000" />
            <Text className="text-base font-semibold ml-2" style={{ color: '#000' }}>
              {payLoading ? 'Processing...' : 'Proceed to Payment'}
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </SafeAreaView>
  );
}