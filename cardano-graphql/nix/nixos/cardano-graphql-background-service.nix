
{ lib, pkgs, config, ... }:
let
  cfg = config.services.cardano-graphql-background;
in {
  options = {
    services.cardano-graphql-background = {
      enable = lib.mkEnableOption "cardano-explorer graphql background service";

      frontendPkg = lib.mkOption {
        type = lib.types.package;
        default = (import ../pkgs.nix {}).packages.cardano-graphql;
      };

      persistPkg = lib.mkOption {
        type = lib.types.package;
        default = (import ../pkgs.nix {}).packages.persistgraphql;
      };

      hasuraCliPkg = lib.mkOption {
        type = lib.types.package;
        default = (import ../pkgs.nix {}).packages.hasura-cli;
      };

      hasuraCliExtPkg = lib.mkOption {
        type = lib.types.package;
        default = (import ../pkgs.nix {}).packages.hasura-cli-ext;
      };

      assetMetadataUpdateInterval = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      dbHost = lib.mkOption {
        type = lib.types.str;
        default = "/run/postgresql";
      };

      dbPassword = lib.mkOption {
        type = lib.types.str;
        default = ''""'';
      };

      dbPort = lib.mkOption {
        type = lib.types.int;
        default = 5432;
      };

      dbUser = lib.mkOption {
        type = lib.types.str;
        default = "cexplorer";
      };

      db = lib.mkOption {
        type = lib.types.str;
        default = "cexplorer";
      };

      enginePort = lib.mkOption {
        type = lib.types.int;
        default = 9999;
      };

      loggerMinSeverity = lib.mkOption {
        type = lib.types.str;
        default = "info";
      };

      hasuraIp = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };

      hasuraProtocol = lib.mkOption {
        type = lib.types.str;
        default = "http";
      };

      metadataServerUri = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      ogmiosHost = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };

      ogmiosPort = lib.mkOption {
        type = lib.types.int;
        default = 1337;
      };
    };
  };
  config = let
    boolToNodeJSEnv = bool: if bool then "true" else "false";
    frontend = cfg.frontendPkg;
    persistgraphql = cfg.persistPkg;
    hasura-cli = cfg.hasuraCliPkg;
    hasura-cli-ext = cfg.hasuraCliExtPkg;
    hasuraBaseUri = "${cfg.hasuraProtocol}://${cfg.hasuraIp}:${toString cfg.enginePort}";
    pluginLibPath = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
    ];
  in lib.mkIf cfg.enable {
    systemd.services.cardano-graphql-background = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "graphql-engine.service" ];
      after = [ "graphql-engine.service" ];
      environment = lib.filterAttrs (k: v: v != null) {
        HASURA_CLI_PATH = hasura-cli + "/bin/hasura";
        HASURA_CLI_EXT_PATH = hasura-cli-ext + "/bin/cli-ext-hasura-linux";
        HASURA_GRAPHQL_ENABLE_TELEMETRY = toString false;
        HASURA_URI = hasuraBaseUri;
        LOGGER_MIN_SEVERITY = cfg.loggerMinSeverity;
        OGMIOS_HOST = cfg.ogmiosHost;
        OGMIOS_PORT = toString cfg.ogmiosPort;
        POSTGRES_DB = cfg.db;
        POSTGRES_HOST = cfg.dbHost;
        POSTGRES_PASSWORD = cfg.dbPassword;
        POSTGRES_PORT = toString cfg.dbPort;
        POSTGRES_USER = cfg.dbUser;
      } //
      (lib.optionalAttrs (cfg.assetMetadataUpdateInterval != null) { ASSET_METADATA_UPDATE_INTERVAL = toString cfg.assetMetadataUpdateInterval; }) //
      (lib.optionalAttrs (cfg.metadataServerUri != null) { METADATA_SERVER_URI = toString cfg.metadataServerUri; });
      path = with pkgs; [ netcat curl postgresql frontend hasura-cli glibc.bin patchelf ];
      script = ''
        exec cardano-graphql-background
      '';
    };
  };
}
