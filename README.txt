1、变量命名规则
	1.1、全局变量全部大写
	1.2、局部变量全部小写
	1.3、入口的参数配置文件中，所有变量为全局变量，以“IN_”开头
	1.4、输出参数变量为全局变量，以“CI_”开头

2、参数配置文件内容全部为只读变量，每行一条
	sample：
		IN_BRANCH_NAME=分支名
		IN_TAG_NAME=tag名

3、脚本配置文件内容：脚本名 [input]
	输入/出参数配置文件名保存在 "PB_CI_PARAMS_CFG_TMP" 变量中
	脚本会先从“PB_CI_PARAMS_CFG_TMP”对应的文件中读出所有的变量，后续脚本可以重写或者追加变量到该文件
	原因：可能下一步的脚本需要用到上一步脚本的操作结果，上一步的结果以参数配置文件的方式传给下一步

参数说明：
	--param_cfg：参数配置文件
	--script_cfg 脚本配置文件
sample:
./entrypoint.sh --param_cfg sample_test/param_cfg.cfg --script_cfg sample_test/script_cfg.cfg

common_tools/common_functions.sh: 通用功能函数集，其他脚本可通过source之后使用

code_scripts/get_single_repo.sh: 获取单个仓库，需指定仓库url地址，分支名

build_scripts/system_build.sh:系统环境编译
	必须设定的变量：
		IN_WORKSPACE： 代码环境目录
		IN_LUNCH_NAME： lunch名
		IN_BUILD_COMMAND： 编译命令
	可选变量：
		IN_PRE_BUILD_COMMAND：编译前需执行的命令
		IN_PROJ_CCACHE_PROFILE：使用的ccache文件

release/clean_env.sh: 删除.repo以外的目录和文件；
	必须设定的变量：
		IN_WORKSPACE： 代码环境目录

release/compress_release.sh: 压缩release根目录下的文件夹；

release/package_release.sh: 拷贝release成果物到中间目录
	必须设定的变量：
		IN_WORKSPACE： 代码环境目录
		IN_JK_PROJECT： 项目名
		IN_BRANCH_NAME： release tag
		IN_LUNCH_NAME： lunch name
		IN_RELEASE_BRANCH： release branch
		IN_PROJECT_CONFIG_DIR: 存放project_config的路径

release/upload_release.sh: 上传release；
	必须设定的变量：
		IN_JK_PROJECT： 项目名
		IN_RELEASE_BRANCH： release branch
		IN_PROJECT_CONFIG_DIR: 存放project_config的路径
