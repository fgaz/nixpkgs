import ./make-test-python.nix ({ pkgs, ... }:

{
  name = "phorge";
  meta.maintainers = with pkgs.lib.maintainers; [ fgaz ];

  nodes.machine = {
    services.phorge = {
      enable = true;
      hostName = "phorge.localhost";
    };
    services.mysql.package = pkgs.mariadb;
    services.nginx.virtualHosts."phorge.localhost" = {
      forceSSL = false;
      enableACME = false;
    };
  };

  testScript = ''
    import json
    machine.wait_for_unit("mysql.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_unit("phpfpm-phorge.service")
    machine.wait_for_open_port(80)
    pong = json.loads(machine.succeed("curl -s --fail http://phorge.localhost/api/conduit.ping"))
    if pong["result"] != "machine":
        print(json.dumps(pong))
        raise Exception("Ping failed!")
  '';
})
