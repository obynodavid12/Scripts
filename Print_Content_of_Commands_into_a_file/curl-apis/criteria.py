# import json
# import subprocess

data = [
    {"name": "A", "color": "red", "age": 10},
    {"name": "B", "color": "green", "age": 10},
    {"name": "C", "color": "red", "age": 10},
    {"name": "D", "color": "red", "age": 15},
]

criteria = {"color": "red", "age": 10}

for entry in data:
    # check that the set-like criteria items are subset of entry items:
    if criteria.items() <= entry.items():
    # if all(item in entry.items() for item in criteria.items()):
        print(entry)


# expressing "subset" using "<="!