import MySQLdb
import time
import fire

def get_count_from_mysql():
    db = MySQLdb.connect("10.179.48.90", "redmine_db_user", "Dk9HYb6ri2", "redmine")
    cursor = db.cursor()
    sql = "SELECT count(*) from issues i WHERE project_id in (79,110,111,112,113,114,117,118,119) and status_id not in (5,6) and tracker_id =1"
    try:
        cursor.execute(sql)
        result = cursor.fetchall()
    except:
        print("ERROR")
    # 获取今天p03的打开issue的数量
    sum = result[0][0]
    raw_time = time.gmtime()
    datetime = time.strftime("%Y-%m-%d", raw_time)
    insert_sql = "INSERT INTO daliy_open_issues_count ( date_time ,project_name,sum_num ) VALUES (DATE_FORMAT(now(), '%%Y-%%m-%%d'),'GMW_P03',%d)" % (sum)
    try:
        cursor.execute(insert_sql)
        db.commit()
        print("success")
    except:
        db.rollback()
        print("failed")
    db.close()

fire.Fire(get_count_from_mysql)