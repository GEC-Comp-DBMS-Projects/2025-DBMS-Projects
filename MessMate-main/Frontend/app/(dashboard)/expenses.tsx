import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  Modal,
  FlatList,
  Alert,
  ScrollView,
} from 'react-native';
import { SafeAreaView } from "react-native-safe-area-context";
import { DollarSign, TrendingUp, Utensils, Cookie, Plus } from 'lucide-react-native';
import { LinearGradient } from 'expo-linear-gradient';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Transaction Card Component
const TransactionCard = ({ tx }: { tx: any }) => (
  <View style={styles.transactionCard}>
    <View style={{ flex: 1 }}>
      <Text style={styles.transactionDescription}>{tx.description}</Text>
      <View style={styles.itemsContainer}>
        {tx.items.map((item: string, index: number) => (
          <View key={index} style={styles.itemChip}>
            <Text style={styles.itemChipText}>{item}</Text>
          </View>
        ))}
      </View>
      <View style={styles.transactionMeta}>
        <Text style={styles.transactionDate}>{new Date(tx.date).toLocaleDateString()}</Text>
        <Text style={styles.transactionCategory}> • {tx.category}</Text>
      </View>
    </View>
    <Text style={styles.transactionAmount}>₹{tx.amount}</Text>
  </View>
);

export default function ExpensesScreen() {
  const [selectedPeriod, setSelectedPeriod] = useState('week');
  const [totalExpense, setTotalExpense] = useState(0);
  const [categories, setCategories] = useState([
    { name: 'Regular Meals', amount: 0, icon: Utensils, color: ['#FF7E5F','#FF4500'], percentage: 0 },
    { name: 'Extra Items', amount: 0, icon: Cookie, color: ['#FFB88C','#FF7E5F'], percentage: 0 },
  ]);
  const [recentTransactions, setRecentTransactions] = useState<any[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [newItemName, setNewItemName] = useState('');
  const [newItemPrice, setNewItemPrice] = useState('');
  const [budgetModalVisible, setBudgetModalVisible] = useState(false);
  const [messBudgetLimit, setMessBudgetLimit] = useState(800);
  const [newBudget, setNewBudget] = useState('');
  const [userId, setUserId] = useState<number | null>(null);
  const [token, setToken] = useState<string | null>(null);

  useEffect(() => {
    const fetchUserAndTokenAndBudget = async () => {
      const storedUser = await AsyncStorage.getItem('user');
      const storedToken = await AsyncStorage.getItem('token');
      const storedBudget = await AsyncStorage.getItem('messBudget');

      if (storedUser) setUserId(JSON.parse(storedUser).id);
      if (storedToken) setToken(storedToken);
      if (storedBudget) setMessBudgetLimit(parseFloat(storedBudget));
    };
    fetchUserAndTokenAndBudget();
  }, []);

  const fetchExpenses = async () => {
    if (!userId || !token) return;

    try {
      const res = await fetch(`http://10.246.134.45:5000/expense/total/${userId}?period=${selectedPeriod}`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      const data = await res.json();
      if (!res.ok) return Alert.alert('Error', data.error || 'Failed to fetch expenses');

      setTotalExpense(data.total || 0);

      const byCategory = data.byCategory || [];
      const updatedCategories = categories.map(cat => {
        const catData = byCategory.find((c: any) => c.category === cat.name);
        const amount = catData?.total || 0;
        const percentage =
          selectedPeriod === 'week'
            ? (amount / messBudgetLimit) * 100
            : data.total > 0
            ? (amount / data.total) * 100
            : 0;
        return { ...cat, amount, percentage };
      });
      setCategories(updatedCategories);

      const transactionsWithItems = (data.recentTransactions || []).map((tx: any) => ({
        ...tx,
        items: tx.items || [tx.description || ''],
      }));
      setRecentTransactions(transactionsWithItems);
    } catch (err) {
      console.error(err);
      Alert.alert('Error', 'Unable to fetch expenses');
    }
  };

  useEffect(() => {
    if (userId && token) fetchExpenses();
  }, [userId, token, selectedPeriod, messBudgetLimit]);

  useEffect(() => {
    if (!userId || !token) return;
    const interval = setInterval(() => fetchExpenses(), 5000);
    return () => clearInterval(interval);
  }, [userId, token, selectedPeriod, messBudgetLimit]);

  const addExtraItem = async () => {
    if (!newItemName || !newItemPrice) return Alert.alert('Error', 'Enter item name and price');
    if (!token || !userId) return;

    try {
      const res = await fetch(`http://10.246.134.45:5000/expense/add`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({
          user_id: userId,
          name: newItemName,
          price: parseFloat(newItemPrice),
          category: 'Extra Items',
        }),
      });

      const data = await res.json();
      if (res.ok) {
        setModalVisible(false);
        setNewItemName('');
        setNewItemPrice('');
        fetchExpenses();
      } else {
        Alert.alert('Error', data.error || 'Could not add item');
      }
    } catch (err) {
      console.error(err);
      Alert.alert('Error', 'Unable to add expense');
    }
  };

  const updateBudget = async () => {
    const value = parseFloat(newBudget);
    if (isNaN(value) || value <= 0) return Alert.alert('Error', 'Enter a valid budget');

    try {
      await AsyncStorage.setItem('messBudget', value.toString());
      setMessBudgetLimit(value);
      setBudgetModalVisible(false);
      setNewBudget('');
    } catch (err) {
      console.error(err);
      Alert.alert('Error', 'Unable to save budget');
    }
  };

  const percentageUsed = (totalExpense / messBudgetLimit) * 100;

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={recentTransactions}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => <TransactionCard tx={item} />}
        ListHeaderComponent={
          <>
            {/* Header */}
            <View style={styles.header}>
              <LinearGradient colors={['#FF7E5F','#FF4500']} style={styles.headerIcon}>
                <DollarSign size={24} color="#fff" />
              </LinearGradient>
              <Text style={styles.headerTitle}>Mess Expense Tracker</Text>
            </View>

            {/* Period Selector */}
            <View style={styles.periodSelector}>
              {['week', 'month', 'year'].map((period) => (
                <TouchableOpacity
                  key={period}
                  style={[styles.periodButton, selectedPeriod === period && styles.periodButtonActive]}
                  onPress={() => setSelectedPeriod(period)}
                >
                  <Text style={[styles.periodButtonText, selectedPeriod === period && styles.periodButtonTextActive]}>
                    {period.charAt(0).toUpperCase() + period.slice(1)}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {/* Budget Card */}
            <View style={styles.budgetCard}>
              <View style={styles.budgetHeader}>
                <Text style={styles.budgetTitle}>Mess Total - This {selectedPeriod}</Text>
                <TrendingUp size={20} color="#FF4500" />
              </View>
              <View style={styles.budgetAmount}>
                <Text style={styles.currentAmount}>₹{totalExpense}</Text>
                {selectedPeriod === 'week' && (
                  <>
                    <Text style={styles.budgetSubAmount}>/ ₹{messBudgetLimit} Budget</Text>
                    <TouchableOpacity
                      onPress={() => setBudgetModalVisible(true)}
                      style={styles.editBudgetButton}
                    >
                      <Text style={{ color:'#fff', fontWeight:'600' }}>Edit Budget</Text>
                    </TouchableOpacity>
                  </>
                )}
              </View>
              {selectedPeriod === 'week' && (
                <>
                  <View style={styles.progressBar}>
                    <LinearGradient
                      colors={['#FF7E5F','#FF4500']}
                      style={[styles.progressFill, { width: `${Math.min(percentageUsed, 100)}%` }]}
                    />
                  </View>
                  <Text style={styles.budgetSubtext}>
                    {percentageUsed < 80
                      ? "Great! You're managing mess expenses well"
                      : 'Consider reducing extra items to save money'}
                  </Text>
                </>
              )}
            </View>

            {/* Categories */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Mess Categories</Text>
              {categories.map((category, index) => (
                <View key={index} style={styles.categoryCard}>
                  <View style={styles.categoryHeader}>
                    <LinearGradient colors={category.color} style={styles.categoryIcon}>
                      <category.icon size={20} color="#fff" />
                    </LinearGradient>
                    <View style={styles.categoryInfo}>
                      <Text style={styles.categoryName}>{category.name}</Text>
                      <Text style={styles.categoryPercentage}>
                        {category.percentage.toFixed(0)}% {selectedPeriod === 'week' ? 'of weekly budget' : 'of total'}
                      </Text>
                    </View>
                    <Text style={styles.categoryAmount}>₹{category.amount}</Text>
                  </View>
                  <View style={styles.categoryProgress}>
                    <View
                      style={[styles.categoryProgressFill, { width: `${category.percentage}%`, backgroundColor: category.color[0] }]}
                    />
                  </View>
                </View>
              ))}
            </View>

            {/* Transactions Header */}
            <View style={styles.section}>
              <View style={styles.transactionHeader}>
                <Text style={styles.sectionTitle}>Recent Mess Purchases</Text>
                <TouchableOpacity style={styles.addButton} onPress={() => setModalVisible(true)}>
                  <Plus size={16} color="#FFFFFF" />
                </TouchableOpacity>
              </View>
            </View>
          </>
        }
        ListEmptyComponent={
          <Text style={{ textAlign: 'center', color: '#6B7280', marginTop: 8 }}>No recent purchases</Text>
        }
        contentContainerStyle={{ paddingBottom: 40 }}
        showsVerticalScrollIndicator={false}
      />

      {/* Add Extra Item Modal */}
      <Modal transparent visible={modalVisible} animationType="slide">
        <View style={styles.modalBackdrop}>
          <View style={styles.modalContainer}>
            <Text style={styles.modalTitle}>Add Extra Item</Text>
            <TextInput
              placeholder="Item Name"
              value={newItemName}
              onChangeText={setNewItemName}
              style={styles.modalInput}
            />
            <TextInput
              placeholder="Price"
              value={newItemPrice}
              onChangeText={setNewItemPrice}
              keyboardType="numeric"
              style={styles.modalInput}
            />
            <View style={styles.modalActions}>
              <TouchableOpacity onPress={() => setModalVisible(false)} style={{ marginRight:12 }}>
                <Text style={{ color:'#FF4500', fontWeight:'bold' }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={addExtraItem}>
                <Text style={{ color:'#FF4500', fontWeight:'bold' }}>Add</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Edit Budget Modal */}
      <Modal transparent visible={budgetModalVisible} animationType="slide">
        <View style={styles.modalBackdrop}>
          <View style={styles.modalContainer}>
            <Text style={styles.modalTitle}>Edit Weekly Budget</Text>
            <TextInput
              placeholder="Enter new budget"
              value={newBudget}
              onChangeText={setNewBudget}
              keyboardType="numeric"
              style={styles.modalInput}
            />
            <View style={styles.modalActions}>
              <TouchableOpacity onPress={() => setBudgetModalVisible(false)} style={{ marginRight:12 }}>
                <Text style={{ color:'#FF4500', fontWeight:'bold' }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={updateBudget}>
                <Text style={{ color:'#FF4500', fontWeight:'bold' }}>Update</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex:1, backgroundColor:'#F9FAFB' },
  header: { flexDirection:'row', alignItems:'center', padding:24, paddingBottom:16 },
  headerIcon: { width:50, height:50, borderRadius:12, justifyContent:'center', alignItems:'center' },
  headerTitle: { fontSize:24, fontWeight:'bold', color:'#111827', marginLeft:12 },
  periodSelector: { flexDirection:'row', paddingHorizontal:24, marginBottom:24 },
  periodButton: { flex:1, paddingVertical:12, borderRadius:24, marginRight:8, backgroundColor:'#FFF', borderWidth:1, borderColor:'#E5E7EB', alignItems:'center' },
  periodButtonActive: { backgroundColor:'#FF4500', borderColor:'#FF4500' },
  periodButtonText: { fontSize:14, fontWeight:'600', color:'#6B7280' },
  periodButtonTextActive: { color:'#FFF' },
  budgetCard: { backgroundColor:'#FFF', borderRadius:16, padding:20, marginHorizontal:24, marginBottom:24, shadowColor:'#000', shadowOffset:{width:0,height:2}, shadowOpacity:0.05, shadowRadius:8, elevation:2 },
  budgetHeader: { flexDirection:'row', justifyContent:'space-between', alignItems:'center', marginBottom:16 },
  budgetTitle: { fontSize:16, fontWeight:'600', color:'#111827' },
  budgetAmount: { flexDirection:'row', alignItems:'baseline', marginBottom:16 },
  currentAmount: { fontSize:32, fontWeight:'bold', color:'#111827' },
  budgetSubAmount: { marginLeft:12, fontSize:16, fontWeight:'600', color:'#6B7280', alignSelf:'center' },
  editBudgetButton: { marginLeft:12, paddingHorizontal:12, paddingVertical:4, backgroundColor:'#FF4500', borderRadius:8 },
  progressBar: { height:8, backgroundColor:'#E5E7EB', borderRadius:4, marginBottom:8 },
  progressFill: { height:'100%', borderRadius:4 },
  budgetSubtext: { fontSize:14, color:'#6B7280' },
  section: { paddingHorizontal:24, paddingTop:0 },
  sectionTitle: { fontSize:18, fontWeight:'600', color:'#111827', marginBottom:16 },
  categoryCard: { backgroundColor:'#FFF', borderRadius:16, padding:16, marginBottom:12, shadowColor:'#000', shadowOffset:{width:0,height:2}, shadowOpacity:0.05, shadowRadius:4, elevation:2 },
  categoryHeader: { flexDirection:'row', alignItems:'center', marginBottom:12 },
  categoryIcon: { width:36, height:36, borderRadius:12, alignItems:'center', justifyContent:'center' },
  categoryInfo: { flex:1, marginLeft:12 },
  categoryName: { fontSize:14, fontWeight:'600', color:'#111827' },
  categoryPercentage: { fontSize:12, color:'#6B7280' },
  categoryAmount: { fontSize:16, fontWeight:'600', color:'#111827' },
  categoryProgress: { height:6, backgroundColor:'#E5E7EB', borderRadius:3 },
  categoryProgressFill: { height:'100%', borderRadius:3 },
  transactionHeader: { flexDirection:'row', justifyContent:'space-between', alignItems:'center', marginBottom:16 },
  addButton: { backgroundColor:'#FF4500', borderRadius:12, width:36, height:36, alignItems:'center', justifyContent:'center' },
  transactionCard: { backgroundColor:'#FFF', borderRadius:16, padding:16, marginHorizontal:24, marginBottom:12, flexDirection:'row', alignItems:'center', shadowColor:'#000', shadowOpacity:0.05, shadowRadius:4, elevation:2 },
  transactionDescription: { fontSize:14, fontWeight:'600', color:'#111827', marginBottom:6 },
  itemsContainer: { flexDirection:'row', flexWrap:'wrap', marginBottom:6 },
  itemChip: { backgroundColor:'#FFEDD5', paddingHorizontal:10, paddingVertical:4, borderRadius:12, marginRight:6, marginBottom:6 },
  itemChipText: { fontSize:12, color:'#C2410C', fontWeight:'500' },
  transactionMeta: { flexDirection:'row', alignItems:'center' },
  transactionDate: { fontSize:12, color:'#6B7280' },
  transactionCategory: { fontSize:12, color:'#6B7280', marginLeft:4 },
  transactionAmount: { fontSize:16, fontWeight:'600', color:'#111827', marginLeft:12 },
  modalBackdrop: { flex:1, justifyContent:'center', alignItems:'center', backgroundColor:'rgba(0,0,0,0.5)' },
  modalContainer: { width:'80%', backgroundColor:'#fff', borderRadius:16, padding:20 },
  modalTitle: { fontSize:18, fontWeight:'bold', marginBottom:12 },
  modalInput: { borderWidth:1, borderColor:'#E5E7EB', borderRadius:12, padding:10, marginBottom:12 },
  modalActions: { flexDirection:'row', justifyContent:'flex-end' },
});
