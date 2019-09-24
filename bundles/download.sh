if [ ! -f jakartaeetck.zip ]; then
  wget --read-timeout=20 http://download.eclipse.org/jakartaee/platform/8/eclipse-jakartaeetck-8.0.1.zip -O jakartaeetck.zip
fi
if [ ! -f cdi-tck-2.0.6-dist.zip ]; then
  wget http://download.eclipse.org/ee4j/cdi/cdi-tck-2.0.6-dist.zip
fi
if [ ! -f jakarta.inject-tck-1.0-bin.zip ]; then
  wget http://download.eclipse.org/ee4j/cdi/jakarta.inject-tck-1.0-bin.zip
fi
