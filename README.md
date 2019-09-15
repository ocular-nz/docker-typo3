# Docker TYPO3 Dev

This image installs all required php extensions that TYPO3 wants, and applies the additional PHP resources that TYPO3 needs in the `php.ini` file.

## How to use this image

### Docker installed

You need to make sure you have Docker installed.

https://hub.docker.com

### Build

Be in the directory of the `Dockerfile` and run the following command:

```docker build -t "typo3dev:latest" .```

You can change `typo3dev` to whatever you want. For example `yolo:latest`, or if you want to version your builds, `swag:0.0.1`.

Giving version numbers to your images is good when you're changing your image over time and want to be able to spin up previous copies of your builds.

### Use

Now that you have a built image, you can use it. Make sure you're in the directory with your website source files. Run the following command (the volume commands might be different on windows).

```docker run --rm -it --name whatever -v $PWD:/var/www/html -p 8000:80 typo3dev:latest```

This will run a container named `whatever` and mount your current directory into the `/var/www/html` directory inside the container, which is where apache is looking.

You have linked your local machine's port `8000` to the container's port `80`, so if you now go to `http://localhost:8000` you should see something from apache!

### typo3_src

TYPO3 loves to make things difficult by requiring symlinks for the source code. "Who wants to develop on Windows anyway" - TYPO3. Containers cannot see outside the folders that you mount into it, so you'll want to put the `typo3_src` folder inside your project root, not one directory above like the TYPO3 documentation says.

Symlink typo `typo3` and `index.php` files as usual from there.

**NEED TO FIND OUT HOW TO DO THIS ON WINDOWS.**

### Databases

Once you're more familiar with Docker you'll use networks which can resolve container names instead of IP addresses, but for now if you want to connect to a database outside the container, you'll need to put the database host as `0.0.0.0`, not `localhost` or `127.0.0.1` because those refer to the container, not the host (your computer which is running the database).
