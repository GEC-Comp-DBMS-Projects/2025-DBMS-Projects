import LottieView from 'lottie-react-native';
import React, { createContext, useContext, useState, useCallback } from 'react';
import { View, Text, Animated, TouchableOpacity } from 'react-native';
import Successful from '@/assets/animations/authentication.json';
import Unsuccessful from '@/assets/animations/unsuccessful.json';
import Info from '@/assets/animations/info.json';
import { useTheme } from '@/contexts/ThemeContext';
type ToastType = 'success' | 'error' | 'info';

interface ToastOptions {
    type: ToastType;
    title: string;
    description?: string;
    duration?: number;
}

interface ToastContextValue {
    showToast: (options: ToastOptions) => void;
}

const ToastContext = createContext<ToastContextValue | undefined>(undefined);

export function useToast() {
    const ctx = useContext(ToastContext);
    if (!ctx) throw new Error('useToast must be used within ToastProvider');
    return ctx;
}

export const ToastProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [visible, setVisible] = useState(false);
    const [toast, setToast] = useState<ToastOptions | null>(null);
    const [fadeAnim] = useState(new Animated.Value(0));
    const { colors, isDark } = useTheme();
    const showToast = useCallback((options: ToastOptions) => {
        setToast(options);
        setVisible(true);
        Animated.timing(fadeAnim, {
            toValue: 1,
            duration: 200,
            useNativeDriver: true,
        }).start();

        setTimeout(() => {
            Animated.timing(fadeAnim, {
                toValue: 0,
                duration: 200,
                useNativeDriver: true,
            }).start(() => {
                setVisible(false);
                setToast(null);
            });
        }, options.duration || 5000);
    }, [fadeAnim]);

    return (
        <ToastContext.Provider value={{ showToast }}>
            {children}
            {visible && toast && (
                <Animated.View
                    style={[
                        {
                            position: 'absolute',
                            top: 60,
                            left: 20,
                            right: 20,
                            zIndex: 9999,
                            opacity: fadeAnim,
                            backgroundColor: colors.accent,
                        },
                    ]}
                    className="rounded-2xl p-4 shadow-xl flex flex-row items-center justify-between"
                >
                    <View className='w-12 h-12'>
                        <LottieView
                            autoPlay
                            style={{
                                width: "90%",
                                height: "100%",
                                backgroundColor: 'transparent',
                            }}
                            source={
                                toast.type === "success"
                                    ? Successful
                                    : toast.type === "error"
                                    ? Unsuccessful
                                    : Info
                            }
                        />
                    </View>
                    <View className='flex-1 ml-1'>
                        <View className="flex-row items-center">
                            <Text
                                style={{
                                    color: colors.primary,
                                    fontWeight: 'bold',
                                    fontSize: 16,
                                }}
                                className="flex-1"
                            >
                                {toast.title}
                            </Text>
                            <TouchableOpacity onPress={() => setVisible(false)}>
                                <Text
                                    style={{
                                        color: colors.primary,
                                        fontWeight: 'bold',
                                        fontSize: 18,
                                    }}
                                    className="ml-3"
                                >
                                    ×
                                </Text>
                            </TouchableOpacity>
                        </View>
                        { toast.description && (
                            <Text style={{ color: colors.primary }} className="flex-1 ">
                                {toast.description || " "}
                            </Text>
                        )}
                    </View>
                </Animated.View>
            )}
        </ToastContext.Provider>
    );
};