import React from "react";
import { Pressable, Text, View } from "react-native";
import { useTheme } from "../providers/ThemeProvider";

export const ThemeToggle = () => {
  const { mode, toggleTheme, theme } = useTheme();

  return (
    <View
      style={{
        position: "absolute",
        top: 40,
        right: 20,
        backgroundColor: theme.colors.surface,
        borderRadius: 20,
        paddingVertical: 6,
        paddingHorizontal: 12,
        elevation: 3,
        shadowColor: "#000",
        shadowOpacity: 0.1,
        shadowRadius: 4,
      }}
    >
      <Pressable onPress={toggleTheme}>
        <Text
          style={{
            color: theme.colors.text,
            fontSize: 18,
          }}
        >
          {mode === "light" ? "🌙" : "☀️"}
        </Text>
      </Pressable>
    </View>
  );
};
