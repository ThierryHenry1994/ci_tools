import fire
from xml.dom import minidom
from redminelib import Redmine

def get_result_from_xml(path):
    # time.sleep(3)
    title_list = []
    dom_obj = minidom.parse(path)
    root = dom_obj.documentElement
    nodes = root.getElementsByTagName("testcase")
    # print(nodes)
    for node in nodes:
        for n in node.getElementsByTagName("verdict"):
            result = n.getAttribute("result")
            print(result)
            if result == "fail":
                title = node.getElementsByTagName("title")[0].childNodes[0].nodeValue
                title_list.append(title)
    return title_list


def create_issue(path,jenkins_url,version):
    testcase = get_result_from_xml(path)
    redmine_url = 'https://redmine.bitech-auto.com/redmine'
    redmine_key = '1c159c411c8ed320899935a55779f8c22b2a0f13'
    issue_project = 139
    issue_subject ='[CI][T19C]network management testcase execute failed'
    issue_description = 'pls check report on '+jenkins_url+"  testcase is "+str(testcase)
    issue_status = 1

    redmine = Redmine(url=redmine_url, key=redmine_key)
    redmine.issue.create(project_id=issue_project,subject=issue_subject, tracker_id=1,description= issue_description,
    status_id=issue_status, assigned_to_id=232, custom_fields=[{'id': 11, 'value': 232}, {'id': 9, 'value': version}]
    )


#get_result_from_xml("X95_NM_AutoTest_report.xml")
# create_issue("X95_NM_AutoTest_report.xml", "111", "develop")
fire.Fire(create_issue)