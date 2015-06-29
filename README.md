json rt-api
-----------

This is a custom HTTP JSON API for RT. The service exposes a JSON API and
uses the "rt" command line tool to control RT.

## Build

Generally it might be a good idea to use rvm.
However what you actually need is a working JRuby.

* `$ gem install bundler`
* `$ bundle install`
* `$ rake jar`

## Setup 

* On the RequestTracker server you simply run the jar file with java. Typically from an upstart job.
  An example upstart config is in `contrib/init/json-rt-api.conf`. 

* On the icinga / nagios side you hook into the global event handlers. Proper scripts are in the `nagios-icinga` directory.


## RT Command Line Tool

Some usage hints can be found in the RT wiki.

* http://requesttracker.wikia.com/wiki/CLI

Please see the following examples for the `rt` commands we need for the API.

### Search

```shell
rt list -s "Subject LIKE 'Test' AND Status != 'resolved'" -q icinga

=> "18425: Test 1"
```

### Search for unowned tickets

```shell
rt list -s "Subject LIKE 'Test' AND Status != 'resolved' AND Owner = 'Nobody'" -q icinga

=> "18425: Test 1"
```

### Create

```shell
rt create -t ticket set subject="Test cli" queue="icinga" text="Test content"

=> "# Ticket 18427 created."
```

### Comment

```shell
rt comment -m "This is a comment on 18427" 18427

=> "# Message recorded"
```

### Retrieve owner of a ticket

```shell
rt show ticket/18427 -f owner,id

=> "# Owner: Nobody
    # id: ticket/18427"
```

### Edit

```shell
rt edit 18427 set status=resolved

=> "# Ticket 18427 updated."
```

## Authors

Daniel Rauer, <rauer@bytemine.net>

Bernd Ahlers, <ahlers@bytemine.net>

