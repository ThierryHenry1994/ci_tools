def get_file_from_git_pull():
    file_list = []
    text_file = open("test.txt", "r")
    lines = text_file.readlines()
    for line in lines:
        if "|" in line:
            filename = line.split("|")[0]
            file_list.append(filename)
    text_file.close()
    return file_list


def write_data(data_list):
    with open("filelist.txt", "w") as f:
        for data in data_list:
            f.write(data.strip()+"\n")


list1 = get_file_from_git_pull()
write_data(list1)
