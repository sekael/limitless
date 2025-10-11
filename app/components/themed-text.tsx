import { StyleSheet, Text, type TextProps } from 'react-native';
import { lightTheme, useAppTheme } from '../constants/theme';

export type ThemedTextType = TextProps & {
  textColor?: keyof typeof lightTheme.colors;
  type?: 'default' | 'title' | 'defaultSemiBold' | 'subtitle' | 'link';
};

export function ThemedText({
  style,
  textColor = 'text',
  type = 'default',
  ...rest
}: ThemedTextType) {
  const theme = useAppTheme();
  const color = theme.colors[textColor];
  return (
    <Text
      style={[
        { color },
        type === 'default' ? styles.default : undefined,
        type === 'title' ? styles.title : undefined,
        type === 'defaultSemiBold' ? styles.defaultSemiBold : undefined,
        type === 'subtitle' ? styles.subtitle : undefined,
        type === 'link' ? styles.link : undefined,
        style,
      ]}
      {...rest}
    />
  );
}

const styles = StyleSheet.create({
  default: {
    fontSize: 16,
    lineHeight: 24,
  },
  defaultSemiBold: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '600',
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    lineHeight: 32,
    paddingBottom: 10,
  },
  subtitle: {
    fontSize: 20,
    fontWeight: '500',
  },
  link: {
    lineHeight: 30,
    fontSize: 16,
    color: '#0a7ea4',
  },
});
