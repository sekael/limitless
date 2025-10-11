import React from "react";

type Props = {
  value: ReactNavigation.Theme | undefined;
  children: React.ReactNode;
}

export const ThemeContext = React.createContext<ReactNavigation.Theme | undefined>(undefined);
ThemeContext.displayName = 'ThemeContext';

export function ThemeProvider({ value: value, children }: Props) {
  return (
  <ThemeContext.Provider value={value}>
    {children}
  </ThemeContext.Provider>
  );
}
