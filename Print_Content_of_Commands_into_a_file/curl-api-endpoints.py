# # PRINTS INTO API1_response.json, API2_response.json etc
import subprocess
import json

# Define a dictionary of APIs with their corresponding curl commands
apis = {
    "API1": "curl -s https://api.restful-api.dev/objects | jq .",
    "API2": "curl -s https://api.restful-api.dev/objects/1/ | jq .",
    "API3": "curl -s https://api.restful-api.dev/objects?id=3 | jq ."
}

# Iterate over each API and execute its curl command
for api_name, curl_command in apis.items():
    print(f"Validating {api_name}...")
    try:
        # Execute curl command and capture output
        result = subprocess.run(curl_command, shell=True, check=True, capture_output=True, text=True)
        
        # Load the response as JSON
        response_json = json.loads(result.stdout)
        
        # Save response to JSON file
        with open(f"{api_name}_response.json", "w") as f:
            json.dump(response_json, f, indent=2)
        
        print(f"{api_name} validated. Response saved to {api_name}_response.json")
    except subprocess.CalledProcessError as e:
        print(f"Error validating {api_name}: {e}")


# https://dev.to/ritaly/the-simplest-guide-to-curl-for-rest-api-requests-35ii#get-request