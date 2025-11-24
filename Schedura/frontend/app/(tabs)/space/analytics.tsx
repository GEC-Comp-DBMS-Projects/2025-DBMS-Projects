import { Image, ScrollView, Text, View, StatusBar, Dimensions } from 'react-native';
import { Animated } from 'react-native';
import {getBookingOfSpace, getRequestpending, getTotalBookings} from '@/supabase/controllers/analytics';
import React, { useEffect, useState, useCallback } from 'react';
import { getMySpaces } from '@/supabase/controllers/spaces.controller';
import { useUser } from '@clerk/clerk-expo';
import { useTheme } from '@/contexts/ThemeContext';
import SafeBoundingView from '../../../components/SafeBoundingView'; 
import PieChart from 'react-native-chart-kit/dist/PieChart';
import MonthGraph from '@/components/Analytics/MonthGraph';
import DayOfWeekAll from '@/components/Analytics/DayOfWeekAll';
const CSpace = require("@/assets/images/illustrations/cspace.png");

const COLORS_PIE_LIGHT = ['#000000', '#666666', '#333333', '#999999', '#cccccc'];
const COLORS_PIE_DARK = ['#ffffff', '#aaaaaa', '#777777', '#cccccc', '#eeeeee'];

interface dataPie{
    name: string;
    bookings: number;
    color?:string;
    legendFontSize: number;
    legendFontColor: string;
}

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

// Analytics Skeleton
const AnalyticsSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View>
    {/* Stats Cards Skeleton */}
    <View className='flex flex-col justify-center gap-y-3 w-[100%] p-4'>
      <View className='border rounded-xl w-[100%] px-3 py-6' style={{ borderColor: colors.border }}>
        <SkeletonLoader width="60%" height={24} style={{ alignSelf: 'center', marginBottom: 8 }} />
        <SkeletonLoader width="80%" height={14} style={{ alignSelf: 'center', marginBottom: 12 }} />
        <SkeletonLoader width={60} height={36} style={{ alignSelf: 'center', borderRadius: 8 }} />
      </View>

      <View className='border rounded-xl w-[100%] px-3 py-6' style={{ borderColor: colors.border }}>
        <SkeletonLoader width="60%" height={24} style={{ alignSelf: 'center', marginBottom: 8 }} />
        <SkeletonLoader width="80%" height={14} style={{ alignSelf: 'center', marginBottom: 12 }} />
        <SkeletonLoader width={60} height={36} style={{ alignSelf: 'center', borderRadius: 8 }} />
      </View>
    </View>

    {/* Pie Chart Skeleton */}
    <View className='mx-5 my-6'>
      <SkeletonLoader width="60%" height={24} style={{ alignSelf: 'center', marginBottom: 8 }} />
      <SkeletonLoader width="70%" height={16} style={{ alignSelf: 'center', marginBottom: 16 }} />
      <View className='items-center'>
        <SkeletonLoader width={200} height={200} style={{ borderRadius: 100 }} />
      </View>
    </View>

    {/* Line Graph Skeleton */}
    <View className='mx-5 my-6'>
      <SkeletonLoader width="50%" height={24} style={{ alignSelf: 'center', marginBottom: 8 }} />
      <SkeletonLoader width="80%" height={16} style={{ alignSelf: 'center', marginBottom: 16 }} />
      <SkeletonLoader width="100%" height={280} style={{ borderRadius: 8 }} />
    </View>

    {/* Bar Chart Skeleton */}
    <View className='mx-5 my-6'>
      <SkeletonLoader width="50%" height={24} style={{ alignSelf: 'center', marginBottom: 8 }} />
      <SkeletonLoader width="80%" height={16} style={{ alignSelf: 'center', marginBottom: 16 }} />
      <SkeletonLoader width="100%" height={220} style={{ borderRadius: 8 }} />
    </View>
  </View>
);

function Manage() {
    const [spaces, setSpaces] = useState<any[]>([]);
    const [totalBookings, setTotalBookings] = useState<number>(0);
    const { colors, isDark } = useTheme();
    const [dayscount, setDayscount] = useState<number[]>([0, 0, 0, 0, 0, 0, 0]);
    const [pendingData , setPendingData] = useState<number>(0);
    const [loading, setLoading] = useState(true);
    
    const [dataSet, setDataSet] = useState<number[]>([]);
    const [labels, setLabels] = useState<string[]>([]);

    const getColor = (i: number) => {
        return isDark ?  COLORS_PIE_DARK[i % COLORS_PIE_DARK.length] : COLORS_PIE_LIGHT[i % COLORS_PIE_LIGHT.length];
    };

   const months_map: Record<string, string> = {
    "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr",
    "05": "May", "06": "Jun", "07": "Jul", "08": "Aug",
    "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"
  };

  useEffect(() => {
  setPieData(prev =>
    prev.map((item, i) => ({
      ...item,
      color: getColor(i),
      legendFontColor: isDark ? '#ffffff' : '#000000'
    }))
  );
}, [isDark]);


    const { user } = useUser();
    const screenWidth = Dimensions.get("window").width;
    const chartConfig = {
  backgroundColor: isDark ? "#0b1220" : "#f7f7f7",
  backgroundGradientFrom: isDark ? "#0b1220" : "#ffffff",
  backgroundGradientTo: isDark ? "#0b1220" : "#ffffff",
  backgroundGradientToOpacity: 1,
                color: (opacity = 1) => `${colors.text.replace(/^#/, '') ? `${hexToRgba(colors.text, opacity)}` : `rgba(60,60,60,${opacity})`}`,
              labelColor: (opacity = 1) => `${hexToRgba(colors.textSecondary, opacity)}`,
              propsForDots: {
                r: "8",
                strokeWidth: "2",
                stroke: isDark ? "#ffa726" : "#ffa726",
                fill: isDark ? "#0b1220" : "#fff"
              },
  strokeWidth: 2, 
  barPercentage: 0.5,
  useShadowColorFromDataset: false 
};

    const [pieData, setPieData] = useState<dataPie[]>([]);


const fetchSpaceData = useCallback(async () => {
    if(!user) return;
    setLoading(true);
    const { data: spacesData } = await getMySpaces(user?.id!);
    setSpaces(spacesData || []);
    // console.log("Fetched spaces: ", spacesData);

    const list = spacesData || [];
    if (list.length > 0) {
        const newData: dataPie[] = [];
        setTotalBookings(0);
        setPendingData(0);
        const weekdayCnt = new Array(7).fill(0);
        
        const aggregatedMonthMap = new Map<string, number>();

        for (let i = 0; i < list.length; i++) {
            const sp: any = list[i];
            const { data: totalBookings } = await getTotalBookings(sp?.id as string);
            
            let bookingsNum = 0;
            if (typeof totalBookings === 'number') bookingsNum = totalBookings as number;
            else if (Array.isArray(totalBookings)) bookingsNum = Number((totalBookings[0] as any)?.count ?? totalBookings[0] ?? 0);
            else if (totalBookings && typeof totalBookings === 'object') bookingsNum = Number((totalBookings as any).count ?? (totalBookings as any).total ?? 0);
            else bookingsNum = Number(totalBookings ?? 0);
            
            setTotalBookings(prev => prev + bookingsNum);
            console.log(`Space: ${sp?.name}, Bookings: ${bookingsNum}`);
            
            const spaceData: dataPie = {
                name: sp?.name ?? 'Unnamed',
                bookings: isNaN(bookingsNum) ? 0 : bookingsNum,
                color: getColor(i),
                legendFontSize: 15,
                legendFontColor: isDark ? '#ffffff' : '#000000'
            };
            newData.push(spaceData);

            const {data: lineg , error} = await getBookingOfSpace(sp?.id as string);
            if(error || !lineg) {
                console.log("Error fetching booking data for spaces:", sp?.id, error);
                continue;
            }

            lineg?.forEach((bk: any)=>{
                if(!bk?.start) return;
                try{
                    const date = new Date(bk.start);
                    const month = date.toISOString().slice(5, 7);
                    aggregatedMonthMap.set(month, (aggregatedMonthMap.get(month) || 0) + 1);

                    const dayIndex = date.getDay(); // 0 (Sun) to 6 (Sat)   
                    const adjustedDay = dayIndex === 0 ? 6 : dayIndex - 1;
                    weekdayCnt[adjustedDay]++;
                }catch(error){
                    console.log("Error in parsing date:" , error);
                }
            });

            const {data:pending , error:pendingError} = await getRequestpending(sp?.id as string);
            if(pendingError || pending == null){
                console.log("Error fetching pending data for space:", sp?.id, pendingError);
            } else {
                setPendingData(prev => prev + pending);
            }
        }

        const sortedMonths = Array.from(aggregatedMonthMap.keys()).sort((a, b) => 
            a.localeCompare(b)
        );

        const labelsArr: string[] = [];
        const valuesArr: number[] = [];

        sortedMonths.forEach(month => {
            if (months_map[month]) {
                labelsArr.push(months_map[month]);
                valuesArr.push(aggregatedMonthMap.get(month) || 0);
            }
        });

        setLabels(labelsArr);
        setDataSet(valuesArr);
        setPieData(newData);
        setDayscount(weekdayCnt);
        
        console.log("Booking Analytics - Labels:", labelsArr, "DataSet:", valuesArr);
        console.log("Weekend counts:", weekdayCnt);

    } else {
        setPieData([]);
        setLabels([]);
        setDataSet([]);
    }
    setLoading(false);

}, [user]);

    useEffect(()=>{
        fetchSpaceData();
    }, [user]);

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      <ScrollView style={{ backgroundColor: colors.backgroundSecondary }}>
        <View className="p-6 pb-12 rounded-b-2xl" style={{ backgroundColor: colors.primary }}>
          <Text className="text-4xl font-bold mt-6" style={{ color: colors.accent }}>Manage Your Spaces</Text>
          <Text className="mt-2 text-lg" style={{ color: colors.text }}>View analytics of all spaces {'\n'}and manage them with ease</Text>
          <Image source={CSpace} className="absolute right-2 bottom-0" />
        </View>

        <Text className="text-2xl font-bold mx-5 my-6 text-center" style={{ color: colors.accent }}>View Analytics Of All Spaces</Text>

        {loading ? (
          <AnalyticsSkeleton colors={colors} />
        ) : (
          <>
        <View className='flex flex-col justify-center gap-y-3 w-[100%] p-4'>
            <View className='border rounded-xl w-[100%] px-3 py-2 mb-2' style={{ borderColor: colors.border }}>
                <Text className='text-2xl text-center font-semibold' style={{ color: colors.text }}>Total Bookings</Text>

                <Text className='text-xs font-light text-center' style={{ color: colors.text }}>Total bookings of all spaces.</Text>

                <Text className={`text-3xl font-bold text-center`} style={{ color: colors.text }}>
                {totalBookings}
                </Text>
            </View>

            <View className='border rounded-xl w-[100%] px-3 py-2' style={{ borderColor: colors.border }}>
                <Text className='text-2xl text-center font-semibold' style={{ color: colors.text }}>Pending Bookings</Text>
    
                <Text className='text-xs font-light text-center' style={{ color: colors.text }}>Pending Bookings for all spaces.</Text>
    
                <Text
                className="text-3xl font-bold text-center"
                style={{ color: pendingData > 0 ? 'red' : 'green' }}
                >
                {pendingData}
                </Text>
            </View>
        </View>


        {spaces.length > 0 && totalBookings > 0 ? (
            <ScrollView>

                    <Text className='text-2xl font-bold text-center' style={{ color: colors.accent }}>Percentage Breakdown</Text>
                    <Text className='text-center' style={{ color: colors.textSecondary }}>View all spaces contribution</Text>
                <ScrollView horizontal={true} className='mx-5 my-6'>
                        <PieChart
                        data={pieData}
                        width={screenWidth}
                        height={240}
                        chartConfig={chartConfig}
                        accessor={"bookings"}
                        backgroundColor={"transparent"}
                        paddingLeft={"10"}
                        center={[0, 0]}
                        avoidFalseZero={true}
                        // absolute
                    />
                </ScrollView>


                <MonthGraph data={dataSet} labels={labels} />

                <DayOfWeekAll dayscount={dayscount} totalCount={totalBookings} />
            </ScrollView> 

        ) : (
            <View className='flex items-center justify-center h-[100%]'>
                <Text className="text-center mt-4 mx-5 text-base" style={{ color: colors.textSecondary }}>
                    You have not created any spaces yet. Create a space to view analytics.
                </Text>
            </View>
        )}
          </>
        )}

      </ScrollView>
    </SafeBoundingView>   
  )
}

function hexToRgba(hex: string, alpha = 1) {
  if (!hex) return `rgba(60,60,60,${alpha})`;
  const cleaned = hex.replace('#', '');
  const bigint = parseInt(cleaned, 16);
  const r = (bigint >> 16) & 255;
  const g = (bigint >> 8) & 255;
  const b = bigint & 255;
  return `rgba(${r},${g},${b},${alpha})`;
}

export default Manage