import json

for i in range(1,1001):

    data = {
    "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.", 
    "external_url": f"https://openseacreatures.io/{i}", 
    "image": f"https://storage.googleapis.com/opensea-prod.appspot.com/puffs/{i}.png", 
    "name": "Dave Starbelly",
    "attributes": [], 
    }
    with open(f"{i}.json", "w") as file:
        json.dump(data, file, indent=4)
