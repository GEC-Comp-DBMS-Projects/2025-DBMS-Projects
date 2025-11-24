import React, { useEffect, useState } from "react";
import { View, Text, ScrollView, StyleSheet } from "react-native";
import { MotiView } from "moti";
import { Ionicons } from "@expo/vector-icons";
import axios from "axios";

const AttendanceCountModule = () => {
  const [counts, setCounts] = useState({ breakfast: 0, lunch: 0, dinner: 0 });
  const [emailStatus, setEmailStatus] = useState({
    breakfast: false,
    lunch: false,
    dinner: false,
  });

  useEffect(() => {
    const fetchAttendanceCounts = async () => {
      try {
        const res = await axios.get(
          "http://10.246.134.45:5000/api/admin/attendance/today-students"
        );
        setCounts({
          breakfast: res.data.breakfast.length,
          lunch: res.data.lunch.length,
          dinner: res.data.dinner.length,
        });
      } catch (err) {
        console.error("Error fetching attendance:", err);
      }
    };
    fetchAttendanceCounts();
  }, []);

  useEffect(() => {
    const fetchEmailStatus = async () => {
      try {
        const res = await axios.get(
          "http://10.246.134.45:5000/api/admin/attendance/email-status"
        );
        setEmailStatus(res.data);
      } catch (err) {
        console.error("Error fetching email status:", err);
      }
    };
    fetchEmailStatus();
    const interval = setInterval(fetchEmailStatus, 60000);
    return () => clearInterval(interval);
  }, []);

  const meals = [
    { name: "Breakfast", key: "breakfast", icon: "sunny", color: "#FFB347" },
    { name: "Lunch", key: "lunch", icon: "restaurant", color: "#FF7E5F" },
    { name: "Dinner", key: "dinner", icon: "moon", color: "#6B5B95" },
  ];

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.header}>Today's Attendance 📊</Text>
      {meals.map((meal, index) => (
        <MotiView
          key={meal.key}
          from={{ opacity: 0, translateX: -30 }}
          animate={{ opacity: 1, translateX: 0 }}
          transition={{ type: "timing", duration: 400, delay: index * 100 }}
          style={[styles.card, { borderLeftWidth: 4, borderLeftColor: meal.color }]}
        >
          <View style={styles.cardHeader}>
            <Ionicons name={meal.icon as any} size={28} color={meal.color} />
            <Text style={[styles.meal, { color: meal.color }]}>{meal.name}</Text>
          </View>
          <Text style={styles.count}>{counts[meal.key as keyof typeof counts]} students</Text>
          <View style={styles.statusRow}>
            <Ionicons
              name={emailStatus[meal.key as keyof typeof emailStatus] ? "checkmark-circle" : "time"}
              size={18}
              color={emailStatus[meal.key as keyof typeof emailStatus] ? "#34C759" : "#FF9500"}
            />
            <Text style={styles.statusText}>
              {emailStatus[meal.key as keyof typeof emailStatus] ? "Email Sent" : "Pending"}
            </Text>
          </View>
        </MotiView>
      ))}
    </ScrollView>
  );
};

export default AttendanceCountModule;

const styles = StyleSheet.create({
  container: { padding: 10 },
  header: {
    fontSize: 24,
    fontWeight: "700",
    marginBottom: 20,
    color: "#FF4500",
    textAlign: "center",
  },
  card: {
    backgroundColor: "rgba(255,255,255,0.95)",
    padding: 18,
    borderRadius: 18,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
  },
  cardHeader: { flexDirection: "row", alignItems: "center", marginBottom: 10, gap: 10 },
  meal: { fontSize: 20, fontWeight: "700" },
  count: { fontSize: 18, fontWeight: "600", color: "#333", marginBottom: 8 },
  statusRow: { flexDirection: "row", alignItems: "center", gap: 6 },
  statusText: { fontSize: 14, color: "#666", fontWeight: "500" },
});
