import * as ImagePicker from "expo-image-picker";
import { LinearGradient } from "expo-linear-gradient";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    FlatList,
    Image,
    KeyboardAvoidingView,
    Modal,
    Platform,
    SafeAreaView,
    ScrollView,
    Switch,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";

const API_BASE = "URL_Backend/admin";

const hardwareTypes = ["cpu", "gpu", "psu", "motherboard", "ram", "storage"] as const;
type HardwareType = typeof hardwareTypes[number];

const fieldMap: Record<HardwareType, any[]> = {
  cpu: [
    { key: "name" },
    { key: "brand" },
    { key: "model" },
    { key: "socket" },
    { key: "cores", type: "number" },
    { key: "threads", type: "number" },
    { key: "base_clock", type: "number" },
    { key: "boost_clock", type: "number" },
    { key: "tdp", type: "number" },
    { key: "ram_type" },
    { key: "performance_score", type: "number" },
    { key: "image_url" },
  ],
  gpu: [
    { key: "name" },
    { key: "brand" },
    { key: "vram", type: "number" },
    { key: "tdp", type: "number" },
    { key: "pcie_version" },
    { key: "performance_score", type: "number" },
    { key: "price", type: "number" },
    { key: "length_mm", type: "number" },
    { key: "image_url" },
  ],
  psu: [
    { key: "name" },
    { key: "wattage", type: "number" },
    { key: "efficiency_rating" },
    { key: "modularity" },
    { key: "connector_6_pin", type: "boolean" },
    { key: "connector_8_pin", type: "boolean" },
    { key: "connector_12_pin", type: "boolean" },
    { key: "price", type: "number" },
    { key: "image_url" },
  ],
  motherboard: [
    { key: "name" },
    { key: "brand" },
    { key: "chipset" },
    { key: "cpu_socket" },
    { key: "ram_type" },
    { key: "max_ram_capacity", type: "number" },
    { key: "ram_slots", type: "number" },
    { key: "pcie_version" },
    { key: "form_factor" },
    { key: "sata_ports", type: "number" },
    { key: "m2_slots", type: "number" },
    { key: "price", type: "number" },
    { key: "image_url" },
  ],
  ram: [
    { key: "name" },
    { key: "brand" },
    { key: "type" },
    { key: "speed", type: "number" },
    { key: "capacity", type: "number" },
    { key: "modules", type: "number" },
    { key: "price", type: "number" },
    { key: "image_url" },
  ],
  storage: [
    { key: "name" },
    { key: "brand" },
    { key: "type" },
    { key: "capacity", type: "number" },
    { key: "read_speed", type: "number" },
    { key: "write_speed", type: "number" },
    { key: "interface" },
    { key: "price", type: "number" },
    { key: "image_url" },
  ],
};

export default function HardwareSection({ theme }: { theme: any }) {
  const [selectedType, setSelectedType] = useState<HardwareType>("cpu");
  const [data, setData] = useState<any[]>([]);
  const [form, setForm] = useState<Record<string, any>>({});
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [showAddModal, setShowAddModal] = useState(false);

  useEffect(() => {
    fetchData(selectedType);
  }, [selectedType]);

  const fetchData = async (type: HardwareType) => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/get/${type}`);
      const json = await res.json();
      setData(Array.isArray(json) ? json : []);
    } catch {
      Alert.alert("Error", "Failed to load components.");
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (key: string, val: any) =>
    setForm((p) => ({ ...p, [key]: val }));

  const pickImage = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== "granted") {
      Alert.alert("Permission required", "We need permission to access your photos.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });

    if (!result.canceled && result.assets.length > 0) {
      const asset = result.assets[0];
      handleInputChange("image", {
        uri: asset.uri,
        name: asset.uri.split("/").pop(),
        type: "image/jpeg",
      });
    }
  };

  const handleSubmit = async () => {
    if (!form.name) {
      Alert.alert("Error", "Please fill in required fields.");
      return;
    }

    const formData = new FormData();
    Object.entries(form).forEach(([key, value]) => {
      if (key === "image" && value) {
        formData.append("image", value as any);
      } else {
        formData.append(key, String(value));
      }
    });

    try {
      const res = await fetch(`${API_BASE}/add/${selectedType}`, {
        method: "POST",
        body: formData,
      });
      const json = await res.json();

      if (res.ok) {
        Alert.alert("Success", `${selectedType.toUpperCase()} added successfully!`);
        setForm({});
        setShowAddModal(false);
        fetchData(selectedType);
      } else {
        Alert.alert("Failed", json.message || "Add failed.");
      }
    } catch (err) {
      console.error(err);
      Alert.alert("Error", "Network issue occurred.");
    }
  };

  const filtered = data.filter((item) =>
    Object.values(item)
      .join(" ")
      .toLowerCase()
      .includes(searchQuery.toLowerCase())
  );

  const briefFields = (item: any) => {
    switch (selectedType) {
      case "cpu":
        return `Cores: ${item.cores} | Threads: ${item.threads}`;
      case "gpu":
        return `VRAM: ${item.vram}GB | TDP: ${item.tdp}W`;
      case "psu":
        return `Wattage: ${item.wattage}W | Efficiency: ${item.efficiency_rating}`;
      case "motherboard":
        return `Socket: ${item.cpu_socket} | RAM: ${item.ram_type}`;
      case "ram":
        return `${item.capacity}GB x${item.modules} | ${item.speed}MHz`;
      case "storage":
        return `${item.capacity}GB | ${item.type}`;
      default:
        return "";
    }
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <LinearGradient
        colors={[theme.background, theme.cardBackground]}
        style={{ flex: 1, padding: 16 }}
      >
        <KeyboardAvoidingView
          style={{ flex: 1 }}
          behavior={Platform.OS === "ios" ? "padding" : undefined}
        >
          <Text
            style={{
              fontSize: 24,
              fontWeight: "700",
              color: theme.textPrimary,
              marginBottom: 16,
              marginTop: -10,
            }}
          >
            ⚙️ Hardware Manager
          </Text>

          <View style={{ flexDirection: "row", flexWrap: "wrap", marginBottom: 14 }}>
            {hardwareTypes.map((t) => (
              <TouchableOpacity
                key={t}
                onPress={() => setSelectedType(t)}
                style={{
                  paddingVertical: 8,
                  paddingHorizontal: 14,
                  borderRadius: 20,
                  backgroundColor:
                    selectedType === t ? theme.primary : theme.cardBackground,
                  marginRight: 8,
                  marginBottom: 8,
                  borderWidth: 1,
                  borderColor: theme.border,
                }}
              >
                <Text
                  style={{
                    color: selectedType === t ? "#fff" : theme.textPrimary,
                    fontWeight: "600",
                  }}
                >
                  {t.toUpperCase()}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <TextInput
            placeholder="🔍 Search components..."
            placeholderTextColor={theme.placeholder}
            style={{
              backgroundColor: theme.inputBackground,
              borderColor: theme.inputBorder,
              borderWidth: 1,
              borderRadius: 10,
              paddingHorizontal: 12,
              paddingVertical: 10,
              color: theme.textPrimary,
              marginBottom: 12,
            }}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />

          {loading ? (
            <ActivityIndicator size="large" color={theme.primary} />
          ) : (
            <FlatList
              data={filtered}
              keyExtractor={(item) => String(item.id || Math.random())}
              renderItem={({ item }) => (
                <TouchableOpacity
                  style={{
                    backgroundColor: theme.cardBackground,
                    borderRadius: 12,
                    padding: 12,
                    marginBottom: 10,
                    flexDirection: "row",
                    alignItems: "center",
                  }}
                  onPress={() => setSelectedItem(item)}
                >
                  {item.image_url && (
                    <Image
                      source={{ uri: item.image_url }}
                      style={{
                        width: 60,
                        height: 60,
                        borderRadius: 8,
                        marginRight: 10,
                      }}
                    />
                  )}
                  <View style={{ flex: 1 }}>
                    <Text
                      style={{
                        color: theme.textPrimary,
                        fontWeight: "700",
                        fontSize: 16,
                      }}
                    >
                      {item.name}
                    </Text>
                    <Text style={{ color: theme.textSecondary, marginTop: 2 }}>
                      {briefFields(item)}
                    </Text>
                  </View>
                </TouchableOpacity>
              )}
            />
          )}

          <TouchableOpacity
            style={{
              backgroundColor: theme.primary,
              paddingVertical: 12,
              borderRadius: 10,
              marginTop: 14,
              alignItems: "center",
            }}
            onPress={() => setShowAddModal(true)}
          >
            <Text style={{ color: "#fff", fontWeight: "700" }}>
              ➕ Add New {selectedType.toUpperCase()}
            </Text>
          </TouchableOpacity>

          <Modal
            visible={!!selectedItem}
            transparent
            animationType="slide"
            onRequestClose={() => setSelectedItem(null)}
          >
            <View
              style={{
                flex: 1,
                backgroundColor: "rgba(0,0,0,0.6)",
                justifyContent: "center",
                padding: 20,
              }}
            >
              <ScrollView
                style={{
                  backgroundColor: theme.cardBackground,
                  borderRadius: 14,
                  padding: 16,
                }}
              >
                <Text
                  style={{
                    fontSize: 20,
                    fontWeight: "700",
                    color: theme.textPrimary,
                    marginBottom: 10,
                  }}
                >
                  Details
                </Text>

                {selectedItem?.image_url && (
                  <Image
                    source={{ uri: selectedItem.image_url }}
                    style={{
                      width: "100%",
                      height: 200,
                      borderRadius: 12,
                      marginBottom: 12,
                    }}
                  />
                )}

                {selectedItem &&
                  Object.entries(selectedItem).map(([k, v]) =>
                    k !== "image_url" ? (
                      <Text key={k} style={{ color: theme.textPrimary, marginBottom: 6 }}>
                        <Text style={{ fontWeight: "700" }}>{k}:</Text> {String(v)}
                      </Text>
                    ) : null
                  )}

                <TouchableOpacity
                  onPress={() => setSelectedItem(null)}
                  style={{
                    backgroundColor: theme.primary,
                    paddingVertical: 10,
                    borderRadius: 10,
                    marginTop: 16,
                    alignItems: "center",
                  }}
                >
                  <Text style={{ color: "#fff", fontWeight: "700" }}>Close</Text>
                </TouchableOpacity>
              </ScrollView>
            </View>
          </Modal>

          <Modal
            visible={showAddModal}
            transparent
            animationType="slide"
            onRequestClose={() => setShowAddModal(false)}
          >
            <View
              style={{
                flex: 1,
                backgroundColor: "rgba(0,0,0,0.6)",
                justifyContent: "center",
                padding: 20,
              }}
            >
              <ScrollView
                style={{
                  backgroundColor: theme.cardBackground,
                  borderRadius: 14,
                  padding: 16,
                }}
              >
                <Text
                  style={{
                    fontSize: 20,
                    fontWeight: "700",
                    color: theme.textPrimary,
                    marginBottom: 10,
                  }}
                >
                  Add New {selectedType.toUpperCase()}
                </Text>

                {fieldMap[selectedType].map((field) =>
                  field.key === "image_url" ? (
                    <View key="image_url" style={{ marginVertical: 10 }}>
                      <TouchableOpacity
                        style={{
                          backgroundColor: theme.primary,
                          paddingVertical: 10,
                          borderRadius: 10,
                          alignItems: "center",
                        }}
                        onPress={pickImage}
                      >
                        <Text style={{ color: "#fff", fontWeight: "700" }}>
                          {form.image ? "Change Image" : "Select Image"}
                        </Text>
                      </TouchableOpacity>
                      {form.image && (
                        <Image
                          source={{ uri: form.image.uri }}
                          style={{
                            width: "100%",
                            height: 200,
                            borderRadius: 12,
                            marginTop: 10,
                          }}
                        />
                      )}
                    </View>
                  ) : field.type === "boolean" ? (
                    <View
                      key={field.key}
                      style={{
                        flexDirection: "row",
                        justifyContent: "space-between",
                        alignItems: "center",
                        marginVertical: 8,
                      }}
                    >
                      <Text style={{ color: theme.textPrimary }}>{field.key}</Text>
                      <Switch
                        value={!!form[field.key]}
                        onValueChange={(v) => handleInputChange(field.key, v)}
                        thumbColor={theme.primary}
                      />
                    </View>
                  ) : (
                    <TextInput
                      key={field.key}
                      placeholder={field.key}
                      placeholderTextColor={theme.placeholder}
                      keyboardType={field.type === "number" ? "numeric" : "default"}
                      style={{
                        backgroundColor: theme.inputBackground,
                        color: theme.textPrimary,
                        borderColor: theme.inputBorder,
                        borderWidth: 1,
                        borderRadius: 10,
                        paddingHorizontal: 12,
                        paddingVertical: 10,
                        marginBottom: 10,
                      }}
                      value={form[field.key] ? String(form[field.key]) : ""}
                      onChangeText={(t) =>
                        handleInputChange(
                          field.key,
                          field.type === "number" ? Number(t) : t
                        )
                      }
                    />
                  )
                )}

                <TouchableOpacity
                  style={{
                    backgroundColor: theme.primary,
                    paddingVertical: 10,
                    borderRadius: 10,
                    marginTop: 12,
                    alignItems: "center",
                  }}
                  onPress={handleSubmit}
                >
                  <Text style={{ color: "#fff", fontWeight: "700" }}>Save</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={{
                    backgroundColor: "#ccc",
                    paddingVertical: 10,
                    borderRadius: 10,
                    marginTop: 10,
                    alignItems: "center",
                  }}
                  onPress={() => setShowAddModal(false)}
                >
                  <Text style={{ color: "#000", fontWeight: "700" }}>Cancel</Text>
                </TouchableOpacity>
              </ScrollView>
            </View>
          </Modal>
        </KeyboardAvoidingView>
      </LinearGradient>
    </SafeAreaView>
  );
}
