import requests
import json
import subprocess  # Import subprocess module

# Define API URLs
api_urls = [
    "https://api.restful-api.dev/objects",
    "https://api.restful-api.dev/objects/1/",
    "https://api.restful-api.dev/objects?id=3"
    # Add more API URLs as needed
]

# Define filter expression for jq
#filter_expression = '.[] | select(.id == "2")'
# filter_expression = '.[] | select(.id) | [.name, .data.color] | join(", ")'
# filter_expression = '.[] | select(.id == "1") | [.name, .data.color, .data.capacity]'
# filter_expression = '.[] | [ .id, .name ]'
# filter_expression = '.[] | select(.id != "1") | [.name, .data.color]'
# filter_expression = '.[] | if .id != "3" then .name else empty end'
# filter_expression = '.[] | select(has("id"))'
# filter_expression = '. | select(has("id"))' # just to filter this https://api.restful-api.dev/objects/1/
# filter_expression = '.[] | select(.data.color == "Cloudy White") | .id'
# filter_expression = ". | to_entries"   # to_entries filter. It will transform the dict into an array of items
# filter_expression = '.[] | select(.id != 1 and .data.color == "Cloudy White")'
filter_expression = '.[] | select(.data)'

# Function to fetch data from API and filter using jq
def fetch_and_filter(api_url):
    try:
        # Make HTTP GET request
        response = requests.get(api_url)
        response.raise_for_status()  # Raise exception for bad status codes

        # Parse JSON response
        data = response.json()

        # Filter data using jq (or any other tool)
        filtered_data = subprocess.run(['jq', filter_expression], input=json.dumps(data), capture_output=True, text=True)
        if filtered_data.returncode == 0:
            return filtered_data.stdout
        else:
            print(f"Error filtering data from {api_url}")
            return None
    except Exception as e:
        print(f"Error fetching or filtering data from {api_url}: {str(e)}")
        return None

# Fetch and filter data from each API URL
for api_url in api_urls:
    filtered_data = fetch_and_filter(api_url)
    if filtered_data:
        print(f"Filtered data from {api_url}:")
        print(filtered_data)