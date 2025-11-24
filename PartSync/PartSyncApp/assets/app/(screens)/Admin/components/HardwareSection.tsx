import * as ImagePicker from "expo-image-picker";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    FlatList,
    Image,
    Modal,
    ScrollView,
    Switch,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { styles } from "./adminStyles";

const API_BASE = "http://10.102.232.54:5000/admin";

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
      Alert.alert("Error", "Please enter required fields.");
      return;
    }

    const formData = new FormData();
    Object.entries(form).forEach(([key, value]) => {
      if (key === "image" && value) {
        formData.append("image", {
          uri: value.uri,
          name: value.name,
          type: value.type,
        } as any);
      } else {
        formData.append(key, String(value));
      }
    });

    try {
      const res = await fetch(`${API_BASE}/add/${selectedType}`, {
        method: "POST",
        body: formData,
        headers: { "Content-Type": "multipart/form-data" },
      });

      const json = await res.json();
      if (res.ok) {
        Alert.alert("Success", `${selectedType.toUpperCase()} added.`);
        setForm({});
        setShowAddModal(false);
        fetchData(selectedType);
      } else Alert.alert("Failed", json.message || "Add failed.");
    } catch (err) {
      console.error(err);
      Alert.alert("Error", "Network issue.");
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
    <View style={styles(theme).content}>
      <Text style={styles(theme).subheading}>Hardware Manager</Text>

      <View style={{ flexDirection: "row", marginBottom: 10, flexWrap: "wrap" }}>
        {hardwareTypes.map((t) => (
          <TouchableOpacity
            key={t}
            onPress={() => setSelectedType(t)}
            style={[
              styles(theme).chip,
              selectedType === t && { backgroundColor: theme.primary },
            ]}
          >
            <Text
              style={[
                styles(theme).chipText,
                selectedType === t && { color: "#fff" },
              ]}
            >
              {t.toUpperCase()}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <TextInput
        placeholder="🔍 Search components..."
        placeholderTextColor={theme.placeholder}
        style={styles(theme).searchInput}
        value={searchQuery}
        onChangeText={setSearchQuery}
      />

      {loading ? (
        <ActivityIndicator />
      ) : (
        <FlatList
          data={filtered}
          keyExtractor={(item) => String(item.id || Math.random())}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={styles(theme).card}
              onPress={() => setSelectedItem(item)}
            >
              {item.image_url && (
                <Image
                  source={{ uri: item.image_url }}
                  style={styles(theme).image}
                />
              )}
              <View style={{ flex: 1 }}>
                <Text style={styles(theme).cardText}>
                  <Text style={{ fontWeight: "700" }}>Name:</Text> {item.name}
                </Text>
                <Text style={styles(theme).cardText}>{briefFields(item)}</Text>
              </View>
            </TouchableOpacity>
          )}
        />
      )}

      <Modal
        visible={!!selectedItem}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setSelectedItem(null)}
      >
        <View style={styles(theme).modalContainer}>
          <ScrollView style={styles(theme).modalContent}>
            <Text style={styles(theme).subheading}>Details</Text>

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
                  <Text key={k} style={styles(theme).cardText}>
                    <Text style={{ fontWeight: "700" }}>{k}:</Text> {String(v)}
                  </Text>
                ) : null
              )}

            <TouchableOpacity
              onPress={() => setSelectedItem(null)}
              style={styles(theme).submit}
            >
              <Text style={styles(theme).submitText}>Close</Text>
            </TouchableOpacity>
          </ScrollView>
        </View>
      </Modal>

      <TouchableOpacity
        style={[styles(theme).submit, { marginTop: 12 }]}
        onPress={() => setShowAddModal(true)}
      >
        <Text style={styles(theme).submitText}>
          ➕ Add New {selectedType.toUpperCase()}
        </Text>
      </TouchableOpacity>

      <Modal
        visible={showAddModal}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setShowAddModal(false)}
      >
        <View style={styles(theme).modalContainer}>
          <ScrollView style={styles(theme).modalContent}>
            <Text style={styles(theme).subheading}>
              Add New {selectedType.toUpperCase()}
            </Text>

            {fieldMap[selectedType].map((field) =>
              field.key === "image_url" ? (
                <View key="image_url" style={{ marginVertical: 10 }}>
                  <TouchableOpacity
                    style={[styles(theme).submit, { backgroundColor: theme.primary }]}
                    onPress={pickImage}
                  >
                    <Text style={styles(theme).submitText}>
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
                <View key={field.key} style={styles(theme).toggleRow}>
                  <Text style={styles(theme).toggleLabel}>{field.key}</Text>
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
                  style={styles(theme).input}
                  value={form[field.key] ? String(form[field.key]) : ""}
                  onChangeText={(t) =>
                    handleInputChange(field.key, field.type === "number" ? Number(t) : t)
                  }
                />
              )
            )}

            <TouchableOpacity style={styles(theme).submit} onPress={handleSubmit}>
              <Text style={styles(theme).submitText}>Save</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles(theme).submit, { backgroundColor: "#ccc" }]}
              onPress={() => setShowAddModal(false)}
            >
              <Text style={[styles(theme).submitText, { color: "#000" }]}>Cancel</Text>
            </TouchableOpacity>
          </ScrollView>
        </View>
      </Modal>
    </View>
  );
}
