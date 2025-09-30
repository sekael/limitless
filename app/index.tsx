import { Stack } from "expo-router";
import { StyleSheet, Text, View } from "react-native";

export default function Index() {
  return (
    <>
    <Stack.Screen options={{ headerShown: false }}/>
    <View
      style={styles.container}
    >
      <Text style={styles.title}>Hello there!</Text>
      <Text style={styles.subtitle}>More is coming soon, maybe ... when I find time!</Text>
    </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f8fafc", // light background 
    alignItems: "center",
    justifyContent: "center",
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: "700",
    color: "#1e293b", // dark slate
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: "400",
    color: "#475569", // modern gray
    textAlign: "center",
    lineHeight: 26,
  },
});
