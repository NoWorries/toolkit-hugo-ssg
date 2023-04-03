module.exports = {
  content: [
    "./content/**/*.md",
    "./content/**/*.html",
    "./layouts/**/*.html",
    "./assets/**/*.js",
    "./themes/toolkit-theme/content/**/*.md",
    "./themes/toolkit-theme/content/**/*.html",
    "./themes/toolkit-theme/layouts/**/*.html",
    "./themes/toolkit-theme/assets/**/*.js",
  ],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [require('@tailwindcss/typography'), require('@tailwindcss/line-clamp')],
}
