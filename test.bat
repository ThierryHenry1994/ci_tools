git log -1 --pretty=%%B>>git.txt

cd %workspace%
python ci_tools\python_snippets\bundle_get_project.py git.txt project.txt