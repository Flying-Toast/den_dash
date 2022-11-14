// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
        fontFamily: {
            riffic: ['riffic']
	}
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
