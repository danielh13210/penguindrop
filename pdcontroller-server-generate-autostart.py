import jinja2
template=jinja2.Environment(loader=jinja2.FileSystemLoader('.')).get_template('pdcontroller-server.desktop')
import os
uid=os.getuid()
print(template.render(port_http=6707+(uid%39000),port_ssh=6707+(uid%39000)+1))
