// Theme colors configuration for light and dark modes
export const Colors = {
  light: {
    // Primary colors
    primary: '#E9F0E9',
    secondary: '#FFFFFF',
    tertiary: '#F5F5F5',
    accent: 'black',
    
    // Text colors
    text: '#000000',
    textSecondary: '#6B7280',
    textTertiary: '#9CA3AF',
    
    // Background colors
    background: '#FFFFFF',
    backgroundSecondary: '#F9FAFB',
    backgroundTertiary: '#F3F4F6',
    
    // UI colors
    border: '#E5E7EB',
    shadow: '#000000',
    card: '#FFFFFF',
    
    // Status colors
    success: '#10B981',
    error: '#EF4444',
    warning: '#F59E0B',
    info: '#3B82F6',
    
    // Interactive colors
    link: '#6366F1',
    linkHover: '#4F46E5',
    
    // Tab bar
    tabBarBackground: '#FFFFFF',
    tabBarBorder: '#E5E7EB',
    tabIconDefault: '#9CA3AF',
    tabIconSelected: '#000000',
  },
  dark: {
    // Primary colors
    primary: 'black',
    secondary: '#111827',
    tertiary: '#151515',
    accent: '#E9F0E9',
    
    // Text colors
    text: '#F9FAFB',
    textSecondary: '#D1D5DB',
    textTertiary: '#9CA3AF',
    
    // Background colors
    background: '#151515',
    backgroundSecondary: '#151515',
    backgroundTertiary: '#374151',
    
    // UI colors
    border: '#374151',
    shadow: '#000000',
    card: 'black',
    
    // Status colors
    success: '#10B981',
    error: '#EF4444',
    warning: '#F59E0B',
    info: '#3B82F6',
    
    // Interactive colors
    link: '#818CF8',
    linkHover: '#6366F1',
    
    // Tab bar
    tabBarBackground: 'black',
    tabBarBorder: '#374151',
    tabIconDefault: '#6B7280',
    tabIconSelected: '#FFFFFF',
  },
} as const;

export type Theme = 'light' | 'dark';
export type ThemeColors = {
  primary: string;
  secondary: string;
  tertiary: string;
  accent: string;
  text: string;
  textSecondary: string;
  textTertiary: string;
  background: string;
  backgroundSecondary: string;
  backgroundTertiary: string;
  border: string;
  shadow: string;
  card: string;
  success: string;
  error: string;
  warning: string;
  info: string;
  link: string;
  linkHover: string;
  tabBarBackground: string;
  tabBarBorder: string;
  tabIconDefault: string;
  tabIconSelected: string;
};
