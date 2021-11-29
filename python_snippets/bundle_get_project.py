import os
import fire

bundle_list = ["EC24_C_T1_AUO", "EC24_C_T1_HX", "EC24_C_M1_AUO", "EC24_C_M1_HX"]
# 执行BAT命令
def execCmd(cmd):
    r = os.popen(cmd)
    text = r.read()
    r.close()
    return text

def write_project_file(source_file,target_file):
    project_list =[]

    with open(target_file, "w") as f:
        logfile = open(source_file, "r")
        lines = logfile.readlines()
        for line in lines:
            if "project" in line:
                project = line.split("\n")
                print(project)
                for i in project:
                    if "project" in i:
                        name = i.split(":")[1].split(",")
                        print(name)
                        for j in name:
                            if j in bundle_list:
                                f.write(j + "\n")
                            else:
                                raise BaseException("param not in project name list!!! pls check it")

#write_project_file("..\\git.txt","project.txt")
fire.Fire(write_project_file)