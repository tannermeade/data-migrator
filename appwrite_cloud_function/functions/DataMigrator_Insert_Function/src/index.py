# # general imports
# import os
# from datetime import datetime, timedelta

# # dependencies
# from appwrite.client import Client
# from appwrite.services.storage import Storage
# from appwrite.services.database import Database

# # Setup the appwrite SDK
# try:
#     client = Client()
#     client.set_endpoint(os.environ['APPWRITE_ENDPOINT'])
#     client.set_project(os.environ['APPWRITE_FUNCTION_PROJECT_ID'])
#     client.set_key(os.environ['APPWRITE_API_KEY'])
# except SomeError as e:
#     print('Failed creating client. Check cloud function's environment variables: APPWRITE_ENDPOINT, APPWRITE_FUNCTION_PROJECT_ID, APPWRITE_API_KEY')
#     raise e

# try:
#     # Get parameters from execution command
#     bundle_id = os.environ['APPWRITE_FUNCTION_DATA']

#     # Get file from storage
#     storage = Storage(client)
#     result = storage.get_file_download(bundle_id)
# except SomeError as e:
#     print('Failed getting file from storage. Tried file $id(' + bundle_id + ')')
#     raise e

# # Decode file into json obj
# # already done somehow??

# try:
#     # Setup Database
#     database = Database(client)
#     # Get collection attributes
#     collectionId = result['collectionId']
#     attributeList = database.list_attributes(collectionId)
# except SomeError as e:
#     print('Failed getting collection attributes for collection $id:')
#     print(result['collectionId'])
#     raise e


# try:
#     # Get collection_id & data from obj
#     data = result['data']

#     # Loop thru data and prepare to insert
#     dataList = []
#     for dataRow in data:
#         dataMap = {'$id': dataRow[0]}
#         i = 1
#         for attr in attributeList['attributes']:
#             dataMap[attr['key']] = dataRow[i]
#             i += 1
#         dataList.append(dataMap)
# except SomeError as e:
#     print('Failed connecting the data rows with collection attributes.')
#     raise e

# try:
#     # insert into database
#     insertResults = []
#     for dataRow in dataList:
#         # inserting row
#         id = dataRow['$id']  # 'unique()'
#         del dataRow['$id']
#         insertResult = database.create_document(collectionId, id, dataRow)
#         insertResults.append(insertResult)
# except SomeError as e:
#     print('Failed inserting data rows into database. Number of rows completed were:')
#     print(len(insertResults))
#     raise e

# print('Inserted ' + str(len(insertResults)) + ' rows of data out of ' +
#       str(len(data)) + ' to collection $id(' + str(collectionId) + ') in file $id(' + bundle_id + ')')



from operator import contains
import os
from datetime import datetime, timedelta
from appwrite.client import Client

# You can remove imports of services you don't use
from appwrite.services.account import Account
from appwrite.services.avatars import Avatars
from appwrite.services.database import Database
from appwrite.services.functions import Functions
from appwrite.services.health import Health
from appwrite.services.locale import Locale
from appwrite.services.storage import Storage
from appwrite.services.teams import Teams
from appwrite.services.users import Users

def main(req, res):
    resultString = 'hello world'
    
    client = setupClient()
    resultString += '\nmade client obj'

    # # Get data bundle
    bundleId = os.environ['APPWRITE_FUNCTION_DATA']
    bundle = getBundle(bundleId, client)
    resultString += '\ndone getting bundle'

    # Prepare for database work
    db = Database(client)
    collectionId = bundle['collectionId']
    
    # Prepare Data
    preparedData = prepareData(bundle)
    
    # Insert Data
    insertResults = insertData(db, collectionId, preparedData)

    resultString += '--Inserted ' + str(len(insertResults)) + ' rows of data out of ' + str(len(bundle['data'])) + ' to collection $id(' + str(collectionId) + ') in file $id(' + bundleId + ')'
    
    return res.json({
        'areDevelopersAwesome': True,
        'result': resultString,
    })


# Setup the appwrite SDK
def setupClient():
    try:
        print('connecting client')
        print(os.environ['APPWRITE_ENDPOINT'])
        print(os.environ['APPWRITE_FUNCTION_PROJECT_ID'])
        print(os.environ['APPWRITE_API_KEY'])
        client = Client()
        print('made client obj')
        client.set_endpoint(os.environ['APPWRITE_ENDPOINT'])
        print('set endpoint')
        client.set_project(os.environ['APPWRITE_FUNCTION_PROJECT_ID'])
        print('set project')
        client.set_key(os.environ['APPWRITE_API_KEY'])
        print('set key... done')
        return client
    except Exception as e:
        print("Failed creating client. Check cloud function's environment variables: APPWRITE_ENDPOINT, APPWRITE_FUNCTION_PROJECT_ID, APPWRITE_API_KEY")
        raise e

def getBundle(bundleId, client):
    try:
        # Get file from storage
        storage = Storage(client)
        return storage.get_file_download('data_migrator_upload_bucket_id', bundleId)
    except Exception as e:
        print('Failed getting file from storage. Tried file $id(' + bundleId + ')')
        raise e

def getCollectionAttributes(db, collectionId):
    try:
        # Get collection attributes
        collectionId = collectionId
        return db.list_attributes(collectionId)
    except Exception as e:
        print('Failed getting collection attributes for collection $id:')
        print(collectionId)
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
        print('Failed connecting the data rows with collection attributes.')
        raise e

def insertData(db, collectionId, preparedData):
    try:
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
        print('Failed inserting data rows into database. Number of rows completed were:')
        print(len(insertResults))
        raise e