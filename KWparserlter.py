'''
Vyčte z textového exportu z MongoDB firm_id a keywords a nahraje je do tabulky v databázi
'''

import sys
import mysql.connector
from mysql.connector import errorcode
import re


def getFirmID(line):  
    # získá ze zadaného řádku firm_id a vrátí ho   
    id = re.search(r"'firm_id': ([\d]+)", line)  
    return int(id.group(1))
    

def getAllKeywords(line):
    # získá ze zadaného řádku všechna keywords a vrátí je v seznamu
    return re.findall( r"name': '(.*?)'", line)

def splitKeywords(list):
    # rozdělí keywords na jednotlivá slova a vrátí je v seznamu
    # současně nahradí speciální znaky mezerami -
    # - jednak kvůli správnému oddělení slov, jednak kvůli vyřazení znaků nepovolených v URL (pro API Majky)
    splitedKW = []
    for i in list:
        splited = []
        i = i.replace('e-mail', 'email')
        i = i.replace('-'," ")
        i = i.replace(':'," ")
        i = i.replace('|'," ")
        i = i.replace(','," ")
        i = i.replace(';'," ")
        i = i.replace('*'," ")
        i = i.replace('+'," ")
        i = i.replace('\\n'," ")
        i = i.replace('\\t'," ")
        i = i.replace('\\r'," ")
        i = i.replace('\\'," ")
        i = i.replace('&'," ")
        i = i.replace('"'," ")
        i = i.replace("'"," ")
        i = i.replace('/'," ")
        i = i.replace('#'," ")
        i = i.replace('!'," ")
        i = i.replace('('," ")
        i = i.replace(')'," ")
        i = i.replace('_'," ")
        i = i.replace('„'," ")
        i = i.replace('“'," ")
        i = i.replace('['," ")
        i = i.replace(']'," ")
        splited = i.split()
        for j in splited:
            if not (("@" in j) or ("www." in j) or ("http" in j) or (".cz" in j) or (".net" in j) or (".com" in j) or (".eu" in j) or (".sk" in j) or (".org" in j)):
                j = j.replace('.'," ")
                splitedKW.extend(j.split())
    return splitedKW

def upravKeyword(keyword):
    # keyword = keyword.strip() - vyřešeno ve splitKeywords()
    keyword = keyword.lower()
    # otazníky prozatím nevyřazovat! Jsou potřeba k vytřídění špatně kódovaných slov v SQL 
    return keyword                
          
# připojení k MySQL
connection = mysql.connector.connect(
   host='localhost',
   database='projektda',
   user='root',
   password='sqlmy')

# kontrola připojení
cursor = connection.cursor()
cursor.execute("select database();")
record = cursor.fetchone()
print("Aktuální databáze je: ", record)

DB_NAME = 'projektda'

# příprava MySQL statementu na vytvoření tabulky
table_name = "firm_keywords"
create_statement = f"CREATE TABLE `{table_name}` (`id` int NOT NULL AUTO_INCREMENT,`firm_id` int(11) NOT NULL,`keyword` varchar(1024),`kw_status` varchar(16), PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"


# vytvoření tabulky - pokud existuje, smaže ji
try:
    cursor.execute(f"DROP TABLE if exists {table_name};")
    print(f"Creating table {table_name}: ", end='')
    cursor.execute(create_statement)
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_TABLE_EXISTS_ERROR:
        print(f"Table {table_name} already exists.")
    else:
        print(err.msg)
else:
    print("OK")
    
# čtení ze souboru a zápis do MySQL databáze
with open("soubor_keyword.txt", encoding="utf8") as textFile:
    i = 1
    for row in textFile:
        # i = i + 1
        # if i == 1000:
        #     break
        try:
            firm_id = getFirmID(row)
        except:
            print("Invalid firm_id on line:")           
            print(row)
            continue
        keywords = getAllKeywords(row)
        keywords = splitKeywords(keywords)
        for keyword in keywords:
            keyword = upravKeyword(keyword)
            if len(keyword) in range (1,1025):
                #print(firm_id, keyword)
                insert_statement = f'INSERT INTO `{table_name}` (`firm_id`,`keyword`) VALUES ({firm_id},"{keyword}");'
                try:
                    cursor.execute(insert_statement)   
                except mysql.connector.Error as err:
                    print(err.msg)
                    print(firm_id)
                    print(keyword)
                    print(insert_statement)
                    
    cursor.execute("COMMIT;")


# ukočení připojení k MySQL
cursor.close()
connection.close()
