import os
import fire

bundle_list = ["A02_C_T1_TM", "A02_C_T1_AUO", "B06_C_T1_TM", "B06_C_T1_AUO", "A08_C_T1_TM", "A08_C_M1_TM", "A08_P_T1_TM", "A08_P_M1_TM", "EC24_C_T1_TM", "EC24_C_T1_AUO", "EC24_C_M1_TM", "EC24_C_M1_AUO", "V72_C_T1_TM", "V72_C_M1_TM", "V72_P_T1_TM", "V72_P_M1_TM", "B16_C_T1_TM", "B16_C_M1_TM", "D01_C_T1_TM", "D01_C_M2_TM", "D02_C_T1_TM", "D02_C_M2_TM", "CC02_C_T1_TM", "CC02_C_T1_TM", "CC02_C_M2_TM", "CC02_C_M2_TM", "CC03_C_T1_TM", "CC03_C_T1_TM", "CC03_C_M2_TM", "CC03_C_M2_TM", "V71_A_T2_BOE", "V71_A_M1_BOE", "TEST_BOX"]

# 执行BAT命令
def execCmd(cmd):
    r = os.popen(cmd)
    text = r.read()
    r.close()
    return text
def check_txt(project_file):
    if os.path.getsize(project_file):
        return True
    else:
        return False
    
def write_project_file(source_file,target_file):
    project_list =[]

    with open(target_file, "w") as f:
        logfile = open(source_file, "r")
        lines = logfile.readlines()
        for line in lines:
            if "[project]" in line:
                project = line.split("\n")
                print("project row is {0}".format(project))
                for i in project:
                    if "project" in i:
                        name = i.split(":")[1].split(",")
                        print("project name is {0}".format(name))
                        if name[0] == "All" or name[0] == "ALL":
                            print("this is",name[0])
                            for bundle in bundle_list:
                                f.write(bundle + "\n")
                        else:

                            for j in name:
                                if j in bundle_list:
                                    f.write(j + "\n")
                                else:
                                    raise BaseException("param not in project name list!!! pls check it")
    if check_txt(target_file):
        print("======================get project name success========================")
    else:
        raise BaseException("=============commit message is not valid!!!! pls check it =================")
#write_project_file("../git.txt","project.txt")
fire.Fire(write_project_file)