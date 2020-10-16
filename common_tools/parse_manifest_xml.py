#!/usr/bin/python

import os
import sys
import xml.dom.minidom as minidom
import xml.etree.ElementTree as ET

if sys.version_info[0] == 3:
  import urllib.parse
else:
  import imp
  import urlparse
  urllib = imp.new_module('urllib')
  urllib.parse = urlparse


class manifest_xml():
    def __init__(self,xmlname):
        self.main_xmlpath = xmlname
        self.manifest_dir = os.path.dirname(xmlname)

    def parse_manifest_remote(self):
        self._remotes = {}
        domm = minidom.parse(self.main_xmlpath)
        root = domm.documentElement
        remote_list=root.getElementsByTagName("remote")
	if len(remote_list) == 0:
	    exit(0)

        for remote in remote_list:
            fetch_url=remote.getAttribute("fetch")
            fetch_url = urllib.parse.urljoin(manifest_url, fetch_url)
            name=remote.getAttribute("name")
            self._remotes[name]=fetch_url

    def parse_manifest_default(self):
        domm = minidom.parse(self.main_xmlpath)
        root = domm.documentElement
        default_list=root.getElementsByTagName("default")

        if len(default_list) > 0:
            default_node=default_list[0]
            self._default_remote=default_node.getAttribute("remote")
            self._default_revision=default_node.getAttribute("revision")

    def parse_manifest_project(self,path,include_root):
        domm=minidom.parse(path)
        root = domm.documentElement
        project_list=root.getElementsByTagName("project")
        for project in project_list:
            pathname=project.getAttribute("path")
            remote=project.getAttribute("remote")
            revision=project.getAttribute("revision")
            relative=project.getAttribute("name")
            groups=project.getAttribute("groups")

            if groups.find('notdefault') != -1:
                continue

            if remote:
                remote_url=self._remotes[remote]
                remote_name=remote
            else:
                remote_url=self._remotes[self._default_remote]
                remote_name=self._default_remote

            if revision:
                revision_name=revision
            else:
                revision_name=self._default_revision

            if not pathname:
                   pathname=relative

            project_url=os.path.join(remote_url, relative)

            project_pre="ssh://"

            cut_result=project_url[len(project_pre):]
            project_name=cut_result[cut_result.find("/")+1:]
            server_info=cut_result[:cut_result.find("/")]
            if server_info.find(":") != -1:
                server_name,server_port=server_info.split(":")
            else:
                server_name=server_info
                server_port="null"

            return_result=os.system("echo "+server_name+" "+server_port+" "+project_name+" "+relative+" "+pathname+" "+revision_name.replace('refs/heads/','')+" ")

            if return_result!=0:
                os.system("echo parse_xml_repolist.py failer: "+pathname+"")
                sys.exit(1)

        include_list=root.getElementsByTagName("include")

        for include in include_list:
            include_name = include.getAttribute("name")
            local=os.path.join(include_root, include_name)
            if not os.path.isfile(local):
                os.system("echo include" +include+ "doesn't exist or isn't a file ")
                sys.exit(1)
            else:
                self.parse_manifest_project(local,include_root)

    def parse(self):
        self.parse_manifest_remote()
        self.parse_manifest_default()
        self.parse_manifest_project(self.main_xmlpath, self.manifest_dir)

if __name__ == '__main__':
    xmlname=sys.argv[1]
    manifest_url=sys.argv[2]

    urllib.parse.uses_relative.extend(['ssh', 'git', 'persistent-https', 'rpc'])
    urllib.parse.uses_netloc.extend(['ssh', 'git', 'persistent-https', 'rpc'])

    _manifest_xml=manifest_xml(xmlname)
    _manifest_xml.parse()

