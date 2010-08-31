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

## Author
* Dan Mayer (danmayer)

__TODO__

* if you log in with a non existant fitbit email/pass it just crashes
* some bug displays unformatted text before displaying formatted html on ajax actions (bug in my jquery-offline branch I think)
* work on caching all the files/CSS/images
* Spinner to display that things are loading between page loads
* make tmp dir if doesn't exist
* make it easier to get up and running (rake gems install? )
* factor out various environment dependant stuff.
* log currently logs password, apply a filter to the log to not record passwords.
* add the Android project to the git repo.