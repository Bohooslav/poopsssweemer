let ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  module: {
    rules: [
      {
        test: /\.imba$/,
        loader: 'imba/loader',
      },
      {
        test: /\.css$/,
        loader: 'style-loader!css-loader'
      }
    ],
  },
  resolve: {
    extensions: [".imba", ".js", ".json"]
  },
  entry: ["./src/app.imba", "./dist/app.css"],
  output: {  path: __dirname + '/dist', filename: "app.js" },
  plugins: [
    new ExtractTextPlugin('app.css')
  ],
  mode: "development"
}
