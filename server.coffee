#+--------------------------------------------------------------------+
#| iwishua.coffee
#+--------------------------------------------------------------------+
#| Copyright FiftyTwoFiftyTwo, LLC (c) 2014
#+--------------------------------------------------------------------+
#|
#| This file is a part of iwishua
#|
#| This file is subject to the terms and conditions defined in
#| file 'license.md', which is part of this source code package.
#|
#+--------------------------------------------------------------------+
#
# Start a simple server to demo the application
#

fs = require("fs")
http = require("http")
path = require("path")
express = require("express")

port  = process.env.VCAP_APP_PORT ? 3000
key   = process.env.CLIENT_SECRET ? 'ZAHvYIu8u1iRS6Hox7jADpnCMYKf57ex0BEWc8bM0/4='

app = express()
app.set "port", port
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.cookieSession(secret: key)
app.use app.router
app.use express.static(path.join(__dirname, "cloudCode/public"))
app.use express.errorHandler()  if "development" is app.get("env")

#cache = String(fs.readFileSync("./www/index.html"))

app.all "/", (req, res) ->
  res.send String(fs.readFileSync("./cloudCode/public/index.html"))

app.use ->
  res.send 404,'Not Found'

http.createServer(app).listen port, ->
  console.log "listening on port http://localhost:%d", port

