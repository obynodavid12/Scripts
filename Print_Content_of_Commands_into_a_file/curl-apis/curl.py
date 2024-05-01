import subprocess
import json

# List of switcher API URLs
api_urls = [
    "https://api.restful-api.dev/objects",
    "https://api.restful-api.dev/objects/1/",
    "https://api.restful-api.dev/objects?id=3",
]

# Initialize an empty dictionary to store the responses
responses = {}

# Iterate through the API URLs
for url in api_urls:
    # Execute the curl command and capture the output
    output = subprocess.check_output(["curl", "-s", url])

    # Parse the JSON response
    response = json.loads(output)

    # Add the response to the dictionary
    responses[url] = response

# Write the responses to a JSON file
with open("response.json", "w") as outfile:
    json.dump(responses, outfile, indent=4)