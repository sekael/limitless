import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { useTheme } from "../providers/ThemeProvider";

export const ThemePicker = () => {
  const { mode, toggleTheme } = useTheme();

  const setMode = (newMode: "light" | "dark") => {
    if (newMode !== mode) toggleTheme();
  };

  return (
    <View style={styles.container}>
      <Pressable
        style={[styles.option, mode === "light" && styles.selected]}
        onPress={() => setMode("light")}
      >
        <Text style={styles.icon}>🌞</Text>
        <Text style={styles.label}>Light</Text>
      </Pressable>

      <Pressable
        style={[styles.option, mode === "dark" && styles.selected]}
        onPress={() => setMode("dark")}
      >
        <Text style={styles.icon}>🌙</Text>
        <Text style={styles.label}>Dark</Text>
      </Pressable>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: "absolute",
    bottom: 40,
    right: 20,
    flexDirection: "row",
    backgroundColor: "rgba(126, 162, 198, 0.7)",
    borderRadius: 20,
    overflow: "hidden",
  },
  option: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 10,
    paddingVertical: 6,
    gap: 4,
  },
  selected: {
    backgroundColor: "rgba(0,0,0,0.5)",
  },
  icon: {
    fontSize: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: "600",
  },
});
