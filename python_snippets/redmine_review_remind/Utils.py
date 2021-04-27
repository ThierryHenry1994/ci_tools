import get_issue_from_remine
import mail2reviewers
import time
import sys
import fire


def date_trans(raw_date):
    sp_date = raw_date.replace("/", "-")
    try:
        date_sec = time.strptime(sp_date, '%Y-%m-%d')
    except ValueError:
        print("%s is not a rightful date!!" % raw_date)
        sys.exit(1)
    return time.mktime(date_sec)


def time_diff(d1, d2):
    trans_time = 24 * 60 * 60
    if d1 > d2:
        return int((d1 - d2)/trans_time)
    else:
        return "overdue"


def handle_mail_list(redmine_url, redmine_key, project, num):
    issue_list = get_issue_from_remine.get_issue_from_redmine(redmine_url, redmine_key, project)
    data_list = get_issue_from_remine.handle_issue_data(redmine_url, redmine_key, issue_list)
    for data in data_list:

        review_date = date_trans(data["review_date"])
        now_date = date_trans(time.strftime("%Y-%m-%d"))
        if time_diff(review_date, now_date) == num:
            mail2reviewers.send_mail(num, data["issue_id"], data["subject"], data["reviewers"])
        '''
        if data["issue_id"] == 7026:
            mail2reviewers.send_mail(num, 7026, data["subject"], data["reviewers"])
        '''


if __name__ == "__main__":
    fire.Fire(handle_mail_list)
