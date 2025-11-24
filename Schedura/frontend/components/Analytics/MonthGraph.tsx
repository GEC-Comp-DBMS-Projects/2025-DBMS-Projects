import { ScrollView, Text , View, Dimensions, TouchableOpacity, Modal } from 'react-native';
//@ts-ignore
import { useEffect, useState } from 'react';
import { useTheme } from '@/contexts/ThemeContext';
import { LineChart } from 'react-native-chart-kit';

interface DataPointInfo {
  month: string;
  value: number;
  index: number;
  x: number;
  y: number;
}

function MonthGraph(props: {data: number[] , labels: string[]}) {
    const { colors, isDark } = useTheme();

    const [dataSet, setDataSet] = useState<number[]>([]);
    const [labels, setLabels] = useState<string[]>([]);
    const [selectedPoint, setSelectedPoint] = useState<DataPointInfo | null>(null);
    const [showModal, setShowModal] = useState<boolean>(false);

    const month_record: Record<string, string> = {
      "Jan": "January", "Feb": "February", "Mar": "March", "Apr": "April",
      "May": "May", "Jun": "June", "Jul": "July", "Aug": "August",
      "Sep": "September", "Oct": "October", "Nov": "November", "Dec": "December"
    };

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

    useEffect(() => {
        setDataSet(props.data);
        setLabels(props.labels);
    }, [props.data, props.labels]);

  return (
    <ScrollView>
        <View className='bg-transparent px-4'>
          <Text style={{ color: colors.text, fontWeight: '600', textAlign: 'center', fontSize: 20, marginTop: 12 }}>
            Month On Month Growth
          </Text>
          <Text style={{ color: colors.textSecondary, textAlign: 'center', fontSize: 13, marginBottom: 8 }}>
            Shows the monthly growth of booked spaces. Tap any point for details.
          </Text>

            <LineChart
            data={{
              labels: labels,
              datasets: [{ data: dataSet.length > 0 ? dataSet : [0] }],
            }}
            width={Dimensions.get("window").width-32}
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
              labelColor: (opacity = 1) => `${hexToRgba(colors.text, opacity)}`,
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

            <View className={`flex-row justify-around items-center rounded-lg p-4 mt-2 mb-9`} style={{backgroundColor: isDark ? colors.textSecondary : '#cecece'}}>
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
                    {month_record[selectedPoint?.month] || selectedPoint?.month}
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
        </View>
    </ScrollView>
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

export default MonthGraph