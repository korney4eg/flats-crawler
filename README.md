# flats-crawler

## Description

crawler.rb - script to grab flats from t-s.by and monitor prices

site-gen.rb - html generator script

## Installation

To use scripts you need to install following:
```
gem install rubygems nokogiri open-uri mysql2 json
```

Also you need to create database and user in Mysql db-server by running folowing command:
```
mysql -uroot -p < create_db.sql
```


## Usage
./crawler.rb - will fill database with all the flats

./site-gen.rb - will generate html site
