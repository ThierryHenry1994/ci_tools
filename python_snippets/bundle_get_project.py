import os
import fire

bundle_list = ["EC24_C_T1_AUO", "EC24_C_T1_HX", "EC24_C_M1_AUO", "EC24_C_M1_HX", "A02_C_T1_AUO"]
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
            if "project" in line:
                project = line.split("\n")
                print(project)
                for i in project:
                    if "project" in i:
                        name = i.split(":")[1].split(",")
                        print(name)
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
write_project_file("git.txt","project.txt")
#fire.Fire(write_project_file)