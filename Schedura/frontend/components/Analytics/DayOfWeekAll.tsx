import { useEffect, useState } from 'react';
import { ActivityIndicator, Dimensions, Text, TouchableOpacity, View } from 'react-native'
import { BarChart } from 'react-native-chart-kit'
import { useToast } from '../Toast';
import { useTheme } from '@/contexts/ThemeContext';

interface DayStats {
  day: string;
  count: number;
  percentage: number;
  isWeekend: boolean;
}

function DayOfWeekAll(props: {dayscount: number[] , totalCount: number}) {

    const [selectedDay, setSelectedDay] = useState<number | null>(null);
    const Xdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  const fullDayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    const [geminiInsight, setGeminiInsight] = useState<string | null>(null);
    const [geminiLoading, setGeminiLoading] = useState<boolean>(false);
    const { showToast } = useToast();
    const { colors, isDark } = useTheme();

    const maxValue = Math.max(...props.dayscount, 1);
  const roundedMax = Math.ceil(maxValue / 5) * 5;
  const safeSegments = Math.max(Math.floor(roundedMax / 5), 1);

    const chartConfig = {
    backgroundGradientFromOpacity: 0,
    backgroundGradientToOpacity: 0,
    color: (opacity = 1) => `${colors.text.replace(/^#/, '') ? `${hexToRgba(colors.text, opacity)}` : `rgba(100,100,100,${opacity})`}`,
    strokeWidth: 2,
    barPercentage: 0.65,
    decimalPlaces: 0,
    propsForBackgroundLines: {
      strokeDasharray: '',
      stroke: '#e0e0e0',
      strokeWidth: 1
    },
    propsForLabels: {
      fontSize: 11,
      fontWeight: '600'
    }
  };

    const screenWidth = Dimensions.get("window").width;

    const graphStyle = {
    marginVertical: 8,
    borderRadius: 16,
    paddingRight: 20
  };

    const getDayStats = (index: number): DayStats => {
    const count = props.dayscount[index];
    const percentage = props.totalCount > 0 ? (count / props.totalCount) * 100 : 0;
    const isWeekend = index >= 5;
    
    return {
      day: fullDayNames[index],
      count,
      percentage,
      isWeekend
    };
  };

    const getChartData = () => {
    return {
      labels: Xdays,
      datasets: [
        {
          data: props.dayscount.length > 0 ? props.dayscount : [0, 0, 0, 0, 0, 0, 0],
          colors: Xdays.map((_, index) => 
            (opacity = 1) => {
              if (selectedDay === index) {
                return `rgba(59, 130, 246, ${opacity})`; // Blue for selected
              }
              return index >= 5 
                ? `rgba(147, 51, 234, ${opacity})` // Purple for weekends
                : `rgba(60, 60, 60, ${opacity})`; // Dark gray for weekdays
            }
          )
        }
      ]
    };
  };

    useEffect(() => {
      if (props.totalCount > 0) {
        fetchGeminiInsight(split, props.dayscount, props.totalCount);
      }
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [props.totalCount]);


    const fetchGeminiInsight = async (split: any, dayscount: number[], totalBookings: number) => {
    setGeminiLoading(true);
    setGeminiInsight(null);
    try {
      // Prepare prompt for Gemini
      const prompt = `
        Given the following booking data for all the venues of the owner:
        - Total bookings: ${totalBookings}
        - Bookings per day (Mon-Sun): ${dayscount.join(', ')}
        - Weekday bookings: ${split.weekday} (${split.weekdayPercent.toFixed(1)}%)
        - Weekend bookings: ${split.weekend} (${split.weekendPercent.toFixed(1)}%)
        Please provide a short actionable insight or recommendation for all the venue owner to improve bookings or optimize pricing. Respond in 1-2 sentences, no greeting, no closing.
      `;
      const response = await fetch(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + process.env.EXPO_PUBLIC_GOOGLE_GEMINI_API_KEY,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }]
          })
        }
      );
      const data = await response.json();
      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
      setGeminiInsight(text || "No insight generated.");
    } catch (err: any) {
      setGeminiInsight(null);
      showToast({
        type: 'error',
        title: 'Gemini API Error',
        description: err?.message || 'Failed to fetch insight.'
      });
    } finally {
      setGeminiLoading(false);
    }
  };

    const getMostPopularDay = () => {
    const maxCount = Math.max(...props.dayscount);
    const maxIndex = props.dayscount.indexOf(maxCount);
    return maxIndex >= 0 && maxCount > 0 ? fullDayNames[maxIndex] : null;
  };
  
  const getLeastPopularDay = () => {
    if (props.totalCount === 0) return null;
    const nonZeroCounts = props.dayscount.filter(c => c > 0);
    if (nonZeroCounts.length === 0) return null;
    
    const minCount = Math.min(...nonZeroCounts);
    const minIndex = props.dayscount.indexOf(minCount);
    return minIndex >= 0 ? fullDayNames[minIndex] : null;
  };
  
  const getWeekdayVsWeekendSplit = () => {
    const weekdayTotal = props.dayscount.slice(0, 5).reduce((a, b) => a + b, 0);
    const weekendTotal = props.dayscount.slice(5).reduce((a, b) => a + b, 0);
    const total = weekdayTotal + weekendTotal;
    const weekdayPercent = total > 0 ? (weekdayTotal / total) * 100 : 0;
    const weekendPercent = total > 0 ? (weekendTotal / total) * 100 : 0;
    return { weekdayTotal, weekendTotal, weekdayPercent, weekendPercent };
  };

  const split = getWeekdayVsWeekendSplit();
  const mostPopular = getMostPopularDay();
  const leastPopular = getLeastPopularDay();

  return (
    <View className='mb-6 mt-4 px-4'>
      <Text className='font-bold text-center text-2xl mb-1' style={{ color: colors.accent }}>
        Bookings By Day Of Week
      </Text>
      <Text className='text-center text-sm mb-4 text-gray-600' style={{ color: colors.text }}>
        Tap day labels below the chart or cards below to see details
      </Text>

            {/* Interactive Day Labels Above Chart */}
            <View className='flex-row justify-around mb-2 px-2'>
              {Xdays.map((day, index) => {
                const isSelected = selectedDay === index;
                const stats = getDayStats(index);
                return (
                  <TouchableOpacity
                    key={day}
                    onPress={() => setSelectedDay(isSelected ? null : index)}
                    className={`px-2 py-1 rounded-md ${
                      isSelected 
                        ? 'bg-blue-500' 
                        : stats.isWeekend 
                        ? 'bg-purple-200' 
                        : 'bg-gray-200'
                    }`}
                  >
                    <Text className={`text-xs font-semibold ${
                      isSelected ? 'text-white' : 'text-gray-700'
                    }`}>
                      {day}
                    </Text>
                  </TouchableOpacity>
                );
              })}
            </View>

        <BarChart
            yAxisSuffix=''
            style={graphStyle}
            data={getChartData()}
            width={screenWidth - 32}
            height={240}
            yAxisLabel=""
            chartConfig={chartConfig}
            fromZero={true}
            yAxisInterval={1}
            showValuesOnTopOfBars={true}
            segments={safeSegments}
            withInnerLines={true}
            withCustomBarColorFromData={true}
            flatColor={true}
      />

            {selectedDay !== null && (
        <View className='bg-blue-50 border border-blue-200 rounded-xl p-4 mb-4 mt-2'>
          <View className='flex-row justify-between items-center mb-2'>
            <Text className='text-lg font-bold text-blue-900'>
              {getDayStats(selectedDay).day}
            </Text>
            <TouchableOpacity onPress={() => setSelectedDay(null)}>
              <Text className='text-blue-600 font-semibold text-lg'>✕</Text>
            </TouchableOpacity>
          </View>
          <View className='flex-row justify-between items-center'>
            <View>
              <Text className='text-3xl font-bold text-blue-600'>
                {getDayStats(selectedDay).count}
              </Text>
              <Text className='text-xs text-gray-600'>bookings</Text>
            </View>
            <View className='items-end'>
              <Text className='text-2xl font-bold text-blue-600'>
                {getDayStats(selectedDay).percentage.toFixed(1)}%
              </Text>
              <Text className='text-xs text-gray-600'>of total</Text>
            </View>
          </View>
          {getDayStats(selectedDay).isWeekend && (
            <View className='mt-2 bg-purple-100 rounded-lg px-3 py-1 self-start'>
              <Text className='text-xs font-semibold text-purple-700'>Weekend 🎉</Text>
            </View>
          )}
        </View>
      )}

            <View className='bg-gray-500/20 rounded-xl p-4 mb-4'>
        <Text className='font-semibold text-gray-900 mb-3 text-xl' style={{ color: colors.text }}>📊 Key Insights</Text>
        
        <View className='gap-y-2'>
          {mostPopular && (
            <View className='flex-row justify-between items-center py-2 border-b border-gray-200'>
              <Text className='text-gray-700 text-sm' style={{ color: colors.text }}>Most Popular Day</Text>
              <View className='flex-row items-center'>
                <Text className='font-bold text-yellow-500'>{mostPopular}</Text>
              </View>
            </View>
          )}
          
          {leastPopular && (
            <View className='flex-row justify-between items-center py-2 border-b border-gray-200'>
              <Text className='text-gray-700 text-sm' style={{ color: colors.text }}>Least Popular Day</Text>
              <Text className='font-semibold text-orange-600'>{leastPopular}</Text>
            </View>
          )}
          
          <View className='flex-row justify-between items-center py-2'>
            <Text className='text-gray-700 text-sm' style={{ color: colors.text }}>Average per Day</Text>
            <Text className='font-semibold text-blue-600'>
              {(props.totalCount / 7).toFixed(1)}
            </Text>
          </View>
        </View>
      </View>

             <View className='bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl py-4 mb-4'>
        <Text className='font-semibold text-gray-900 mb-3 text-xl' style={{ color: colors.text }}>
          Weekday vs Weekend Split
        </Text>
        
        <View className='flex-row justify-between mb-3'>
          <View className='flex-1 mr-2'>
            <View className='bg-blue-100 rounded-lg p-3 items-center'>
              <Text className='text-xs text-blue-700 font-semibold mb-1'>Weekdays</Text>
              <Text className='text-2xl font-bold text-blue-600'>{split.weekdayTotal}</Text>
              <Text className='text-xs text-blue-700 mt-1'>
                {split.weekdayPercent.toFixed(0)}%
              </Text>
            </View>
          </View>
          
          <View className='flex-1 ml-2'>
            <View className='bg-purple-100 rounded-lg p-3 items-center'>
              <Text className='text-xs text-purple-700 font-semibold mb-1' >Weekends</Text>
              <Text className='text-2xl font-bold text-purple-600'>{split.weekendTotal}</Text>
              <Text className='text-xs text-purple-700 mt-1'>
                {split.weekendPercent.toFixed(0)}%
              </Text>
            </View>
          </View>
        </View>
        
        {/* Visual Progress Bar */}
        <View className='h-3 bg-gray-200 rounded-full overflow-hidden flex-row'>
          <View 
            className='bg-blue-500 h-full' 
            style={{ width: `${split.weekdayPercent}%` }}
          />
          <View 
            className='bg-purple-500 h-full' 
            style={{ width: `${split.weekendPercent}%` }}
          />
        </View>
      </View>


            <View className='mb-4'>
        <Text className='font-semibold text-gray-900 mb-3 text-xl' style={{ color: colors.text }}>Quick Overview</Text>
        <View className='flex-row flex-wrap justify-between'>
          {Xdays.map((day, index) => {
            const stats = getDayStats(index);
            const isSelected = selectedDay === index;
            const isMostPopular = stats.count === Math.max(...props.dayscount) && stats.count > 0;
            
            return (
              <TouchableOpacity
                key={day}
                onPress={() => setSelectedDay(isSelected ? null : index)}
                activeOpacity={0.7}
                className={`w-[48%] mb-3 p-3 rounded-lg border-2 ${
                  isSelected 
                    ? 'bg-blue-100 border-blue-500' 
                    : stats.isWeekend 
                    ? 'bg-purple-50 border-purple-300' 
                    : 'bg-white border-gray-300'
                }`}
              >
                <View className='flex-row justify-between items-start mb-1'>
                  <Text className={`font-bold text-sm ${
                    isSelected ? 'text-blue-900' : 'text-gray-800'
                  }`}>
                    {day}
                  </Text>
                  {isMostPopular && <Text className='text-base'>👑</Text>}
                </View>
                <Text className={`text-2xl font-bold ${
                  isSelected ? 'text-blue-600' : stats.isWeekend ? 'text-purple-600' : 'text-gray-700'
                }`}>
                  {stats.count}
                </Text>
                <Text className='text-xs text-gray-500 mt-0.5'>
                  {stats.percentage.toFixed(1)}% of total
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>

        <View className='bg-yellow-50 border border-yellow-300 rounded-lg p-4 mb-4'>
                <Text className='font-semibold text-yellow-900 mb-1'>💡 Gemini Insight</Text>
                {geminiLoading ? (
                  <View className="flex-row items-center">
                    <ActivityIndicator size="small" color="#f59e0b" />
                    <Text className="ml-2 text-yellow-800">Generating insight...</Text>
                  </View>
                ) : (
                  <Text className='text-sm text-yellow-800'>
                    {geminiInsight || "No insight available."}
                  </Text>
                )}
        </View>
      </View>
    </View>
  );
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

export default DayOfWeekAll