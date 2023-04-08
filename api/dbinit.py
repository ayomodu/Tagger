import sqlite3
try:
        connection = sqlite3.connect('tagger.db')
        cursor = connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tagger (
            project_name TEXT NOT NULL UNIQUE,
            development TEXT,
            staging TEXT,
            production TEXT,
            PRIMARY KEY(project_name)
            )
        ''')
        connection.commit()
except (Exception, sqlite3.Error):
        print("Unable To Initialize DB")
except (Exception, sqlite3.Error):
        print("Unable To Setup Schema")
finally:
        connection.close()

db_init()