# UZH Cardano Explorer

To setup the UZH Cardano Explorer follow the following steps:

## Prerequisites
1. Run a Cardano node in the UZH Cardano network following these [instructions](https://github.com/mostafachegeni/UZH-Cardano-Network)

2. Have access to the machine running UZH Cardano node and, according to the [IntersectMBO/cardano-db-sync](https://github.com/IntersectMBO/cardano-db-sync) repository, have the follow system requirements:
    * Any of the big well known Linux distributions (eg, Debian, Ubuntu, RHEL, CentOS, Arch
    etc).
    * 32 Gigabytes of RAM or more.
    * 4 CPU cores or more.
    * Ensure that the machine has sufficient IOPS (Input/Output Operations per Second). Ie it should be
    60k IOPS or better. Lower IOPS ratings will result in slower sync times and/or falling behind the
    chain tip.
    * 320 Gigabytes or more of disk storage (preferably SSD which are 2-5 times faster than
    electro-mechanical disks).

3. Locate your Cardano node's `node.socket` file

    NB: for the UZH Cardano node the file was located in the `/opt/cardano/cnode/sockets` folder

4. Locate the following configuration and genesis files of the Cardano node:
    - config.json
    - dbsync.json
    - params.json
    - topology.json
    - alonzo-genesis.json
    - byron-genesis.json
    - conway-genesis.json
    - shelley-genesis.json

    NB: for the UZH Cardano node the files were located in the `/opt/cardano/cnode/files` folder

## Setup Cardano Graphql

1. Navigate to the `cardano-graphql` folder:
    ```bash
    cd cardano-graphql
    ```

2. Copy the configuration and genesis files located in the prerequisites adhering to the following subfolder structure:
    ```bash
    cardano-graphql/
    └── config/
        └── network/
            └── <folder-name>/
                ├── cardano-db-sync/
                │   └── config.json
                └── cardano-node/
                    ├── config.json
                    ├── alonzo-genesis.json
                    ├── byron-genesis.json
                    ├── conway-genesis.json
                    ├── shelley-genesis.json
                    ├── params.json
                    └── topology.json
    ```
    NB: the `config.json` file in the `cardano-graphql/config/network/<folder-name>/cardano-db-sync/` folder is the `dbsync.json` file and must be renamed to `config.json`

3. Add the following keys to the `config.json` file in the `cardano-graphql/config/network/<folder-name>/cardano-node/` folder:
    - Alonzo Genesis Hash:
        - Key: AlonzoGenesisHash
        - Value: output of the following command:
            ```bash
            cardano-cli genesis hash --genesis <alonzo-genesis-filename>
            ```
    - Byron Genesis Hash:
        - Key: ByronGenesisHash
        - Value: output of the following command:
            ```bash
            cardano-cli byron genesis print-genesis-hash --genesis-json <byron-genesis-filename>
            ```
    - Conway Genesis Hash:
        - Key: ConwayGenesisHash
        - Value: output of the following command:
            ```bash
            cardano-cli genesis hash --genesis <conway-genesis-filename>
            ```
    - Shelley Genesis Hash:
        - Key: ShelleyGenesisHash
        - Value: output of the following command:
            ```bash
            cardano-cli genesis hash --genesis <shelley-genesis-filename>
            ```
4. Modify the `NodeConfigFile` key of the `config.json` file in the `cardano-graphql/config/network/<folder-name>/cardano-db-sync/` folder to the following value: `../cardano-node/config.json`


5. Modify the following lines of the `docker-compose.yml` file:
    - `cardano-node-ogmios` Service:
        - Replace the volume mount line for configs with:
            ```yaml
            volumes:
              - ./config/network/<folder-name>:/config
              - path/to/node/socket/file/folder:/node-ipc
            ```
    - `cardano-db-sync` Service:
        - Replace the volume mount line for configs with:
            ```yaml
            volumes:
              - ./config/network/<folder-name>:/config
              - path/to/node/socket/file/folder:/node-ipc
            ```

6. Set the following environment variables:
    ```properties
    DOCKER_BUILDKIT=1
    COMPOSE_DOCKER_CLI_BUILD=1
    NETWORK=preview
    API_PORT=3100
    HASURA_PORT=8090
    OGMIOS_PORT=1337
    POSTGRES_PORT=5432
    METADATA_SERVER_URI="https://metadata.world.dev.cardano.org"
    ```

7. Run Cardano graphql with Docker:
    ```bash
    docker-compose up -d
    ```

## Setup the Cardano Explorer App

1. Navigate to the `cardano-explorer-app` folder:
    ```bash
    cd cardano-explorer-app
    ```

2. Set the following environment variables:
    ```properties
    CARDANO_ERA=Babbage
    CARDANO_NETWORK=UZH-Cardano
    GRAPHQL_API_PROTOCOL=http
    GRAPHQL_API_HOST=localhost
    GRAPHQL_API_PORT=3100
    GRAPHQL_API_PATH=graphql
    POLLING_INTERVAL=5000
    GA_TRACKING_ID=
    DEBUG=false
    ```

3. Install packages and build the app:
    ```bash
    yarn --offline && yarn static:build
    ```

4. Serve the app:
    ```bash
    cd build/static
    python3 -m http.server <port>
    ```
