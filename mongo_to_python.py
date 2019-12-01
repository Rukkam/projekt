import pymongo
import pprint
import re

myclient = pymongo.MongoClient()
mydb = myclient['daprojekt']
mycol = mydb["firm_db_web_keywords"]
print(mydb.list_collection_names())
i=1

with open("keyword_nove.txt", mode='w', encoding='utf-8')as f:
    for x in mycol.find({},{"firm_id":1,"keyword":1}):
        x=str(x)
        f.write("{}\n".format(x))
        pprint.pprint(x)
