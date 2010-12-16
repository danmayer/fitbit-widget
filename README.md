# Fitbit widget  

A simple app to help users brows fitbit data on mobile devices or embed it in webpages.

Also a example of how to build mobile sites and apps.

__GETTING STARTED__

* There is no rake task to install gems for you. Look at the requires at the top of fitbit-widget.rb
* Also you can look at the .gems file which installs gems on Heroku
* Unfortunately to really try this code you need a fitbit account
  * set fitbit_email and fitbit_pass to your environment to get tests or the project working
  * you can do this via fitbit_email=my@email.com fitbit_pass=pass ruby fitbit-widget.rb or set them in your .bash_profile
* `rake test`, to run the tests
* `ruby fitbit-widget.rb` to start the sinatra server
* Install gems that are in the .gems file, and install do_mysql, do_posgress, or do_sqlite3 depending on which DB you wish to dev on.
* install json gem
* `ruby fitbit-widget.rb`

## Author
* Dan Mayer (danmayer)

__TODO__
* work on caching all the files/CSS/images / minifying them all as part of deployment process
* make it easier to get up and running (rake gems install?, bundler?)
* log currently logs password, apply a filter to the log to not record passwords.
* Use progressive updating via jquery opposed to the hardcoded onclick function calls.
* move sinatra simple account to gem and provide plugin mechanism.
  * ie use SinatraSimpleAccount :success => x, :protocall => {} , etc
  * clean up and make all the above options setable
* menu with actual quit option (close option)
* larger clickable links in the UI
* add viewable notice for offline mode
* Real cached assests
* Better shared image solution than local images and full page to site images, same relative path.
* Add arbitrary background tracking using accelerometers and/or GPS, so non fitbit users can have a value.
* Food Log frequently double submits the food (disable form on submit)
* Updates parts of the Ruby API to use the new fitbit api
* fitbit-widget dates seem skewed by one