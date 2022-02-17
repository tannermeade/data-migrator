# general imports
import os
from datetime import datetime, timedelta

# dependencies
from appwrite.client import Client
from appwrite.services.storage import Storage
from appwrite.services.database import Database

print("Imported all dependencies")

print("Trying to open connection to Appwrite Client:")
print(os.environ["APPWRITE_ENDPOINT"])
print(os.environ["APPWRITE_FUNCTION_PROJECT_ID"])
print(os.environ["APPWRITE_API_KEY"])
# Setup the appwrite SDK
client = Client()
client.set_endpoint(os.environ["APPWRITE_ENDPOINT"])
client.set_project(os.environ["APPWRITE_FUNCTION_PROJECT_ID"])
client.set_key(os.environ["APPWRITE_API_KEY"])

# Setup Database
database = Database(client)

print("database obj created")


# Get parameters from execution command
print(os.environ["APPWRITE_FUNCTION_DATA"])
bundle_id = os.environ["APPWRITE_FUNCTION_DATA"]

# Get file from storage
storage = Storage(client)
result = storage.get_file_download(bundle_id)
print(result)

# Decode file into json obj
# already done somehow??

# Get collection_id & data from obj
print("mark 0:saving data")
data = result["data"]
print("mark 1:data")
print(data)
print("mark 2")

# print("mark 3")
# print(responseData["data"])
# print("mark 4")
# print(responseData)
# print(data)

# Get collection attributes
database = Database(client)
collectionId = result["collectionId"]
attributeList = database.list_attributes(collectionId)
print(attributeList["attributes"])

# Loop thru data and prepare to insert
dataList = []
for dataRow in data:
    dataMap = {}
    i = 0
    for attr in attributeList["attributes"]:
        dataMap[attr["key"]] = dataRow[i]
        i += 1
    dataList.append(dataMap)

print("dataList:")
print(dataList)

# insert into database
insertResults = []
for dataRow in dataList:
    print("inserting row")
    insertResult = database.create_document(collectionId, 'unique()', dataRow)
    insertResults.append(insertResult)
    print("done")
    print(insertResult)

print(insertResults)
