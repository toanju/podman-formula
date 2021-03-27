# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{%- for name, container in podman.containers.items() %}

{#- XXX check if groups are existing ? #}
{#- XXX configure subuid,subgid #}
{#- XXX find a better way for config files #}
{#- XXX set se linux file context:
    semanage fcontext -a -t container_file_t 'data'
    restorecon -v 'data' #}
{#- XXX split this file up #}

podman-config-user-{{ name }}-user-present:
  user.present:
    - name: {{ container.user.name }}
    - usergroup: True
{%- if 'groups' in container.user %}
    - groups: {{ container.user.groups }}
{%- endif %}
    - remove_groups: True
    - home: {{ podman.homedir_prefix }}/{{ container.user.name }}
    - createhome: True
    - shell: {{ podman.default_shell }}
    - system: True
    - fullname: Podman {{ name }}

{#- data directory #}
podman-config-user-{{ name }}-file-directory:
  file.directory:
    - name: {{ podman.homedir_prefix }}/{{ container.user.name }}/data
    - user: {{ container.user.name }}
    - group: {{ container.user.name }}
    - recurse:
      - user
      - group
    - require:
      - user: podman-config-user-{{ name }}-user-present

{#- selinux context #}
podman-config-user-{{ name }}-selinux-fcontext_policy_present:
  selinux.fcontext_policy_present:
    - name: "{{ podman.homedir_prefix }}/{{ container.user.name }}/data(/.*)?"
    - sel_type: container_file_t
    - require:
      - file: podman-config-user-{{ name }}-file-directory

podman-config-user-{{ name }}-selinux-fcontext_policy_applied:
  selinux.fcontext_policy_applied:
    - name: {{ podman.homedir_prefix }}/{{ container.user.name }}/data
    - recursive: True

{%- endfor %}
