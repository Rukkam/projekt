import mysql.connector

# kontrola připojení
try:
    connection = mysql.connector.connect(
        host='localhost',
        database='projektda',
        user='root',
        password='***')

    cursor = connection.cursor()
    cursor.execute("select database();")
    record = cursor.fetchone()
    print("Aktuální databáze je: ", record)

    
    allowed_len = 10000
    cursor.execute(f"SELECT keyword FROM keywords_unique;")
    record = cursor.fetchall()
    with open("KW_k_lematizaci.txt", mode="w", encoding="utf8") as textFile:
        line_len = 0
        file_line = []
        i = 1
        for kw in record:
            KW_len = len(kw[0])
            if line_len + KW_len + 1 < allowed_len:
                # zapiš slovo na aktuální řádek
                file_line.append(kw[0])
                line_len = line_len + KW_len + 1
            else:
                # zapiš slovo na další řádek
                textFile.write(" ".join(file_line) + "\n")
                file_line = [kw[0]]
                line_len = KW_len
                # i = i + 1
                # if i == 10:
                #     break
        if file_line != []:
            textFile.write(" ".join(file_line))
           
except mysql.connector.Error as error:
        print(f"Failed to get record from MySQL table: {error}")

finally:
    if (connection.is_connected()):
        cursor.close()
        connection.close()
        print("MySQL connection is closed")
