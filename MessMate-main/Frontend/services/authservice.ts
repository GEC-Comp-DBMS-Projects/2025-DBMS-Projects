import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

const API_URL = "http://192.168.1.3:5000"; // replace with your IP

export const signup = async (full_name: string, email: string, password: string, user_type = "student") => {
  return axios.post(`${API_URL}/signup`, { full_name, email, password, user_type });
};

export const login = async (email: string, password: string) => {
  const response = await axios.post(`${API_URL}/login`, { email, password });
  const { token } = response.data;
  await AsyncStorage.setItem("token", token); // store token
  return response.data;
};

export const getProfile = async () => {
  const token = await AsyncStorage.getItem("token");
  return axios.get(`${API_URL}/profile`, {
    headers: { Authorization: `Bearer ${token}` },
  });
};
