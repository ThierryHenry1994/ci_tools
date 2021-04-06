import fire


def get_file_from_git_pull(git_pull_log):
    file_list = []
    text_file = open(git_pull_log, "r")
    lines = text_file.readlines()
    for line in lines:
        if "|" in line:
            filename = line.split("|")[0]
            file_list.append(filename)
    text_file.close()
    return file_list


def write_data(data_list, data_file):
    with open(data_file, "w") as f:
        for data in data_list:
            f.write(data.strip()+"\n")


def write_qac_file_list(git_log, qac_file):
    change_list = get_file_from_git_pull(git_log)
    write_data(change_list, qac_file)


if __name__ == "__main__":
    fire.Fire(write_qac_file_list)
