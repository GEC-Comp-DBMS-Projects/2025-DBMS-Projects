import React, { useState, useEffect } from "react";
import {
  Modal,
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Dimensions,
  Platform,
} from "react-native";
import { MotiView } from "moti";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Easing } from "react-native-reanimated";
import { SafeAreaView } from "react-native-safe-area-context";
import MaterialCommunityIcons from "react-native-vector-icons/MaterialCommunityIcons";
import Svg, { Rect, Text as SvgText, Defs, LinearGradient, Stop, Line } from "react-native-svg";
import ConfettiCannon from "react-native-confetti-cannon";
import { DollarSign, Clock, CircleCheck as CheckCircle } from "lucide-react-native";
import AlertModal from "@/components/AlertModal";

export default function HomeScreen() {
  const [mealStatus, setMealStatus] = useState({ breakfast: false, lunch: false, dinner: false });
  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState<"success" | "error" | "warning">("success");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");
  const [announcements, setAnnouncements] = useState<any[]>([]);
  const [hasTodayAnnouncement, setHasTodayAnnouncement] = useState(false);
  const [expenseSummary, setExpenseSummary] = useState<{
    today: number;
    week: number;
    month: number;
    year: number;
  } | null>(null);
  const [messAttendance, setMessAttendance] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);
  const [activeModal, setActiveModal] = useState<null | "notice" | "expense">(null);
  const [weeklyData, setWeeklyData] = useState<number[]>([]);
  const [user, setUser] = useState<{ user_id: number; full_name: string } | null>(null);

  const showAlert = (type: "success" | "error" | "warning", title: string, message: string) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  const currentDate = new Date().toLocaleDateString("en-US", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
  
   const MEAL_THEME = {
  breakfast: {
    icon: "white-balance-sunny",
    bg: "#FFF7ED",
    border: "#FDBA74",
    fg: "#9A3412",
    pill: "rgba(251,146,60,0.16)",
  },
  lunch: {
    icon: "silverware-fork-knife",
    bg: "#ECFEFF",
    border: "#67E8F9",
    fg: "#155E75",
    pill: "rgba(14,165,233,0.16)",
  },
  dinner: {
    icon: "weather-night",
    bg: "#F5F3FF",
    border: "#C7D2FE",
    fg: "#4338CA",
    pill: "rgba(79,70,229,0.16)",
  },
} as const;

  const presentPercent = messAttendance ? 88 : 60;
  const radius = 60;
  const strokeWidth = 12;

  const screenWidth = Dimensions.get("window").width;
  const days = ["M", "T", "W", "T", "F", "S", "S"];
  const chartHeight = 150;
  const maxValue = 3;

const [mealItems, setMealItems] = useState<{
  breakfast: { name: string; price: number; image_url?: string }[];
  lunch: { name: string; price: number; image_url?: string }[];
  dinner: { name: string; price: number; image_url?: string }[];
}>({ breakfast: [], lunch: [], dinner: [] });


  const cutoffTimes = {
    breakfast: { hour: 8, minute: 0 },
    lunch: { hour: 13, minute: 15 },
    dinner: { hour: 20, minute: 0 },
  };

  const getNextMeal = () => {
    const now = new Date();
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    const breakfastCutoff = cutoffTimes.breakfast.hour * 60 + cutoffTimes.breakfast.minute;
    const lunchCutoff = cutoffTimes.lunch.hour * 60 + cutoffTimes.lunch.minute;
    const dinnerCutoff = cutoffTimes.dinner.hour * 60 + cutoffTimes.dinner.minute;

    if (currentMinutes < breakfastCutoff) return "breakfast";
    if (currentMinutes < lunchCutoff) return "lunch";
    if (currentMinutes < dinnerCutoff) return "dinner";
    return null;
  };

  const formatDate = (date: Date) => {
    const options: Intl.DateTimeFormatOptions = { month: "short", day: "numeric" };
    return date.toLocaleDateString("en-US", options);
  };

  const getWeekRange = () => {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const monday = new Date(now);
    monday.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    return `${formatDate(monday)} - ${formatDate(sunday)}`;
  };

  const markMeal = async (meal: "breakfast" | "lunch" | "dinner") => {
    const token = await AsyncStorage.getItem("token");
    if (!token) return;

    try {
      const totalAmount = mealItems[meal].reduce((sum, item) => sum + Number(item.price), 0);

      const response = await fetch("http://10.246.134.45:5000/dashboard/attendance/mark", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ meal, amount: totalAmount }),
      });

      const data = await response.json();
      if (response.ok) {
        setMealStatus((prev) => ({ ...prev, [meal]: true }));
        showAlert("success", "Attendance Marked", `₹${totalAmount} added for ${meal}`);
        fetchWeekly();
      } else {
        showAlert("error", "Error", data.error || "Could not mark attendance");
      }
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const storedUser = await AsyncStorage.getItem("user");
        if (storedUser) setUser(JSON.parse(storedUser));

        const token = await AsyncStorage.getItem("token");
        if (!token) return;

        const response = await fetch("http://10.246.134.45:5000/profile", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await response.json();

        if (response.ok && data.user) {
          setUser(data.user);
        }
      } catch (err) {
        console.error("Error fetching user:", err);
      }
    };

    fetchUser();
  }, []);

  useEffect(() => {
    const fetchAttendance = async () => {
      const token = await AsyncStorage.getItem("token");
      if (!token) return;

      try {
        const response = await fetch("http://10.246.134.45:5000/dashboard/attendance/today", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await response.json();

        if (response.ok) {
          setMealStatus({
            breakfast: !!data.breakfast,
            lunch: !!data.lunch,
            dinner: !!data.dinner,
          });
        }
      } catch (err) {
        console.error(err);
      }
    };

    fetchAttendance();
  }, []);

  useEffect(() => {
    const fetchAnnouncements = async () => {
      try {
        const response = await fetch("http://10.246.134.45:5000/announcements");
        const data = await response.json();
        if (response.ok || response.status === 200) {
          setAnnouncements(data);

          const today = new Date();
          const todayAnnouncements = data.filter((a: any) => {
            const created = new Date(a.created_at);
            return (
              created.getFullYear() === today.getFullYear() &&
              created.getMonth() === today.getMonth() &&
              created.getDate() === today.getDate()
            );
          });
          setHasTodayAnnouncement(todayAnnouncements.length > 0);
        }
      } catch (err) {
        console.error("Error fetching announcements:", err);
      }
    };

    fetchAnnouncements();
    const interval = setInterval(fetchAnnouncements, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchExpenseSummary = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      const storedUser = await AsyncStorage.getItem("user");
      if (!token || !storedUser) return;

      const u = JSON.parse(storedUser);
      const response = await fetch(`http://10.246.134.45:5000/expense/summary/${u.id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await response.json();
      if (response.ok) setExpenseSummary(data);
    } catch (err) {
      console.error("Error fetching expense summary:", err);
    }
  };

  useEffect(() => {
    if (activeModal === "expense") {
      fetchExpenseSummary();
    }
  }, [activeModal]);

  const fetchWeekly = async () => {
    const token = await AsyncStorage.getItem("token");
    if (!token) return;

    try {
      const response = await fetch("http://10.246.134.45:5000/dashboard/weekly-attendance", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await response.json();
      if (response.ok) {
        setWeeklyData(data.weeklyData);
      }
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchWeekly();
  }, []);

  useEffect(() => {
    const fetchTodayMeals = async () => {
      const token = await AsyncStorage.getItem("token");
      if (!token) return;

      try {
        const response = await fetch("http://10.246.134.45:5000/dashboard/today-meal", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await response.json();
        if (response.ok) {
          setMealItems(data.mealItems);
        }
      } catch (err) {
        console.error(err);
      }
    };

    fetchTodayMeals();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <AlertModal
        visible={alertVisible}
        type={alertType}
        title={alertTitle}
        message={alertMessage}
        onClose={() => setAlertVisible(false)}
      />

      {/* Header */}


      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 20 }}>
        <View style={styles.header}>
            <View>
              <Text style={styles.welcomeText}>Good Evening,</Text>
              <Text style={styles.userName}>{user?.full_name || "Resident"}</Text>
            </View>
            <View style={styles.headerRight}>
              <Text style={styles.dateText}>{currentDate}</Text>
              <MaterialCommunityIcons name="account-circle" size={38} color="#0EA5E9" />
            </View>
        </View>
        {/* Quick actions */}
        <View style={styles.row}>
          
          <TouchableOpacity style={[styles.cardButton, styles.cardElevated]} onPress={() => setActiveModal("notice")}>
            {hasTodayAnnouncement && (
              <View style={styles.badgeNB}>
                <Text style={styles.badgeTextNB}>!</Text>
              </View>
            )}
            <View style={styles.iconPill}>
              <MaterialCommunityIcons name="bullhorn" size={22} color="#F97316" />
            </View>
            <Text style={styles.cardLabel}>Notice Board</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.cardButton, styles.cardElevated]} onPress={() => setActiveModal("expense")}>
            <View style={[styles.iconPill, { backgroundColor: "rgba(34,197,94,0.12)" }]}>
              <DollarSign size={22} color="#22C55E" />
            </View>
            <Text style={styles.cardLabel}>Expense</Text>
          </TouchableOpacity>
        </View>

        {/* Attendance + Menu */}
        <View style={styles.attendanceMealsRow}>
          {/* Menu */}
             <View style={[styles.mealCard, styles.cardElevated]}>
                    <View style={styles.cardTitleRow}>
                      <Image source={require("../../assets/images/logo.png")} style={styles.menuLogo} />
                      <Text style={styles.cardTitle}>
                        {(getNextMeal()
                          ? getNextMeal()!.charAt(0).toUpperCase() + getNextMeal()!.slice(1)
                          : "Meal") + " Menu"}
                      </Text>
                    </View>


                    {(mealItems[getNextMeal() as "breakfast" | "lunch" | "dinner"] || []).length > 0 ? (
                      (mealItems[getNextMeal() as "breakfast" | "lunch" | "dinner"] || []).map((item, index) => (
                        <View key={index} style={styles.mealItemRow}>
                          {item.image_url ? (
                            <Image
                              source={{ uri: item.image_url }}
                              style={styles.mealItemImage}
                            />
                          ) : (
                            <View style={styles.mealItemPlaceholder} />
                          )}
                          <View style={{ flex: 1, flexDirection: "row", justifyContent: "space-between", alignItems: "center" }}>
                            <Text style={styles.mealItemName}>{item.name}</Text>
                          </View>
                        </View>
                      ))
                    ) : (
                      <View style={styles.skeletonGroup}>
                        <View style={[styles.skeletonLine, { width: "85%" }]} />
                        <View style={[styles.skeletonLine, { width: "70%" }]} />
                        <View style={[styles.skeletonLine, { width: "60%" }]} />
                      </View>
                    )}

           </View>



          {/* Mark Attendance */}
          
          <View style={[styles.mealColumn]}>
            <Text style={styles.mealLabel}>Mark Attendance</Text>

            {["breakfast", "lunch", "dinner"].map((meal, index) => {
              const theme = MEAL_THEME[meal as "breakfast" | "lunch" | "dinner"];
              const marked = mealStatus[meal as "breakfast" | "lunch" | "dinner"];

              return (
                <MotiView
                  key={meal}
                  from={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{
                    type: "timing",
                    duration: 400,
                    delay: 100 * index, // staggered effect
                    easing: Easing.out(Easing.ease),
                  }}
                  style={styles.attendanceBtnShadowContainer}
                >
                  <TouchableOpacity
                    disabled={marked}
                    activeOpacity={0.8}
                    onPress={() => {
                      if (!marked) markMeal(meal as any);
                      else
                        showAlert(
                          "warning",
                          "Already Marked",
                          `You've already marked attendance for ${meal}.`
                        );
                    }}
                    style={[
                      styles.attendanceBtn,
                      { backgroundColor: theme.bg, borderColor: marked ? "#22C55E" : theme.border },
                      marked && styles.attendanceBtnMarked,styles.cardElevated
                    ]}
                  >
                    <View style={styles.attendanceBtnContent}>
                      <View style={[styles.attendanceIconPill, { backgroundColor: theme.pill }]}>
                        <MaterialCommunityIcons name={theme.icon} size={18} color={theme.fg} />
                      </View>

                      <View style={styles.attendanceTextCol}>
                        <Text style={[styles.attendanceTitle, { color: theme.fg }]}>
                          {meal.charAt(0).toUpperCase() + meal.slice(1)}
                        </Text>
                        <Text style={styles.attendanceHint}>
                          {marked ? "Already marked" : "Tap to mark"}
                        </Text>
                      </View>

                      {marked && (
                        <View style={styles.attendanceCheck}>
                          <CheckCircle size={18} color="#22C55E" />
                        </View>
                      )}
                    </View>
                  </TouchableOpacity>
                </MotiView>
              );
            })}

          </View>


        </View>

        {/* Next Meal */}
        <View style={[styles.card, styles.cardElevated]}>
          <View style={styles.summaryRow}>
            <View style={styles.summaryIconRow}>
              <View style={[styles.iconPill, { backgroundColor: "rgba(14,165,233,0.12)" }]}>
                <Clock size={18} color="#0EA5E9" />
              </View>
              <Text style={styles.summaryLabel}>Next Meal</Text>
            </View>

            {getNextMeal() ? (
              <Text style={styles.summaryValue}>
                {getNextMeal() === "breakfast"
                  ? "Breakfast - 8:30 AM"
                  : getNextMeal() === "lunch"
                  ? "Lunch - 1:45 PM"
                  : "Dinner - 8:30 PM"}
              </Text>
            ) : (
              <Text style={styles.summaryValue}>All meals done</Text>
            )}
          </View>

          {getNextMeal() ? (
            mealStatus[getNextMeal() as "breakfast" | "lunch" | "dinner"] ? (
              <Text style={[styles.attendanceNote, { color: "#22C55E", fontWeight: "700" }]}>✅ Attendance marked</Text>
            ) : (
              <Text style={styles.attendanceNote}>
                Mark your attendance before{" "}
                <Text style={{ fontWeight: "700", color: "#EF4444" }}>
                  {getNextMeal() === "breakfast" ? "8:00 AM" : getNextMeal() === "lunch" ? "1:15 PM" : "8:00 PM"}
                </Text>
              </Text>
            )
          ) : (
            <Text style={styles.attendanceNote}>No upcoming meals today</Text>
          )}
        </View>

        {/* Weekly Overview */}
        <View style={[styles.cardweekly, styles.cardElevated]}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Weekly Overview</Text>
            <Text style={styles.dateText}>{getWeekRange()}</Text>
          </View>

          <View style={styles.chartContainer}>
            <Svg height={chartHeight + 40} width={screenWidth - 60}>
              <Defs>
                <LinearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                  <Stop offset="0%" stopColor="#0EA5E9" stopOpacity="0.9" />
                  <Stop offset="100%" stopColor="#0EA5E9" stopOpacity="0.4" />
                </LinearGradient>
              </Defs>

              {[1, 2, 3].map((i) => (
                <Line
                  key={i}
                  x1={0}
                  y1={chartHeight - (i / maxValue) * chartHeight}
                  x2={screenWidth - 60}
                  y2={chartHeight - (i / maxValue) * chartHeight}
                  stroke="#E5E7EB"
                  strokeWidth={1}
                />
              ))}

              {weeklyData.map((value, index) => {
                const totalBars = weeklyData.length || 7;
                const availableWidth = screenWidth - 100;
                const spacing = availableWidth / totalBars;
                const barX = index * spacing + spacing / 4;
                const barHeight = (value / maxValue) * chartHeight;
                const barY = chartHeight - barHeight;
                const isPeak = value === maxValue;

                return (
                  <Rect
                    key={index}
                    x={barX}
                    y={barY}
                    width={spacing / 2}
                    height={barHeight}
                    fill={isPeak ? "#F97316" : "url(#barGradient)"}
                    rx={6}
                  />
                );
              })}

              {days.map((day, index) => {
                const totalBars = weeklyData.length || 7;
                const availableWidth = screenWidth - 100;
                const spacing = availableWidth / totalBars;
                const centerX = index * spacing + spacing / 2;
                return (
                  <SvgText key={index} x={centerX} y={chartHeight + 20} fill="#6B7280" fontSize={12} textAnchor="middle">
                    {day}
                  </SvgText>
                );
              })}

              {weeklyData.map((value, index) => {
                const totalBars = weeklyData.length || 7;
                const availableWidth = screenWidth - 100;
                const spacing = availableWidth / totalBars;
                const centerX = index * spacing + spacing / 2;
                return (
                  <SvgText
                    key={index}
                    x={centerX}
                    y={chartHeight - (value / maxValue) * chartHeight - 6}
                    fill="#111827"
                    fontSize={11}
                    fontWeight="600"
                    textAnchor="middle"
                  >
                    {value}
                  </SvgText>
                );
              })}
            </Svg>
          </View>
        </View>
      </ScrollView>

      {showConfetti && <ConfettiCannon count={150} origin={{ x: 200, y: -10 }} fadeOut />}

      {/* Modals */}
      <Modal transparent={true} visible={activeModal !== null} onRequestClose={() => setActiveModal(null)}>
        <View style={styles.modalBackground}>
          <MotiView
            from={{ scale: 0.96, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.96, opacity: 0 }}
            transition={{ type: "timing", duration: 220, easing: Easing.out(Easing.ease) }}
            style={[styles.modalContainer, styles.cardElevated]}
          >
            {activeModal === "notice" && (
              <>
                <Text style={styles.modalTitle}>📢 Announcement</Text>
                {announcements.length === 0 || !hasTodayAnnouncement ? (
                  <Text style={styles.modalMessage}>No announcements today</Text>
                ) : (
                  announcements
                    .filter((a) => {
                      const today = new Date();
                      const created = new Date(a.created_at);
                      return (
                        created.getFullYear() === today.getFullYear() &&
                        created.getMonth() === today.getMonth() &&
                        created.getDate() === today.getDate()
                      );
                    })
                    .map((a, idx) => (
                      <Text key={idx} style={styles.modalMessage}>
                        {a.title}: {a.content}
                      </Text>
                    ))
                )}
              </>
            )}

            {activeModal === "expense" && (
              <>
                <Text style={styles.modalTitle}>💰 Expense Summary</Text>
                {expenseSummary ? (
                  <>
                    <Text style={styles.modalMessage}>Today: ₹{expenseSummary.today}</Text>
                    <Text style={styles.modalMessage}>This Week: ₹{expenseSummary.week}</Text>
                    <Text style={styles.modalMessage}>This Month: ₹{expenseSummary.month}</Text>
                    <Text style={styles.modalMessage}>This Year: ₹{expenseSummary.year}</Text>
                  </>
                ) : (
                  <Text style={styles.modalMessage}>Loading summary...</Text>
                )}
              </>
            )}

            <TouchableOpacity style={styles.closeButton} onPress={() => setActiveModal(null)}>
              <Text style={styles.closeText}>Close</Text>
            </TouchableOpacity>
          </MotiView>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  // App surfaces
  container: {
    flex: 1,
    backgroundColor: "#F7F8FA",
  },
  scrollView: {
    flex: 1,
  },

  // Header
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 14,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    backgroundColor: "#FFFFFF",
    borderBottomLeftRadius: 18,
    borderBottomRightRadius: 18,
    ...Platform.select({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.08,
        shadowRadius: 12,
      },
      android: { elevation: 6 },
    }),
  },
  headerRight: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  welcomeText: {
    fontSize: 14,
    fontWeight: "500",
    color: "#6B7280",
    marginBottom: -2,
  },
  userName: {
    fontSize: 20,
    fontWeight: "700",
    color: "#0F172A",
  },
  dateText: {
    fontSize: 13,
    color: "#9CA3AF",
    fontWeight: "500",
    marginRight: 6,
  },

  // Cards base
  cardElevated: {
    backgroundColor: "#FFFFFF",
    borderRadius: 16,
    ...Platform.select({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.07,
        shadowRadius: 10,
      },
      android: { elevation: 4 },
    }),
  },

  // Quick actions
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 12,
    marginHorizontal: 20,
    marginTop: 16,
    marginBottom: 6,
  },
  cardButton: {
    flex: 1,
    paddingVertical: 16,
    paddingHorizontal: 14,
    alignItems: "center",
  },
  iconPill: {
    paddingHorizontal: 10,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: "rgba(249,115,22,0.12)",
  },
  cardLabel: {
    marginTop: 8,
    fontSize: 14,
    fontWeight: "700",
    color: "#0F172A",
  },
  badgeNB: {
    position: "absolute",
    top: -6,
    right: -4,
    backgroundColor: "#EF4444",
    borderRadius: 10,
    minWidth: 18,
    height: 18,
    justifyContent: "center",
    alignItems: "center",
    zIndex: 1,
  },
  badgeTextNB: {
    color: "white",
    fontSize: 10,
    fontWeight: "bold",
  },

  // Attendance + Menu layout
  attendanceMealsRow: {
    flexDirection: "row",
    gap: 12,
    marginHorizontal: 20,
    marginTop: 12,
    marginBottom: 12,
    alignItems: "stretch",
  },

  // Menu card
  mealCard: {
    flex: 1.1,
    padding: 16,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: "700",
    color: "#0F172A",
    marginBottom: 8,
  },
  cardSubtitle: {
    fontSize: 12,
    color: "#6B7280",
    marginTop: 4,
  },
  // Attendance column
  mealColumn: {
    flex: 0.9,
    alignItems: "center",
    justifyContent: "flex-start",
  },
  mealLabel: {
    fontSize: 15,
    fontWeight: "800",
    color: "#0F172A",
    marginBottom: 8,
    textAlign: "center",
  },
  mealCardSmall: {
    width: "100%",
    height: 84,
    borderRadius: 14,
    overflow: "hidden",
    marginBottom: 10,
    backgroundColor: "#F3F4F6",
  },
  mealBackground: {
    width: "100%",
    height: "100%",
    position: "absolute",
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.25)",
  },
  overlayContent: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  mealText: {
    fontSize: 13,
    fontWeight: "800",
    color: "#FFFFFF",
    textShadowColor: "rgba(0,0,0,0.6)",
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
    letterSpacing: 0.2,
  },
  checkBadge: {
    position: "absolute",
    top: 8,
    right: 8,
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    padding: 4,
    ...Platform.select({
      ios: {
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
      },
      android: { elevation: 2 },
    }),
  },

  // Next meal
  card: {
    borderRadius: 16,
    paddingVertical: 14,
    paddingHorizontal: 16,
    marginHorizontal: 20,
    marginBottom: 14,
    backgroundColor: "#FFFFFF",
  },
  summaryRow: {
    gap: 6,
  },
  summaryIconRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  summaryLabel: {
    fontSize: 12,
    color: "#6B7280",
  },
  summaryValue: {
    fontSize: 15,
    fontWeight: "700",
    color: "#0F172A",
    marginTop: 2,
  },
  attendanceNote: {
    marginTop: 8,
    fontSize: 12,
    color: "#EF4444",
    fontWeight: "500",
  },

  // Weekly overview
  cardweekly: {
    borderRadius: 16,
    padding: 16,
    marginHorizontal: 20,
    marginBottom: 20,
    backgroundColor: "#FFFFFF",
  },
  cardHeader: {
    width: "100%",
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 8,
  },
  chartContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    width: "100%",
  },

  // Modal
  modalBackground: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.45)",
    paddingHorizontal: 20,
  },
  modalContainer: {
    width: "100%",
    maxWidth: 440,
    backgroundColor: "white",
    padding: 20,
    borderRadius: 16,
    alignItems: "center",
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 8,
    textAlign: "center",
    color: "#0F172A",
  },
  modalMessage: {
    fontSize: 15,
    textAlign: "center",
    marginBottom: 8,
    color: "#334155",
  },
  closeButton: {
    backgroundColor: "#0EA5E9",
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 10,
    marginTop: 10,
  },
  closeText: {
    color: "white",
    fontWeight: "800",
    letterSpacing: 0.3,
  },
  skeletonGroup: {
  gap: 10,
  paddingVertical: 6,
},
skeletonLine: {
  height: 12,
  borderRadius: 6,
  backgroundColor: "#E5E7EB",
},
cardTitleRow: {
  flexDirection: "row",
  alignItems: "center",
  gap: 8,
  marginBottom: 6,
},
menuLogo: {
  width: 18,
  height: 18,
  borderRadius: 4,
},
// Attendance buttons
attendanceBtnShadowContainer: {
  marginBottom: 12,
  borderRadius: 16,
  ...Platform.select({
    ios: {
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.1,
      shadowRadius: 8,
      overflow: "visible", // ensures shadow renders outside rounded button
    },
    android: {
      // keep elevation on button itself
    },
  }),
},

attendanceBtn: {
  width: "100%",
  height: 60,
  borderRadius: 16,
  paddingHorizontal: 16,
  paddingVertical: 12,
  flexDirection: "row",
  alignItems: "center",
  justifyContent: "space-between",
},

attendanceBtnMarked: {
  borderColor: "#22C55E",
  opacity: 1,
},

attendanceBtnContent: {
  flexDirection: "row",
  alignItems: "center",
  justifyContent: "space-between",
  flex: 1,
},

attendanceIconPill: {
  width: 36,
  height: 36,
  borderRadius: 18,
  justifyContent: "center",
  alignItems: "center",
},

attendanceTextCol: {
  flex: 1,
  marginLeft: 12,
},

attendanceTitle: {
  fontSize: 14,
  fontWeight: "700",
},

attendanceHint: {
  fontSize: 12,
  color: "#9CA3AF",
  marginTop: 2,
},

attendanceCheck: {
  marginLeft: 8,
},
mealItemRow: {
  flexDirection: "row",
  alignItems: "center",
  paddingVertical: 6,
  borderBottomWidth: 0.5,
  borderBottomColor: "#E5E7EB",
},
mealItemImage: {
  width: 65,
  height: 45,
  borderRadius: 8,
  marginRight: 12,
},
mealItemPlaceholder: {
  width: 40,
  height: 40,
  borderRadius: 8,
  marginRight: 12,
  backgroundColor: "#E5E7EB",
},
mealItemName: {
  fontSize: 14,
  fontWeight: "500",
  color: "#6B7280",
},
// mealItemPrice: {
//   fontSize: 14,
//   color: "#6B7280",
// },

});
