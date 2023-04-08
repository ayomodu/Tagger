from fastapi import FastAPI
from typing import Optional
from pydantic import BaseModel
import sqlite3


class Item(BaseModel):
    project_name: str = None
    development_version: Optional[str] = None
    staging_version: Optional[str] = None
    production_version: Optional[str] = None

app = FastAPI()

@app.get("/api/health")
def get_health():
    return { "Status" : "Healthy" }

@app.post("/api/add_project/")
def add_project(item: Item):
    project_name, development_version, staging_version, production_version = item.project_name, item.development_version, item.staging_version, item.production_version
    data = (project_name, development_version, staging_version, production_version)
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
        cursor.execute("INSERT INTO tagger values (?,?,?,?)", data)
        return {"Success": f"Project {project_name} Added"}
    except:
        print(f"Project {project_name} already exists")
        if development_version != None:
            cursor.execute(f'insert into tagger (project_name,development) values("{project_name}", "{development_version}") \
                           on conflict(project_name) do update set development=excluded.development')
            return {"Success": f"Project {project_name} development version updated to: {development_version}"}
        if staging_version != None:
            cursor.execute(f'insert into tagger (project_name,staging) values("{project_name}", "{staging_version}") \
                           on conflict(project_name) do update set staging=excluded.staging')
            return {"Success": f"Project {project_name} staging version updated to: {staging_version}"}
        if production_version != None:
            cursor.execute(f'insert into tagger (project_name,production) values("{project_name}", "{production_version}") \
                           on conflict(project_name) do update set production=excluded.production')
            return {"Success": f"Project {project_name} production version updated to: {production_version}"}
    finally:
        connection.commit()
        connection.close()
    
    

# @app.get("/api/get_projects/")
# def get_all():
#     try:
#         connection = sqlite3.connect('tagger.db')
#         cursor = connection.cursor()
#         cursor.execute("SELECT * FROM tagger")
#         results = cursor.fetchall()
#         return results


    