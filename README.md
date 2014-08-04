# AnyYolk

AnyYolk is a fun HTML5 game powered by [Parse](https://parse.com). The game uses CSS 3 animations and the highscore is submitted via facebook authentication and stored on Parse. You can check out the live version on the [AnyYolk website](https://anyyolk.com).

## Modified template structure

- Moved web page to cloudCode/public
- Replaced local libs with http://www.cdnjs.com/
- Compile src/main.coffee to cloudCode/public/js/app.min.js
- Moved javascript to bottom of index.html
- Local node.js server for testing
- Async load templates
- Published to [gh-page] (http://darkoverlordofdata.github.io/AnyYolk)

## Setup

### Web Setup
1. Sign up for [Parse](https://parse.com/#signup) and create a new Parse Application.
2. Copy paste your `Application ID` and `JavaScript Key` in the `Parse.initialize()` function in the `index.html` file.

```js
Parse.initialize("APPLICATION_ID", "CLIENT_KEY");
```

### Cloud Code Setup
1. Install the [Parse command line tool](https://parse.com/docs/cloud_code_guide#started) using `curl -s https://www.parse.com/downloads/cloud_code/installer.sh | sudo /bin/bash`
2. Run the `parse new cloudCode` command from the root directory to initialize the cloud code with your Parse app keys (follow the on screen instructions).
3. Navigate to the `/cloudCode` directory using `cd cloudCode` and run the `parse deploy` command to deploy the Cloud Code.

### Facebook Setup
1. Create a new [Facebook application](https://developers.facebook.com/apps) and under the app's settings, under the Mobile Web header, set the Mobile Site URL to your localhost web server.
2. Update the Facebook App ID in the `Parse.FacebookUtils.init` function.

```js
Parse.FacebookUtils.init({
    appId : 'FACEBOOK_APP_ID',
    ...
```

### CSS and SASS

AnyYolk uses [Sass](http://sass-lang.com/) and [Compass](http://compass-style.org/) to generate its CSS. You will find the main SCSS file in `sass/screen.scss`. To generate the css from this file, install [Compass](http://compass-style.org/) and run the `compass watch` command from the root directory.
