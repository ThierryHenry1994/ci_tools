import time
import fire
from xml.dom import minidom
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


def get_result_from_xml(path):
    time.sleep(3)
    dom_obj = minidom.parse(path)
    root = dom_obj.documentElement
    nodes = root.getElementsByTagName("verdict")
    print(nodes)
    for node in nodes:
        s = node.getAttribute("result")
        if s == "pass":
            print("Programmable power or ECU supply is under of control")
        else:
            raise Exception(print("Programmable power or ECU supply is out of control!!!! pls check it!!!!"))

#get_result_from_xml("DetectPower_report.xml")
fire.Fire(get_result_from_xml)