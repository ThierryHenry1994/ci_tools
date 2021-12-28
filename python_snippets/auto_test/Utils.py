import fire
from xml.dom import minidom
from redminelib import Redmine

def get_result_from_xml(path):
    # time.sleep(3)
    config_dict= {}
    title_list = []
    dom_obj = minidom.parse(path)
    root = dom_obj.documentElement
    nodes = root.getElementsByTagName("testcase")
    # print(nodes)
    for node in nodes:
        for n in node.getElementsByTagName("verdict"):
            result = n.getAttribute("result")
            title = node.getElementsByTagName("title")[0].childNodes[0].nodeValue
            config_dict[title] = result
    return config_dict


def create_issue(path, jenkins_url, version):
    testcase = get_result_from_xml(path)
    redmine_url = 'https://redmine.bitech-auto.com/redmine'
    redmine_key = '1c159c411c8ed320899935a55779f8c22b2a0f13'
    issue_project = 139
    issue_subject ='[CI][T19C]network management testcase execute failed'
    issue_description = 'pls check report on '+jenkins_url+"  testcase is "+str(testcase)
    issue_status = 1

    redmine = Redmine(url=redmine_url, key=redmine_key)
    issue = redmine.issue.create(project_id=issue_project, subject=issue_subject, tracker_id=1, description= issue_description,
    status_id=issue_status, assigned_to_id=232, custom_fields=[{'id': 11, 'value': 232}, {'id': 9, 'value': version}]
    )
    print(issue.id)


def update_issue(issue_id, status_id, testcase, jenkins_url, version):
    redmine_url = 'https://redmine.bitech-auto.com/redmine'
    redmine_key = '1c159c411c8ed320899935a55779f8c22b2a0f13'
    issue_project = 139
    issue_subject = '[CI][T19C]network management testcase execute is also failed'
    issue_description = 'pls check report on ' + jenkins_url + "  testcase is " + str(testcase)


    redmine = Redmine(url=redmine_url, key=redmine_key)
    redmine.issue.update(resource_id =issue_id,project_id=issue_project, subject=issue_subject, tracker_id=1, description=issue_description,
                         status_id=status_id, assigned_to_id=232,
                         custom_fields=[{'id': 11, 'value': 232}, {'id': 9, 'value': version}]
                         )

def close_issue(issue_id, status_id, testcase, jenkins_url, version):
    redmine_url = 'https://redmine.bitech-auto.com/redmine'
    redmine_key = '1c159c411c8ed320899935a55779f8c22b2a0f13'
    issue_project = 139
    issue_subject = '[CI][T19C]network management testcase execute is also failed'
    issue_description = 'pls check report on ' + jenkins_url + "  testcase is " + str(testcase)


    redmine = Redmine(url=redmine_url, key=redmine_key)
    redmine.issue.update(resource_id =issue_id,project_id=issue_project, subject=issue_subject, tracker_id=1, description=issue_description,
                         status_id=status_id, assigned_to_id=232,
                         custom_fields=[{'id': 11, 'value': 232}, {'id': 9, 'value': version}]
                         )

def utils(xml_path,log_file,version,url):
    issue_dict = get_result_from_xml(xml_path)
    # print(issue_dict)
    issue_file = open(log_file, "r+")
    lines = issue_file.readlines()
    for line in lines:
        _str = line.split(",")
        result = issue_dict.get(_str[0])
        if "fail" in result:
            # 今天失败，昨天成功
            if "pass" in _str[1]:
                issue_id = create_issue()
                issue_file.write(_str[0]+","+"failed"+","+issue_id)
                issue_file.seek(0)
            # 今天失败，昨天失败
            else:
                update_issue(_str[2], 1, _str[0], url, version)
        else:
            print(_str[1], result)
            # 今天成功，昨天成功
            if "pass" in _str[1]:
                print("{0} is also pass today".format(_str[0]))
            # 今天成功，昨天失败
            else:
                print(line)
                print("{0} pls close this issue,issue num is {1}".format(_str[0], _str[2]))
                update_issue(_str[2], 5, _str[0], url, version)
    log_file.close()



# get_result_from_xml("T19C_NM_AutoTest_report.xml")
# create_issue("T19C_NM_AutoTest_report.xml", "111", "develop")
# close_issue("15711", 5, "testcase","jenkins", "develop")
#utils("T19C_NM_AutoTest_report.xml", "issue.txt")
fire.Fire(utils)