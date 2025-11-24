"use client";
import { Dimensions, Text, ScrollView, View, TouchableOpacity, Modal } from 'react-native';
import { LineChart } from "react-native-chart-kit";
import { getBookingOfSpace } from '@/supabase/controllers/analytics';
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import Totalbookings from '@/components/Analytics/Totalbookings';
import Daysofweek from '@/components/Analytics/Daysofweek';
import { useTheme } from '@/contexts/ThemeContext';

interface DataPointInfo {
  month: string;
  value: number;
  index: number;
  x: number;
  y: number;
}

export default function MangeSpaceScreen() {
  const { id } = useLocalSearchParams();
  const { colors, isDark } = useTheme();

  const [labels, setLabels] = useState<string[]>([]);
  const [dataSet, setDataSet] = useState<number[]>([]);
  const [selectedPoint, setSelectedPoint] = useState<DataPointInfo | null>(null);
  const [showModal, setShowModal] = useState(false);

  const months_map: Record<string, string> = {
    "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr",
    "05": "May", "06": "Jun", "07": "Jul", "08": "Aug",
    "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec"
  };

  const months_full: Record<string, string> = {
    "Jan": "January", "Feb": "February", "Mar": "March", "Apr": "April",
    "May": "May", "Jun": "June", "Jul": "July", "Aug": "August",
    "Sep": "September", "Oct": "October", "Nov": "November", "Dec": "December"
  };

  useEffect(() => {
    handleAnalyticsData();
  }, [id]);

  async function handleAnalyticsData() {
    try {
      const { data } = await getBookingOfSpace(id as string);
      if (!data || !Array.isArray(data)) return;

      const start_month_map = new Map<string, number>();

      data.forEach(ele => {
        if (!ele?.start) return;
        
        try {
          const start_date = new Date(ele.start);
          if (isNaN(start_date.getTime())) return;
          
          const month = start_date.toISOString().slice(5, 7);
          start_month_map.set(month, (start_month_map.get(month) || 0) + 1);
        } catch (err) {
          console.log("Invalid date:", ele.start);
        }
      });

      // Sort months chronologically
      const sortedEntries = Array.from(start_month_map.entries()).sort((a, b) => 
        a[0].localeCompare(b[0])
      );

      const labelsArr: string[] = [];
      const valuesArr: number[] = [];

      sortedEntries.forEach(([month, count]) => {
        if (months_map[month]) {
          labelsArr.push(months_map[month]);
          valuesArr.push(Number(count) || 0);
        }
      });

      setLabels(labelsArr);
      setDataSet(valuesArr);

    //   console.log("Monthly booking data:", { labelsArr, valuesArr });

    } catch (error) {
      console.log("Error fetching booking data:", error);
    }
  }

  const handleDataPointClick = (data: any) => {
    const { value, index } = data;
    const month = labels[index];
    
    setSelectedPoint({
      month,
      value,
      index,
      x: data.x,
      y: data.y
    });
    setShowModal(true);
  };

  const calculateGrowth = (index: number) => {
    if (index === 0) return null;
    const current = dataSet[index];
    const previous = dataSet[index - 1];
    const growth = ((current - previous) / previous) * 100;
    return growth;
  };

  return (
    <ScrollView className='w-full' style={{ backgroundColor: colors.tertiary }}>
      <Totalbookings/>

      {dataSet.length > 0 && (
        <View className='bg-transparent px-4'>
          <Text style={{ color: colors.text, fontWeight: '600', textAlign: 'center', fontSize: 20, marginTop: 12 }}>
            Month On Month Growth
          </Text>
          <Text style={{ color: colors.textSecondary, textAlign: 'center', fontSize: 13, marginBottom: 8 }}>
            Shows the monthly growth of booked spaces. Tap any point for details.
          </Text>

          {/* Inline Data Point Display */}
          {selectedPoint && !showModal && (
            <View className='bg-blue-50 border border-blue-200 rounded-lg p-3 mb-3'>
              <Text className='text-sm font-semibold text-blue-900'>
                {months_full[selectedPoint.month] || selectedPoint.month}
              </Text>
              <Text className='text-2xl font-bold text-blue-600'>
                {selectedPoint.value} bookings
              </Text>
            </View>
          )}

          {/* Chart: use theme colors */}
          <LineChart
            data={{
              labels: labels,
              datasets: [{ data: dataSet.length > 0 ? dataSet : [0] }],
            }}
            width={Dimensions.get("window").width - 32}
            height={280}
            yAxisInterval={1}
            chartConfig={{
              backgroundColor: isDark ? "#0b1220" : "#f7f7f7",
              backgroundGradientFrom: isDark ? "#0b1220" : "#ffffff",
              backgroundGradientTo: isDark ? "#0b1220" : "#ffffff",
              backgroundGradientFromOpacity: 0,
              backgroundGradientToOpacity: 0,
              decimalPlaces: 0,
              color: (opacity = 1) => `${colors.text.replace(/^#/, '') ? `${hexToRgba(colors.text, opacity)}` : `rgba(60,60,60,${opacity})`}`,
              labelColor: (opacity = 1) => `${hexToRgba(colors.textSecondary, opacity)}`,
              propsForDots: {
                r: "8",
                strokeWidth: "2",
                stroke: isDark ? "#ffa726" : "#ffa726",
                fill: isDark ? "#0b1220" : "#fff"
              }
            }}
            fromZero={true}
            bezier
            style={{
              marginVertical: 8,
              borderRadius: 8
            }}
            onDataPointClick={handleDataPointClick}
          />

          {/* Summary Stats Below Chart */}
          {dataSet.length > 0 && (
            <View className={`flex-row justify-around items-center rounded-lg p-4 mt-2`} style={{backgroundColor: isDark ? colors.textSecondary : '#cecece'}}>
              <View className='items-center'>
                <Text className='text-base text-gray-600'>Total</Text>
                <Text className='text-xl font-bold text-gray-900'>
                  {dataSet.reduce((a, b) => a + b, 0)}
                </Text>
              </View>
              <View className='items-center'>
                <Text className='text-base text-gray-600'>Average</Text>
                <Text className='text-xl font-bold text-gray-900'>
                  {Math.round(dataSet.reduce((a, b) => a + b, 0) / dataSet.length)}
                </Text>
              </View>
              <View className='items-center'>
                <Text className='text-base text-gray-600'>Peak</Text>
                <Text className='text-xl font-bold text-gray-900'>
                  {Math.max(...dataSet)}
                </Text>
              </View>
            </View>
          )}
        </View>
      )}

      {/* Modal for Detailed View */}
      <Modal
        visible={showModal}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setShowModal(false)}
      >
        <TouchableOpacity 
          activeOpacity={1}
          onPress={() => setShowModal(false)}
          style={{
            flex: 1,
            justifyContent: 'center',
            alignItems: 'center',
            backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.5)'
          }}
        >
          <TouchableOpacity 
            activeOpacity={1}
            onPress={(e) => e.stopPropagation()}
            style={{
              backgroundColor: colors.card,
              borderRadius: 16,
              padding: 20,
              marginHorizontal: 12,
              width: 320,
              shadowColor: '#000',
              shadowOpacity: 0.1,
              shadowRadius: 10,
            }}
          >
            {selectedPoint && (
              <View style={{ borderStyle: 'solid', borderColor: '#ffffff' }}>
                <View style={{ alignItems: 'center', marginBottom: 12 }}>
                  <Text style={{ color: colors.textSecondary, fontSize: 13 }}>
                    {months_full[selectedPoint.month] || selectedPoint.month}
                  </Text>
                  <Text style={{ color: colors.text, fontSize: 36, fontWeight: '700', marginTop: 6 }}>
                    {selectedPoint.value}
                  </Text>
                  <Text style={{ color: colors.textSecondary, fontSize: 13 }}>bookings</Text>
                </View>

                <View className='border-t border-gray-200 pt-4 gap-y-3'>
                  {/* Growth Rate */}
                  {selectedPoint.index > 0 && (
                    <View className='flex-row justify-between items-center'>
                      <Text className='text-gray-600' style={{color: colors.text}}>Growth Rate</Text>
                      <View className='flex-row items-center'>
                        {(() => {
                          const growth = calculateGrowth(selectedPoint.index);
                          if (growth === null) return null;
                          const isPositive = growth >= 0;
                          return (
                            <>
                              <Text className={`font-semibold ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
                                {isPositive ? '+' : ''}{growth.toFixed(1)}%
                              </Text>
                              <Text className='ml-1'>{isPositive ? '📈' : '📉'}</Text>
                            </>
                          );
                        })()}
                      </View>
                    </View>
                  )}

                  {/* Comparison with Average */}
                  <View className='flex-row justify-between items-center'>
                    <Text className='text-gray-600' style={{color: colors.text}}>vs. Average</Text>
                    <Text className='font-semibold text-gray-900' style={{color: colors.text}}>
                      {selectedPoint.value > (dataSet.reduce((a, b) => a + b, 0) / dataSet.length) 
                        ? 'Above ⭐' 
                        : 'Below'}
                    </Text>
                  </View>

                  {/* Position */}
                  <View className='flex-row justify-between items-center'>
                    <Text className='text-gray-600' style={{color: colors.text}}>Ranking</Text>
                    <Text className='font-semibold text-gray-900' style={{color: colors.text}}>
                      {dataSet
                        .map((val, idx) => ({ val, idx }))
                        .sort((a, b) => b.val - a.val)
                        .findIndex(item => item.idx === selectedPoint.index) + 1} of {dataSet.length}
                    </Text>
                  </View>
                </View>

                <TouchableOpacity
                  onPress={() => setShowModal(false)}
                  style={{ backgroundColor: colors.accent, borderRadius: 10, paddingVertical: 12, marginTop: 16 }}
                >
                  <Text style={{ color: colors.background, textAlign: 'center', fontWeight: '600' }}>Close</Text>
                </TouchableOpacity>
              </View>
            )}
          </TouchableOpacity>
        </TouchableOpacity>
      </Modal>

      <Daysofweek/>
    </ScrollView>
  );
}

// helper: convert hex to rgba string
function hexToRgba(hex: string, alpha = 1) {
  if (!hex) return `rgba(60,60,60,${alpha})`;
  const cleaned = hex.replace('#', '');
  const bigint = parseInt(cleaned, 16);
  const r = (bigint >> 16) & 255;
  const g = (bigint >> 8) & 255;
  const b = bigint & 255;
  return `rgba(${r},${g},${b},${alpha})`;
}