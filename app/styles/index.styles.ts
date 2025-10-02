import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  background: {
    flex: 1,
    justifyContent: "flex-start",
    alignItems: "center",
    paddingTop: 250 
  },
  overlay: {
    backgroundColor: "rgba(255,255,255,0.7)", // optional overlay
    padding: 20,
    borderRadius: 12,
  },
  title: {
    fontSize: 32,
    fontWeight: "700",
    color: "#1e293b",
    textAlign: "center",
  },
  subtitle: {
    fontSize: 18,
    fontWeight: "400",
    color: "#475569",
    textAlign: "center",
    lineHeight: 26,
    padding: 12
  },
});
