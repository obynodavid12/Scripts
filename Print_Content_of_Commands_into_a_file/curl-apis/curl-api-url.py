import subprocess
import json

# Read API URLs from the file
with open("api_urls.txt", "r") as f:
    api_urls = [line.strip() for line in f if line.strip()]

# Define a dictionary to store responses
responses = {}

# Iterate over each API URL and execute its curl command
for idx, api_url in enumerate(api_urls, start=1):
    api_name = f"API{idx}"
    curl_command = f"curl -X GET {api_url}"
    print(f"Validating {api_name} ({api_url})...")
    try:
        # Execute curl command and capture output
        result = subprocess.run(curl_command, shell=True, check=True, capture_output=True, text=True)
        
        # Store response in dictionary
        responses[api_name] = json.loads(result.stdout)
        
        print(f"{api_name} validated.")
    except subprocess.CalledProcessError as e:
        print(f"Error validating {api_name} ({api_url}): {e}")

# Save aggregated responses to a single JSON file
with open("response.json", "w") as f:
    json.dump(responses, f, indent=4)

print("Aggregated responses saved to response.json")
