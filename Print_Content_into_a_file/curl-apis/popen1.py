import subprocess
import json

api_urls = [
    'https://api.restful-api.dev/objects',
    'https://api.restful-api.dev/objects/1/',
    'https://api.restful-api.dev/objects?id=3',
    'https://dummy.restapiexample.com/api/v1/employees'
]

for api_url in api_urls:
    process = subprocess.run(['curl', '-s', api_url], stdout=subprocess.PIPE, check=True)
    output = process.stdout.decode().strip()
    data = json.loads(output)

    if api_url == 'https://dummy.restapiexample.com/api/v1/employees':
        if isinstance(data, dict) and 'data' in data:
            for item in data['data']:
                print(f"ID: {item['id']}")
                print(f"Name: {item['employee_name']}")
                print(f"Salary: {item['employee_salary']}")
                print(f"Age: {item['employee_age']}")
                print(f"Profile Image: {item['profile_image']}")
                print()
    elif isinstance(data, list):
        for item in data:
            print(f"ID: {item.get('id', 'N/A')}")
            print(f"Name: {item.get('name', 'N/A')}")
            print(f"Data: {item}")
            print()
    else:
        print(f"ID: {data.get('id', 'N/A')}")
        print(f"Name: {data.get('name', 'N/A')}")
        print(f"Data: {data}")
        print()



