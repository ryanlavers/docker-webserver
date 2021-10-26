import argparse
import yaml
from mako.template import Template
from mako.lookup import TemplateLookup

parser = argparse.ArgumentParser(description='Generate the NGINX config')

parser.add_argument('templates', help='Location of the templates directory')
parser.add_argument('configfile', help='Input config.yml file')
parser.add_argument('output', help='Output NGINX config file to write')

args = parser.parse_args()

# serverDefaults = {
# 	'ssl': False,
# 	'redirect-www': False,
# 	'additional-config': False
# }

servers = []
with open(args.configfile, 'r') as infile:
	servers = list(yaml.safe_load_all(infile))

lookup = TemplateLookup(directories=[args.templates])
tpl = lookup.get_template('nginx.conf.tpl')

with open(args.output, 'w+') as outfile:
	outfile.write(tpl.render(servers=servers))
