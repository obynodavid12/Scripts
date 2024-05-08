import requests

api_urls = [
    'https://stream-status-restful-api.dev/objects',
    'https://stream-status-restful-api.dev/objects/1/',
    'https://stream-status-restful-api.dev/objects?id=3'
]

# Function to filter the response data
def filter_stream_data(url):
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        filtered_data = []
        for item in data:
            if 'stream_id' in item and 'stream_priority' in item and 'stream_status' in item:
                filtered_data.append({
                    'stream_id': item['stream_id'],
                    'stream_priority': item['stream_priority'],
                    'stream_status': item['stream_status']
                })
        return filtered_data
    else:
        return []

# Filter the data for each API URL
for url in api_urls:
    filtered_data = filter_stream_data(url)
    print(f"Filtered data for {url}:")
    print(filtered_data)
