# empyrion-server
**Docker image for the [Empyrion](https://empyriongame.com/) dedicated server using WINE**

Orginally forked from [BitR/emyrion-docker](https://github.com/BitR/empyrion-docker)'s respository, changes have been made based on another game server hosted in docker: [balnaimi/conan-exiles-server](https://github.com/balnaimi/conan-exiles-server).

This Docker image includes WINE and steamcmd, along with an entrypoint script that bootstraps the Empyrion dedicated server installation via steamcmd.

## Usage

### Basic setup
1. Create a directory for your game data:
    ```sh
    mkdir -p gamedir
    ```
2. Run the Docker container:
    ```sh
    docker run -d -p 30000:30000/udp --restart unless-stopped -v $PWD/gamedir:/empyrion-server 2ddevworks/docker-server
    ```
   Or if you're running a public server and you want it to appear in the server list in game:
   ```sh
    docker run -d -p 30000-30003:30000-300003/udp --restart unless-stopped -v $PWD/gamedir:/empyrion-server 2ddevworks/docker-server
    ```
   There is also a compose file example if you want to go that route
   
## Permission errors
If you're getting permission errors, it's because the folder you mounted in with `-v` didn't already exist and is now created and owned by **root:root**. You need to `chown` the volume mount to **1000:1000** (unless you've specified otherwise when you ran the `docker` command)

## Configuration
After starting the server, you can edit the **dedicated.yaml** file located at **/gamedir/dedicated.yaml**. You will need to restart the Docker container after making changes.

The **DedicatedServer** folder is symlinked to **/empyrion-server**, allowing you to refer to saves with **Z:/empyrion-server/Saves**. For example, for a save called **The_Game**:
```sh
# Run the container with the specific save
docker run -d -p 30000:30000/udp --restart unless-stopped -v $PWD/gamedir:/empyrion-server -e "DEDICATED_YML=Z:/empyrion-server/Saves/Games/The_Game/dedicated.yaml" 2ddevworks/docker-server
```

## Additional Information
For more information about setting up the Empyrion dedicated server, refer to the [wiki](https://empyrion.gamepedia.com/Dedicated_Server_Setup).

