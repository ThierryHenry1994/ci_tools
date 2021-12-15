import time
import fire

def get_result_from_check_report(path):
    time.sleep(3)
    logfile = open(path, "r")
    lines = logfile.readlines(logfile)
    for line in lines:
        if "class=\"NegativeResult\"" in line:
            if "failed" in line:
                raise Exception(print("Programmable power or ECU supply is out of control!!!! pls check it!!!!"))
            else:
                print("Programmable power or ECU supply is under of control")


fire.Fire(get_result_from_check_report)