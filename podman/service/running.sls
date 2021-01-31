# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_user = tplroot ~ '.config.user' %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

include:
  - {{ sls_config_user }}

{% for name, container in podman.containers.items() %}
podman-image-{{ name }}:
  cmd.run:
    - name: {{ podman.bin }} pull {{ container.image }}
    - runas: {{ container.user.name }}
    - require:
      - sls: {{ sls_config_user }}

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
      - sls: {{ sls_config_user }}

podman-container-service-{{ name }}:
  service.running:
    - name: podman-{{ name }}
    - enable: True
    - watch:
      - file: podman-container-startup-config-{{ name }}
{% endfor %}
