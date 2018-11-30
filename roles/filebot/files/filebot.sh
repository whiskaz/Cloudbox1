#!/bin/sh
FILEBOT_HOME="/opt/filebot"
JAVA_HOME="$FILEBOT_HOME/jre"

if [ -z "$HOME" ]; then
	echo '$HOME must be set'
	exit 1
fi

# select application data folder
APP_DATA="$HOME/.filebot"
LIBRARY_PATH="$FILEBOT_HOME/lib"

"$JAVA_HOME/bin/java" -Dapplication.deployment=deb -Dnet.filebot.AcoustID.fpcalc="$LIBRARY_PATH/fpcalc" -Dunixfs=false -DuseExtendedFileAttributes=true -DuseCreationDate=false -Djava.net.useSystemProxies=true -Djna.nosys=true -Djna.nounpack=true --illegal-access=permit --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.function=ALL-UNNAMED --add-opens=java.base/java.util.regex=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio.file=ALL-UNNAMED --add-opens=java.base/java.nio.file.attribute=ALL-UNNAMED --add-opens=java.base/java.nio.channels=ALL-UNNAMED --add-opens=java.base/java.nio.charset=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.time.chrono=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.logging/java.util.logging=ALL-UNNAMED --add-opens=java.desktop/java.awt=ALL-UNNAMED --add-opens=java.prefs/java.util.prefs=ALL-UNNAMED -Djna.boot.library.path="$LIBRARY_PATH" -Djna.library.path="$LIBRARY_PATH" -Djava.library.path="$LIBRARY_PATH" -Dapplication.dir="$APP_DATA" -Dapplication.cache="$APP_DATA/cache" -Djava.io.tmpdir="$APP_DATA/tmp" -Dfile.encoding="UTF-8" -Dsun.jnu.encoding="UTF-8" -Djdk.gtk.version=2 -Dsun.java2d.xrender=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dapplication.help=show -Dnet.filebot.UserFiles.fileChooser=JavaFX -DuseGVFS=true -Dnet.filebot.gio.GVFS="$XDG_RUNTIME_DIR/gvfs" $JAVA_OPTS $FILEBOT_OPTS -jar "$FILEBOT_HOME/jar/filebot.jar" "$@"
