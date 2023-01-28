from operator import contains
import os
import json
from datetime import datetime, timedelta
import sys

from appwrite.client import Client
from appwrite.services.database import Database
from appwrite.services.storage import Storage
from appwrite.services.users import Users

# from appwrite.services.account import Account
# from appwrite.services.avatars import Avatars
# from appwrite.services.functions import Functions
# from appwrite.services.health import Health
# from appwrite.services.locale import Locale
# from appwrite.services.teams import Teams

def main(req, res):
    resultString = 'hello world'
    
    client = setupClient()
    resultString += '\nmade client obj'
    
    # Get data bundle
    executionPayload = json.loads(os.environ['APPWRITE_FUNCTION_DATA'])
    bundleId = executionPayload['fileId']
    bundle = getBundle(bundleId, client)
    resultString += '\ndone getting bundle'
    insertResults = []
    
    destination = bundle['destination']
    if destination == "users":
        insertResults = handleUsersInsert(client, bundle)
    else:
        return res.json({
            'areDevelopersAwesome': True,
            'result': resultString,
        })
        insertResults = handleDatabaseInsert(client, bundle)
    
    resultString += '--Inserted ' + str(len(insertResults)) + ' rows of data out of ' + str(len(bundle['data'])) + ' to collection $id(' + 'str(collectionId)' + ') in file $id(' + bundleId + ')'
    
    return res.json({
        'areDevelopersAwesome': True,
        'result': resultString,
    })
    


def handleUsersInsert(client, bundle):
    # Prepare Data
    preparedData = prepareData(bundle)

    # Insert Users
    return insertUsersData(client, preparedData)

def insertUsersData(client, preparedData):
    # Prepare for user insert
    usersClient = Users(client)

    results = []
    for userData in preparedData:
        userId = "unique()"
        if "$id" in userData and userData["$id"] is not None:
            userId = userData["$id"]
        result = usersClient.create(userId, userData["email"], userData["password"])
        results.append(result)
    return results

def handleDatabaseInsert(client, bundle):
    # Prepare Data
    preparedData = prepareData(bundle)
    return preparedData
    # Insert Data
    return insertDatabaseData(client, bundle['collectionId'], preparedData)

# Setup the appwrite SDK
def setupClient():
    try:
        client = Client()
        client.set_endpoint(os.environ['APPWRITE_ENDPOINT'])
        client.set_project(os.environ['APPWRITE_FUNCTION_PROJECT_ID'])
        client.set_key(os.environ['APPWRITE_API_KEY'])
        return client
    except Exception as e:
        sys.stderr.write("Failed creating client. Check cloud function's environment variables: APPWRITE_ENDPOINT, APPWRITE_FUNCTION_PROJECT_ID, APPWRITE_API_KEY")
        raise e

def getBundle(bundleId, client):
    try:
        # Get file from storage
        storage = Storage(client)
        return storage.get_file_download('data_migrator_upload_bucket_id', bundleId)
    except Exception as e:
        sys.stderr.write('Failed getting file from storage. Tried file $id(' + bundleId + ')')
        raise e

def prepareData(bundle):
    try:
        # Get collection_id & data from obj
        data = bundle['data']
        collectionId = bundle['collectionId']

        # Get field list from bundle
        fields = bundle['fields']

        # Loop through data and prepare
        dataList = []
        for dataRow in data:
            if len(fields) != len(dataRow):
                raise Exception("dataRow has a different field count than the collectin. data/fields:", len(dataRow), len(fields), type(fields))
            dataMap = {}
            i = 0
            for dataField in dataRow:
                dataMap[fields[i]] = dataField
                i += 1
            dataList.append(dataMap)
        
        return dataList
    except Exception as e:
        sys.stderr.write('Failed connecting the data rows with collection attributes.')
        raise e

def insertDatabaseData(client, collectionId, preparedData):
    try:
        # Prepare for database work
        db = Database(client)

        # insert into database
        insertResults = []
        for dataRow in preparedData:
            #preparing the id
            id = 'unique()'
            if '$id' in dataRow:
                id = dataRow['$id']
                del dataRow['$id']
            
            # inserting row
            insertResult = db.create_document(collectionId, id, dataRow)
            insertResults.append(insertResult)
        
        return insertResults
    except Exception as e:
        sys.stderr.write('Failed inserting data rows into database. Number of rows completed were:')
        sys.stderr.write(len(insertResults))
        raise e

# def getCollectionAttributes(db, collectionId):
#     try:
#         # Get collection attributes
#         collectionId = collectionId
#         return db.list_attributes(collectionId)
#     except Exception as e:
#         sys.stderr.write('Failed getting collection attributes for collection $id:')
#         sys.stderr.write(collectionId)
#         raise e