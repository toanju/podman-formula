# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{#-
include:
  - {{ sls_config_file }}

podman-service-running-service-running:
  service.running:
    - name: {{ podman.service.name }}
    - enable: True
    - watch:
      - sls: {{ sls_config_file }}
#}


{% for name, container in podman.containers.items() %}
podman-image-{{ name }}:
  cmd.run:
    - name: {{ podman.bin }} pull {{ container.image }}

podman-container-startup-config-{{ name }}:
  file.managed:
    - name: /etc/systemd/system/podman-{{ name }}.service
    - source: salt://podman/files/service_file.jinja
    - mode: 644
    - user: root
    - template: jinja
    - defaults:
        podman_bin: {{ podman.bin | json }}
        name: {{ name | json }}
        container: {{ container | json }}
    - require:
      - cmd: podman-image-{{ name }}

podman-container-service-{{ name }}:
  service.running:
    - name: podman-{{ name }}
    - enable: True
    - watch:
      - file: podman-container-startup-config-{{ name }}
{% endfor %}
