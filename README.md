# Docker TYPO3 Dev

This Dockerfile creates a container with composer and PHP installed, along with the additional PHP extensions and `.ini` changes that TYPO3 requests.

The container is to be used in conjunction with your TYPO3 website source code.
You would mount your code to `/var/www/html`.

## How to use this image

### Docker installed

You need to make sure you have Docker installed.

https://hub.docker.com

### Build

#### Non-composer mode

Be in the directory of the `Dockerfile` and run the following command:

```docker build -t "typo3dev:latest" .```

You can change `typo3dev` to whatever you want. For example `yolo:latest`, or if you want to version your builds, `swag:0.0.1`.

Giving version numbers to your images is good when you're changing your image over time and want to be able to spin up previous copies of your builds.

#### Composer mode

Use the instructions above but make one small change to your `sites-available/000-default.conf` file by changing `DocumentRoot /var/www/html` to `DocumentRoot /var/www/html/public`.

The `Dockerfile` in this project is actually a Multi-Stage build. It first builds a composer container, and then builds the php-apache container and *copies* the composer binary from the composer container into the php-apache container.

Basically this means that the php-apache container has composer installed, but it doesn't have all the additional crap that was required to build it! This keeps container sizes small.

```bash
docker exec -it container_name composer dump-autoload
```

The only problem with the dockerised version of composer is that won't have a token to access GitHub, and unless you [set composer up according to Docker Hub](https://hub.docker.com/_/composer) to store cache and keys, you'll likely have to enter a token each time you run it. 

### Use

Now that you have a built image, you can use it. Make sure you're in the directory with your website source files. Run the following command (the volume commands might be different on windows).

#### Windows (Git Bash)

```bash
docker run --rm --name whatever -v `pwd -W`:/var/www/html -p 8000:80 typo3dev:latest
```

#### Windows (PowerShell)

The `-it` flag doesn't work in Git Bash, only PowerShell. The way volumes are mounted is different too:

**TODO:** PowerShell command here. I think it's "$PWD", just need to confirm.

#### MacOS

MacOS has a slow filesystem so you'll want to add `:delegated` to your volume mount to speed things up.
It's basically a file read/write cache between the container and MacOS.
It *really* does speed things up, so use it.

```bash
docker run --rm -it --name whatever -v $(pwd):/var/www/html:delegated -p 8000:80 typo3dev:latest
```

This will run a container named `whatever` and mount your current directory into the `/var/www/html` directory inside the container, which is where apache is looking.

You have linked your local machine's port `8000` to the container's port `80`, so if you now go to `http://localhost:8000` you should see something from apache!

You could mount port 80 too if you know that your host OS doesn't have something using it.
That means you can have a nice clean `http://localhost` in your browser without any port numbers.

### typo3_src when not in composer mode

TYPO3 loves to make things difficult by requiring symlinks for the source code.

> "Who wants to develop on Windows anyway" - TYPO3, probably.
  
Containers cannot see outside the folders that you mount into it, so you'll want to put the `typo3_src` folder inside your project root, not one directory above like the TYPO3 documentation says.

Symlink typo `typo3` and `index.php` files as usual from there, if you're on MacOS or Linux, otherwise `exec` yourself into the PHP container and run the symlink commands there. It works, surprisingly.

### Databases

Once you're more familiar with Docker you'll use networks which can resolve container names instead of IP addresses, but for now if you want to connect to a database outside the container, you'll need to put the database host as `0.0.0.0`, not `localhost` or `127.0.0.1` because those refer to the container, not the host (your computer which is running the database).

### Running php commands

The copy of PHP inside your container will likely be different to the copy of PHP installed on your local machine (if you have it installed at all, you Docker master you). You will want to run your PHP commands *through* the container.

```bash
docker exec -it container_name vendor/bin/typo3cms extension:setupactive
docker exec -it container_name php artisan migrate
```

Be wary of permission issues.
The container typically runs as a root user, and since it's creating files on your host machine they might be the wrong user for your environment.
Windows seems to handle this OK, but MacOS and Linux do permissions properly so just keep an eye on it.
