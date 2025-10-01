import { ImageBackground } from "expo-image";
import { Stack } from "expo-router";
import { StyleSheet, Text } from "react-native";

export default function Index() {
  return (
    <>
    <Stack.Screen options={{ title: "limitless", headerShown: false }}/>
    <ImageBackground
    source={require("../assets/images/background.jpg")}
    style={styles.background}
    contentFit="fill">
    <Text style={styles.title}>Hello there!</Text>
    <Text style={styles.subtitle}>More is coming soon, maybe ... when I find time!</Text>
    </ImageBackground>
    </>
  );
}

const styles = StyleSheet.create({
  background: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
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
    color: "#f8fafc", // dark slate
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: "400",
    color: "#bec7d2ff", // modern gray
    textAlign: "center",
    lineHeight: 26,
  },
});
