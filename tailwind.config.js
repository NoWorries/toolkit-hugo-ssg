module.exports = {
  content: [
    "./content/**/*.md",
    "./content/**/*.html",
    "./layouts/**/*.html",
    "./assets/**/*.js",
    "./themes/toolkit/content/**/*.md",
    "./themes/toolkit/content/**/*.html",
    "./themes/toolkit/layouts/**/*.html",
    "./themes/toolkit/assets/**/*.js",
  ],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [require('@tailwindcss/typography'), require('@tailwindcss/line-clamp')],
}
