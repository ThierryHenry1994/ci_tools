import os
import zipfile
import json
import shutil
import fire


def get_zip(version, config, project_name, source_root, target_root):
    target_root="SVN/"+target_root
    if os.path.exists(source_root):
        create_target_root(target_root)
        make_root_dict = get_config_from_json(project_name, json_config=config)
        for _root in make_root_dict.keys():
            create_target_root(os.path.join(target_root, _root))
            if not make_root_dict[_root] == []:
                # 配置文件中如果需要文件夹下所有文件末尾加上*
                if match_rules_endswith("*", make_root_dict[_root][0]):
                    for root, dirs, files in os.walk(make_root_dict[_root][0].split("/*")[0]):
                        for f in files:
                            # 复制某个文件夹下的所有文件到指定文件夹
                            shutil.copy(os.path.join(root, f), os.path.join(target_root, _root))
                else:
                    # 复制指定文件到指定文件夹
                    for target_file in make_root_dict[_root]:
                        shutil.copy(target_file, os.path.join(target_root, _root))
    else:
        raise FileNotFoundError("build target folder not exists")
    svnCommit(target_root)

# 创建产物存档文件夹
def create_target_root(path):
    if not os.path.exists(path):
        os.mkdir(path)


# 基于文本尾部进行规则匹配
def match_rules_endswith(rule, str):
    if str.endswith(rule):
        return True
    else:
        return False


# 基于json文件创建release目录
def get_config_from_json(project_name, json_config):
    json_file = open(json_config, "rb")
    load_dict = json.load(json_file)
    # print(load_dict[project_name])
    return load_dict[project_name]


# 基于版本号和项目名重命名产物
def rename_item(project, version, filename):
    new_name = project+version
    file_type = "."+filename.split(".")[-1]
    os.rename(filename, new_name+file_type)
    return
    '''
    except:
        raise FileNotFoundError("Rename file failed")
    '''

# 执行BAT命令
def execCmd(cmd):
    r = os.popen(cmd)
    text = r.read()
    r.close()
    return text

# svn commit
def svnCommit(localDir):
    command_str = "svn add --force " + localDir
    text = execCmd(command_str)
    print(text)

    command_str = "svn ci -m auto_commit " + localDir
    text = execCmd(command_str)
    print(text)

#svnCommit("ci_test\Test\config")
# get_zip( "SWP2.20", "dir_config.txt", "GAC_A88", "code_build_target_release/RELEASE", "SVN/ci_test")
fire.Fire(get_zip)