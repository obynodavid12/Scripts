# import os
# import subprocess

# # Define API URLs with curl and jq commands
# apis = {
#     "API1": "curl -s https://api.restful-api.dev/objects | jq .",
#     "API2": "curl -s https://api.restful-api.dev/objects/1/ | jq .",
#     "API3": "curl -s https://api.restful-api.dev/objects?id=3 | jq ."
# }

# # Function to fetch and filter data
# def fetch_and_filter(api_command):
#     try:
#         # Execute curl and jq command using subprocess
#         result = subprocess.run(api_command, shell=True, check=True, capture_output=True, text=True)
#         filtered_data = result.stdout
#         return filtered_data
#     except subprocess.CalledProcessError as e:
#         raise Exception(f"Error fetching data: {e}")
#     except Exception as e:
#         raise Exception(f"Error processing data: {e}")

# # Iterate over APIs and fetch/filter data
# for name, command in apis.items():
#     print(f"Fetching and filtering data from {name}...")
#     try:
#         filtered_data = fetch_and_filter(command)
#         if filtered_data:
#             print(filtered_data)
#         else:
#             print(f"No data found for {name}")
#     except Exception as e:
#         print(f"Error: {e}")

# import os
# import requests
# import json
# import subprocess

# # Define API URLs
# apis = {
#     "API1": "https://api.restful-api.dev/objects",
#     "API2": "https://api.restful-api.dev/objects/1/",
#     "API3": "https://api.restful-api.dev/objects?id=3"
# }

# # Define filter expression for jq for API1 and API3
# filter_expression_list = '.[] | {id, name, data}'

# # Define filter expression for jq for API2
# filter_expression_object = '{id, name, data}'

# # Function to fetch and filter data
# def fetch_and_filter(api_url):
#     try:
#         # Execute curl and jq command using subprocess
#         result = subprocess.run(['curl', '-s', api_url], capture_output=True, text=True)
#         if result.returncode != 0:
#             raise Exception(f"Error fetching data: {result.stderr}")
        
#         # Parse JSON response
#         data = json.loads(result.stdout)
        
#         # Filter data using jq expression based on the JSON structure
#         if isinstance(data, list):  # For API1 and API3
#             filter_expression = filter_expression_list
#         elif isinstance(data, dict):  # For API2
#             filter_expression = filter_expression_object
#         else:
#             raise Exception("Unexpected JSON structure")
        
#         filtered_data = subprocess.run(['jq', filter_expression], input=json.dumps(data), capture_output=True, text=True)
#         if filtered_data.returncode == 0:
#             return filtered_data.stdout
#         else:
#             raise Exception(f"Error filtering data: {filtered_data.stderr}")
#     except subprocess.CalledProcessError as e:
#         raise Exception(f"Error fetching data: {e}")
#     except Exception as e:
#         raise Exception(f"Error processing data: {e}")

# # Iterate over APIs and fetch/filter data
# for name, url in apis.items():
#     print(f"Fetching and filtering data from {name}...")
#     try:
#         filtered_data = fetch_and_filter(url)
#         if filtered_data:
#             print(filtered_data)
#         else:
#             print(f"No data found for {name}")
#     except Exception as e:
#         print(f"Error: {e}")
