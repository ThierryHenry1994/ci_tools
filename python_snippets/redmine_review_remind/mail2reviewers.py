import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
import base64


def send_mail(date, task_id, task_subject, review_list):
    from_addr = 'guj1whu@bitech-automotive.com'
    password = 'Q1l6cGhlbnJ5NzMyMTU4'
    pwd = base64.b64decode(password)
    # 输入SMTP服务器地址:
    smtp_server = 'smtp.partner.outlook.cn'
    msg = MIMEText('please check project people', 'plain', 'utf-8')
    # SMTP协议默认端口是25
    server = smtplib.SMTP(smtp_server, 25)
    # server.set_debuglevel(1)
    server.ehlo()  # 向邮箱发送SMTP 'ehlo' 命令
    server.starttls()
    server.login(from_addr, bytes.decode(pwd))
    msg = MIMEMultipart()
    msg['Subject'] = Header('remine_task_remind', 'utf-8').encode()
    message = MIMEText('<html><body>Hi'+"\n" +'<p>当前距离 <a href="https://redmine.bitech-auto.com/redmine/issues/'+str(task_id)+'">'+task_subject+'</a>设置的Review date还剩'+str(date)+'天请注意合理安排时间，谢谢</p>' +'</body></html>', 'html', 'utf-8')
    msg.attach(message)
    server.sendmail(from_addr, review_list, msg.as_string())
    server.quit()

