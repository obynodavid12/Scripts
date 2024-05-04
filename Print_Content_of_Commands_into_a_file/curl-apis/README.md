curl -s https://api.restful-api.dev/objects | jq -r '.[] | [ .id, .name ]'
[
  "1",
  "Google Pixel 6 Pro"
]
[
  "2",
  "Apple iPhone 12 Mini, 256GB, Blue"
]
[
  "3",
  "Apple iPhone 12 Pro Max"
]
[
  "4",
  "Apple iPhone 11, 64GB"
]
[
  "5",
  "Samsung Galaxy Z Fold2"
]
[
  "6",
  "Apple AirPods"
]
[
  "7",
  "Apple MacBook Pro 16"
]
[
  "8",
  "Apple Watch Series 8"
]
[
  "9",
  "Beats Studio3 Wireless"
]
[
  "10",
  "Apple iPad Mini 5th Gen"
]
[
  "11",
  "Apple iPad Mini 5th Gen"
]
[
  "12",
  "Apple iPad Air"
]
[
  "13",
  "Apple iPad Air"
]

curl -s https://api.restful-api.dev/objects | jq -r '.[] | [ .id, .name ] | @tsv'

1       Google Pixel 6 Pro
2       Apple iPhone 12 Mini, 256GB, Blue
3       Apple iPhone 12 Pro Max
4       Apple iPhone 11, 64GB
5       Samsung Galaxy Z Fold2
6       Apple AirPods
7       Apple MacBook Pro 16
8       Apple Watch Series 8
9       Beats Studio3 Wireless
10      Apple iPad Mini 5th Gen
11      Apple iPad Mini 5th Gen
12      Apple iPad Air
13      Apple iPad Air

curl -s https://api.restful-api.dev/objects | jq -r '.[] | [ .id, .name ] | join(", ")'
1, Google Pixel 6 Pro
2, Apple iPhone 12 Mini, 256GB, Blue
3, Apple iPhone 12 Pro Max
4, Apple iPhone 11, 64GB
5, Samsung Galaxy Z Fold2
6, Apple AirPods
7, Apple MacBook Pro 16
8, Apple Watch Series 8
9, Beats Studio3 Wireless
10, Apple iPad Mini 5th Gen
11, Apple iPad Mini 5th Gen
12, Apple iPad Air
13, Apple iPad Air


curl -s https://api.restful-api.dev/objects | jq -r '.[] | [ .id, .name ] | @csv'
"1","Google Pixel 6 Pro"
"2","Apple iPhone 12 Mini, 256GB, Blue"
"3","Apple iPhone 12 Pro Max"
"4","Apple iPhone 11, 64GB"
"5","Samsung Galaxy Z Fold2"
"6","Apple AirPods"
"7","Apple MacBook Pro 16"
"8","Apple Watch Series 8"
"9","Beats Studio3 Wireless"
"10","Apple iPad Mini 5th Gen"
"11","Apple iPad Mini 5th Gen"
"12","Apple iPad Air"
"13","Apple iPad Air"

curl -s https://api.restful-api.dev/objects  | jq -r '.[] | select(.id != "1") | [.name, .data.color] | @tsv'
Apple iPhone 12 Mini, 256GB, Blue
Apple iPhone 12 Pro Max Cloudy White
Apple iPhone 11, 64GB   Purple
Samsung Galaxy Z Fold2  Brown
Apple AirPods
Apple MacBook Pro 16
Apple Watch Series 8
Beats Studio3 Wireless
Apple iPad Mini 5th Gen
Apple iPad Mini 5th Gen
Apple iPad Air
Apple iPad Air

curl -s https://api.restful-api.dev/objects  | jq -r '.[] | select(.id == "1") | [.name, .data.color] | @tsv'
Google Pixel 6 Pro      Cloudy White

curl -s https://api.restful-api.dev/objects  | jq -r '.[] | select(.id) | [.name, .data.color] | @tsv'
Google Pixel 6 Pro      Cloudy White
Apple iPhone 12 Mini, 256GB, Blue
Apple iPhone 12 Pro Max Cloudy White
Apple iPhone 11, 64GB   Purple
Samsung Galaxy Z Fold2  Brown
Apple AirPods
Apple MacBook Pro 16
Apple Watch Series 8
Beats Studio3 Wireless
Apple iPad Mini 5th Gen
Apple iPad Mini 5th Gen
Apple iPad Air
Apple iPad Air

https://github.com/jqlang/jq/wiki/Cookbook#filter-objects-based-on-the-contents-of-a-key

then for each top-level object or array of objects, emit the value if any of its "id" key; the values should be emitted as a stream, it being understood that if any of the objects does not have an "id" key, then it should be skipped.

curl -s https://api.restful-api.dev/objects | jq 'if type == "array" then .[] | .name elif type == "object" then .id else empty end'
"Google Pixel 6 Pro"
"Apple iPhone 12 Mini, 256GB, Blue"
"Apple iPhone 12 Pro Max"
"Apple iPhone 11, 64GB"
"Samsung Galaxy Z Fold2"
"Apple AirPods"
"Apple MacBook Pro 16"
"Apple Watch Series 8"
"Beats Studio3 Wireless"
"Apple iPad Mini 5th Gen"
"Apple iPad Mini 5th Gen"
"Apple iPad Air"
"Apple iPad Air"

curl -s https://api.restful-api.dev/objects | jq 'if type == "array" then .[] | .id elif type == "object" then .id else empty end'
"1"
"2"
"3"
"4"
"5"
"6"
"7"
"8"
"9"
"10"
"11"
"12"
"13"

cat curl-1.json | jq -r '.data[] | select(.id) | [.employee_name, .employee_salary] | @tsv'
Tiger Nixon     320800
Garrett Winters 170750
Ashton Cox      86000
Cedric Kelly    433060
Airi Satou      162700
Brielle Williamson      372000
Herrod Chandler 137500
Rhona Davidson  327900
Colleen Hurst   205500
Sonya Frost     103600
Jena Gaines     90560
Quinn Flynn     342000
Charde Marshall 470600
Haley Kennedy   313500
Tatyana Fitzpatrick     385750
Michael Silva   198500
Paul Byrd       725000
Gloria Little   237500
Bradley Greer   132000
Dai Rios        217500
Jenette Caldwell        345000
Yuri Berry      675000
Caesar Vance    106450
Doris Wilder    85600


# About popen.py script
In this example, we have a list of three API URLs that we want to retrieve data from. We then loop through each URL, make a request using subprocess.check_output() and curl, and parse the JSON response using json.loads().

For each API response, we check if the data is a list or a single object. If it's a list, we iterate through each item in the list and print out the id, name, and the entire data object. If it's a single object, we simply print out the id, name, and the entire data object.

This approach allows you to handle different API response formats and print out the relevant information for each API endpoint.

Note that this code assumes the API responses contain id and name fields. If the API responses have different field names, you'll need to update the code accordingly.