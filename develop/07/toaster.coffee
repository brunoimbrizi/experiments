# => SRC FOLDER
toast 'src'

  # EXCLUDED FOLDERS (optional)
  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

  # => VENDORS (optional)
  # vendors: ['vendors/x.js', 'vendors/y.js', ... ]

  # => OPTIONS (optional, default values listed)
  # bare: false
  packaging: false
  # expose: ''
  # minify: true

  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
  httpfolder: ''
  release: '../../website/07/js/main.js'
  debug: '../../website/07/js/main-debug.js'
  minify: true