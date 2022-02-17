# general imports
import os
from datetime import datetime, timedelta

# dependencies
from appwrite.client import Client
from appwrite.services.storage import Storage
from appwrite.services.database import Database

# Setup the appwrite SDK
try:
    client = Client()
    client.set_endpoint(os.environ["APPWRITE_ENDPOINT"])
    client.set_project(os.environ["APPWRITE_FUNCTION_PROJECT_ID"])
    client.set_key(os.environ["APPWRITE_API_KEY"])
except SomeError as e:
    print("Failed creating client. Check cloud function's environment variables: APPWRITE_ENDPOINT, APPWRITE_FUNCTION_PROJECT_ID, APPWRITE_API_KEY")
    raise e

try:
    # Get parameters from execution command
    bundle_id = os.environ["APPWRITE_FUNCTION_DATA"]

    # Get file from storage
    storage = Storage(client)
    result = storage.get_file_download(bundle_id)
except SomeError as e:
    print("Failed getting file from storage. Tried file $id(" + bundle_id + ")")
    raise e

# Decode file into json obj
# already done somehow??

try:
    # Setup Database
    database = Database(client)
    # Get collection attributes
    database = Database(client)
    collectionId = result["collectionId"]
    attributeList = database.list_attributes(collectionId)
except SomeError as e:
    print("Failed getting collection attributes for collection $id:")
    print(result["collectionId"])
    raise e


try:
    # Get collection_id & data from obj
    data = result["data"]

    # Loop thru data and prepare to insert
    dataList = []
    for dataRow in data:
        dataMap = {}
        i = 0
        for attr in attributeList["attributes"]:
            dataMap[attr["key"]] = dataRow[i]
            i += 1
        dataList.append(dataMap)
except SomeError as e:
    print("Failed connecting the data rows with collection attributes.")
    raise e

try:
    # insert into database
    insertResults = []
    for dataRow in dataList:
        # inserting row
        insertResult = database.create_document(
            collectionId, 'unique()', dataRow)
        insertResults.append(insertResult)
except SomeError as e:
    print("Failed inserting data rows into database. Number of rows completed were:")
    print(len(insertResults))
    raise e

print("Inserted " + str(len(insertResults)) + " rows of data out of " +
      str(len(data)) + " to collection $id(" + str(collectionId) + ") in file $id(" + bundle_id + ")")
