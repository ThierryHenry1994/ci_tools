from redminelib import Redmine


def get_issue_from_redmine(redmine_url, redmine_key, project):
    issue_data = []
    url = redmine_url
    key = redmine_key
    redmine = Redmine(url=url, key=key)
    issues = redmine.project.get(project).issues
    for issue in issues:
        for item in list(issue):
            if item[0] == "tracker":
                # 只抓取tracker类型为review的issue
                if item[1]["id"] == 12:
                    issue_data.append(list(issue))
    return issue_data


def handle_issue_data(redmine_url, redmine_key, issue_list):
    data_list = []
    for issue in issue_list:
        data_dict = {}
        reviewer_list = []
        for item in issue:
            # print(item)
            if item[0] == "id":
                issue_id = item[1]
            if item[0] == "subject":
                subject = item[1]
            if item[0] == "assigned_to":
                assign = item[1]["id"]
            if item[0] == "custom_fields":
                for custom_field in item[1]:
                    if custom_field["name"] == "Review预定日":
                        review_date = custom_field["value"]
                    if "评审者" in custom_field["name"]:
                        if "value" in custom_field.keys():
                            if custom_field["value"] != "":
                                reviewer_list.append(get_mail_by_id(redmine_url, redmine_key, custom_field["value"]))

        if issue_id:
            data_dict["issue_id"] = issue_id
        else:
            data_dict["issue_id"] = ""
        if assign:
            data_dict["assign"] = assign
        else:
            data_dict["assign"] = ""
        if review_date:
            data_dict["review_date"] = review_date
        else:
            data_dict["review_date"] = ""
        if reviewer_list:
            data_dict["reviewers"] = reviewer_list
        else:
            data_dict["reviewers"] = ""
        if subject:
            data_dict["subject"] = subject
        else:
            data_dict["subject"] = ""
        data_list.append(data_dict)
    #print(data_list)
    return data_list


def get_mail_by_id(redmine_url, redmine_key, redmine_id):
    redmine = Redmine(url=redmine_url, key=redmine_key)
    user = redmine.user.get(redmine_id)
    mail = user.mail
    return mail


#data_list = get_issue_from_redmine('https://redmine.bitech-auto.com/redmine', "1c159c411c8ed320899935a55779f8c22b2a0f13", "gmw_p03")
# print(data_list)
#handle_issue_data('https://redmine.bitech-auto.com/redmine', "1c159c411c8ed320899935a55779f8c22b2a0f13", data_list)