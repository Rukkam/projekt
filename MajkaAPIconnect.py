import requests
import re
import mysql.connector
from mysql.connector import errorcode

# připojení k databázi
connection = mysql.connector.connect(
   host='localhost',
   database='projektda',
   user='root',
   password='***')

# kontrola připojení
cursor = connection.cursor()
cursor.execute("select database();")
record = cursor.fetchone()
print("Aktuální databáze je: ", record) 

current_line_num = 1
# čte řádky ze souboru se seznamem unikátních slov
with open("KW_k_lematizaci.txt", mode="r", encoding="utf8") as textFile:
    
    # každý řádek pošle na API pro lematizaci a uloží výstup do proměnné
    i = 1
    for line in textFile:
        # i = i + 1
        # if i == 3:
        #     break
        KWlist = line
        url = f"https://nlp.fi.muni.cz/languageservices/service.py?call=tagger&lang=cs&output=json&text={KWlist}"
        lemmata = requests.get(url)
        current_line_num += 1 # číslo řádku, odkterého se má začít v případě přerušení
        print(url)
        print(lemmata)
        # ze výstupu z lematizátoru vytáhne původní klíčové slovo, jeho zlematizovanou podobu a kód morfologických kategorií
        zlematizovane = re.findall(r'\["(\w+)", "(\w+)", "([^"]+)"\]', lemmata.text)     
        for tripple in zlematizovane:
            keyword = tripple[0]
            lemmatized_kw = tripple[1]
            morf = tripple[2]
            update_statement = f"UPDATE keywords_unique SET lemmatized_kw = '{lemmatized_kw}', morfologie = '{morf}' WHERE keyword = '{keyword}';"

            # tyto hodnoty uloží do databáze do tabulky keywords_unique    
            try:
                cursor.execute(update_statement)
            except mysql.connector.Error as err:
                    print(err.msg)
                    print(keyword)
                    print(update_statement)
           
    cursor.execute("COMMIT;")


# ukočení připojení k MySQL
cursor.close()
connection.close()
