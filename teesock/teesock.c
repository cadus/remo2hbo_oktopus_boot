#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/un.h>
#include <sys/types.h>
#include <sys/socket.h>

int error(int error) {
  if (error & 1) fprintf(stderr, "socket path must be given\n");
  if (error & 2) fprintf(stderr, "could not bind to socket\n");
  if (error & 4) fprintf(stderr, "failed to close some connections\n");
  return error;
}

int accept_connections( int listener, int connections[], int connection_count ) {
  while (connection_count > 0) {
    connection_count--;
    if (connections[connection_count] <= 0) connections[connection_count] = accept(listener, NULL, NULL);
    if (connections[connection_count] <= 0) break;
  }
  return 0;
}

int feed_connections( int connections[], int connection_count, char feed[], int feedsize ) {
  while (connection_count > 0) {
    connection_count--;
    if (connections[connection_count] > 0) if ( write(connections[connection_count], feed, feedsize) < 0 )
      connections[connection_count] = close(connections[connection_count]);
  }
  return 0;
}

int clean_connections( int connections[], int connection_count ) {
  int stat = 0;

  while (connection_count > 0) {
    connection_count--;
    connections[connection_count] = close(connections[connection_count]);
    stat += connections[connection_count];
  }
  if ( stat > 0 ) return 1; else return 0;
}

int distribute( int listener, int connection_count ) {
  int coni, connections[connection_count];
  char feed[1024]; int feedsize;
  for ( coni = 0; coni < connection_count; coni++) connections[coni] = 0;

  listen(listener, connection_count);

  while ( (feedsize = read(0, feed, 1024)) > 0 ) {
    accept_connections(listener, connections, connection_count);
    feed_connections(connections, connection_count, feed, feedsize);
  }
  return clean_connections(connections, connection_count);
}

int sockopen( char path[] ) {
  struct sockaddr_un address;
  int listener;

  address.sun_family = AF_UNIX;
  strncpy(address.sun_path, path, sizeof(address.sun_path) - 1);

  listener = socket(AF_UNIX, SOCK_STREAM, 0);
  if ( fcntl(listener, F_SETFL, fcntl(listener, F_GETFL, 0) | O_NONBLOCK) < 0 ) return -1;

  if ( bind(listener, (struct sockaddr *) &address, sizeof(struct sockaddr_un)) < 0 )
    return -1;
  else return listener;
}

int main(int argc, char *argv[]) {
  int listener; 

  signal(SIGPIPE, SIG_IGN);

  if ( argc < 2 ) return error(1);
  if ( (listener = sockopen(argv[1])) < 0 ) return error(2);
  if ( distribute(listener, 64) ) error(4);

  unlink(argv[1]);
  return 0;
}
