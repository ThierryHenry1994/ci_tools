#!/usr/bin/python
##################################################################################################
# File: set_revision.py
# Author: huangbin
# Email: huangbin@pset.suntec.net
# Date: 2014/8/19
##################################################################################################
#usage: set_revision.py args(revisionname)
import os, sys
import optparse
from xml.etree.ElementTree import ElementTree

#Init default value
default_manifest_xml = "build.xml"
default_remote_value = "origin"
default_revision_value = "master"

#Parse system argv
parser = optparse.OptionParser()
parser.add_option('-m', action="store", default=default_manifest_xml, dest="manifest_xml", help="set manifest file")
parser.add_option('-r', action="store", default=default_remote_value, dest="remote_value", help="set manifest remote default value")
parser.add_option('-v', action="store", default=default_revision_value, dest="revision_value", help="set manifest revision default value")
parser.description="The python parse manifest and set remote & revision value"
(options, args) = parser.parse_args(args=sys.argv)

#Parse and set manifest argument value
tree = ElementTree()
try:
    root = tree.parse(options.manifest_xml)
except IOError as e:
    print e
    sys.exit(1)

attrib_list = ["revision"]
for pro in root.findall("project"):
    for key in attrib_list:
        if key in pro.attrib:
            del pro.attrib[key]

if root.find("default") != None:
    tag_default = root.find("default")
    # tag_default.set("remote", options.remote_value)
    tag_default.set("revision", options.revision_value)
else:
    print "This manifest need't to set revision ."

tree.write(options.manifest_xml, "utf-8")

