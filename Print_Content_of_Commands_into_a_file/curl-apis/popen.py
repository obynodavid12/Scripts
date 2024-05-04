import subprocess
import json

api_urls = [
    'https://api.restful-api.dev/objects',
    'https://api.restful-api.dev/objects/1/',
    'https://api.restful-api.dev/objects?id=3'
]

for api_url in api_urls:
    output = subprocess.check_output(['bash', '-c', f'curl -s {api_url}'])
    data = json.loads(output.decode().strip())

    if isinstance(data, list):
        for item in data:
            print(f"ID: {item['id']}")
            print(f"Name: {item['name']}")
            print(f"Data: {item}")
            print()
    else:
        print(f"ID: {data['id']}")
        print(f"Name: {data['name']}")
        print(f"Data: {data}")
        print()



