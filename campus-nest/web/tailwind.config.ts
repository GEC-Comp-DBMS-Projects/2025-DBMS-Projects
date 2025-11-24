import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      // Add your app's color palette
      colors: {
        primary: "#5D9493",
        secondary: "#8CA1A4",
        dark: "#21464E",
        light: "#F8F9F9",
        gray: "#A1B5B7",
      },
      // Set Montserrat as the default font
      fontFamily: {
        sans: ["var(--font-montserrat)", "sans-serif"],
      },
      // Define your app's gradient
      backgroundImage: {
        "theme-gradient": "linear-gradient(to bottom right, var(--tw-gradient-stops))",
      },
    },
  },
  plugins: [],
};
export default config;