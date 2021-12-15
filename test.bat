git log -1 --pretty=%%B>>git.txt

cd %workspace%
python python_snippets\bundle_get_project.py git.txt project.txt