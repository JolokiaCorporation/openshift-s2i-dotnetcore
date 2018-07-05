FROM microsoft/dotnet:2.1.301-sdk

# This image provides a .NET Core 2.1 rc1 environment you can use to run your .NET
# applications.

# Default to UTF-8 file.encoding
ENV PATH=/opt/app-root/src/.local/bin:/opt/app-root/src/bin:/opt/app-root/node_modules/.bin:/usr/local/lib:${PATH} \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
	DOTNET_CORE_VERSION=2.1 \
    DOTNET_FRAMEWORK=netcoreapp2.1 \
	DOTNET_APP_PATH=/app/bin\
	DOTNET_DEFAULT_CMD=default-cmd.sh 

LABEL io.k8s.description="Platform for building and running .NET Core 2.0 applications" \
      io.k8s.display-name=".NET Core 2.1-rc1" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.openshift.tags="builder,.net,dotnet,dotnetcore,ubuntu-dotnet21" \
      io.openshift.expose-services="8080:http" \
      io.s2i.scripts-url=image:///usr/libexec/s2i


# Switch to root for package installs
USER 0

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH.
COPY ./s2i/bin/ /usr/libexec/s2i

# Dotnet needs to know a username (any username) for home directory info
RUN echo "dotnet:x:1001:0::/app:/bin/false" >> /etc/passwd

# Directory with the sources is set as the working directory.
WORKDIR /app

# Since $HOME is set to /opt/app-root, the yum install may have created config
# directories (such as ~/.pki/nssdb) there. These will be owned by root and can
# cause actions that work on all of /opt/app-root to fail. So we need to fix
# the permissions on those too.
#RUN chmod -R og+rw /opt/apt-root
RUN chown -R 1001:0 /app && mkdir /.dotnet 

# For backwards compatibility, s2i builds default to the oldest sdk in the image.
# We keep the patch at '0', the latest patch version is automatically picked up.
ENV DOTNET_SDK_BASE_VERSION=2.1.0 \
# Needed for the `dotnet watch` to detect changes in a container.
    DOTNET_USE_POLLING_FILE_WATCHER=true

# Run container by default as user with id 1001 (default)
USER 1001

# Set the default CMD to print the usage of the language image.
CMD /usr/libexec/s2i/usage
