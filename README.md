# Description
Creates a map based on user's Tweets, Gowalla and Foursquare check-ins

# Setup

1. Create user_data.rb and add users based on users_data.example.rb
2. If you want to use Gowalla, obtain a key and add it as ````ENV['GOWALLA_API_KEY']````
3. In development, run ````foreman start```` to start both the worker and main Sinatra app (you can also run either on their own)

# Deploying to Heroku

1. Create an app on the cedar stack ( ````heroku create --stack cedar```` )
2. Add the free Memcache add-on (the app stores user location data in memcache and refreshes every 15 min)
3. Run the included rake task to deploy ( ````bundle exec rake deploy```` )
4. If you haven't already, make sure to scale both the web and worker processes ( ````heroku scale web=1 worker=1 ````)

The Rake task will temporarily add your user_data.rb file to the repo to deploy it, then revert the changes after deploying.

# Screenshots

![soft tabs](https://github.com/lifechurch/location-board-ruby/raw/master/screenshot.png)

# History

This app was made during a hackfest at the 2010 LifeChurch.tv Digerati retreat. After releasing the original PHP version, we then created this Ruby/Sinatra version.

# Contributing

In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by translating to a new language
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving issues
* by reviewing patches