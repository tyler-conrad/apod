# Flutter NASA Astronomy Picture of the Day

Flutter App to browse images provided by NASA on a daily basis.

![Demo Gif](assets/demo.gif)

## Getting Started

This app uses the [apod-api](https://github.com/nasa/apod-api) project to 
provide image metadata including links scraped from the [**Astronomy Picture 
of the Day](https://apod.nasa.gov/apod/astropix.html) website. There is a public
version of this API (https://api.nasa.gov/planetary/apod) which was used for 
initial development but this endpoint gets a lot of traffic and populating the
image link database from there became problematic due to failed network
requests. See below for instructions on setting up the apod-api server locally
to get more reliable network behavior.  If you still wish to use the public API,
apply for an API key [here](https://api.nasa.gov/#signUp) and pass this string as
a query parameter in your [Client](lib/src/client.dart) requests. The lines that
need to be updated are:

```dart
// lib/src/client.dart line: 89
queryParameters: {
  'api_key': '<API_KEY>'
  'thumbs': 'True',
  'start_date':
    s.yearMonthDayStringFromDateTime(dateTime: dateTimePair[0]),
  'end_date':
    s.yearMonthDayStringFromDateTime(dateTime: dateTimePair[1])
},

// lib/src/client.dart line: 113
queryParameters: {
  'api_key': '<API_KEY>'
  'thumbs': 'True',
  'date': s.yearMonthDayStringFromDateTime(dateTime: nafd.futureDay)
},
```

As currently written the code only supports running the apod-api server locally
which results in the Astronomy Picture of the Day website being indirectly
scraped returning JSON to be used by the app.  It takes around three minutes to
populate the database for the app using the local server.  See below for the
local server setup instructions.

From my testing the apod-api server seems to be timezone aware therefore the
[timezone](https://pub.dev/packages/timezone) package is utilized to have hour
offset aware DateTimes within the app.  The
[Hive](https://github.com/hivedb/hive) database backing the app can only persist
naive DateTimes but these are stored and retrieved with the correct hour offset
determined by the variable 'timeZone' ([shared.dart](lib/src/shared.dart) which
is a Location object used by the timezone package:

```dart
final tz.Location timeZone = tz.getLocation('America/Chicago');
```

The code currently uses central time.  It is my understanding that the local
apod-api server uses the system time of the machine that its running on to
determine date changes and the availability of new image data.  You will likely
want to change the Location object to point at a timezone that matches your
system time.  A list of available supported timezone location codes is
[here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) (timezones
in green should be supported).

The code has the variable chunkSize in [client.dart](lib/src/client.dart) that
controls the number of concurrent requests to the server - if your network 
connection is slow or you are using the public API you can update this variable
to reduce the rate of network requests:

```dart
// line 125
for (final chunk in s.chunks<Uri>(
  list: uriIterable(startDate: date).toList(),
  chunkSize: 20,
)) {
```

If you are having trouble getting the initial database population to complete,
prepopulated Hive box files are available in the assets/db directory.  To use
them copy the following files to the ~/Documents directory:
 - latest_media_metadata_box_name.hive
 - media_metadata_box_name.hive
 - media_metadata_box_name.lock

Once the files have been copied only image metadata that has been added more
currently than 11/23/21 will be added when app is started using the update
feature.

## Features

The app uses the Material Design based widgets provided by the Flutter project.
 - Uses the local key-value store database
   [Hive](https://github.com/hivedb/hive) to persist metadata about images.
 - Custom backend network client and database wrapper classes which are composed
   in to the Controller class for usage.
 - AppBar that implements a route aware back button.
 - Drawer that remembers the route state and highlights and disables links
   dynamically.
 - A database population screen that is displayed with a loading bar when the
   initial load needs to happen the first the app is run. It is also 
   displayed in an update mode when the app is started after a day has gone by
   and there are potentially new image links provided by the api which need to
   be added to the local database.
 - Multiple ways to browse images that support forward and backward paging
   through time:
   - SlideShow widget that displays an animated zoom of a random image from the
     API.
   - ImageInteraction widget which is used throughout the app to provide access
     to image dates, titles, explanations and also provides a link to a 
     panning/zooming InteractiveViewer widget for all images.
   - VerticalScrollBrowser that uses sticky headers to display the date of the
     image.
   - Gallery widget which displays a scrollable grid of thumbnails sorted by
     month with the ability to navigate to the image details by tapping.

## Running

First setup the [apod-api](https://github.com/nasa/apod-api) server to run on
localhost:8000.

1. Install python3
    ```bash
    sudo apt update
    sudo apt install python3 pythone3-pip
    ````
2. Clone the repo
    ```bash
    git clone https://github.com/nasa/apod-api
    ```

3. `cd` into the new directory
    ```bash
    cd apod-api
    ```

4. Create a virtual environment
    ```bash
    python3 -m venv venv
    ```

5. Activate the virtual environment
    ```bash
    source venv/bin/activate
    ```

6. Install dependencies into the project's `lib`
    ```bash
    pip install -r requirements.txt -t lib
    ```
   
7. Add `lib` to your PYTHONPATH and run the server
    ```bash
    PYTHONPATH=./lib python application.py
    ```

If the default setup for the server above does not work for you there are other
installation options outlined in the readme for the apod-api project.

1. Instructions for installing Flutter for Linux are
   [here](https://docs.flutter.dev/get-started/install/linux)

2. Enable linux binary building
    ```bash
    flutter config --enable-linux-desktop
    ```

3. Clone this repo
    ```bash
    git clone
    ```

4. Change to the repo directory
    ```bash
    cd apod
    ```

5. Update dependencies
    ```bash
    flutter pub get
    ```

6. Run the tests
    ```bash
    flutter test
    ```

7. Run the application
    ```bash
    flutter run -d linux
    ```

## Tested on
Platform:
- Ubuntu 20.04.4 LTS

Flutter:
 - Flutter 2.13.0-0.1.pre • channel beta • https://github.com/flutter/flutter.git
 - Framework • revision 13a2fb10b8 (8 days ago) • 2022-04-12 15:34:25 -0500
 - Engine • revision 499984f99c
 - Tools • Dart 2.17.0 (build 2.17.0-266.1.beta) • DevTools 2.12.1
