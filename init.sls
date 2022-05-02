minecraft_user_present:
  user.present:
    - name: minecraft
    - usergroup: True
    - home: /opt/minecraft
    - createhome: True

minecraft_jar_present:
  file.managed:
    - name: /opt/minecraft/server/server.jar
    - source: https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar
    - skip_verify: True
    - makedirs: True
    - user: minecraft
    - group: minecraft

minecraft_eula_accepted:
  file.append:
    - name: /opt/minecraft/server/eula.txt
    - text: eula=true

minecraft_server_configured:
  file.managed:
    - name: /opt/minecraft/server/server.properties
    - source: salt://minecraft/server.properties

minecraft_ops_configured:
  file.managed:
    - name: /opt/minecraft/server/ops.json
    - source: salt://minecraft/ops.json

minecraft_service_present:
  file.managed:
    - name: /usr/lib/systemd/system/minecraft.service
    - source: salt://minecraft/minecraft.service

reload_daemons:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: minecraft_service_present

mc_firewall_configured:
  iptables.append:
    - table: filter
    - chain: IN_public_allow
    - jump: ACCEPT
    - match: state
    - connstate: NEW,UNTRACKED
    - protocol: tcp
    - dport: 25565
    - save: True

rcon_firewall_configured:
  iptables.append:
    - table: filter
    - chain: IN_public_allow
    - jump: ACCEPT
    - match: state
    - connstate: NEW,UNTRACKED
    - protocol: tcp
    - dport: 25575
    - save: True

minecraft_service_running:
  service.running:
    - name: minecraft
    - enable: True
    - watch:
      - file: minecraft_server_configured