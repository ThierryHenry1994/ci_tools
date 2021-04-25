import os
import fire


def get_file_from_project(project_path, file_path):
    for root, ds, fs in os.walk(project_path):
        for f in fs:
            if f.endswith('.cpp') or f.endswith(".c"):
                if f!="GPT_cfg.c" and f!="display.c" and f!="FP_cfg.c":
                    fullname = os.path.join(root, f)
                    with open(file_path+"/"+'qac_filelist.txt', "a") as log:
                        log.write(fullname+"\n")


if __name__ == '__main__':
    fire.Fire(get_file_from_project)

