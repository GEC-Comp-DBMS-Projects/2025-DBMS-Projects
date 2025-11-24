import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Image,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Calendar, Clock } from "lucide-react-native";
import Icon from "react-native-vector-icons/FontAwesome5";
import MCIcon from "react-native-vector-icons/MaterialCommunityIcons";
import { LinearGradient } from "expo-linear-gradient";

export default function MenuScreen() {
  const [selectedDay, setSelectedDay] = useState(new Date().getDay());
  const [weeklyMenu, setWeeklyMenu] = useState<any>({});
  const [loading, setLoading] = useState(true);

  const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const dayKeys = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"];
  const dayNames = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];

  useEffect(() => {
    const intervalId = setInterval(fetchMenu, 10000);
    fetchMenu();
    return () => clearInterval(intervalId);
  }, []);

  const fetchMenu = async () => {
    try {
      const res = await fetch("http://10.246.134.45:5000/menu/weekly");
      if (!res.ok) return;
      const data = await res.json();
      const convertedMenu: any = Object.fromEntries(
        Object.entries(data.menu).map(([day, meals]: [string, any]) => [
          day,
          {
            breakfast: meals.breakfast.map((i: any) => ({ ...i, price: parseFloat(i.price) })),
            lunch: meals.lunch.map((i: any) => ({ ...i, price: parseFloat(i.price) })),
            dinner: meals.dinner.map((i: any) => ({ ...i, price: parseFloat(i.price) })),
          },
        ])
      );
      setWeeklyMenu(convertedMenu);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const todayMenu = weeklyMenu[dayKeys[selectedDay]] || { breakfast: [], lunch: [], dinner: [] };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.headerIcon}>
            <Calendar size={26} color="#fff" />
          </LinearGradient>
          <Text style={styles.headerTitle}>Weekly Menu</Text>
        </View>

        {/* Day Selector */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.daySelector}>
          {days.map((day, i) => (
            <TouchableOpacity
              key={i}
              onPress={() => setSelectedDay(i)}
              style={[
                styles.dayButton,
                selectedDay === i && { backgroundColor: "#FF7E5F" },
              ]}
              activeOpacity={0.7}
            >
              <Text
                style={[
                  styles.dayButtonText,
                  selectedDay === i && { color: "#fff" },
                ]}
              >
                {day}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Loading */}
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#FF4500" />
            <Text style={{ marginTop: 10, color: "#6B7280" }}>Loading menu...</Text>
          </View>
        ) : (
          <View style={styles.menuContainer}>
            <Text style={styles.dayTitle}>{dayNames[selectedDay]}'s Menu</Text>

            <MealCard title="Breakfast" time="8:00 AM - 10:00 AM" items={todayMenu.breakfast} />
            <MealCard title="Lunch" time="12:30 PM - 2:30 PM" items={todayMenu.lunch} />
            <MealCard title="Dinner" time="7:30 PM - 9:30 PM" items={todayMenu.dinner} />
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

// ----- Meal Card -----
function MealCard({ title, time, items }: { title: string; time: string; items: any[] }) {
  const getMealIconAndColor = () => {
    switch (title) {
      case "Breakfast":
        return { icon: <Icon name="coffee" size={20} color="#fff" />, colors: ["#FFA17F","#FF7E5F"] };
      case "Lunch":
        return { icon: <Icon name="utensils" size={20} color="#fff" />, colors: ["#FF512F","#DD2476"] };
      case "Dinner":
        return { icon: <MCIcon name="food-fork-drink" size={20} color="#fff" />, colors: ["#7F00FF","#E100FF"] };
      default:
        return { icon: <Icon name="utensils" size={20} color="#fff" />, colors: ["#6B3F69","#A76C9E"] };
    }
  };
  const { icon, colors } = getMealIconAndColor();

  return (
    <View style={styles.mealCard}>
      <View style={styles.mealHeader}>
        <LinearGradient colors ={colors} style={styles.mealIcon}>{icon}</LinearGradient>
        <View style={styles.mealInfo}>
          <Text style={styles.mealTitle}>{title}</Text>
          <View style={styles.timeContainer}>
            <Clock size={14} color="#6B7280" />
            <Text style={styles.mealTime}>{time}</Text>
          </View>
        </View>
      </View>

      <View style={styles.itemsContainer}>
        {items.length > 0 ? (
          items.map((item, i) => (
            <View key={i} style={styles.menuItemCard}>
              {item.image_url ? (
                <Image
                  source={{ uri: item.image_url }}
                  style={styles.foodImage}
                />
              ) : (
                <View style={styles.foodPlaceholder} />
              )}
              <View style={{ flex: 1, flexDirection: "row" , alignItems: "center" }}>
                <Text style={styles.itemText}>{item.name}</Text>
                <Text style={styles.priceText}> ₹ {item.price}</Text>
              </View>
            </View>
          ))
        ) : (
          <Text style={{ color: "#6B7280" }}>No items available</Text>
        )}
      </View>
    </View>
  );
}

// ----- Styles -----
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#F9FAFB" },
  header: { flexDirection: "row", alignItems: "center", padding: 24 },
  headerIcon: { width: 50, height: 50, borderRadius: 12, justifyContent: "center", alignItems: "center" },
  headerTitle: { fontSize: 26, fontWeight: "700", marginLeft: 12, color: "#111827" },
  daySelector: { paddingHorizontal: 24, marginBottom: 16 },
  dayButton: {
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 20,
    marginRight: 10,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: "#fff",
  },
  dayButtonText: { fontWeight: "600", color: "#6B7280" },
  menuContainer: { paddingHorizontal: 24, paddingBottom: 24 },
  dayTitle: { fontSize: 20, fontWeight: "700", marginBottom: 16, color: "#111827" },
  mealCard: {
    backgroundColor: "#fff",
    borderRadius: 20,
    padding: 15,
    marginBottom: 16,
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 5,
  },
  mealHeader: { flexDirection: "row", alignItems: "center", marginBottom: 10 },
  mealIcon: { width: 45, height: 45, borderRadius: 12, justifyContent: "center", alignItems: "center" },
  mealInfo: { marginLeft: 16, flex: 1 },
  mealTitle: { fontSize: 18, fontWeight: "700", color: "#111827" },
  timeContainer: { flexDirection: "row", alignItems: "center", marginTop: 4 },
  mealTime: { marginLeft: 6, fontSize: 14, color: "#6B7280" },
  itemsContainer: { marginLeft: 1 },
  menuItemCard: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 12,
    marginBottom: 4,
  },
  foodImage: {
    width: 55,
    height: 45,
    borderRadius: 10,
    marginRight: 12,
  },
  foodPlaceholder: {
    width: 50,
    height: 50,
    borderRadius: 10,
    marginRight: 12,
    backgroundColor: "#E5E7EB",
  },
  itemText: { fontSize: 15, fontWeight: "400", color: "#111827" },
  priceText: { fontSize: 13, color: "#6B7280", marginTop: 2 ,marginLeft:10 },
  loadingContainer: { marginTop: 60, alignItems: "center" },
});
