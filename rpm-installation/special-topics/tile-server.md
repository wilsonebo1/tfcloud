# Tile Server

Datarobot ships with a tile server that allows geospatial visualizations in the app to have a map in the background.

## Downloading Tiles

There is only an empty tile included with the installer which would render a blank background in the geospatial visualizations.

Datarobot provides tiles at different zoom levels which vary from few MBs upto 70 GB. Tiles with different levels of detail can be downloaded from our S3 location.

  * Large tiles (69.1 GB): https://datarobot-geospatial.s3.amazonaws.com/geospatial-map-data/mbtiles/tiles-zoom-14-20191202.post1%2Bdr.mbtiles
  * Medium tiles (4.0 GB): https://datarobot-geospatial.s3.amazonaws.com/geospatial-map-data/mbtiles/tiles-zoom-11-20191202.post1%2Bdr.mbtiles
  * Small tiles (245 MB): https://datarobot-geospatial.s3.amazonaws.com/geospatial-map-data/mbtiles/tiles-zoom-08-20191202.post1%2Bdr.mbtiles

## DataRobot Application Configuration

Tileserver supports [HA Configuration](special-topics/ha-web-services.html). You need to enable the service on _webserver_ nodes.

```yaml
# Enable tileservergl service
# This should be done on the same node(s) as the webserver
- services:
  - tileservergl
  hosts:
  - 192.168.1.10

```

## Configuring Tile-Set as part of installation process

In order to configure the tile-set as part of the installation process `TILESERVERGL_TILESET_PATH` should be provided in global `app_configuration` section. This will distribute the tiles to each of the HA nodes.


```yaml
app_configuration:
  drenv_override:
    TILESERVERGL_TILESET_PATH: tiles-dist/tiles-zoom-01-20200202.post1+dr.mbtiles
```

Please note that this step might require you to have additional space on the destination depending on the size of the map tiles you choose. You would also need space for tiles on each instance running tileserver.

Caveat: if you are re-running installer for DataRobot cluster that had tiles installed before, it may not automatically switch to the new tiles. To switch to the new tiles, use the `switch` command in the next section.

## Tile Management post-install

It is also possible to manage the tiles at any point after the installation. The following commands need to be run on the provisioner host as a user without admin privileges (`datarobot` by default).

List tile-sets available in storage: (the tile-set selected to be replicated to HA nodes would be marked with `*`)
```bash
source /opt/datarobot/etc/profile
python3 -m tools.manager.tileservergl list
```

To upload a tile-set to storage:
```bash
source /opt/datarobot/etc/profile
python3 -m tools.manager.tileservergl push --tileset <path/to/tileset>
```

To select one of the tile-sets as the one to be used by the Tileserver (and replicated to HA nodes):
```bash
source /opt/datarobot/etc/profile
python3 -m tools.manager.tileservergl switch --tileset <tileset-name>
```

To remove a tile-set from storage:
```bash
source /opt/datarobot/etc/profile
python3 -m tools.manager.tileservergl remove --tileset <tileset-name>
```
