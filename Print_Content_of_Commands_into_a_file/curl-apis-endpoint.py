# # PRINTS TO ONLY ONE RESPONSE.JSON FILE
import subprocess
import json

# Define a dictionary of APIs with their corresponding curl commands
apis = {
    "API1": "curl -s https://api.restful-api.dev/objects | jq .",
    "API2": "curl -s https://api.restful-api.dev/objects/1/ | jq .",
    "API3": "curl -s https://api.restful-api.dev/objects?id=3 | jq ."
}

# Dictionary to store responses
responses = {}

# Iterate over each API and execute its curl command
for api_name, curl_command in apis.items():
    print(f"Validating {api_name}...")
    try:
        # Execute curl command and capture output
        result = subprocess.run(curl_command, shell=True, check=True, capture_output=True, text=True)
        
        # Store response in dictionary
        responses[api_name] = json.loads(result.stdout)
        
        print(f"{api_name} validated.")
    except subprocess.CalledProcessError as e:
        print(f"Error validating {api_name}: {e}")

# Save aggregated responses to a single JSON file
with open("response.json", "w") as f:
    json.dump(responses, f, indent=4)

print("Aggregated responses saved to response.json")

# https://dev.to/ritaly/the-simplest-guide-to-curl-for-rest-api-requests-35ii#get-request