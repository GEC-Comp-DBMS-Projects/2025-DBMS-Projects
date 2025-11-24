import React, { useState, useEffect } from "react";
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, Modal } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView, MotiText } from "moti";
import { Ionicons } from "@expo/vector-icons";
import Checkbox from "expo-checkbox";
import { Picker } from "@react-native-picker/picker";
import axios from "axios";

// ✅ Alert Modal
function AlertModal({ visible, type, title, message, onClose }: any) {
  const getIcon = () => {
    switch (type) {
      case "success": return "checkmark-circle";
      case "error": return "close-circle";
      default: return "alert-circle";
    }
  };

  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.modalOverlay}>
        <MotiView
          from={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ type: "timing", duration: 300 }}
          style={styles.alertCard}
        >
          <Ionicons
            name={getIcon()}
            size={56}
            color={type === "success" ? "#34C759" : "#FF3B30"}
            style={{ marginBottom: 10 }}
          />
          <MotiText style={styles.alertTitle}>{title}</MotiText>
          <Text style={styles.alertMessage}>{message}</Text>
          <TouchableOpacity onPress={onClose} style={{ width: "100%", marginTop: 15 }}>
            <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.alertButton}>
              <Text style={styles.alertButtonText}>OK</Text>
            </LinearGradient>
          </TouchableOpacity>
        </MotiView>
      </View>
    </Modal>
  );
}

const AdminMenu: React.FC = () => {
  const days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
  const [selectedDay, setSelectedDay] = useState("monday");
  const [menu, setMenu] = useState<any>({ breakfast: [], lunch: [], dinner: [] });
  const [foodItems, setFoodItems] = useState<any[]>([]);

  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState("success");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");

  const showAlert = (type: string, title: string, message: string) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  useEffect(() => {
    fetchMenu(selectedDay);
  }, [selectedDay]);

  const fetchMenu = (day: string) => {
    axios
      .get(`http://10.246.134.45:5000/api/admin/menu/${day}`)
      .then((res) => {
        setMenu(res.data.menu);
        setFoodItems(res.data.foodItems);
      })
      .catch((err) => console.error(err));
  };

  const toggleSelection = (meal: string, food_id: number) => {
    setMenu((prev: any) => {
      const selected = prev[meal];
      return {
        ...prev,
        [meal]: selected.includes(food_id)
          ? selected.filter((id: number) => id !== food_id)
          : [...selected, food_id],
      };
    });
  };

  const saveMenu = (mealType: string, menu_id: number) => {
    const foodIds = menu[mealType];
    axios
      .post(`http://10.246.134.45:5000/api/admin/menu/${menu_id}`, { foodIds })
      .then(() => showAlert("success", "Saved!", `${mealType} menu saved successfully`))
      .catch(() => showAlert("error", "Error", "Failed to save menu"));
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <MotiView
        from={{ opacity: 0, translateY: 20 }}
        animate={{ opacity: 1, translateY: 0 }}
        transition={{ type: "timing", duration: 400 }}
        style={styles.pickerCard}
      >
        <Text style={styles.label}>Select Day:</Text>
        <View style={styles.pickerWrapper}>
          <Picker
            selectedValue={selectedDay}
            onValueChange={(value) => setSelectedDay(value)}
            style={styles.picker}
          >
            {days.map((day) => (
              <Picker.Item key={day} label={day.toUpperCase()} value={day} />
            ))}
          </Picker>
        </View>
      </MotiView>

      {["breakfast", "lunch", "dinner"].map((meal, index) => (
        <MotiView
          key={meal}
          from={{ opacity: 0, translateY: 30 }}
          animate={{ opacity: 1, translateY: 0 }}
          transition={{ type: "timing", duration: 400, delay: index * 100 }}
          style={styles.mealCard}
        >
          <Text style={styles.mealTitle}>{meal.toUpperCase()}</Text>
          {foodItems.map((item) => (
            <View key={item.food_id} style={styles.itemRow}>
              <Checkbox
                value={menu[meal]?.includes(item.food_id)}
                onValueChange={() => toggleSelection(meal, item.food_id)}
                color={menu[meal]?.includes(item.food_id) ? "#FF4500" : undefined}
              />
              <Text style={styles.itemText}>
                {item.name} (₹{item.price})
              </Text>
            </View>
          ))}
          <TouchableOpacity
            onPress={() => saveMenu(meal, menu[meal][0]?.menu_id || 1)}
            style={{ marginTop: 10 }}
          >
            <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.saveButton}>
              <Ionicons name="save-outline" size={18} color="#fff" />
              <Text style={styles.saveButtonText}>Save {meal}</Text>
            </LinearGradient>
          </TouchableOpacity>
        </MotiView>
      ))}

      <AlertModal
        visible={alertVisible}
        type={alertType}
        title={alertTitle}
        message={alertMessage}
        onClose={() => setAlertVisible(false)}
      />
    </ScrollView>
  );
};

export default AdminMenu;

const styles = StyleSheet.create({
  container: { flex: 1 },
  pickerCard: {
    backgroundColor: "rgba(255,255,255,0.95)",
    padding: 15,
    borderRadius: 18,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
  },
  label: { fontSize: 16, fontWeight: "600", marginBottom: 8, color: "#333" },
  pickerWrapper: {
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 10,
    overflow: "hidden",
    backgroundColor: "#fff",
  },
  picker: { height: 50 },
  mealCard: {
    backgroundColor: "rgba(255,255,255,0.95)",
    padding: 15,
    borderRadius: 18,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
  },
  mealTitle: { fontSize: 18, fontWeight: "700", marginBottom: 12, color: "#FF4500" },
  itemRow: { flexDirection: "row", alignItems: "center", marginVertical: 6 },
  itemText: { marginLeft: 10, fontSize: 14, color: "#333" },
  saveButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 12,
    borderRadius: 10,
    gap: 6,
  },
  saveButtonText: { color: "#fff", fontWeight: "600", fontSize: 15 },
  modalOverlay: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.35)",
  },
  alertCard: {
    width: "80%",
    backgroundColor: "#fff",
    borderRadius: 18,
    padding: 20,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.25,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 8,
    elevation: 10,
  },
  alertTitle: { fontSize: 18, fontWeight: "700", color: "#333", marginBottom: 6 },
  alertMessage: { fontSize: 14, color: "#666", textAlign: "center" },
  alertButton: { padding: 12, borderRadius: 10, alignItems: "center", width: "100%" },
  alertButtonText: { color: "#fff", fontWeight: "bold", fontSize: 16 },
});

